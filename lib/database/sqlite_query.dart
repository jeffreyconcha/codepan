import 'package:codepan/database/entities/table.dart';
import 'package:codepan/database/mixin/query_properties.dart';
import 'entities/field.dart';

enum JoinType {
  LEFT,
  RIGHT,
  INNER,
  OUTER,
}

class SQLiteQuery with QueryProperties {
  List<SQLiteQuery> joinList;
  final Table table;
  JoinType type;

  bool get hasJoin => joinList != null && joinList.isNotEmpty;

  SQLiteQuery(
    this.table, {
    List<dynamic> fields,
    Map<String, dynamic> conditions,
  }) {
    addFields(fields, alias: table.alias);
    withConditions(conditions, alias: table.alias);
  }

  void _setJoinType(JoinType type) {
    this.type = type;
  }

  void join(SQLiteQuery query, JoinType type) {
    query._setJoinType(type);
    joinList ??= [];
    joinList.add(query);
  }

  Field field(String name) {
    return Field(name)..setAlias(table.alias);
  }
}
