import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

class SQLiteBinder {
  final SQLiteAdapter db;
  Transaction _txn;
  Batch _batch;

  SQLiteBinder(this.db);

  Transaction get txn => this._txn;

  Batch get batch => this._batch;

  Future<void> beginTransaction() async {
    await db.instance.transaction((txn) async {
      this._batch = txn.batch();
      this._txn = txn;
    });
  }

  Future<bool> finish() async {
    bool result = false;
    await _batch.commit(noResult: true).then((v) {
      result = true;
    }).catchError((e) {
      print(e);
    });
    return result;
  }

  Future<dynamic> txnInsert(String table, SQLiteQuery query) {
    String sql = query.insert(table);
    return txn.rawInsert(sql);
  }

  Future<dynamic> txnUpdate(String table, SQLiteQuery query, dynamic id) {
    String sql = query.update(table, id);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnUpdateWithConditions(String table, SQLiteQuery query) {
    String sql = query.updateWithConditions(table);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnDelete(String table, SQLiteQuery query, dynamic id) {
    String sql = query.delete(table, id);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnDeleteWithConditions(String table, SQLiteQuery query) {
    String sql = query.deleteWithConditions(table);
    return txn.rawUpdate(sql);
  }

  void bindInsert(String table, SQLiteQuery query) {
    batch.insert(
      table,
      query.map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void bindUpdate(String table, SQLiteQuery query, dynamic id) {
    batch.update(
      table,
      query.map,
      where: "${SQLiteQuery.ID} = ?",
      whereArgs: [id],
    );
  }

  void bindDelete(String table, dynamic id) {
    batch.delete(
      table,
      where: "${SQLiteQuery.ID} = ?",
      whereArgs: [id],
    );
  }

  void insert(String table, SQLiteQuery query) {
    String sql = query.insert(table);
    batch.rawInsert(sql);
  }

  void update(String table, SQLiteQuery query, dynamic id) {
    String sql = query.update(table, id);
    batch.rawUpdate(sql);
  }

  void updateWithConditions(String table, SQLiteQuery query) {
    String sql = query.updateWithConditions(table);
    batch.rawUpdate(sql);
  }

  void delete(String table, SQLiteQuery query, dynamic id) {
    String sql = query.delete(table, id);
    batch.rawUpdate(sql);
  }

  void deleteWithConditions(String table, SQLiteQuery query) {
    String sql = query.deleteWithConditions(table);
    batch.rawUpdate(sql);
  }

  void createTable(String table, SQLiteQuery query) {
    String sql = query.createTable(table);
    batch.execute(sql);
  }

  void createIndex(String idx, String table, SQLiteQuery query) {
    String sql = query.createIndex(idx, table);
    batch.execute(sql);
  }

  void dropTable(String table) {
    var query = new SQLiteQuery();
    String sql = query.dropTable(table);
    batch.execute(sql);
  }

  void dropIndex(String idx) {
    var query = new SQLiteQuery();
    String sql = query.dropIndex(idx);
    batch.execute(sql);
  }

  void renameTable(String oldName, String newName) {
    var query = new SQLiteQuery();
    String sql = query.renameTable(oldName, newName);
    batch.execute(sql);
  }

  void addColumn(String table, Field field) {
    var query = new SQLiteQuery();
    String sql = query.addColumn(table, field);
    batch.execute(sql);
  }
}
