import 'package:codepan/data/database/models/field_value.dart';
import 'package:codepan/data/database/models/sqlite_model.dart';
import 'package:codepan/data/database/models/table.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/extensions/dynamic.dart';

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

enum Constraint {
  primaryKey,
  foreignKey,
  defaultField,
  unique,
  dateFormatted,
  timeFormatted,
  notNull,
}

enum SqliteFunction {
  count,
  sum,
}

enum DataType {
  integer,
  text,
  real,
  blob,
}

class Field extends SqliteModel {
  final bool collate, isIndex, inUniqueGroup, withDateTrigger, withTimeTrigger;
  final List<Constraint>? constraints;
  final SqliteFunction? function;
  final Table? reference;
  final DataType? type;
  final Order? order;
  final dynamic value;

  bool get isForeignKey {
    return constraints?.contains(Constraint.foreignKey) ?? false;
  }

  bool get isUnique {
    return constraints?.contains(Constraint.unique) ?? false;
  }

  bool get isFunction => function != null;

  String? get defaultValue {
    if (value != null) {
      if (value is bool) {
        return value ? '1' : '0';
      } else if (value is SqliteTime) {
        return '(${(value as SqliteTime).value})';
      } else {
        return value.toString();
      }
    }
    return null;
  }

  const Field({
    required super.field,
    super.table,
    super.useRawField,
    this.type,
    this.constraints,
    this.reference,
    this.value,
    this.collate = false,
    this.isIndex = false,
    this.inUniqueGroup = false,
    this.withDateTrigger = false,
    this.withTimeTrigger = false,
    this.function,
    this.order,
  });

  @override
  Field copyWith({
    String? field,
    Table? table,
    bool? useRawField,
    DataType? type,
    List<Constraint>? constraints,
    Table? reference,
    dynamic value,
    bool? collate,
    bool? isIndex,
    bool? inUniqueGroup,
    bool? withDateTrigger,
    bool? withTimeTrigger,
    SqliteFunction? function,
    Order? order,
  }) {
    return Field(
      field: field ?? this.field,
      table: table ?? this.table,
      useRawField: useRawField ?? this.useRawField,
      type: type ?? this.type,
      constraints: constraints ?? this.constraints,
      reference: reference ?? this.reference,
      value: value ?? this.value,
      collate: collate ?? this.collate,
      isIndex: isIndex ?? this.isIndex,
      inUniqueGroup: inUniqueGroup ?? this.inUniqueGroup,
      withDateTrigger: withDateTrigger ?? this.withDateTrigger,
      withTimeTrigger: withTimeTrigger ?? this.withTimeTrigger,
      function: function ?? this.function,
      order: order ?? this.order,
    );
  }

  //Constructor for table creation.

  factory Field.primaryKey([
    String field = SqliteStatement.id,
  ]) {
    return Field(
      field: field,
      type: DataType.integer,
      constraints: [Constraint.primaryKey],
    );
  }

  factory Field.foreignKey(
    String field, {
    required Table at,
  }) {
    return Field(
      field: field,
      reference: at,
      type: DataType.integer,
      constraints: [Constraint.foreignKey],
    );
  }

  factory Field.column(
    String field, {
    required DataType type,
  }) {
    return Field(
      field: field,
      type: type,
    );
  }

  factory Field.unique(
    String field, {
    DataType type = DataType.integer,
  }) {
    return Field(
      field: field,
      type: type,
      constraints: [Constraint.unique],
    );
  }

  factory Field.defaultValue(
    String field, {
    required dynamic value,
  }) {
    return Field(
      field: field,
      value: value,
      constraints: [Constraint.defaultField],
      type: _getDataType(value),
    );
  }

  factory Field.date(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [Constraint.dateFormatted],
    );
  }

  factory Field.time(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [Constraint.timeFormatted],
    );
  }

  factory Field.defaultDate(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [
        Constraint.dateFormatted,
        Constraint.defaultField,
      ],
      value: SqliteTime.dateNow,
    );
  }

  factory Field.defaultTime(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [
        Constraint.timeFormatted,
        Constraint.defaultField,
      ],
      value: SqliteTime.timeNow,
    );
  }

  factory Field.autoUpdateDate(String field) {
    return Field.date(field).copyWith(
      withDateTrigger: true,
    );
  }

  factory Field.autoUpdateTime(String field) {
    return Field.time(field).copyWith(
      withTimeTrigger: true,
    );
  }

  factory Field.uniqueDate(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [
        Constraint.dateFormatted,
        Constraint.unique,
      ],
    );
  }

  factory Field.uniqueTime(String field) {
    return Field(
      field: field,
      type: DataType.text,
      constraints: [
        Constraint.timeFormatted,
        Constraint.unique,
      ],
    );
  }

  /// Short for "<b>Unique Group</b>" <br/>
  /// Call this method if you want this field to be included in the unique group. <br/>
  /// If the same record has the same unique group fields it will update the
  /// existing record instead of inserting new record thus eliminating duplicates.<br/>
  /// Will only be applied to a non-unique constraint.<br/><br/>
  /// <b>Note:</b> If you added a column to an existing table with this constraint, it is advisable to recreate the table instead.
  Field ug() {
    if (!(constraints?.contains(Constraint.unique) ?? false)) {
      return this.copyWith(
        inUniqueGroup: true,
      );
    }
    return this;
  }

  // Constructors for queries.

  factory Field.reference({
    required String field,
    required Table reference,
  }) {
    return Field(
      field: field,
      reference: reference,
      constraints: [
        Constraint.foreignKey,
      ],
    );
  }

  factory Field.order({
    required String field,
    Order order = Order.ascending,
    bool collate = false,
    Table? table,
  }) {
    return Field(
      field: field,
      order: order,
      collate: collate,
      table: table,
    );
  }

  factory Field.function(
    String field, {
    required SqliteFunction function,
  }) {
    return Field(
      field: field,
      function: function,
    );
  }

  factory Field.count(String field) {
    return Field.function(
      field,
      function: SqliteFunction.count,
    );
  }

  factory Field.sum(String field) {
    return Field.function(
      field,
      function: SqliteFunction.sum,
    );
  }

  bool hasConstraint(Constraint constraint) {
    if (constraints?.isNotEmpty ?? false) {
      return constraints!.contains(constraint);
    }
    return false;
  }

  String asString() {
    final buffer = StringBuffer();
    if (type != null) {
      buffer.write('$field ${type.enumValue}');
      if (constraints?.isNotEmpty ?? false) {
        for (final constraint in constraints!) {
          switch (constraint) {
            case Constraint.primaryKey:
              buffer.write(' PRIMARY KEY NOT NULL');
              break;
            case Constraint.foreignKey:
              buffer.write(
                  ' REFERENCES ${reference!.name}(${SqliteStatement.id})');
              break;
            case Constraint.unique:
              buffer.write(' UNIQUE');
              break;
            case Constraint.defaultField:
              buffer.write(' DEFAULT $defaultValue');
              break;
            case Constraint.dateFormatted:
              buffer.write(
                  ' CHECK ($field IS DATE($field) OR $field = \'0000-00-00\')');
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
      if (order != null) {
        buffer.write('$field');
        if (collate) {
          buffer.write(' COLLATE NOCASE');
        }
        final value = order.enumValue;
        final direction = value.replaceAll('ending', '').toUpperCase();
        buffer.write(' $direction');
      } else if (function != null) {
        switch (function) {
          case SqliteFunction.count:
            buffer.write('COUNT($field)');
            break;
          case SqliteFunction.sum:
            buffer.write('SUM($field)');
            break;
          default:
            break;
        }
      }
    }
    return buffer.toString();
  }
}
