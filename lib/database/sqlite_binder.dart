import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/schema.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:codepan/models/transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

const tag = 'DATABASE BINDER';

class SQLiteBinder {
  final SQLiteAdapter db;
  Map<String, int> _map;
  Batch _batch;

  SQLiteBinder(this.db);

  Future<void> beginTransaction({List<TableSchema> prepare}) async {
    if (prepare?.isNotEmpty ?? false) {
      await _prepare(prepare);
    }
    _batch = db.batch();
  }

  Future<void> _prepare(List<TableSchema> schemaList) async {
    _map ??= {};
    for (final schema in schemaList) {
      final unique = schema.unique;
      final uniqueGroup = schema.uniqueGroup;
      final table = schema.tableName;
      final alias = schema.alias;
      final primaryKey = SQLiteStatement.id;
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
              order: Order.ASC,
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
              order: Order.ASC,
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
    final result = await finish();
    if (result) {
      await beginTransaction();
    }
    return result;
  }

  Future<bool> finish() async {
    bool result = false;
    _map?.clear();
    try {
      await _batch.commit(noResult: true);
      debugPrint('$tag: TRANSACTION SUCCESSFUL');
      result = true;
    } catch (error) {
      print(error.toString());
      rethrow;
    }
    return result;
  }

  Future<void> _registerLastId(String table) async {
    _map ??= {};
    if (!_map.containsKey(table)) {
      final primaryKey = SQLiteStatement.id;
      final query = SQLiteQuery(
        select: [
          primaryKey,
        ],
        from: table,
        orderBy: [
          Field.asOrder(
            field: primaryKey,
            order: Order.DESC,
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
    final primaryKey = SQLiteStatement.id;
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

  Future<TransactionData> insertForId({@required TransactionData data}) async {
    final transaction = data.copyWith(
      id: await insertData(data: data),
    );
    return transaction;
  }

  Future<int> insertData({@required TransactionData data}) {
    return insert(
      data.table,
      data.toStatement(),
      data.unique ?? data.uniqueGroup,
    );
  }

  Future<int> insert(String table, SQLiteStatement stmt,
      [dynamic unique]) async {
    final primaryKey = SQLiteStatement.id;
    final map = stmt.map;
    final field = map[primaryKey] != null ? primaryKey : unique;
    addStatement(stmt.insert(table, unique: field));
    return await _mapId(table, stmt, unique: field);
  }

  void updateData({@required TransactionData data}) {
    update(data.table, data.toStatement(), data.id);
  }

  void update(String table, SQLiteStatement stmt, dynamic id) {
    final sql = stmt.update(table, id);
    addStatement(sql);
  }

  void updateWithConditions(String table, SQLiteStatement stmt) {
    final sql = stmt.updateWithConditions(table);
    addStatement(sql);
  }

  void updateFromStatement({
    @required String table,
    @required SQLiteStatement stmt,
  }) {
    final sql = stmt.updateFromStatement(table);
    addStatement(sql);
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
