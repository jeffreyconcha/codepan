class SQLiteEntity {
  String _field, alias;

  String get field => alias != null ? '$alias.$_field' : this._field;

  SQLiteEntity(this._field, {this.alias});

  void setAlias(String alias) {
    this.alias = alias;
  }
}
