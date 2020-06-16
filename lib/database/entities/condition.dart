import 'package:codepan/database/entities/field.dart';
import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/sqlite_statement.dart';

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
  LIKE,
}

class Condition extends SQLiteEntity {
  List<Condition> orList;
  Operator _operator;
  String _start, _end;
  dynamic _value;

  String get start => _start;

  String get end => _end;

  Operator get operator => _operator;

  String get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SQLiteStatement.TRUE.toString()
            : SQLiteStatement.FALSE.toString();
      } else if (_value is String) {
        final text = _value as String;
        return '\'$text\'';
      } else if (_value is Field) {
        final field = _value as Field;
        return field.field;
      } else {
        return _value.toString();
      }
    }
    return SQLiteStatement.NULL;
  }

  bool get hasValue => _value != null;

  Condition(
    String _field,
    this._value, {
    String start,
    String end,
    Operator operator = Operator.EQUALS,
  }) : super(_field) {
    this._start = start;
    this._end = end;
    this._operator = operator;
  }

  Condition.or(this.orList) : super(null);

  String asString() {
    final type = hasValue && _value is Operator ? _value : operator;
    switch (type) {
      case Operator.EQUALS:
        return "$field = $value";
        break;
      case Operator.NOT_EQUALS:
        return "$field != $value";
        break;
      case Operator.GREATER_THAN:
        return "$field > $value";
        break;
      case Operator.LESS_THAN:
        return "$field < $value";
        break;
      case Operator.GREATER_THAN_OR_EQUALS:
        return "$field >= $value";
        break;
      case Operator.LESS_THAN_OR_EQUALS:
        return "$field <= $value";
        break;
      case Operator.BETWEEN:
        return "$field BETWEEN $start AND $end";
        break;
      case Operator.IS_NULL:
        return "$field IS NULL";
        break;
      case Operator.NOT_NULL:
        return "$field NOT NULL";
        break;
      case Operator.IS_EMPTY:
        return "$field = ''";
        break;
      case Operator.NOT_EMPTY:
        return "$field != ''";
        break;
      case Operator.LIKE:
        return "$field LIKE $value";
        break;
    }
    return null;
  }
}
