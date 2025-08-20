import 'package:codepan/data/database/models/field.dart';
import 'package:codepan/data/database/models/sqlite_model.dart';
import 'package:codepan/data/database/models/table.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/data/models/entities/transaction.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:inflection3/inflection3.dart';

enum Operator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterThanOrEquals,
  lessThanOrEquals,
  between,
  isNull,
  notNull,
  isEmpty,
  notEmpty,
  like,
  inside,
  notInside,
}

enum Scan {
  start,
  end,
  between,
}

class Condition extends SqliteModel {
  final dynamic _value, _start, _end;
  final List<Condition>? andList;
  final List<Condition>? orList;
  final Operator? _operator;
  final Scan? _scan;

  Operator? get operator {
    if (_value is Operator) {
      return _value;
    }
    return _operator;
  }

  Scan? get scan {
    if (operator == Operator.like) {
      return _scan;
    }
    return null;
  }

  String get start => _getValue(_start);

  String get end => _getValue(_end);

  bool get hasOrList => orList?.isNotEmpty ?? false;

  bool get hasAndList => andList?.isNotEmpty ?? false;

  String? get value {
    if (_value != null) {
      if (_value is bool) {
        return _value
            ? SqliteStatement.trueValue.toString()
            : SqliteStatement.falseValue.toString();
      } else if (_value is String) {
        final text = _value as String?;
        if (scan != null) {
          switch (scan!) {
            case Scan.start:
              return '\'%$text\'';
            case Scan.end:
              return '\'$text%\'';
            case Scan.between:
              return '\'%$text%\'';
          }
        }
        return '\'$text\'';
      } else if (_value is Field) {
        final field = _value as Field;
        return field.field;
      } else if (_value is SqliteQuery) {
        final query = _value as SqliteQuery;
        return query.build();
      } else if (_value is List<dynamic>) {
        final buffer = StringBuffer();
        final list = _value as List<dynamic>?;
        for (final v in _value) {
          if (v is TransactionData) {
            buffer.write(v.id);
          } else if (PanUtils.isEnum(v)) {
            final value = PanUtils.enumValue(v);
            buffer.write('\'${SNAKE_CASE.convert(value)}\'');
          } else {
            buffer.write('\'${v.toString()}\'');
          }
          if (v != list!.last) {
            buffer.write(',');
          }
        }
        return buffer.toString();
      } else if (PanUtils.isEnum(_value)) {
        final value = PanUtils.enumValue(_value);
        return '\'${SNAKE_CASE.convert(value)}\'';
      } else {
        return _value.toString();
      }
    }
    return SqliteStatement.nullValue;
  }

  List<Operator> get _noValueOperators {
    return [
      Operator.between,
      Operator.isNull,
      Operator.notNull,
      Operator.isEmpty,
      Operator.notEmpty,
    ];
  }

  bool get _isNoValueOperator {
    return operator != null && _noValueOperators.contains(operator);
  }

  bool get hasValue => _value != null;

  bool get isValid => hasValue || _isNoValueOperator;

  const Condition(
    String field,
    dynamic value, {
    super.table,
    super.useRawField,
    dynamic start,
    dynamic end,
    Operator? operator = Operator.equals,
    Scan? scan = Scan.between,
    this.orList,
    this.andList,
  })  : _value = value,
        _start = start,
        _end = end,
        _operator = operator,
        _scan = scan,
        super(
          field: field,
        );

  @override
  Condition copyWith({
    String? field,
    dynamic value,
    Table? table,
    bool? useRawField,
    dynamic start,
    dynamic end,
    Operator? operator,
    Scan? scan,
    List<Condition>? orList,
    List<Condition>? andList,
  }) {
    return Condition(
      field ?? super.field,
      value ?? _value,
      table: table ?? super.table,
      useRawField: useRawField ?? super.useRawField,
      start: start ?? _start,
      end: end ?? _end,
      operator: operator ?? _operator,
      scan: scan ?? _scan,
      orList: orList ?? this.orList,
      andList: andList ?? this.andList,
    );
  }

  factory Condition.or(List<Condition> orList) {
    return Condition(
      '',
      null,
      orList: orList,
    );
  }

  factory Condition.and(List<Condition> andList) {
    return Condition(
      '',
      null,
      andList: andList,
    );
  }

  factory Condition.equals(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.equals,
    );
  }

  factory Condition.notEquals(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.notEquals,
    );
  }

  factory Condition.greaterThan(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.greaterThan,
    );
  }

  factory Condition.lessThan(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.lessThan,
    );
  }

  factory Condition.greaterThanOrEquals(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.greaterThanOrEquals,
    );
  }

  factory Condition.lessThanOrEquals(
    String field,
    dynamic value,
  ) {
    return Condition(
      field,
      value,
      operator: Operator.lessThanOrEquals,
    );
  }

  factory Condition.between(
    String field,
    dynamic start,
    dynamic end,
  ) {
    return Condition(
      field,
      null,
      start: start,
      end: end,
      operator: Operator.between,
    );
  }

  factory Condition.isNull(String field) {
    return Condition(
      field,
      null,
      operator: Operator.isNull,
    );
  }

  factory Condition.notNull(String field) {
    return Condition(
      field,
      null,
      operator: Operator.notNull,
    );
  }

  factory Condition.isEmpty(String field) {
    return Condition(
      field,
      null,
      operator: Operator.isEmpty,
    );
  }

  factory Condition.notEmpty(String field) {
    return Condition(
      field,
      null,
      operator: Operator.notEmpty,
    );
  }

  factory Condition.like(
    String field,
    String value, {
    Scan scan = Scan.between,
  }) {
    return Condition(
      field,
      value,
      operator: Operator.like,
      scan: scan,
    );
  }

  factory Condition.inQuery(
    String field,
    SqliteQuery query,
  ) {
    return Condition(
      field,
      query,
      operator: Operator.inside,
    );
  }

  factory Condition.notInQuery(
    String field,
    SqliteQuery query,
  ) {
    return Condition(
      field,
      query,
      operator: Operator.notInside,
    );
  }

  factory Condition.inList(
    String field,
    List<dynamic> list,
  ) {
    return Condition(
      field,
      list,
      operator: Operator.inside,
    );
  }

  factory Condition.notInList(
    String field,
    List<dynamic> list,
  ) {
    return Condition(
      field,
      list,
      operator: Operator.notInside,
    );
  }

  factory Condition.isTrue(String field) {
    return Condition(field, true);
  }

  factory Condition.isFalse(String field) {
    return Condition(field, false);
  }

  String? asString() {
    if (hasOrList) {
      final b = StringBuffer();
      for (final condition in orList!) {
        b.write(condition.asString());
        if (condition != orList!.last) {
          b.write(" OR ");
        }
      }
      return '(${b.toString()})';
    } else if (hasAndList) {
      final b = StringBuffer();
      for (final condition in andList!) {
        b.write(condition.asString());
        if (condition != andList!.last) {
          b.write(" AND ");
        }
      }
      return '(${b.toString()})';
    } else {
      final type = hasValue && _value is Operator ? _value : operator;
      switch (type) {
        case Operator.equals:
          return "$field = $value";
        case Operator.notEquals:
          return "$field != $value";
        case Operator.greaterThan:
          return "$field > $value";
        case Operator.lessThan:
          return "$field < $value";
        case Operator.greaterThanOrEquals:
          return "$field >= $value";
        case Operator.lessThanOrEquals:
          return "$field <= $value";
        case Operator.between:
          return "$field BETWEEN $start AND $end";
        case Operator.isNull:
          return "$field IS NULL";
        case Operator.notNull:
          return "$field NOT NULL";
        case Operator.isEmpty:
          return "$field = ''";
        case Operator.notEmpty:
          return "$field != ''";
        case Operator.like:
          return "$field LIKE $value";
        case Operator.inside:
          return "$field IN ($value)";
        case Operator.notInside:
          return "$field NOT IN ($value)";
      }
    }
    return null;
  }

  String _getValue(dynamic input) {
    if (input != null) {
      if (input is String) {
        return '\'${input.toString()}\'';
      } else if (input is Field) {
        return input.field;
      }
    }
    return input.toString();
  }
}
