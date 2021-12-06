import 'package:codepan/data/database/models/table.dart';

class SQLiteModel {
  String _field;
  Table? table;

  String? get alias => table?.alias;

  bool get hasAlias => alias != null;

  String get field => hasAlias ? '$alias.$_field' : this._field;

  SQLiteModel(this._field, {this.table});

  void setTable(Table? table) {
    this.table = table;
  }
}
