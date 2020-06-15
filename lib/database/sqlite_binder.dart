import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_statement.dart';
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
    });
    return result;
  }

  Future<dynamic> txnInsert(String table, SQLiteStatement stmt,
      {bool replace = false}) {
    String sql = stmt.insert(table, replace: replace);
    return txn.rawInsert(sql);
  }

  Future<dynamic> txnUpdate(String table, SQLiteStatement stmt, dynamic id) {
    String sql = stmt.update(table, id);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnUpdateWithConditions(String table, SQLiteStatement stmt) {
    String sql = stmt.updateWithConditions(table);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnDelete(String table, SQLiteStatement stmt, dynamic id) {
    String sql = stmt.delete(table, id);
    return txn.rawUpdate(sql);
  }

  Future<dynamic> txnDeleteWithConditions(String table, SQLiteStatement stmt) {
    String sql = stmt.deleteWithConditions(table);
    return txn.rawUpdate(sql);
  }

  void bindInsert(String table, SQLiteStatement stmt) {
    batch.insert(
      table,
      stmt.map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void bindUpdate(String table, SQLiteStatement stmt, dynamic id) {
    batch.update(
      table,
      stmt.map,
      where: "${SQLiteStatement.ID} = ?",
      whereArgs: [id],
    );
  }

  void bindDelete(String table, dynamic id) {
    batch.delete(
      table,
      where: "${SQLiteStatement.ID} = ?",
      whereArgs: [id],
    );
  }

  void insert(String table, SQLiteStatement stmt) {
    String sql = stmt.insert(table);
    batch.rawInsert(sql);
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
