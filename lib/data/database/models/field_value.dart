import 'package:codepan/data/database/models/sqlite_model.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:inflection3/inflection3.dart';

enum SqliteTime {
  dateNow('date(\'now\', \'localtime\')'),
  timeNow('time(\'now\', \'localtime\')');

  final String value;

  const SqliteTime(this.value);
}

class FieldValue extends SqliteModel {
  final dynamic _value;

  String get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SqliteStatement.trueValue.toString()
            : SqliteStatement.falseValue.toString();
      } else if (_value is String) {
        return "'${_value.replaceAll("'", "''")}'";
      } else if (_value is SqliteTime) {
        return (_value as SqliteTime).value;
      } else if (PanUtils.isEnum(_value)) {
        final value = PanUtils.enumValue(_value);
        return '\'${SNAKE_CASE.convert(value)}\'';
      } else {
        return _value.toString();
      }
    } else {
      return SqliteStatement.nullValue;
    }
  }

  dynamic get rawValue {
    if (_value != null) {
      if (_value is bool) {
        return _value ? SqliteStatement.trueValue : SqliteStatement.falseValue;
      }
      return _value;
    }
    return null;
  }

  const FieldValue(
    String field,
    dynamic value,
  )   : _value = value,
        super(field: field);
}
