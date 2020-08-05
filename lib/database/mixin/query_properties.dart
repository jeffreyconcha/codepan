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
      for (final field in fieldList) {
        if (!field.isCount) {
          buffer.write(field.field);
        } else {
          buffer.write(field.asString());
        }
        if (withAlias) {
          if (!field.isCount) {
            buffer.write(' as \'${field.field}\'');
          } else {
            buffer.write(' as \'${field.asString()}\'');
          }
        }
        if (field != fieldList.last) {
          buffer.write(", ");
        }
      }
    }
    return buffer.toString();
  }

  String get conditions {
    final buffer = StringBuffer();
    if (hasConditions) {
      for (final condition in conditionList) {
        final operator = condition.operator;
        if (operator != null) {
          buffer.write(condition.asString());
        } else {
          if (condition.hasOrList) {
            final b = StringBuffer();
            final orList = condition.orList;
            for (final condition in orList) {
              b.write(condition.asString());
              if (condition != orList.last) {
                b.write(" OR ");
              }
            }
            buffer.write("(${b.toString()})");
          }
        }
        if (condition != conditionList.last) {
          buffer.write(" AND ");
        }
      }
    }
    return buffer.toString();
  }

  void addField(Field f, {String alias}) {
    if (f != null) {
      f.setAlias(alias);
      _fieldList ??= [];
      _fieldList.add(f);
    }
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
    if (c != null) {
      if (c.isValid) {
        c.setAlias(alias);
        _conditionList ??= [];
        _conditionList.add(c);
      } else if (c.hasOrList) {
        _conditionList ??= [];
        _conditionList.add(c);
      }
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
      final uniqueList = <String>[];
      for (final field in fieldList) {
        buffer.write(field.asString());
        if (field != fieldList.last) {
          buffer.write(", ");
        }
        if (field.inUniqueGroup) {
          uniqueList.add(field.field);
        }
      }
      if (uniqueList.isNotEmpty) {
        buffer.write(', UNIQUE (');
        for (final field in uniqueList) {
          buffer.write(field);
          if (field != uniqueList.last) {
            buffer.write(", ");
          } else {
            buffer.write(')');
          }
        }
      }
    }
    return buffer.toString();
  }
}
