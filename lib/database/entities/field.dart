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
}

class Field extends SQLiteEntity {
  Constraint _constraint;
  DataType _type;
  dynamic _value;
  Table _table;
  Order _order;
  bool _collate;

  Constraint get constraint => _constraint;

  dynamic get value => _value;

  DataType get type => _type;

  Table get table => _table;

  Order get order => _order;

  bool get collate => _collate;

  bool get hasConstraint => _constraint != null;

  bool get hasDataType => _type != null;

  bool get hasOrder => _order != null;

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

  Field(String _field, {DataType type, Constraint constraint, dynamic value})
      : super(_field) {
    if (value != null) {
      this._constraint = Constraint.DEFAULT;
      this._type =
          _value is int || _value is bool ? DataType.INTEGER : DataType.TEXT;
    } else {
      this._constraint = constraint;
      this._type = type;
    }
    this._value = value;
  }

  Field.asPrimaryKey([String field = SQLiteStatement.ID]) : super(field) {
    this._constraint = Constraint.PRIMARY_KEY;
    this._type = DataType.INTEGER;
  }

  Field.asForeignKey(String field, {@required Table reference}) : super(field) {
    this._constraint = Constraint.FOREIGN_KEY;
    this._type = DataType.INTEGER;
    this._table = reference;
  }

  Field.asUnique(String field) : super(field) {
    this._constraint = Constraint.UNIQUE;
    this._type = DataType.INTEGER;
  }

  Field.asOrder({
    @required String field,
    Order order = Order.ASC,
    bool collate = false,
  }) : super(field) {
    this._order = order;
    this._collate = collate;
  }

  String asString() {
    final buffer = new StringBuffer();
    if (hasDataType) {
      buffer.write('$field $dataType');
      if (hasConstraint) {
        switch (constraint) {
          case Constraint.PRIMARY_KEY:
            buffer.write(' PRIMARY KEY AUTOINCREMENT NOT NULL');
            break;
          case Constraint.FOREIGN_KEY:
            buffer.write(' REFERENCES ${table.name}(${SQLiteStatement.ID})');
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
      if (hasOrder) {
        buffer.write('$field');
        if (collate) {
          buffer.write(' COLLATE NOCASE');
        }
        final direction = order.toString().split('.').last;
        buffer.write(' $direction');
      }
    }
    return buffer.toString();
  }
}
