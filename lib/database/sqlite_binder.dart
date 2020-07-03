import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

class SQLiteBinder {
  final SQLiteAdapter db;
  Map<String, int> _map;
  Batch _batch;

  SQLiteBinder(this.db);

  Batch get batch => this._batch;

  Future<void> beginTransaction() async {
    await db.instance.transaction((txn) async {
      this._batch = txn.batch();
    });
  }

  Future<bool> finish() async {
    bool result = false;
    await _batch.commit(noResult: true).then((v) {
      result = true;
    });
    return result;
  }

  Future<void> _registerLastId(String table) async {
    _map ??= {};
    if (!_map.containsKey(table)) {
      final query = SQLiteQuery(
        select: [
          'rowId',
        ],
        from: table,
        orderBy: [
          Field.asOrder(
            field: 'rowId',
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
          'rowId',
        ],
        from: table,
        where: {
          unique: map[unique],
        },
      );
      final key = '$table.$unique';
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

  Future<int> bindInsert(
    String table,
    SQLiteStatement stmt, {
    ConflictAlgorithm conflictAlgorithm,
  }) async {
    batch.insert(
      table,
      stmt.map,
      conflictAlgorithm: conflictAlgorithm,
    );
    return await _mapId(table, stmt);
  }

  void bindUpdate(String table, SQLiteStatement stmt, dynamic id) {
    batch.update(
      table,
      stmt.map,
      where: '${SQLiteStatement.ID} = ?',
      whereArgs: [id],
    );
  }

  void bindDelete(String table, dynamic id) {
    batch.delete(
      table,
      where: '${SQLiteStatement.ID} = ?',
      whereArgs: [id],
    );
  }

  Future<int> insert(String table, SQLiteStatement stmt,
      [String unique]) async {
    final pk = SQLiteStatement.ID;
    final map = stmt.map;
    final field = map[pk] != null ? pk : unique;
    String sql = stmt.insert(table, unique: field);
    batch.rawInsert(sql);
    return await _mapId(table, stmt, unique: field);
  }

  void update(String table, SQLiteStatement stmt, dynamic id) {
    String sql = stmt.update(table, id);
    batch.rawUpdate(sql);
  }

  void updateWithConditions(String table, SQLiteStatement stmt) {
    String sql = stmt.updateWithConditions(table);
    batch.rawUpdate(sql);
  }

  void delete(String table, SQLiteStatement stmt, dynamic id) {
    String sql = stmt.delete(table, id);
    batch.rawUpdate(sql);
  }

  void deleteWithConditions(String table, SQLiteStatement stmt) {
    String sql = stmt.deleteWithConditions(table);
    batch.rawUpdate(sql);
  }

  void createTable(String table, SQLiteStatement stmt) {
    String sql = stmt.createTable(table);
    batch.execute(sql);
  }

  void createIndex(String idx, String table, SQLiteStatement stmt) {
    String sql = stmt.createIndex(idx, table);
    batch.execute(sql);
  }

  void dropTable(String table) {
    final stmt = SQLiteStatement();
    String sql = stmt.dropTable(table);
    batch.execute(sql);
  }

  void dropIndex(String idx) {
    final stmt = SQLiteStatement();
    String sql = stmt.dropIndex(idx);
    batch.execute(sql);
  }

  void renameTable(String oldName, String newName) {
    final stmt = SQLiteStatement();
    String sql = stmt.renameTable(oldName, newName);
    batch.execute(sql);
  }

  void addColumn(String table, Field field) {
    final stmt = SQLiteStatement();
    String sql = stmt.addColumn(table, field);
    batch.execute(sql);
  }
}
