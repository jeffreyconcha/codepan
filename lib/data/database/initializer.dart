import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/database/sqlite_binder.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

abstract class DatabaseInitializer {
  final DatabaseSchema schema;

  const DatabaseInitializer(this.schema);

  Future<void> onCreate(
    SqliteAdapter db,
    int version,
  );

  Future<void> onUpgrade(
    SqliteAdapter db,
    int oldVersion,
    int newVersion,
  );

  Future<void> onDowngrade(
    SqliteAdapter db,
    int oldVersion,
    int newVersion,
  );
}

abstract class DefaultDatabaseInitializer extends DatabaseInitializer {
  const DefaultDatabaseInitializer(super.schema);

  Future<void> onDatabaseCreated(
    SqliteAdapter db,
    int version,
  );

  Future<void> onDatabaseUpdated(
    SqliteAdapter db,
    int oldVersion,
    int newVersion,
  );

  @override
  Future<void> onCreate(SqliteAdapter db, int version) async {
    final binder = SqliteBinder.of(db);
    try {
      await binder.transact<bool>(
        body: (binder) async {
          await _createTables(binder);
          await _createIndices(binder);
          await _createTimeTriggers(binder);
        },
      );
      await onDatabaseCreated(db, version);
    } catch (error) {
      final message = "${SqliteException.initializationFailed}\n$error";
      throw SqliteException(message);
    }
  }

  @override
  Future<void> onDowngrade(
    SqliteAdapter db,
    int oldVersion,
    int newVersion,
  ) async {
    final binder = SqliteBinder.of(db);
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
      await onDatabaseUpdated(db, oldVersion, newVersion);
    } catch (error) {
      await db.instance!.setVersion(oldVersion);
      final message = "${SqliteException.initializationFailed}\n$error";
      throw SqliteException(message);
    }
  }

  @override
  Future<void> onUpgrade(
    SqliteAdapter db,
    int oldVersion,
    int newVersion,
  ) async {
    final binder = SqliteBinder.of(db);
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
      await onDatabaseUpdated(db, oldVersion, newVersion);
    } catch (error) {
      await db.instance!.setVersion(oldVersion);
      final message = "${SqliteException.initializationFailed}\n$error";
      throw SqliteException(message);
    }
  }

  Future<void> _createTables(SqliteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final stmt = SqliteStatement.fromList(entity.fields);
      if (stmt.hasFields) {
        binder.createTable(entity.tableName, stmt);
        binder.apply();
      }
    }
  }

  Future<void> _createIndices(SqliteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SqliteStatement.fromList(entity.indices);
      if (stmt.hasFields) {
        final idx = entity.indexName;
        binder.createIndex(idx, table, stmt);
        binder.apply();
      }
    }
  }

  Future<void> _createTimeTriggers(SqliteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SqliteStatement.fromList(entity.triggers);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final trg = entity.triggerName;
        binder.createTimeTrigger(trg, table, stmt);
        binder.apply();
      }
    }
  }

  Future<void> _updateTables(SqliteBinder binder) async {
    final db = binder.db;
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SqliteStatement.fromList(entity.fields);
      if (stmt.hasFields) {
        final fieldList = stmt.fieldList!;
        final columnList = await db.getColumnList(table);
        fieldList.loop((item, index) {
          if (!columnList.contains(item.field)) {
            binder.addColumn(table, item);
            debugPrint('Column ${item.field} added to $table');
          }
        });
        binder.apply();
      }
    }
  }

  Future<void> _updateIndices(SqliteBinder binder) async {
    final db = binder.db;
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SqliteStatement.fromList(entity.indices);
      if (stmt.hasFields) {
        final idx = entity.indexName;
        final int count = await db.getIndexColumnCount(idx);
        if (stmt.fieldList!.length > count) {
          binder.dropIndex(idx);
          binder.createIndex(idx, table, stmt);
        }
        binder.apply();
      }
    }
  }
}
