import 'package:codepan/database/entities/sqlite_entity.dart';
import 'package:codepan/database/entities/table.dart';
import 'package:codepan/database/sqlite_query.dart';

class Field extends SQLiteEntity {
  Constraint constraint;
  DataType type;
  dynamic value;
  Table table;

  bool get hasConstraint => constraint != null;

  bool get hasDataType => type != null;

  String get dataType => hasDataType ? type.toString() : null;

  String get defaultValue => value != null ? value.toString() : null;

  Field(String _field, {this.type, this.constraint, this.value})
      : super(_field) {
    if (value != null) {
      this.constraint = Constraint.DEFAULT;
      this.type = value is int ? DataType.INTEGER : DataType.TEXT;
    }
  }

  Field.foreignKey(this.table) : super(null) {
    this.constraint = Constraint.FOREIGN_KEY;
    this.type = DataType.INTEGER;
  }

  String asString() {
    var buffer = new StringBuffer();
    if (hasDataType) {
      buffer.write("$field $dataType");
      if (hasConstraint) {
        switch (constraint) {
          case Constraint.PRIMARY_KEY:
            buffer.write(" PRIMARY KEY AUTOINCREMENT NOT NULL");
            break;
          case Constraint.FOREIGN_KEY:
            buffer.write(" REFERENCES ${table.name}(${SQLiteQuery.ID})");
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
