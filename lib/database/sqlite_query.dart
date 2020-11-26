import 'package:codepan/database/mixin/query_properties.dart';
import 'package:codepan/database/models/field.dart';
import 'package:codepan/database/models/table.dart' as tb;
import 'package:codepan/database/schema.dart';
import 'package:flutter/cupertino.dart';

enum JoinType {
  LEFT,
  RIGHT,
  INNER,
  OUTER,
}
enum Order {
  ASC,
  DESC,
}

class SQLiteQuery with QueryProperties {
  List<SQLiteQuery> _joinList;
  List<Field> _orderList;
  List<Field> _groupList;
  bool _randomOrder;
  tb.Table _table;
  JoinType _type;
  int _limit;

  JoinType get type => _type;

  tb.Table get table => _table;

  List<SQLiteQuery> get joinList => _joinList;

  List<Field> get groupList => _groupList;

  List<Field> get orderList => _orderList;

  int get limit => _limit;

  bool get hasJoin => _joinList != null && _joinList.isNotEmpty;

  bool get hasOrder => _orderList != null && _orderList.isNotEmpty;

  bool get hasGroup => _groupList != null && _groupList.isNotEmpty;

  bool get hasLimit => _limit != null && _limit != 0;

  /// table - Can only be a type String or Table
  SQLiteQuery({
    @required List<dynamic> select,
    @required dynamic from,
    dynamic where,
    List<dynamic> orderBy,
    List<dynamic> groupBy,
    bool randomOrder = false,
    bool joinAllReference = false,
    int limit,
  }) {
    if (from is tb.Table) {
      this._table = from;
    } else if (from is String) {
      this._table = tb.Table(from);
    }
    addFields(select, alias: _table.alias);
    addConditions(where, alias: _table.alias);
    _addOrders(orderBy, alias: _table.alias);
    _addGroups(groupBy, alias: _table.alias);
    this._randomOrder = randomOrder;
    this._limit = limit;
  }

  void _addOrders(List<dynamic> input, {String alias}) {
    input?.forEach((field) {
      if (field is Field) {
        _addOrder(field, alias: alias);
      } else if (field is String) {
        final f = Field.asOrder(field: field);
        _addOrder(f, alias: alias);
      }
    });
  }

  void _addOrder(Field f, {String alias}) {
    if (!f.hasAlias) {
      f.setAlias(alias);
    }
    _orderList ??= [];
    _orderList.add(f);
  }

  void _addGroups(List<dynamic> input, {String alias}) {
    input?.forEach((field) {
      if (field is Field) {
        _addGroup(field, alias: alias);
      } else if (field is String) {
        final f = Field(field);
        _addGroup(f, alias: alias);
      }
    });
  }

  void _addGroup(Field f, {String alias}) {
    f.setAlias(alias);
    _groupList ??= [];
    _groupList.add(f);
  }

  void _setJoinType(JoinType type) {
    this._type = type;
  }

  void join({
    @required SQLiteQuery query,
    JoinType type = JoinType.INNER,
  }) {
    query._setJoinType(type);
    _joinList ??= [];
    _joinList.add(query);
  }

  void joinAll({
    @required TableSchema referencesOf,
    JoinType type = JoinType.INNER,
  }) {
    final main = referencesOf.table;
    final schemas = referencesOf.references;
    if (schemas?.isNotEmpty ?? false) {
      for (final schema in schemas) {
        join(
          query: SQLiteQuery(
            select: schema.fields,
            from: schema.table,
            where: {
              'id': main.field(schema.asForeignKey),
            },
          ),
          type: type,
        );
      }
    }
  }

  Field field(String name) {
    return table.field(name);
  }

  String build() {
    if (hasFields) {
      final buffer = new StringBuffer();
      if (hasJoin) {
        final bf = new StringBuffer();
        final bq = new StringBuffer();
        for (final q in joinList) {
          if (q.hasFields) {
            bf.write(', ${q.fieldsWithAlias}');
          }
          final tb = q.table;
          final type = q.type.toString().split('.').last;
          bq.write(' $type JOIN ${tb.name} as ${tb.alias} ON ${q.conditions}');
        }
        buffer.write('SELECT $fieldsWithAlias');
        buffer.write(bf.toString());
        buffer.write(' FROM ${table.name} as ${table.alias}');
        buffer.write(bq.toString());
      } else {
        if (hasFields) {
          buffer.write(
              'SELECT $fieldsWithAlias FROM ${table.name} as ${table.alias}');
        }
      }
      if (hasConditions) {
        buffer.write(' WHERE $conditions');
      }
      if (hasGroup) {
        final group = getFields(groupList);
        buffer.write(' GROUP BY $group');
      }
      if (hasOrder) {
        final order = getCommandFields(orderList);
        buffer.write(' ORDER BY $order');
      } else if (_randomOrder) {
        buffer.write(' ORDER BY RANDOM()');
      }
      if (hasLimit) {
        buffer.write(' LIMIT $limit');
      }
      return buffer.toString();
    }
    return null;
  }
}
