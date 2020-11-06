import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';

class SQLiteBinder {
  final SQLiteAdapter db;
  Map<String, int> _map;
  List<String> _sqlList;

  SQLiteBinder(this.db);

  Future<void> beginTransaction() async {
    if (!db.inTransaction) {
      await db.beginTransaction();
    }
    _sqlList = [];
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
    try {
      for (final sql in _sqlList) {
        await db.execute(sql);
      }
      if (db.inTransaction) {
        await db.endTransaction();
      }
      result = true;
    } catch (error) {
      if (db.inTransaction) {
        await db.rollback();
      }
      print(error.toString());
      rethrow;
    }
    return result;
  }

  Future<void> _registerLastId(String table) async {
    _map ??= {};
    if (!_map.containsKey(table)) {
      final query = SQLiteQuery(
        select: [
          SQLiteStatement.id,
        ],
        from: table,
        orderBy: [
          Field.asOrder(
            field: SQLiteStatement.id,
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
    final pk = SQLiteStatement.id;
    final map = stmt.map;
    if (unique != null) {
      if (unique is String && unique != pk) {
        final value = map[unique];
        final key = '$table.$unique($value)';
        final query = SQLiteQuery(
          select: [
            SQLiteStatement.id,
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
            SQLiteStatement.id,
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

  int mapId(String table, String unique, dynamic value) {
    if (table != null && unique != null && value != null) {
      final key = '$table.$unique($value)';
      return _map[key];
    }
    return null;
  }

  void addStatement(final sql) {
    _sqlList.add(sql);
  }

  Future<int> insert(String table, SQLiteStatement stmt,
      [dynamic unique]) async {
    final pk = SQLiteStatement.id;
    final map = stmt.map;
    final field = map[pk] != null ? pk : unique;
    addStatement(stmt.insert(table, unique: field));
    return await _mapId(table, stmt, unique: field);
  }

  void update(String table, SQLiteStatement stmt, dynamic id) {
    final sql = stmt.update(table, id);
    addStatement(sql);
  }

  void updateWithConditions(String table, SQLiteStatement stmt) {
    final sql = stmt.updateWithConditions(table);
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
