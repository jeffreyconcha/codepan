import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/entities/table.dart';
import 'package:codepan/database/sqlite_query.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';

enum Constraint {
  PRIMARY_KEY,
  FOREIGN_KEY,
  DEFAULT,
  UNIQUE,
}
enum DataType {
  INTEGER,
  TEXT,
  REAL,
  BLOB,
}

class Field extends SQLiteEntity {
  bool _collate, _isCount, _inUniqueGroup, _withDateTrigger, _withTimeTrigger;
  Constraint _constraint;
  DataType _type;
  dynamic _value;
  Table _table;
  Order _order;

  Constraint get constraint => _constraint;

  dynamic get value => _value;

  DataType get type => _type;

  Table get table => _table;

  Order get order => _order;

  bool get inUniqueGroup => _inUniqueGroup ?? false;

  bool get isCount => _isCount ?? false;

  bool get collate => _collate;

  bool get hasConstraint => _constraint != null;

  bool get hasDataType => _type != null;

  bool get isOrder => _order != null;

  bool get withDateTrigger => _withDateTrigger ?? false;

  bool get withTimeTrigger => _withTimeTrigger ?? false;

  bool get isForeignKey => _constraint == Constraint.FOREIGN_KEY;

  bool get isUnique => _constraint == Constraint.UNIQUE;

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
  }) : super(_field) {
    if (value != null) {
      this._constraint = Constraint.DEFAULT;
      if (value is int || value is bool) {
        this._type = DataType.INTEGER;
      } else if (value is double) {
        this._type = DataType.REAL;
      } else if (value is String) {
        this._type = DataType.TEXT;
      } else {
        this._type = DataType.BLOB;
      }
    } else {
      this._constraint = constraint;
      this._type = type;
    }
    this._value = value;
    this._inUniqueGroup = inUniqueGroup;
    this._withDateTrigger = withDateTrigger;
    this._withTimeTrigger = withTimeTrigger;
  }

  Field.asPrimaryKey([String field = SQLiteStatement.id]) : super(field) {
    this._constraint = Constraint.PRIMARY_KEY;
    this._type = DataType.INTEGER;
  }

  Field.asForeignKey(
    String field, {
    @required Table reference,
    bool inUniqueGroup = false,
  }) : super(field) {
    this._constraint = Constraint.FOREIGN_KEY;
    this._type = DataType.INTEGER;
    this._table = reference;
    this._inUniqueGroup = inUniqueGroup;
  }

  Field.asUnique(
    String field, {
    DataType type = DataType.INTEGER,
  }) : super(field) {
    this._constraint = Constraint.UNIQUE;
    this._type = type;
  }

  Field.asDate(
    String field, {
    bool withTrigger = false,
  }) : super(field) {
    this._type = DataType.TEXT;
    this._withDateTrigger = withTrigger;
  }

  Field.asTime(
    String field, {
    bool withTrigger = false,
  }) : super(field) {
    this._type = DataType.TEXT;
    this._withTimeTrigger = withTrigger;
  }

  Field.asUniqueGroup(
    String field, {
    Table reference,
    DataType type = DataType.INTEGER,
  }) : super(field) {
    this._type = type;
    this._inUniqueGroup = true;
    if (reference != null) {
      this._constraint = Constraint.FOREIGN_KEY;
      this._table = reference;
    }
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
          case Constraint.PRIMARY_KEY:
            buffer.write(' PRIMARY KEY NOT NULL');
            break;
          case Constraint.FOREIGN_KEY:
            buffer.write(' REFERENCES ${table.name}(${SQLiteStatement.id})');
            break;
          case Constraint.UNIQUE:
            buffer.write(' UNIQUE');
            break;
          case Constraint.DEFAULT:
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
}
