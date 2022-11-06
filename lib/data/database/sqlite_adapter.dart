import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_binder.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqlite3/open.dart';

typedef OnDatabaseCreate = FutureOr<void> Function(
  SqliteAdapter db,
  int version,
);
typedef OnDatabaseVersionChange = FutureOr<void> Function(
  SqliteAdapter db,
  int oldVersion,
  int newVersion,
);

class SqliteAdapter implements DatabaseExecutor {
  late final String _path;
  final OnDatabaseVersionChange? onDowngrade;
  final OnDatabaseVersionChange? onUpgrade;
  final OnDatabaseCreate? onCreate;
  final DatabaseSchema schema;
  final String? libraryPath;
  final String password;
  final String name;
  final int version;
  SqliteBinder? _binder;
  Database? _db;

  Database? get instance {
    if (_db == null || !_db!.isOpen) {
      throw SqliteException(SqliteException.databaseNotOpened);
    }
    return _db;
  }

  String get path => _path;

  bool get inTransaction => _binder != null;

  SqliteBinder? get binder => _binder;

  SqliteAdapter({
    required this.name,
    required this.version,
    required this.schema,
    required this.password,
    this.libraryPath,
    this.onCreate,
    this.onUpgrade,
    this.onDowngrade,
  });

  /// Always use await when opening a database
  Future<void> openConnection() async {
    if (_db == null || !_db!.isOpen) {
      bool isCreated = false;
      bool isUpgraded = false;
      bool isDowngraded = false;
      int _oldVersion = 0;
      this._db = await _openDatabase(
        version: version,
        password: password,
        onCreate: (db, version) async {
          isCreated = true;
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          isUpgraded = true;
          _oldVersion = oldVersion;
        },
        onDowngrade: (db, oldVersion, newVersion) async {
          isDowngraded = true;
          _oldVersion = oldVersion;
        },
      );
      if (isCreated) {
        await onCreate?.call(this, version);
      }
      if (isUpgraded) {
        await onUpgrade?.call(this, _oldVersion, version);
      }
      if (isDowngraded) {
        await onDowngrade?.call(this, _oldVersion, version);
      }
      debugPrint('Database Path: $_path');
    }
  }

  Future<Database> _openDatabase({
    required String password,
    required int version,
    required OnDatabaseCreateFn onCreate,
    required OnDatabaseVersionChangeFn onUpgrade,
    required OnDatabaseVersionChangeFn onDowngrade,
  }) async {
    if (Platform.isWindows || Platform.isMacOS) {
      final factory = createDatabaseFactoryFfi(ffiInit: _ffiInit);
      return await factory.openDatabase(
        _path = '${Directory.current.path}/$name',
        options: OpenDatabaseOptions(
          version: version,
          onConfigure: (db) async {
            await db.rawQuery("PRAGMA KEY = '$password'");
          },
          onCreate: onCreate,
          onUpgrade: onUpgrade,
          onDowngrade: onDowngrade,
        ),
      );
    } else {
      final directory = await getDatabasesPath();
      return await openDatabase(
        _path = join(directory, name),
        version: version,
        password: password,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
      );
    }
  }

  void _ffiInit() {
    open.overrideFor(OperatingSystem.windows, () {
      if (libraryPath != null) {
        return DynamicLibrary.open(libraryPath!);
      }
      throw SqliteException(
        'Please provide the path for the compiled sqlite3.dll file.',
      );
    });
  }

  Future<List<Map<String, dynamic>>> read(String sql) {
    return rawQuery(sql);
  }

  Future<T?> getValue<T>(String sql) async {
    final list = await rawQuery(sql);
    if (list.isNotEmpty) {
      final first = list.first;
      return first.values.first as T;
    }
    return null;
  }

  Future<bool> isRecordExists(String sql) async {
    final list = await rawQuery(sql);
    return list.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getRecord(String sql) async {
    final list = await rawQuery(sql);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> recordOf({
    required TableSchema schema,
    required int id,
  }) async {
    final query = SqliteQuery.all(
      schema: schema,
      where: {
        SqliteStatement.id: id,
      },
      type: JoinType.left,
    );
    return await getRecord(query.build());
  }

  void close() {
    if (!instance!.isOpen) {
      instance!.close();
    }
  }

  Batch batch() {
    return instance!.batch();
  }

  Future<List<String?>> getColumnList(String? table) async {
    final list = <String?>[];
    final sql = "PRAGMA table_info($table)";
    final cursor = await rawQuery(sql);
    if (cursor.isNotEmpty) {
      cursor.forEach((map) {
        if (map.isNotEmpty) {
          list.add(map['name'] as String?);
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

  Future<int> getIndexColumnCount(String? index) async {
    final sql = "PRAGMA index_info($index)";
    final cursor = await rawQuery(sql);
    return cursor.length;
  }

  Future<bool> hasRecord<E extends DatabaseEntity>(E entity) async {
    final schema = this.schema.of(entity);
    final sql = "SELECT COUNT(*) FROM ${schema.tableName}";
    final record = await getRecord(sql);
    if (record != null) {
      return record.values.first > 0;
    }
    return false;
  }

  Future<void> checkVersion() async {
    final sql = "PRAGMA user_version";
    int? version = await getValue(sql);
    print('$name at version: $version');
  }

  void setBinder(SqliteBinder binder) {
    _binder = binder;
  }

  void removeBinder() {
    if (_binder != null) {
      _binder = null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    return instance!.query(table,
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
  Future<int> delete(String table, {String? where, List? whereArgs}) {
    return instance!.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql, [List? arguments]) {
    return instance!.execute(sql, arguments);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    return instance!.insert(table, values,
        nullColumnHack: null, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<int> rawDelete(String sql, [List? arguments]) {
    return instance!.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List? arguments]) {
    return instance!.rawInsert(sql, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List? arguments]) {
    return instance!.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List? arguments]) {
    return instance!.rawUpdate(sql, arguments);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values,
      {String? where, List? whereArgs, ConflictAlgorithm? conflictAlgorithm}) {
    return instance!.update(table, values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) {
    throw UnimplementedError();
  }
}
