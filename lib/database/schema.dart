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

  String tableName(T entity) => _name(entity, tableSuffix);

  String indexName(T entity) => _name(entity, indexSuffix);

  String triggerName(T entity) => _name(entity, triggerSuffix);

  String alias(T entity) => at(entity).alias;

  Table at(T entity) => Table(tableName(entity));

  String _name(T entity, String suffix) {
    if (entity != null) {
      final value = entity.toString().split('.').last;
      return '${PanUtils.camelToUnderscore(value)}$suffix';
    }
    return null;
  }
}
