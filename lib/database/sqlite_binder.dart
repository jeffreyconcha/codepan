import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

class SQLiteBinder {
  final SQLiteAdapter db;
  Map<String, int> _map;
  List<String> _sqlList;

  SQLiteBinder(this.db);

  Future<void> beginTransaction() async {
    await db.beginTransaction();
    _sqlList = [];
  }

  Future<bool> finish() async {
    bool result = false;
    try {
      for (final sql in _sqlList) {
        await db.execute(sql);
      }
      await db.endTransaction();
      result = true;
    } catch (error) {
      await db.rollback();
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
          SQLiteStatement.ID,
        ],
        from: table,
        orderBy: [
          Field.asOrder(
            field: SQLiteStatement.ID,
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
    String unique,
  }) async {
    await _registerLastId(table);
    final pk = SQLiteStatement.ID;
    final map = stmt.map;
    if (unique != null && unique != pk) {
      final query = SQLiteQuery(
        select: [
          SQLiteStatement.ID,
        ],
        from: table,
        where: {
          unique: map[unique],
        },
      );
      final key = '$table.$unique(${map[unique]})';
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
    return _generateId(map, table);
  }

  int _generateId(Map<String, dynamic> map, String table) {
    final id = map[SQLiteStatement.ID];
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
    _sqlList.add(sql);
  }

  Future<int> insert(String table, SQLiteStatement stmt,
      [String unique]) async {
    final pk = SQLiteStatement.ID;
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
