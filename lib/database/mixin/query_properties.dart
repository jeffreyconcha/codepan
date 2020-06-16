import 'package:codepan/database/entities/condition.dart';
import 'package:codepan/database/entities/field.dart';

mixin QueryProperties {
  List<Condition> _conditionList;
  List<Field> _fieldList;

  List<Condition> get conditionList => _conditionList;

  List<Field> get fieldList => _fieldList;

  bool get hasFields => _fieldList != null && fieldList.isNotEmpty;

  bool get hasConditions => _conditionList != null && _conditionList.isNotEmpty;

  void clearFieldList() {
    if (hasFields) _fieldList.clear();
  }

  void clearConditionList() {
    if (hasConditions) _conditionList.clear();
  }

  String get fields => getFields(fieldList);

  String get fieldsWithAlias => getFields(fieldList, withAlias: true);

  String getFields(List<Field> fieldList, {bool withAlias = false}) {
    final buffer = StringBuffer();
    if (fieldList != null) {
      for (final f in fieldList) {
        buffer.write(f.field);
        if (withAlias) {
          buffer.write(' as \'${f.field}\'');
        }
        if (fieldList.indexOf(f) < fieldList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String getFieldsAsString(List<Field> fieldList, {bool withAlias = false}) {
    final buffer = StringBuffer();
    if (fieldList != null) {
      for (final f in fieldList) {
        buffer.write(f.field);
        if (withAlias) {
          buffer.write(' as \'${f.field}\'');
        }
        if (fieldList.indexOf(f) < fieldList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String get conditions {
    final buffer = StringBuffer();
    if (hasConditions) {
      for (final c in conditionList) {
        final operator = c.operator;
        if (operator != null) {
          buffer.write(c.asString());
        } else {
          final orList = c.orList;
          if (orList != null && orList.isNotEmpty) {
            final b = StringBuffer();
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

  void addField(Field f, {String alias}) {
    f.setAlias(alias);
    _fieldList ??= [];
    _fieldList.add(f);
  }

  void addFields(List<dynamic> list, {String alias}) {
    list?.forEach((field) {
      if (field is Field) {
        addField(field, alias: alias);
      } else if (field is String) {
        final f = Field(field);
        addField(f, alias: alias);
      }
    });
  }

  void addCondition(Condition c, {String alias}) {
    if (c.hasValue) {
      c.setAlias(alias);
      _conditionList ??= [];
      _conditionList.add(c);
    }
  }

  void addConditions(dynamic conditions, {String alias}) {
    if (conditions is Map<String, dynamic>) {
      conditions?.forEach((key, value) {
        final c = Condition(key, value);
        addCondition(c, alias: alias);
      });
    } else if (conditions is List<Condition>) {
      conditions.forEach((condition) {
        addCondition(condition, alias: alias);
      });
    }
  }

  String getCommandFields(List<Field> fieldList) {
    final buffer = StringBuffer();
    if (fieldList != null) {
      for (final field in fieldList) {
        buffer.write(field.asString());
        if (fieldList.indexOf(field) < fieldList.length - 1) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }
}
