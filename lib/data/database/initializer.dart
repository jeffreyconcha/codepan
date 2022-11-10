import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/database/sqlite_binder.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';

typedef DatabaseCreateNotifier = Future<void> Function(
  SqliteAdapter db,
  int version,
);

typedef DatabaseUpdateNotifier = Future<void> Function(
  SqliteAdapter db,
  int oldVersion,
  int newVersion,
);

abstract class DatabaseInitializer {
  final DatabaseSchema schema;
  final DatabaseCreateNotifier? createNotifier;
  final DatabaseUpdateNotifier? updateNotifier;

  DatabaseInitializer(
    this.schema, {
    this.createNotifier,
    this.updateNotifier,
  });

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

class DefaultDatabaseInitializer extends DatabaseInitializer {
  DefaultDatabaseInitializer(
    super.schema, {
    super.createNotifier,
    super.updateNotifier,
  });

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
      await createNotifier?.call(db, version);
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
      await updateNotifier?.call(db, oldVersion, newVersion);
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
      await updateNotifier?.call(db, oldVersion, newVersion);
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
      }
    }
    await binder.apply();
  }

  Future<void> _createIndices(SqliteBinder binder) async {
    for (final tb in schema.entities) {
      final entity = schema.of(tb);
      final table = entity.tableName;
      final stmt = SqliteStatement.fromList(entity.indices);
      if (stmt.hasFields) {
        binder.createTable(table, stmt);
        final idx = entity.indexName;
        binder.createIndex(idx, table, stmt);
      }
    }
    await binder.apply();
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
      }
    }
    await binder.apply();
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
      }
    }
    await binder.apply();
  }
}
