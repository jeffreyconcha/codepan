import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/entities/table.dart';
import 'package:codepan/database/sqlite_statement.dart';
import 'package:flutter/foundation.dart';

class Field extends SQLiteEntity {
  Constraint constraint;
  DataType type;
  dynamic value;
  Table table;

  bool get hasConstraint => constraint != null;

  bool get hasDataType => type != null;

  String get dataType => hasDataType ? type.toString().split('.').last : null;

  String get defaultValue {
    if (value != null) {
      if (value is bool) {
        return value ? '1' : '0';
      } else {
        return value.toString();
      }
    }
    return null;
  }

  Field(String _field, {this.type, this.constraint, this.value})
      : super(_field) {
    if (value != null) {
      this.constraint = Constraint.DEFAULT;
      this.type =
          value is int || value is bool ? DataType.INTEGER : DataType.TEXT;
    }
  }

  Field.asPrimaryKey([String field = SQLiteStatement.ID]) : super(field) {
    this.constraint = Constraint.PRIMARY_KEY;
    this.type = DataType.INTEGER;
  }

  Field.asForeignKey(String field, {@required Table reference}) : super(field) {
    this.constraint = Constraint.FOREIGN_KEY;
    this.type = DataType.INTEGER;
    this.table = reference;
  }

  Field.asUnique(String field) : super(field) {
    this.constraint = Constraint.UNIQUE;
    this.type = DataType.INTEGER;
  }

  String asString() {
    final buffer = new StringBuffer();
    if (hasDataType) {
      buffer.write("$field $dataType");
      if (hasConstraint) {
        switch (constraint) {
          case Constraint.PRIMARY_KEY:
            buffer.write(" PRIMARY KEY AUTOINCREMENT NOT NULL");
            break;
          case Constraint.FOREIGN_KEY:
            buffer.write(" REFERENCES ${table.name}(${SQLiteStatement.ID})");
            break;
          case Constraint.UNIQUE:
            buffer.write(" UNIQUE");
            break;
          case Constraint.DEFAULT:
            buffer.write(" DEFAULT $defaultValue");
            break;
        }
      }
    }
    return buffer.toString();
  }
}
