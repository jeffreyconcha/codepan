import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/sqlite_statement.dart';

class FieldValue extends SQLiteEntity {
  final dynamic _value;

  String get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SQLiteStatement.TRUE.toString()
            : SQLiteStatement.FALSE.toString();
      } else if (_value is String) {
        return "'${_value.replaceAll("'", "''")}'";
      } else {
        return _value.toString();
      }
    } else {
      return SQLiteStatement.NULL;
    }
  }

  dynamic get rawValue {
    if (_value != null) {
      if (_value is bool) {
        return _value ? SQLiteStatement.TRUE : SQLiteStatement.FALSE;
      }
      return _value;
    }
    return null;
  }

  FieldValue(String _field, this._value) : super(_field);
}
