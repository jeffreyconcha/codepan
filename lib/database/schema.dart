import 'package:codepan/utils/codepan_utils.dart';
import 'entities/table.dart';
import 'sqlite_statement.dart';

abstract class DatabaseSchema<T> {
  static const String tableSuffix = '_tb';
  static const String indexSuffix = '_idx';
  static const String triggerSuffix = '_trg';

  List<T> get entities;

  const DatabaseSchema();

  SQLiteStatement fields(T entity);

  SQLiteStatement indices(T entity) {
    final query = SQLiteStatement();
    for (final field in fields(entity).fieldList) {
      if (field.isForeignKey || field.isIndex) {
        query.add(field);
      }
    }
    return query;
  }

  SQLiteStatement triggers(T entity) {
    final query = SQLiteStatement();
    for (final field in fields(entity).fieldList) {
      if (field.withDateTrigger || field.withTimeTrigger) {
        query.add(field);
      }
    }
    return query;
  }

  String unique(T entity) {
    for (final field in fields(entity).fieldList) {
      if (field.isUnique) {
        return field.field;
      }
    }
    return null;
  }

  List<String> uniqueGroup(T entity) {
    final list = <String>[];
    for (final field in fields(entity).fieldList) {
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
