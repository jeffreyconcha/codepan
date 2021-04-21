import 'package:codepan/database/models/sqlite_model.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:inflection3/inflection3.dart';

enum Value {
  dateNow,
  timeNow,
}

class FieldValue extends SQLiteModel {
  final dynamic _value;

  String get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SQLiteStatement.trueValue.toString()
            : SQLiteStatement.falseValue.toString();
      } else if (_value is String) {
        return "'${_value.replaceAll("'", "''")}'";
      } else if (_value is Value) {
        if (_value == Value.dateNow) {
          return 'date(\'now\', \'localtime\')';
        } else {
          return 'time(\'now\', \'localtime\')';
        }
      } else if (PanUtils.isEnum(_value)) {
        final value = PanUtils.enumValue(_value);
        return '\'${SNAKE_CASE.convert(value)}\'';
      } else {
        return _value.toString();
      }
    } else {
      return SQLiteStatement.nullValue;
    }
  }

  dynamic get rawValue {
    if (_value != null) {
      if (_value is bool) {
        return _value ? SQLiteStatement.trueValue : SQLiteStatement.falseValue;
      }
      return _value;
    }
    return null;
  }

  FieldValue(String? _field, this._value) : super(_field);
}
