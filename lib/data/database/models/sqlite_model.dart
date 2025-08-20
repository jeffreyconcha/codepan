import 'package:codepan/data/database/models/table.dart';

class SqliteModel {
  final String _field;
  final Table? table;
  final bool useRawField;

  String? get alias => table?.alias;

  bool get hasAlias => alias != null;

  String get field => hasAlias && !useRawField ? '$alias.$_field' : _field;

  bool nameIs(String name) {
    return name == _field;
  }

  const SqliteModel({
    required String field,
    bool useRawField = false,
    this.table,
  })  : _field = field,
        useRawField = useRawField;

  SqliteModel rawField() {
    return copyWith(
      useRawField: true,
    );
  }

  SqliteModel copyWith({
    String? field,
    Table? table,
    bool? useRawField,
  }) {
    return SqliteModel(
      field: field ?? this._field,
      table: table ?? this.table,
      useRawField: useRawField ?? this.useRawField,
    );
  }
}
