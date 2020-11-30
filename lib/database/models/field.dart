import 'package:codepan/database/models/sqlite_model.dart';
import 'package:codepan/database/models/table.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';

enum Constraint {
  primaryKey,
  foreignKey,
  defaultField,
  unique,
}
enum DataType {
  integer,
  text,
  real,
  blob,
}

class Field extends SQLiteModel {
  bool _collate,
      _isCount,
      _inUniqueGroup,
      _withDateTrigger,
      _withTimeTrigger,
      _isIndex;
  Constraint _constraint;
  DataType _type;
  dynamic _value;
  Table _reference;
  Order _order;

  Constraint get constraint => _constraint;

  dynamic get value => _value;

  DataType get type => _type;

  Table get reference => _reference;

  Order get order => _order;

  bool get inUniqueGroup => _inUniqueGroup ?? false;

  bool get isCount => _isCount ?? false;

  bool get collate => _collate;

  bool get hasConstraint => _constraint != null;

  bool get hasDataType => _type != null;

  bool get isOrder => _order != null;

  bool get withDateTrigger => _withDateTrigger ?? false;

  bool get withTimeTrigger => _withTimeTrigger ?? false;

  bool get isIndex => _isIndex ?? false;

  bool get isForeignKey => _constraint == Constraint.foreignKey;

  bool get isUnique => _constraint == Constraint.unique;

  String get dataType => hasDataType ? _type.toString().split('.').last : null;

  String get defaultValue {
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
    DataType type,
    Constraint constraint,
    dynamic value,
    bool inUniqueGroup = false,
    bool withDateTrigger = false,
    bool withTimeTrigger = false,
    bool isIndex = false,
  }) : super(_field) {
    if (value != null) {
      this._constraint = Constraint.defaultField;
      this._type = _getDataType(value);
    } else {
      this._constraint = constraint;
      this._type = type;
    }
    this._value = value;
    this._inUniqueGroup = inUniqueGroup;
    this._withDateTrigger = withDateTrigger;
    this._withTimeTrigger = withTimeTrigger;
    this._isIndex = isIndex;
  }

  Field.asColumn(
    String field, {
    @required DataType type,
  }) : super(field) {
    this._type = type;
  }

  Field.asPrimaryKey([String field = SQLiteStatement.id]) : super(field) {
    this._constraint = Constraint.primaryKey;
    this._type = DataType.integer;
  }

  Field.asForeignKey(
    String field, {
    @required Table reference,
    bool inUniqueGroup = false,
  }) : super(field) {
    this._constraint = Constraint.foreignKey;
    this._type = DataType.integer;
    this._reference = reference;
    this._inUniqueGroup = inUniqueGroup;
  }

  Field.asUnique(
    String field, {
    DataType type = DataType.integer,
  }) : super(field) {
    this._constraint = Constraint.unique;
    this._type = type;
  }

  Field.asDefault(
    String field, {
    @required dynamic value,
  }) : super(field) {
    this._constraint = Constraint.defaultField;
    this._type = _getDataType(value);
  }

  Field.asDate(
    String field, {
    bool withTrigger = false,
  }) : super(field) {
    this._type = DataType.text;
    this._withDateTrigger = withTrigger;
  }

  Field.asTime(
    String field, {
    bool withTrigger = false,
  }) : super(field) {
    this._type = DataType.text;
    this._withTimeTrigger = withTrigger;
  }

  Field.asUniqueGroup(
    String field, {
    Table reference,
    DataType type = DataType.integer,
  }) : super(field) {
    this._type = type;
    this._inUniqueGroup = true;
    if (reference != null) {
      this._constraint = Constraint.foreignKey;
      this._reference = reference;
    }
  }

  Field.asIndex(
    String field, {
    DataType type = DataType.integer,
    Constraint constraint,
  }) : super(field) {
    this._type = type;
    this._isIndex = true;
    this._constraint = constraint;
  }

  Field.asOrder({
    @required String field,
    Order order = Order.ASC,
    bool collate = false,
  }) : super(field) {
    this._order = order;
    this._collate = collate;
  }

  Field.asCount(String field) : super(field) {
    this._isCount = true;
  }

  String asString() {
    final buffer = new StringBuffer();
    if (hasDataType) {
      buffer.write('$field $dataType');
      if (hasConstraint) {
        switch (constraint) {
          case Constraint.primaryKey:
            buffer.write(' PRIMARY KEY NOT NULL');
            break;
          case Constraint.foreignKey:
            buffer
                .write(' REFERENCES ${reference.name}(${SQLiteStatement.id})');
            break;
          case Constraint.unique:
            buffer.write(' UNIQUE');
            break;
          case Constraint.defaultField:
            buffer.write(' DEFAULT $defaultValue');
            break;
        }
      }
    } else {
      if (isOrder) {
        buffer.write('$field');
        if (collate) {
          buffer.write(' COLLATE NOCASE');
        }
        final direction = order.toString().split('.').last;
        buffer.write(' $direction');
      } else if (isCount) {
        buffer.write('COUNT($field)');
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
}
