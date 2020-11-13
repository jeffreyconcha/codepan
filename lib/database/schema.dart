import 'package:codepan/database/entities/field.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'entities/table.dart';

abstract class DatabaseSchema<T> {
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

  String unique(T entity) {
    for (final field in fields(entity)) {
      if (field.isUnique) {
        return field.field;
      }
    }
    return null;
  }

  List<String> uniqueGroup(T entity) {
    final list = <String>[];
    for (final field in fields(entity)) {
      if (field.inUniqueGroup) {
        list.add(field.field);
      }
    }
    return list;
  }

  List<TableSchema> references(T entity) {
    final references = <TableSchema>[];
    for (final field in fields(entity)) {
      if (field.isForeignKey) {
        final table = field.table;
        references.add(of(table.entity));
      }
    }
    return references;
  }

  String tableName(T entity) => _name(entity, tableSuffix);

  String indexName(T entity) => _name(entity, indexSuffix);

  String triggerName(T entity) => _name(entity, triggerSuffix);

  String alias(T entity) => at(entity).alias;

  Table at(T entity) => Table(tableName(entity), entity);

  TableSchema of(T entity) {
    return TableSchema<T>(this, entity);
  }

  String _name(T entity, String suffix) {
    if (entity != null) {
      final value = entity.toString().split('.').last;
      return '${PanUtils.camelToUnderscore(value)}$suffix';
    }
    return null;
  }
}

class TableSchema<T> {
  final T entity;
  final DatabaseSchema schema;

  const TableSchema(this.schema, this.entity);

  List<Field> get fields => schema?.fields(entity);

  List<Field> get indices => schema?.indices(entity);

  List<Field> get triggers => schema?.triggers(entity);

  Table get table => schema?.at(entity);

  String get alias => table?.alias;

  String get tableName => schema?.tableName(entity);

  String get indexName => schema?.indexName(entity);

  String get triggerName => schema?.triggerName(entity);

  String get unique => schema?.unique(entity);

  List<String> get uniqueGroup => schema?.uniqueGroup(entity);

  List<TableSchema> get references => schema?.references(entity);
}
