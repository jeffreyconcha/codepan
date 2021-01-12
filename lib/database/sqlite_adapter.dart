import 'dart:async';
import 'package:codepan/database/schema.dart';
import 'package:codepan/database/sqlite_binder.dart';
import 'package:codepan/database/sqlite_exception.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

typedef OnDatabaseCreate = FutureOr<void> Function(
  SQLiteAdapter db,
  int version,
);
typedef OnDatabaseVersionChange = FutureOr<void> Function(
  SQLiteAdapter db,
  int oldVersion,
  int newVersion,
);

class SQLiteAdapter implements DatabaseExecutor {
  final OnDatabaseVersionChange onDowngrade;
  final OnDatabaseVersionChange onUpgrade;
  final OnDatabaseCreate onCreate;
  final String name, password;
  final DatabaseSchema schema;
  final int version;
  bool _inTransaction = false;
  SQLiteBinder _binder;
  Database _db;

  Database get instance {
    if (_db == null || !_db.isOpen) {
      throw SQLiteException(SQLiteException.databaseNotOpened);
    }
    return _db;
  }

  bool get inTransaction => _binder != null && _inTransaction ?? false;

  SQLiteBinder get binder => _binder;

  SQLiteAdapter({
    @required this.name,
    @required this.version,
    this.password,
    this.onCreate,
    this.onUpgrade,
    this.onDowngrade,
    this.schema,
  });

  /// Always use await when opening a database
  Future<void> openConnection() async {
    if (_db == null || !_db.isOpen) {
      int _oldVersion;
      bool isCreated = false;
      bool isUpgraded = false;
      bool isDowngraded = false;
      final directory = await getDatabasesPath();
      final path = join(directory, name);
      this._db = await openDatabase(
        path,
        version: version,
        password: password,
        onCreate: (db, version) {
          isCreated = true;
        },
        onUpgrade: (db, oldVersion, newVersion) {
          isUpgraded = true;
          _oldVersion = oldVersion;
        },
        onDowngrade: (db, oldVersion, newVersion) {
          isDowngraded = true;
          _oldVersion = oldVersion;
        },
      );
      if (isCreated) {
        onCreate?.call(this, version);
      }
      if (isUpgraded) {
        onUpgrade?.call(this, _oldVersion, version);
      }
      if (isDowngraded) {
        onDowngrade?.call(this, _oldVersion, version);
      }
    }
  }

  Future<List<Map<String, dynamic>>> read(String sql) {
    return rawQuery(sql);
  }

  Future<dynamic> getValue(String sql) async {
    final list = await rawQuery(sql);
    if (list.isNotEmpty) {
      final first = list.first;
      return first.values.first;
    }
    return null;
  }

  Future<bool> isRecordExists(String sql) async {
    final list = await rawQuery(sql);
    return list.isNotEmpty;
  }

  Future<Map<String, dynamic>> getRecord(String sql) async {
    final list = await rawQuery(sql);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> recordOf({
    @required TableSchema schema,
    @required int id,
  }) async {
    final query = SQLiteQuery.all(
      schema: schema,
      where: {
        SQLiteStatement.id: id,
      },
    );
    return await getRecord(query.build());
  }

  void close() {
    if (!instance.isOpen) {
      instance.close();
    }
  }

  Batch batch() {
    return instance.batch();
  }

  Future<List<String>> getColumnList(String table) async {
    final list = <String>[];
    final sql = "PRAGMA table_info($table)";
    final cursor = await rawQuery(sql);
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
    final cursor = await rawQuery(sql);
    return cursor.length;
  }

  Future<int> getIndexColumnCount(String index) async {
    final sql = "PRAGMA index_info($index)";
    final cursor = await rawQuery(sql);
    return cursor.length;
  }

  Future<void> checkVersion() async {
    final sql = "PRAGMA user_version";
    int version = await getValue(sql);
    print('$name at version: $version');
  }

  void setBinder(SQLiteBinder binder) {
    _binder = binder;
    _inTransaction = true;
  }

  void removeBinder() {
    _inTransaction = false;
    _binder = null;
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
