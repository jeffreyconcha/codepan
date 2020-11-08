import 'package:codepan/database/schema.dart';
import 'package:codepan/database/sqlite_adapter.dart';
import 'package:codepan/database/sqlite_binder.dart';
import 'package:codepan/database/sqlite_exception.dart';
import 'package:flutter/foundation.dart';

abstract class DatabaseInitializer {
  final DatabaseSchema schema;

  DatabaseInitializer(this.schema);

  Future<void> onCreate(SQLiteAdapter db, int version);

  Future<void> onUpgrade(SQLiteAdapter db, int ov, int nv);

  Future<void> onDowngrade(SQLiteAdapter db, int ov, int nv);
}

class DefaultDatabaseInitializer extends DatabaseInitializer {
  DefaultDatabaseInitializer(DatabaseSchema schema) : super(schema);

  @override
  Future<void> onCreate(SQLiteAdapter db, int version) async {
    final binder = new SQLiteBinder(db);
    try {
      await binder.beginTransaction();
      await _createTables(binder);
      await _createIndices(binder);
      await _createTimeTriggers(binder);
      await binder.finish();
    } catch (error) {
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  @override
  Future<void> onDowngrade(SQLiteAdapter db, int ov, int nv) async {
    final binder = new SQLiteBinder(db);
    try {
      await binder.beginTransaction();
      await _createTables(binder);
      await _updateTables(binder);
      await _createIndices(binder);
      await _updateIndices(binder);
      await _createTimeTriggers(binder);
      await binder.finish();
    } catch (error) {
      await db.instance.setVersion(ov);
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  @override
  Future<void> onUpgrade(SQLiteAdapter db, int ov, int nv) async {
    final binder = new SQLiteBinder(db);
    try {
      await binder.beginTransaction();
      await _createTables(binder);
      await _updateTables(binder);
      await _createIndices(binder);
      await _updateIndices(binder);
      await _createTimeTriggers(binder);
      await binder.finish();
    } catch (error) {
      await db.instance.setVersion(ov);
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  Future<void> _createTables(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final table = schema.tableName(tb);
      final stmt = schema.fields(tb);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _createIndices(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final table = schema.tableName(tb);
      final stmt = schema.indices(tb);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final idx = schema.indexName(tb);
        binder.createIndex(idx, table, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _createTimeTriggers(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final table = schema.tableName(tb);
      final stmt = schema.triggers(tb);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final trg = schema.triggerName(tb);
        binder.createTimeTrigger(trg, table, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _updateTables(SQLiteBinder binder) async {
    final db = binder.db;
    for (final tb in schema.entities) {
      final table = schema.tableName(tb);
      final stmt = schema.fields(tb);
      if (stmt.hasFields) {
        final fieldList = stmt.fieldList;
        final columnList = await db.getColumnList(table);
        if (fieldList.length > columnList.length) {
          fieldList.forEach((f) {
            if (!columnList.contains(f.field)) {
              binder.addColumn(table, f);
              debugPrint('Column ${f.field} added to $table');
            }
          });
        }
      }
    }
    await binder.apply();
  }

  Future<void> _updateIndices(SQLiteBinder binder) async {
    final db = binder.db;
    for (final tb in schema.entities) {
      String table = schema.tableName(tb);
      final stmt = schema.indices(tb);
      if (stmt.hasFields) {
        final idx = schema.indexName(tb);
        final int count = await db.getIndexColumnCount(idx);
        if (stmt.fieldList.length > count) {
          binder.dropIndex(idx);
          binder.createIndex(idx, table, stmt);
        }
      }
    }
    await binder.apply();
  }
}
