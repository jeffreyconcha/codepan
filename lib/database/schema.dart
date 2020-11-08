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
      if (field.isForeignKey) {
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

  String tableName(T tb) {
    if (tb != null) {
      final value = tb.toString().split('.').last;
      return '${value.toLowerCase()}$tableSuffix';
    }
    return null;
  }

  String indexName(T entity) {
    if (entity != null) {
      final value = entity.toString().split('.').last;
      return '${value.toLowerCase()}$indexSuffix';
    }
    return null;
  }

  String triggerName(T entity) {
    if (entity != null) {
      final value = entity.toString().split('.').last;
      return '${value.toLowerCase()}$triggerSuffix';
    }
    return null;
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

  Table at(T entity) {
    return Table(tableName(entity));
  }
}
