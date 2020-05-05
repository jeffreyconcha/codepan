import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/sqlite_query.dart';

class Condition extends SQLiteEntity {
  String start, end;
  List<Condition> orList;
  Operator operator;
  dynamic _value;

  String get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SQLiteQuery.TRUE.toString()
            : SQLiteQuery.FALSE.toString();
      } else if (_value is String) {
        return "'$value'";
      } else {
        return _value.toString();
      }
    } else {
      return SQLiteQuery.NULL;
    }
  }

  Condition(
    String _field,
    this._value, {
    this.operator = Operator.EQUALS,
    this.start,
    this.end,
  }) : super(_field);

  Condition.or(this.orList) : super(null);

  String asString() {
    switch (operator) {
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
