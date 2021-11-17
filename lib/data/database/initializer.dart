import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/database/sqlite_binder.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';

abstract class DatabaseInitializer {
  final DatabaseSchema schema;

  DatabaseInitializer(this.schema);

  Future<void> onCreate(SQLiteAdapter db, int version);

  Future<void> onUpgrade(
    SQLiteAdapter db,
    int oldVersion,
    int newVersion,
  );

  Future<void> onDowngrade(
    SQLiteAdapter db,
    int oldVersion,
    int newVersion,
  );
}

class DefaultDatabaseInitializer extends DatabaseInitializer {
  DefaultDatabaseInitializer(DatabaseSchema schema) : super(schema);

  @override
  Future<void> onCreate(SQLiteAdapter db, int version) async {
    final binder = SQLiteBinder(db);
    try {
      await binder.transact<bool>(
        body: (binder) async {
          await _createTables(binder);
          await _createIndices(binder);
          await _createTimeTriggers(binder);
        },
      );
    } catch (error) {
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  @override
  Future<void> onDowngrade(
    SQLiteAdapter db,
    int oldVersion,
    int newVersion,
  ) async {
    final binder = SQLiteBinder(db);
    try {
      await binder.transact<bool>(
        body: (binder) async {
          await _createTables(binder);
          await _updateTables(binder);
          await _createIndices(binder);
          await _updateIndices(binder);
          await _createTimeTriggers(binder);
        },
      );
    } catch (error) {
      await db.instance!.setVersion(oldVersion);
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  @override
  Future<void> onUpgrade(
    SQLiteAdapter db,
    int oldVersion,
    int newVersion,
  ) async {
    final binder = SQLiteBinder(db);
    try {
      await binder.transact<bool>(
        body: (binder) async {
          await _createTables(binder);
          await _updateTables(binder);
          await _createIndices(binder);
          await _updateIndices(binder);
          await _createTimeTriggers(binder);
        },
      );
    } catch (error) {
      await db.instance!.setVersion(oldVersion);
      final message = "${SQLiteException.initializationFailed}\n$error";
      throw SQLiteException(message);
    }
  }

  Future<void> _createTables(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final stmt = SQLiteStatement.fromList(entity.fields);
      if (stmt.hasFields) {
        binder.createTable(entity.tableName, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _createIndices(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SQLiteStatement.fromList(entity.indices);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final idx = entity.indexName;
        binder.createIndex(idx, table, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _createTimeTriggers(SQLiteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SQLiteStatement.fromList(entity.triggers);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final trg = entity.triggerName;
        binder.createTimeTrigger(trg, table, stmt);
      }
    }
    await binder.apply();
  }

  Future<void> _updateTables(SQLiteBinder binder) async {
    final db = binder.db;
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SQLiteStatement.fromList(entity.fields);
      if (stmt.hasFields) {
        final fieldList = stmt.fieldList!;
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
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SQLiteStatement.fromList(entity.indices);
      if (stmt.hasFields) {
        final idx = entity.indexName;
        final int count = await db.getIndexColumnCount(idx);
        if (stmt.fieldList!.length > count) {
          binder.dropIndex(idx);
          binder.createIndex(idx, table, stmt);
        }
      }
    }
    await binder.apply();
  }
}
