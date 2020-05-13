import 'package:codepan/database/entities/condition.dart';
import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/entities/field_value.dart';
import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/sqlite_exception.dart';

enum Constraint {
  PRIMARY_KEY,
  FOREIGN_KEY,
  DEFAULT,
  UNIQUE,
}
enum DataType {
  INTEGER,
  TEXT,
}
enum Operator {
  EQUALS,
  NOT_EQUALS,
  GREATER_THAN,
  LESS_THAN,
  GREATER_THAN_OR_EQUALS,
  LESS_THAN_OR_EQUALS,
  BETWEEN,
  IS_NULL,
  NOT_NULL,
  IS_EMPTY,
  NOT_EMPTY,
  LIKE
}

class SQLiteQuery {
  static const String ID = "id";
  static const String TABLE_SUFFIX = "_tb";
  static const String INDEX_SUFFIX = "_idx";
  static const String NULL = "NULL";
  static const int TRUE = 1;
  static const int FALSE = 0;
  List<FieldValue> _fieldValueList;
  List<Condition> _conditionList;
  List<Field> _fieldList;

  SQLiteQuery();

  SQLiteQuery.fromMap(Map<String, dynamic> map) {
    map?.forEach((key, value) {
      final fv = FieldValue(key, value);
      addFieldValue(fv);
    });
  }

  SQLiteQuery.fromList(List<dynamic> list) {
    list?.forEach((field) {
      if (field is Field) {
        addField(field);
      } else if (field is String) {
        final f = Field(field);
        addField(f);
      }
    });
  }

  void withConditions(dynamic params) {
    if (params is List<Condition>) {
      _conditionList?.addAll(params);
    } else if (params is Map<String, dynamic>) {
      params.forEach((key, value) {
        final c = Condition(key, value);
        addCondition(c);
      });
    }
  }

  List<FieldValue> get fieldValueList => _fieldValueList;

  List<Condition> get conditionList => _conditionList;

  List<Field> get fieldList => _fieldList;

  bool get hasFields => _fieldList?.isNotEmpty;

  bool get hasFieldValues => _fieldValueList?.isNotEmpty;

  bool get hasConditions => _conditionList?.isNotEmpty;

  SQLiteQuery clearAll() {
    if (hasConditions) _conditionList.clear();
    if (hasFieldValues) _fieldValueList.clear();
    if (hasFields) _fieldList.clear();
    return this;
  }

  void clearFieldList() {
    if (hasFields) _fieldList.clear();
  }

  void clearFieldValueList() {
    if (hasFieldValues) _fieldValueList.clear();
  }

  void clearConditionList() {
    if (hasConditions) _conditionList.clear();
  }

  Map<String, dynamic> get map {
    if (hasFieldValues) {
      var map = new Map<String, dynamic>();
      for (var fv in fieldValueList) {
        map[fv.field] = fv.rawValue;
      }
      return map;
    }
    return null;
  }

  String get fields {
    var buffer = new StringBuffer();
    if (hasFields) {
      for (var f in fieldList) {
        buffer.write(f.field);
        if (fieldList.indexOf(f) < fieldList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String get tableFields {
    var buffer = new StringBuffer();
    if (fieldList != null) {
      for (var field in fieldList) {
        buffer.write(field.asString());
        if (fieldList.indexOf(field) < fieldList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String get fieldValues {
    var buffer = new StringBuffer();
    if (hasFieldValues) {
      for (var fv in fieldValueList) {
        var value = fv.value != null ? fv.value : NULL;
        buffer.write("${fv.field} = $value");
        if (fieldValueList.indexOf(fv) < fieldValueList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String get conditions {
    var buffer = new StringBuffer();
    if (hasConditions) {
      for (var c in conditionList) {
        var operator = c.operator;
        if (operator != null) {
          buffer.write(c.asString());
        } else {
          var orList = c.orList;
          if (orList != null && orList.isNotEmpty) {
            var b = new StringBuffer();
            for (Condition c in orList) {
              b.write(c.asString());
              if (orList.indexOf(c) < orList.length - 1) {
                b.write(" OR ");
              }
            }
            buffer.write("(${b.toString()})");
          }
        }
        if (conditionList.indexOf(c) < conditionList.length - 1) {
          buffer.write(" AND ");
        }
      }
    }
    return buffer.toString();
  }

  String insert(String table) {
    if (!hasFieldValues) throw SQLiteException(SQLiteException.NO_FIELD_VALUES);
    var f = new StringBuffer();
    var v = new StringBuffer();
    for (var fv in fieldValueList) {
      f.write(fv.field);
      v.write(fv.value);
      if (fieldValueList.indexOf(fv) < fieldValueList.length - 1) {
        f.write(", ");
        v.write(", ");
      }
    }
    return "INSERT INTO $table (${f.toString()}) VALUES (${v.toString()})";
  }

  String update(String table, dynamic id) {
    if (!hasFieldValues) throw SQLiteException(SQLiteException.NO_FIELD_VALUES);
    return "UPDATE $table SET $fieldValues WHERE $ID = ${id.toString()}";
  }

  String updateWithConditions(String table) {
    if (!hasFieldValues) throw SQLiteException(SQLiteException.NO_FIELD_VALUES);
    if (!hasConditions) throw SQLiteException(SQLiteException.NO_CONDITIONS);
    return "UPDATE $table SET $fieldValues WHERE $conditions";
  }

  String delete(String table, dynamic id) {
    return "DELETE FROM $table WHERE $ID = ${id.toString()}";
  }

  String deleteWithConditions(String table) {
    if (!hasConditions) throw SQLiteException(SQLiteException.NO_CONDITIONS);
    return "DELETE FROM $table WHERE $conditions";
  }

  String createTable(String table) {
    return "CREATE TABLE IF NOT EXISTS $table ($tableFields)";
  }

  String createIndex(String idx, String table) {
    return "CREATE INDEX IF NOT EXISTS $idx ON $table ($fields)";
  }

  String dropTable(String table) {
    return "DROP TABLE IF EXISTS $table";
  }

  String dropIndex(String idx) {
    return "DROP INDEX IF EXISTS $idx";
  }

  String renameTable(String oldName, String newName) {
    return "ALTER TABLE $oldName RENAME TO $newName";
  }

  String resetTable(String table) {
    return "UPDATE SQLITE_SEQUENCE SET SEQ = 0 WHERE NAME ='$table'";
  }

  String addColumn(String table, Field field) {
    if (field != null) {
      return "ALTER TABLE $table ADD COLUMN ${field.asString()}";
    }
    return null;
  }

  void addField(Field f) {
    _fieldList ??= [];
    _fieldList.add(f);
  }

  void addCondition(Condition c) {
    _conditionList ??= [];
    _conditionList.add(c);
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
      throw SQLiteException(SQLiteException.INVALID_SQLITE_ENTITY);
    }
  }
}
