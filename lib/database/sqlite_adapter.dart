import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:codepan/database/sqlite_exception.dart';

typedef OnDatabaseCreate = FutureOr<void> Function(
    SQLiteAdapter db, int version);
typedef OnDatabaseUpgrade = FutureOr<void> Function(
    SQLiteAdapter db, int ov, int nv);
typedef OnDatabaseDowngrade = FutureOr<void> Function(
    SQLiteAdapter db, int ov, int nv);

class SQLiteAdapter implements DatabaseExecutor {
  final OnDatabaseDowngrade onDowngrade;
  final OnDatabaseUpgrade onUpgrade;
  final OnDatabaseCreate onCreate;
  final String name, password;
  final int version;
  Database _db;

  Database get instance {
    if (_db == null || !_db.isOpen) {
      throw SQLiteException(SQLiteException.DATABASE_NOT_OPENED);
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
      int old;
      bool isCreated = false;
      bool isUpgraded = false;
      bool isDowngraded = false;
      final directory = await getDatabasesPath();
      final path = join(directory, name);
      this._db = await openDatabase(
        path,
        version: version,
        password: password,
        onCreate: (db, nv) {
          isCreated = onCreate != null;
        },
        onUpgrade: (db, ov, nv) {
          isUpgraded = onUpgrade != null;
          old = ov;
        },
        onDowngrade: (db, ov, nv) {
          isDowngraded = onDowngrade != null;
          old = ov;
        },
      );
      if (isCreated) {
        onCreate(this, version);
      }
      if (isUpgraded) {
        onUpgrade(this, old, version);
      }
      if (isDowngraded) {
        onDowngrade(this, old, version);
      }
    }
  }

  Future<List<Map<String, dynamic>>> read(String sql) {
    return instance.rawQuery(sql);
  }

  Future<dynamic> getValue(String sql) async {
    final list = await instance.rawQuery(sql);
    if (list.isNotEmpty) {
      final first = list.first;
      return first.values.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> getRecord(String sql) async {
    final list = await instance.rawQuery(sql);
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

  Future<List<String>> getColumnList(String table) async {
    final list = new List<String>();
    final sql = "PRAGMA table_info($table)";
    final cursor = await instance.rawQuery(sql);
    if (cursor.isNotEmpty) {
      cursor.forEach((map) {
        if (map.isNotEmpty) {
          list.add(map['name'] as String);
        }
      });
    }
    return list;
  }

  Future<int> getTableColumnCount(String table) async {
    final sql = "PRAGMA table_info($table)";
    final cursor = await instance.rawQuery(sql);
    return cursor.length;
  }

  Future<int> getIndexColumnCount(String index) async {
    final sql = "PRAGMA index_info($index)";
    final cursor = await instance.rawQuery(sql);
    return cursor.length;
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
