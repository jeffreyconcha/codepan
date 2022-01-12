import 'package:codepan/data/database/models/sqlite_model.dart';
import 'package:codepan/data/database/models/table.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/extensions/dynamic.dart';

enum Constraint {
  primaryKey,
  foreignKey,
  defaultField,
  unique,
  dateFormatted,
  timeFormatted,
  notNull,
}
enum Function {
  count,
  sum,
}
enum DataType {
  integer,
  text,
  real,
  blob,
}

class Field extends SQLiteModel {
  bool? _collate, _inUniqueGroup, _withDateTrigger, _withTimeTrigger, _isIndex;
  List<Constraint>? _constraintList;
  Function? _function;
  DataType? _type;
  dynamic _value;
  Table? _reference;
  Order? _order;

  dynamic get value => _value;

  DataType? get type => _type;

  Table? get reference => _reference;

  Order? get order => _order;

  bool get inUniqueGroup => _inUniqueGroup ?? false;

  bool get isFunction => _function != null;

  bool? get collate => _collate;

  bool get hasConstraints =>
      _constraintList != null && _constraintList!.isNotEmpty;

  bool get hasDataType => _type != null;

  bool get isOrder => _order != null;

  bool get withDateTrigger => _withDateTrigger ?? false;

  bool get withTimeTrigger => _withTimeTrigger ?? false;

  bool get isIndex => _isIndex ?? false;

  bool get isForeignKey => hasConstraint(Constraint.foreignKey);

  bool get isUnique => hasConstraint(Constraint.unique);

  String? get dataType => hasDataType ? _type.toString().split('.').last : null;

  String? get defaultValue {
    if (_value != null) {
      if (_value is bool) {
        return _value ? '1' : '0';
      } else {
        return _value.toString();
      }
    }
    return null;
  }

  Field(
    String _field, {
    DataType? type,
    Constraint? constraint,
    dynamic value,
    bool inUniqueGroup = false,
    bool withDateTrigger = false,
    bool withTimeTrigger = false,
    bool isIndex = false,
  }) : super(_field) {
    if (value != null) {
      _addConstraint(Constraint.defaultField);
      this._type = _getDataType(value);
    } else {
      _addConstraint(constraint);
      this._type = type;
    }
    this._value = value;
    this._inUniqueGroup = inUniqueGroup;
    this._withDateTrigger = withDateTrigger;
    this._withTimeTrigger = withTimeTrigger;
    this._isIndex = isIndex;
  }

  Field.column(
    String field, {
    required DataType type,
    bool inUniqueGroup = false,
  }) : super(field) {
    this._type = type;
    this._inUniqueGroup = inUniqueGroup;
  }

  Field.primaryKey([String field = SQLiteStatement.id]) : super(field) {
    _addConstraint(Constraint.primaryKey);
    this._type = DataType.integer;
  }

  Field.foreignKey(
    String field, {
    required Table at,
    bool inUniqueGroup = false,
  }) : super(field) {
    _addConstraint(Constraint.foreignKey);
    this._type = DataType.integer;
    this._reference = at;
    this._inUniqueGroup = inUniqueGroup;
  }

  Field.unique(
    String field, {
    DataType type = DataType.integer,
  }) : super(field) {
    _addConstraint(Constraint.unique);
    this._type = type;
  }

  Field.defaultValue(
    String field, {
    required dynamic value,
    bool inUniqueGroup = false,
  }) : super(field) {
    _addConstraint(Constraint.defaultField);
    this._type = _getDataType(value);
    this._inUniqueGroup = inUniqueGroup;
    this._value = value;
  }

  Field.autoDate(String field) : super(field) {
    _addConstraint(Constraint.dateFormatted);
    this._type = DataType.text;
    this._withDateTrigger = true;
  }

  Field.autoTime(String field) : super(field) {
    _addConstraint(Constraint.timeFormatted);
    this._type = DataType.text;
    this._withTimeTrigger = true;
  }

  Field.uniqueDate(String field) : super(field) {
    _addConstraint(Constraint.unique);
    _addConstraint(Constraint.dateFormatted);
    this._type = DataType.text;
  }

  Field.uniqueTime(String field) : super(field) {
    _addConstraint(Constraint.unique);
    _addConstraint(Constraint.timeFormatted);
    this._type = DataType.text;
  }

  Field.date(String field) : super(field) {
    _addConstraint(Constraint.dateFormatted);
    this._type = DataType.text;
  }

  Field.time(String field) : super(field) {
    _addConstraint(Constraint.timeFormatted);
    this._type = DataType.text;
  }

  /// Shorthand for instantiating foreign keys. <br/><br/>
  /// Note: Must only be used in queries.
  Field.reference({
    required String field,
    required Table reference,
  }) : super(field) {
    _addConstraint(Constraint.foreignKey);
    this._reference = reference;
  }

  Field.index(
    String field, {
    DataType type = DataType.integer,
    Constraint? constraint,
  }) : super(field) {
    this._type = type;
    this._isIndex = true;
    _addConstraint(constraint);
  }

  Field.order({
    required String field,
    Order order = Order.ascending,
    bool collate = false,
  }) : super(field) {
    this._order = order;
    this._collate = collate;
  }

  Field.function(
    String field, {
    required Function function,
  }) : super(field) {
    this._function = function;
  }

  Field.countOf(String field) : super(field) {
    this._function = Function.count;
  }

  Field.sumOf(String field) : super(field) {
    this._function = Function.sum;
  }

  /// Short for "<b>Unique Group</b>" <br/>
  /// Call this method if you want this field to be included in the unique group. <br/>
  /// If the same record has the same unique group fields it will update the
  /// existing record instead of inserting new record thus eliminating duplicates.<br/>
  /// Will only be applied to a non-unique constraint.
  void ug() {
    if (hasConstraints && !_constraintList!.contains(Constraint.unique)) {
      this._inUniqueGroup = true;
    }
  }

  String asString() {
    final buffer = new StringBuffer();
    if (hasDataType) {
      buffer.write('$field $dataType');
      if (hasConstraints) {
        for (final constraint in _constraintList!) {
          switch (constraint) {
            case Constraint.primaryKey:
              buffer.write(' PRIMARY KEY NOT NULL');
              break;
            case Constraint.foreignKey:
              buffer.write(
                  ' REFERENCES ${reference!.name}(${SQLiteStatement.id})');
              break;
            case Constraint.unique:
              buffer.write(' UNIQUE');
              break;
            case Constraint.defaultField:
              buffer.write(' DEFAULT $defaultValue');
              break;
            case Constraint.dateFormatted:
              buffer.write(' CHECK ($field IS DATE($field) OR $field = \'0000-00-00\')');
              break;
            case Constraint.timeFormatted:
              buffer.write(' CHECK ($field IS TIME($field))');
              break;
            case Constraint.notNull:
              buffer.write(' NOT NULL');
              break;
          }
        }
      }
    } else {
      if (isOrder) {
        buffer.write('$field');
        if (collate!) {
          buffer.write(' COLLATE NOCASE');
        }
        final value = order.enumValue;
        final direction = value.replaceAll('ending', '').toUpperCase();
        buffer.write(' $direction');
      } else if (isFunction) {
        switch (_function) {
          case Function.count:
            buffer.write('COUNT($field)');
            break;
          case Function.sum:
            buffer.write('SUM($field)');
            break;
          default:
            break;
        }
      }
    }
    return buffer.toString();
  }

  DataType _getDataType(dynamic value) {
    if (value is int || value is bool) {
      return DataType.integer;
    } else if (value is double) {
      return DataType.real;
    } else if (value is String) {
      return DataType.text;
    } else {
      return DataType.blob;
    }
  }

  bool hasConstraint(Constraint constraint) {
    if (hasConstraints) {
      return _constraintList!.contains(constraint);
    }
    return false;
  }

  void _addConstraint(Constraint? constraint) {
    if (constraint != null) {
      _constraintList ??= [];
      _constraintList!.add(constraint);
    }
  }
}
