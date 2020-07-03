import 'package:codepan/database/entities/condition.dart';
import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/entities/field_value.dart';
import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/mixin/query_properties.dart';
import 'package:codepan/database/sqlite_exception.dart';
import 'package:codepan/database/sqlite_query.dart';

class SQLiteStatement with QueryProperties {
  static const String ID = 'id';
  static const String TABLE_SUFFIX = '_tb';
  static const String INDEX_SUFFIX = '_idx';
  static const String NULL = 'NULL';
  static const int TRUE = 1;
  static const int FALSE = 0;
  List<FieldValue> _fieldValueList;

  SQLiteStatement();

  /// Constructor for field value list.
  SQLiteStatement.fromMap(Map<String, dynamic> map) {
    addFieldsAndValues(map);
  }

  /// Constructor for field list.
  SQLiteStatement.fromList(List<dynamic> list) {
    addFields(list);
  }

  SQLiteStatement.from({
    List<dynamic> fields,
    Map<String, dynamic> fieldsAndValues,
    dynamic conditions,
  }) {
    addFields(fields);
    addConditions(conditions);
    addFieldsAndValues(fieldsAndValues);
  }

  void addFieldsAndValues(Map<String, dynamic> map) {
    map?.forEach((key, value) {
      final fv = FieldValue(key, value);
      addFieldValue(fv);
    });
  }

  List<FieldValue> get fieldValueList => _fieldValueList;

  bool get hasFieldValues =>
      _fieldValueList != null && _fieldValueList.isNotEmpty;

  SQLiteStatement clearAll() {
    if (hasFieldValues) _fieldValueList.clear();
    clearConditionList();
    clearFieldList();
    return this;
  }

  void clearFieldValueList() {
    if (hasFieldValues) _fieldValueList.clear();
  }

  Map<String, dynamic> get map {
    if (hasFieldValues) {
      final map = Map<String, dynamic>();
      for (final fv in fieldValueList) {
        map[fv.field] = fv.rawValue;
      }
      return map;
    }
    return null;
  }

  String get fieldValues {
    final buffer = StringBuffer();
    if (hasFieldValues) {
      for (final fv in fieldValueList) {
        final value = fv.value != null ? fv.value : NULL;
        buffer.write('${fv.field} = $value');
        if (fieldValueList.indexOf(fv) < fieldValueList.length - 1) {
          buffer.write(', ');
        }
      }
    }
    return buffer.toString();
  }

  String insert(String table, {String unique}) {
    final buffer = StringBuffer();
    if (!hasFieldValues) throw SQLiteException(SQLiteException.noFieldValues);
    final f = StringBuffer();
    final v = StringBuffer();
    for (final fv in fieldValueList) {
      f.write(fv.field);
      v.write(fv.value);
      if (fieldValueList.indexOf(fv) < fieldValueList.length - 1) {
        f.write(', ');
        v.write(', ');
      }
    }
    final fields = f.toString();
    final values = v.toString();
    if (unique != null) {
      buffer.write('INSERT INTO $table ($fields) VALUES ($values)');
      buffer.write(' ON CONFLICT ($unique) ');
      buffer.write('DO UPDATE SET $fieldValues');
    } else {
      buffer.write('INSERT OR IGNORE INTO $table ($fields) VALUES ($values)');
    }
    return buffer.toString();
  }

  String update(String table, dynamic id) {
    if (!hasFieldValues) throw SQLiteException(SQLiteException.noFieldValues);
    return 'UPDATE $table SET $fieldValues WHERE $ID = ${id.toString()}';
  }

  String updateWithConditions(String table) {
    if (!hasFieldValues) throw SQLiteException(SQLiteException.noFieldValues);
    if (!hasConditions) throw SQLiteException(SQLiteException.noConditions);
    return 'UPDATE $table SET $fieldValues WHERE $conditions';
  }

  String delete(String table, dynamic id) {
    return 'DELETE FROM $table WHERE $ID = ${id.toString()}';
  }

  String deleteWithConditions(String table) {
    if (!hasConditions) throw SQLiteException(SQLiteException.noConditions);
    return 'DELETE FROM $table WHERE $conditions';
  }

  String createTable(String table) {
    return 'CREATE TABLE IF NOT EXISTS $table (${getCommandFields(fieldList)})';
  }

  String createIndex(String idx, String table) {
    return 'CREATE INDEX IF NOT EXISTS $idx ON $table ($fields)';
  }

  String dropTable(String table) {
    return 'DROP TABLE IF EXISTS $table';
  }

  String dropIndex(String idx) {
    return 'DROP INDEX IF EXISTS $idx';
  }

  String renameTable(String oldName, String newName) {
    return 'ALTER TABLE $oldName RENAME TO $newName';
  }

  String resetTable(String table) {
    return 'UPDATE SQLITE_SEQUENCE SET SEQ = 0 WHERE NAME =\'$table\'';
  }

  String addColumn(String table, Field field) {
    if (field != null) {
      return 'ALTER TABLE $table ADD COLUMN ${field.asString()}';
    }
    return null;
  }

  String select(String table) {
    final query = SQLiteQuery(
      select: fieldList,
      from: table,
      where: conditionList,
    );
    return query.build();
  }

  void addFieldValue(FieldValue fv) {
    _fieldValueList ??= [];
    _fieldValueList.add(fv);
  }

  void add(SQLiteEntity entity) {
    if (entity != null) {
      if (entity is FieldValue) {
        addFieldValue(entity);
      } else if (entity is Condition) {
        addCondition(entity);
      } else {
        addField(entity);
      }
    } else {
      throw SQLiteException(SQLiteException.invalidSqliteEntity);
    }
  }
}
