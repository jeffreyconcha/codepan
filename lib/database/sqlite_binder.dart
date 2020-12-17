import 'package:codepan/database/models/field.dart';
import 'package:codepan/extensions/duration_ext.dart';
import 'package:codepan/database/models/table.dart' as tb;
import 'package:codepan/database/schema.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_exception.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:codepan/models/transaction.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

enum UpdatePriority {
  unique,
  uniqueGroup,
}

const tag = 'DATABASE BINDER';
const primaryKey = SQLiteStatement.id;

class SQLiteBinder {
  final SQLiteAdapter db;
  Map<String, int> _map;
  bool _showLog = false;
  bool _chain = false;
  DateTime _time;
  Batch _batch;

  SQLiteBinder(this.db);

  factory SQLiteBinder.chain(SQLiteAdapter db) {
    if (db.inTransaction) {
      return db.binder..chain();
    }
    return SQLiteBinder(db);
  }

  Future<void> beginTransaction({
    List<TableSchema> prepare,
    bool showLog = false,
  }) async {
    if (!db.inTransaction) {
      if (prepare?.isNotEmpty ?? false) {
        await _prepare(prepare);
      }
      this._batch = db.batch();
      this._showLog = showLog;
      if (_showLog) {
        _time = DateTime.now();
        debugPrint('$tag: BEGIN TRANSACTION');
      }
      db.setBinder(this);
    }
  }

  Future<void> _prepare(List<TableSchema> schemaList) async {
    _map ??= {};
    for (final schema in schemaList) {
      final unique = schema.unique;
      final uniqueGroup = schema.uniqueGroup;
      final table = schema.tableName;
      final alias = schema.alias;
      if (unique != null) {
        final query = SQLiteQuery(
          select: [
            primaryKey,
            unique,
          ],
          from: schema.table,
          orderBy: [
            Field.asOrder(
              field: primaryKey,
              order: Order.ascending,
            ),
          ],
        );
        final records = await db.read(query.build());
        for (final record in records) {
          final uniqueValue = record['$alias.$unique'];
          final key = '$table.$unique($uniqueValue)';
          _map[key] = record['$alias.$primaryKey'];
        }
        final last = records?.last;
        if (last != null) {
          _map[table] = last['$alias.$primaryKey'];
        }
      } else if (uniqueGroup.isNotEmpty) {
        final query = SQLiteQuery(
          select: uniqueGroup..add(primaryKey),
          from: schema.table,
          orderBy: [
            Field.asOrder(
              field: primaryKey,
              order: Order.ascending,
            ),
          ],
        );
        final records = await db.read(query.build());
        for (final record in records) {
          final buffer = StringBuffer();
          for (final unique in uniqueGroup) {
            final uniqueValue = record['$alias.$unique'];
            buffer.write('$unique($uniqueValue)');
            if (unique != uniqueGroup.last) {
              buffer.write('.');
            }
          }
          final key = '$table.${buffer.toString()}';
          _map[key] = record['$alias.$primaryKey'];
        }
        final last = records?.last;
        if (last != null) {
          _map[table] = last['$alias.$primaryKey'];
        }
      }
    }
  }

  Future<bool> apply() async {
    final result = await finish(clearMap: false);
    if (result) {
      await beginTransaction();
    }
    return result;
  }

  Future<bool> finish({
    bool clearMap = true,
  }) async {
    if (!_chain) {
      bool result = false;
      if (clearMap) {
        _map?.clear();
      }
      try {
        await _batch.commit(noResult: true);
        if (_showLog) {
          final duration = DateTime.now().difference(_time);
          final formatted = duration.format(isReadable: true);
          debugPrint('$tag: TRANSACTION SUCCESSFUL');
          debugPrint('$tag: FINISHED AT $formatted');
        }
        db.removeBinder();
        result = true;
      } catch (error, stacktrace) {
        printError(error, stacktrace);
        rethrow;
      }
      return result;
    } else {
      chain(false);
      return true;
    }
  }

  void chain([bool chain = true]) {
    _chain = chain;
  }

  Future<void> _registerLastId(String table) async {
    _map ??= {};
    if (!_map.containsKey(table)) {
      final query = SQLiteQuery(
        select: [
          primaryKey,
        ],
        from: table,
        orderBy: [
          Field.asOrder(
            field: primaryKey,
            order: Order.descending,
          )
        ],
        limit: 1,
      );
      final id = await db.getValue(query.build());
      _map[table] = id ?? 0;
    }
  }

  Future<int> _mapId(
    String table,
    SQLiteStatement stmt, {
    dynamic unique,
  }) async {
    await _registerLastId(table);
    final map = stmt.map;
    if (unique != null) {
      if (unique is String && unique != primaryKey) {
        final value = map[unique];
        final key = '$table.$unique($value)';
        final query = SQLiteQuery(
          select: [
            primaryKey,
          ],
          from: table,
          where: {
            unique: value,
          },
        );
        return _getId(stmt, query, key, table);
      } else if (unique is List<String>) {
        final conditions = <String, dynamic>{};
        final buffer = StringBuffer();
        for (final field in unique) {
          final value = map[field];
          conditions[field] = value;
          buffer.write('$field($value)');
          if (field != unique.last) {
            buffer.write('.');
          }
        }
        final key = '$table.${buffer.toString()}';
        final query = SQLiteQuery(
          select: [
            primaryKey,
          ],
          from: table,
          where: conditions,
        );
        return _getId(stmt, query, key, table);
      }
    }
    return _generateId(map, table);
  }

  Future<int> _getId(
    SQLiteStatement stmt,
    SQLiteQuery query,
    String key,
    String table,
  ) async {
    final map = stmt.map;
    final oldId = _map[key];
    final id = oldId ?? await db.getValue(query.build());
    if (id != null) {
      _map[key] = id;
      return id;
    } else {
      final newId = _generateId(map, table);
      _map[key] = newId;
      return newId;
    }
  }

  int _generateId(Map<String, dynamic> map, String table) {
    final id = map[SQLiteStatement.id];
    if (id != null) {
      return id as int;
    } else {
      if (_map.containsKey(table)) {
        final oldId = _map[table];
        final newId = oldId + 1;
        _map[table] = newId;
        return newId;
      }
    }
    return null;
  }

  void addStatement(final sql) {
    _batch.execute(sql);
  }

  Future<TransactionData> insertForId({
    @required TransactionData data,
    UpdatePriority priority = UpdatePriority.unique,
  }) async {
    if (data != null) {
      final transaction = data.copyWith(
        id: await insertData(
          data: data,
          priority: priority,
        ),
      );
      return transaction;
    }
    return null;
  }

  Future<int> insertData({
    @required TransactionData data,
    UpdatePriority priority = UpdatePriority.unique,
    bool ignoreId = false,
  }) {
    if (data != null) {
      dynamic unique;
      switch (priority) {
        case UpdatePriority.unique:
          unique = data.unique ?? data.uniqueGroup;
          break;
        case UpdatePriority.uniqueGroup:
          unique = data.uniqueGroup ?? data.unique;
          break;
      }
      return insert(
        data.table,
        data.toStatement(),
        unique: unique,
        ignoreId: ignoreId,
      );
    }
    return null;
  }

  /// table - Can only be a type of String, Table or TableSchema.
  Future<int> insert(
    dynamic table,
    SQLiteStatement stmt, {
    dynamic unique,
    bool ignoreId = false,
  }) async {
    final map = stmt.map;
    final name = _getTableName(table);
    final field = map[primaryKey] != null ? primaryKey : unique;
    addStatement(stmt.insert(name, unique: field));
    return ignoreId ? null : await _mapId(name, stmt, unique: field);
  }

  void updateData({
    @required TransactionData data,
  }) {
    updateRecord(data.table, data.toStatement(), data.id);
  }

  /// table - Can only be a type of String, Table or TableSchema.
  void updateRecord(
    dynamic table,
    SQLiteStatement stmt,
    dynamic id,
  ) {
    final name = _getTableName(table);
    final sql = stmt.update(name, id);
    addStatement(sql);
  }

  @deprecated
  void updateWithConditions(
    String table,
    SQLiteStatement stmt,
  ) {
    final sql = stmt.updateWithConditions(table);
    addStatement(sql);
  }

  /// table - Can only be a type of String, Table or TableSchema.
  void update({
    @required dynamic table,
    @required SQLiteStatement stmt,
  }) {
    final name = _getTableName(table);
    final sql = stmt.updateFromStatement(name);
    addStatement(sql);
  }

  String _getTableName(dynamic table) {
    if (table is String) {
      return table;
    } else if (table is tb.Table) {
      return table.name;
    } else if (table is TableSchema) {
      return table.tableName;
    } else {
      throw SQLiteException(SQLiteException.invalidTableType);
    }
  }

  void delete(String table, dynamic id) {
    final sql = SQLiteStatement().delete(table, id);
    addStatement(sql);
  }

  void deleteWithConditions(String table, SQLiteStatement stmt) {
    final sql = stmt.deleteWithConditions(table);
    addStatement(sql);
  }

  void createTable(String table, SQLiteStatement stmt) {
    final sql = stmt.createTable(table);
    addStatement(sql);
  }

  void createIndex(String idx, String table, SQLiteStatement stmt) {
    final sql = stmt.createIndex(idx, table);
    addStatement(sql);
  }

  void createTimeTrigger(String trg, String table, SQLiteStatement stmt) {
    final sql = stmt.createTimeTrigger(trg, table);
    addStatement(sql);
  }

  void dropTable(String table) {
    final stmt = SQLiteStatement();
    final sql = stmt.dropTable(table);
    addStatement(sql);
  }

  void dropIndex(String idx) {
    final stmt = SQLiteStatement();
    final sql = stmt.dropIndex(idx);
    addStatement(sql);
  }

  void renameTable(String oldName, String newName) {
    final stmt = SQLiteStatement();
    final sql = stmt.renameTable(oldName, newName);
    addStatement(sql);
  }

  void addColumn(String table, Field field) {
    final stmt = SQLiteStatement();
    final sql = stmt.addColumn(table, field);
    addStatement(sql);
  }
}
