import 'package:codepan/data/database/models/field.dart';
import 'package:codepan/data/database/models/table.dart';
import 'package:codepan/extensions/extensions.dart';

abstract class DatabaseEntity {
  String get dbName;

  int get version;

  int get count;
}

abstract class DatabaseSchema<T extends DatabaseEntity> {
  static const String tableSuffix = '_tb';
  static const String indexSuffix = '_idx';
  static const String triggerSuffix = '_trg';

  List<T> get entities;

  const DatabaseSchema();

  List<Field> fields(T entity);

  List<Field> indices(T entity) {
    final indices = <Field>[];
    for (final field in fields(entity)) {
      if (field.isForeignKey || field.isIndex) {
        indices.add(field);
      }
    }
    return indices;
  }

  List<Field> triggers(T entity) {
    final triggers = <Field>[];
    for (final field in fields(entity)) {
      if (field.withDateTrigger || field.withTimeTrigger) {
        triggers.add(field);
      }
    }
    return triggers;
  }

  String? unique(T entity) {
    for (final field in fields(entity)) {
      if (field.isUnique) {
        return field.field;
      }
    }
    return null;
  }

  List<String>? uniqueGroup(T entity) {
    final list = <String>[];
    for (final field in fields(entity)) {
      final name = field.field;
      if (field.inUniqueGroup) {
        list.add(name);
      }
    }
    return list.isNotEmpty ? list : null;
  }

  List<TableSchema> references(T entity) {
    final references = <TableSchema>[];
    for (final field in fields(entity)) {
      if (field.isForeignKey) {
        final table = field.reference!;
        final schema = of(table.entity!);
        if (!references.contains(schema)) {
          references.add(schema);
        }
      }
    }
    return references;
  }

  List<Field> foreignKeys(T entity) {
    final foreignKeys = <Field>[];
    for (final field in fields(entity)) {
      if (field.isForeignKey) {
        foreignKeys.add(field);
      }
    }
    return foreignKeys;
  }

  String tableName(T entity) => _name(entity, tableSuffix);

  String indexName(T entity) => _name(entity, indexSuffix);

  String triggerName(T entity) => _name(entity, triggerSuffix);

  String alias(T entity) => at(entity).alias;

  Table at(T entity) {
    return Table(
      tableName(entity),
      entity: entity,
    );
  }

  String _name(T entity, String suffix) =>
      '${entity.enumValue.toSnake()}$suffix';

  TableSchema of<E extends DatabaseEntity>(E entity) {
    return TableSchema<E>(this, entity);
  }
}

class TableSchema<T extends DatabaseEntity> {
  final DatabaseSchema dbSchema;
  final T entity;

  const TableSchema(this.dbSchema, this.entity);

  List<Field> get fields => dbSchema.fields(entity);

  List<Field> get indices => dbSchema.indices(entity);

  List<Field> get triggers => dbSchema.triggers(entity);

  Table get table => dbSchema.at(entity);

  String get alias => table.alias;

  String get tableName => dbSchema.tableName(entity);

  String get indexName => dbSchema.indexName(entity);

  String get triggerName => dbSchema.triggerName(entity);

  String? get unique => dbSchema.unique(entity);

  List<String>? get uniqueGroup => dbSchema.uniqueGroup(entity);

  List<TableSchema> get references => dbSchema.references(entity);

  List<Field> get foreignKeys => dbSchema.foreignKeys(entity);

  String? get asForeignKey => table.asForeignKey();
}
