import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class SQLiteAdapter implements DatabaseExecutor {
  final FutureOr<void> Function(Database db, int ov, int nv) onUpgrade,
      onDowngrade;
  final FutureOr<void> Function(Database db, int version) onCreate;
  final String name, password;
  final int version;
  String _path;
  Database _db;

  Database get instance {
    if (_db == null || !_db.isOpen) {
      throw SQLiteAdapterException(SQLiteAdapterException.DATABASE_NOT_OPENED);
    }
    return _db;
  }

  SQLiteAdapter({
    @required this.name,
    @required this.version,
    this.password,
    this.onCreate,
    this.onUpgrade,
    this.onDowngrade,
  });

  /// Always use await when opening a database
  Future<void> openConnection() async {
    if (_db == null || !_db.isOpen) {
      var directory = await getDatabasesPath();
      this._path = join(directory, name);
      this._db = await openDatabase(
        _path,
        version: version,
        password: password,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      );
    }
  }

  Future<List<Map<String, dynamic>>> read(String sql) {
    return instance.rawQuery(sql);
  }

  Future<dynamic> getValue(String sql) async {
    var list = await instance.rawQuery(sql);
    if (list.isNotEmpty) {
      var first = list.first;
      return first.values.toList()[0];
    }
    return null;
  }

  Future<Map<String, dynamic>> getRecord(String sql) async {
    var list = await instance.rawQuery(sql);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  void close() {
    if (!instance.isOpen) {
      instance.close();
    }
  }

  Batch batch() {
    return instance.batch();
  }

  Future<Transaction> beginTransaction() async {
    var transaction;
    await instance.transaction((txn) async {
      transaction = txn;
    }, exclusive: true);
    return transaction;
  }

  @override
  Future<int> delete(String table, {String where, List whereArgs}) {
    return instance.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql, [List arguments]) {
    return instance.execute(sql, arguments);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    return instance.insert(table, values,
        nullColumnHack: null, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return instance.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  @override
  Future<int> rawDelete(String sql, [List arguments]) {
    return instance.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List arguments]) {
    return instance.rawInsert(sql, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List arguments]) {
    return instance.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List arguments]) {
    return instance.rawUpdate(sql, arguments);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values,
      {String where, List whereArgs, ConflictAlgorithm conflictAlgorithm}) {
    return instance.update(table, values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
  }
}

class SQLiteAdapterException extends DatabaseException {

  static const String DATABASE_NOT_OPENED = "Database is not open, "
          "client did not call await openDatabase().";

  SQLiteAdapterException(String message) : super(message);

}
