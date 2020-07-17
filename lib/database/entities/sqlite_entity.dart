class SQLiteEntity {
  String _field, alias;

  bool get hasAlias => alias != null;

  String get field => alias != null ? '$alias.$_field' : this._field;

  SQLiteEntity(this._field, {this.alias});

  void setAlias(String alias) {
    this.alias = alias;
  }
}
