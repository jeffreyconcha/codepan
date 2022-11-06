import 'package:codepan/data/database/models/table.dart';

class SqliteModel {
  final String _field;
  final Table? table;

  String? get alias => table?.alias;

  bool get hasAlias => alias != null;

  String get field => hasAlias ? '$alias.$_field' : this._field;

  bool nameIs(String name) {
    return name == _field;
  }

  const SqliteModel({
    required String field,
    this.table,
  }) : _field = field;

  SqliteModel copyWith({
    String? field,
    Table? table,
  }) {
    return SqliteModel(
      field: field ?? this._field,
      table: table ?? this.table,
    );
  }
}
