import 'package:codepan/data/database/mixin/query_properties.dart';
import 'package:codepan/data/database/models/condition.dart';
import 'package:codepan/data/database/models/field.dart';
import 'package:codepan/data/database/models/field_value.dart';
import 'package:codepan/data/database/models/sqlite_model.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/data/database/sqlite_query.dart';

class SqliteStatement with QueryProperties {
  static const String id = 'id';
  static const String nullValue = 'NULL';
  static const int trueValue = 1;
  static const int falseValue = 0;
  List<FieldValue>? _fieldValueList;

  SqliteStatement();

  /// Constructor for field value list.
  SqliteStatement.fromMap(Map<String, dynamic> map) {
    addFieldsAndValues(map);
  }

  /// Constructor for field list.
  SqliteStatement.fromList(List<dynamic> list) {
    addFields(list);
  }

  SqliteStatement.from({
    List<dynamic>? fields,
    Map<String, dynamic>? fieldsAndValues,
    dynamic conditions,
  }) {
    addFields(fields);
    addConditions(conditions);
    addFieldsAndValues(fieldsAndValues);
  }

  void addFieldsAndValues(Map<String, dynamic>? map) {
    map?.forEach((key, value) {
      final fv = FieldValue(key, value);
      addFieldValue(fv);
    });
  }

  List<FieldValue>? get fieldValueList => _fieldValueList;

  bool get hasFieldValues =>
      _fieldValueList != null && _fieldValueList!.isNotEmpty;

  SqliteStatement clearAll() {
    if (hasFieldValues) _fieldValueList!.clear();
    clearConditionList();
    clearFieldList();
    return this;
  }

  void clearFieldValueList() {
    if (hasFieldValues) _fieldValueList!.clear();
  }

  Map<String?, dynamic>? get map {
    if (hasFieldValues) {
      final map = Map<String?, dynamic>();
      for (final fv in fieldValueList!) {
        map[fv.field] = fv.rawValue;
      }
      return map;
    }
    return null;
  }

  String get fieldValues {
    final buffer = StringBuffer();
    if (hasFieldValues) {
      for (final fv in fieldValueList!) {
        buffer.write('${fv.field} = ${fv.value}');
        if (fv != fieldValueList!.last) {
          buffer.write(', ');
        }
      }
    }
    return buffer.toString();
  }

  String insert(String? table, {dynamic unique}) {
    final buffer = StringBuffer();
    if (!hasFieldValues) throw SqliteException(SqliteException.noFieldValues);
    final f = StringBuffer();
    final v = StringBuffer();
    for (final fv in fieldValueList!) {
      f.write(fv.field);
      v.write(fv.value);
      if (fv != fieldValueList!.last) {
        f.write(', ');
        v.write(', ');
      }
    }
    final fields = f.toString();
    final values = v.toString();
    if (unique != null) {
      buffer.write('INSERT INTO $table ($fields) VALUES ($values)');
      if (unique is String) {
        buffer.write(' ON CONFLICT ($unique) ');
      } else if (unique is List<String>) {
        final u = StringBuffer();
        for (final field in unique) {
          u.write(field);
          if (field != unique.last) {
            u.write(', ');
          }
        }
        buffer.write(' ON CONFLICT (${u.toString()}) ');
      }
      buffer.write('DO UPDATE SET $fieldValues');
    } else {
      buffer.write('INSERT OR IGNORE INTO $table ($fields) VALUES ($values)');
    }
    return buffer.toString();
  }

  String update(String? table, dynamic id) {
    if (!hasFieldValues) throw SqliteException(SqliteException.noFieldValues);
    return 'UPDATE $table SET $fieldValues WHERE ${SqliteStatement.id} = ${id.toString()}';
  }

  String updateWithConditions(String table) {
    if (!hasFieldValues) throw SqliteException(SqliteException.noFieldValues);
    if (!hasConditions) throw SqliteException(SqliteException.noConditions);
    return 'UPDATE $table SET $fieldValues WHERE $conditions';
  }

  String updateFromStatement(String? table) {
    final buffer = StringBuffer();
    if (!hasFieldValues) throw SqliteException(SqliteException.noFieldValues);
    buffer.write('UPDATE $table SET $fieldValues');
    if (hasConditions) {
      buffer.write(' WHERE $conditions');
    }
    return buffer.toString();
  }

  String delete(
    String table, [
    dynamic id,
  ]) {
    if (id != null) {
      return 'DELETE FROM $table WHERE ${SqliteStatement.id} = ${id.toString()}';
    }
    return 'DELETE FROM $table';
  }

  String deleteWithConditions(String table) {
    if (!hasConditions) throw SqliteException(SqliteException.noConditions);
    return 'DELETE FROM $table WHERE $conditions';
  }

  String createTable(String? table) {
    return 'CREATE TABLE IF NOT EXISTS $table (${getCommandFields(fieldList)})';
  }

  String createIndex(String idx, String table) {
    return 'CREATE INDEX IF NOT EXISTS $idx ON $table ($fields)';
  }

  String createTimeTrigger(String trg, String table) {
    if (hasFields) {
      for (final f in fieldList!) {
        if (f.withDateTrigger) {
          final fv = FieldValue(f.field, Value.dateNow);
          addFieldValue(fv);
        } else if (f.withTimeTrigger) {
          final fv = FieldValue(f.field, Value.timeNow);
          addFieldValue(fv);
        }
        addCondition(Condition.isNull(f.field));
      }
    }
    return '''CREATE TRIGGER IF NOT EXISTS $trg 
      AFTER INSERT ON $table 
      BEGIN
        UPDATE $table SET $fieldValues WHERE ${SqliteStatement.id} = NEW.id AND $conditions;
      END''';
  }

  String dropTable(String table) {
    return 'DROP TABLE IF EXISTS $table';
  }

  String dropIndex(String idx) {
    return 'DROP INDEX IF EXISTS $idx';
  }

  String dropTrigger(String trg) {
    return 'DROP TRIGGER IF EXISTS $trg';
  }

  String renameTable(String oldName, String newName) {
    return 'ALTER TABLE $oldName RENAME TO $newName';
  }

  String resetTable(String table) {
    return 'UPDATE SQLITE_SEQUENCE SET SEQ = 0 WHERE NAME =\'$table\'';
  }

  String addColumn(String table, Field field) {
    return 'ALTER TABLE $table ADD COLUMN ${field.asString()}';
  }

  String select(String table) {
    final query = SqliteQuery(
      select: fieldList,
      from: table,
      where: conditionList,
    );
    return query.build();
  }

  void addFieldValue(FieldValue fv) {
    _fieldValueList ??= [];
    _fieldValueList!.add(fv);
  }

  void add(SqliteModel entity) {
    if (entity is FieldValue) {
      addFieldValue(entity);
    } else if (entity is Condition) {
      addCondition(entity);
    } else if (entity is Field) {
      addField(entity);
    } else {
      throw SqliteException(SqliteException.invalidSqliteEntity);
    }
  }
}
