import 'package:codepan/database/mixin/query_properties.dart';
import 'package:codepan/database/models/field.dart';
import 'package:codepan/database/models/table.dart' as tb;
import 'package:codepan/database/schema.dart';
import 'package:codepan/database/sqlite_exception.dart';

enum JoinType {
  left,
  right,
  inner,
  outer,
}
enum Order {
  ascending,
  descending,
}

class SQLiteQuery with QueryProperties {
  Map<String, int>? _tableMap;
  List<SQLiteQuery>? _joinList;
  List<Field>? _orderList;
  List<Field>? _groupList;
  TableSchema? _schema;
  late bool _randomOrder;
  tb.Table? _table;
  JoinType? _type;
  int? _limit;

  JoinType? get type => _type;

  tb.Table? get table => _table;

  TableSchema? get schema => _schema;

  List<SQLiteQuery>? get joinList => _joinList;

  List<Field>? get groupList => _groupList;

  List<Field>? get orderList => _orderList;

  int? get limit => _limit;

  bool get hasJoin => _joinList != null && _joinList!.isNotEmpty;

  bool get hasOrder => _orderList != null && _orderList!.isNotEmpty;

  bool get hasGroup => _groupList != null && _groupList!.isNotEmpty;

  bool get hasLimit => _limit != null && _limit != 0;

  /// select - Can only be a list of String or Field.
  /// table - Can only be a type of String, Table or TableSchema.
  /// orderBy - Can only be a list of String or Field.
  /// groupBy - Can only be a list of String or Field.
  SQLiteQuery({
    required List<dynamic>? select,
    required dynamic from,
    dynamic where,
    List<dynamic>? orderBy,
    List<dynamic>? groupBy,
    bool randomOrder = false,
    int? limit,
  }) {
    if (from is tb.Table) {
      this._table = from;
    } else if (from is String) {
      this._table = tb.Table(from);
    } else if (from is TableSchema) {
      this._table = from.table;
      this._schema = from;
    } else {
      throw SQLiteException(SQLiteException.invalidTableType);
    }
    if (_table != null) {
      addFields(select, table: _table);
      addConditions(where, table: _table);
      _addOrders(orderBy, table: _table);
      _addGroups(groupBy, table: _table);
      this._randomOrder = randomOrder;
      this._limit = limit;
    }
  }

  factory SQLiteQuery.all({
    required TableSchema schema,
    dynamic where,
    List<dynamic>? orderBy,
    List<dynamic>? groupBy,
    bool randomOrder = false,
    int? limit,
    JoinType type = JoinType.inner,
  }) {
    return SQLiteQuery(
      select: schema.fields,
      from: schema,
      where: where,
      orderBy: orderBy,
      groupBy: groupBy,
      randomOrder: randomOrder,
      limit: limit,
    )..joinAllForeignKeys(type: type);
  }

  void _addOrders(List<dynamic>? input, {tb.Table? table}) {
    input?.forEach((field) {
      if (field is Field) {
        _addOrder(field, table: table);
      } else if (field is String) {
        final f = Field.asOrder(field: field);
        _addOrder(f, table: table);
      }
    });
  }

  void _addOrder(Field f, {tb.Table? table}) {
    if (!f.hasAlias) {
      f.setTable(table);
    }
    _orderList ??= [];
    _orderList!.add(f);
  }

  void _addGroups(List<dynamic>? input, {tb.Table? table}) {
    input?.forEach((field) {
      if (field is Field) {
        _addGroup(field, table: table);
      } else if (field is String) {
        final f = Field(field);
        _addGroup(f, table: table);
      }
    });
  }

  void _addGroup(Field f, {tb.Table? table}) {
    f.setTable(table);
    _groupList ??= [];
    _groupList!.add(f);
  }

  void _setJoinType(JoinType type) {
    this._type = type;
  }

  void join({
    required SQLiteQuery query,
    JoinType type = JoinType.inner,
  }) {
    query._setJoinType(type);
    _joinList ??= [];
    final table = query.table;
    if (tableExists(table)) {
      _tableMap ??= {};
      final index = _tableMap![table!.name];
      if (index != null) {
        table.setJoinIndex(index + 1);
      } else {
        table.setJoinIndex(1);
      }
    }
    _joinList!.add(query);
  }

  void joinAllForeignKeys({
    JoinType type = JoinType.inner,
  }) {
    if (schema != null) {
      joinForeignKeys(
        foreignKeys: schema!.foreignKeys,
        type: type,
      );
    } else {
      throw SQLiteException(SQLiteException.noSchemaFoundInQuery);
    }
  }

  void joinForeignKeys({
    required List<Field> foreignKeys,
    JoinType type = JoinType.inner,
  }) {
    if (foreignKeys.isNotEmpty) {
      if (schema != null) {
        final all = schema!.databaseSchema;
        for (final field in foreignKeys) {
          final table = field.reference!;
          final schema = all.of(table.entity);
          join(
            query: SQLiteQuery(
              select: schema.fields,
              from: table,
              where: {
                'id': _table!.field(field.field),
              },
            ),
            type: type,
          );
        }
      } else {
        throw SQLiteException(SQLiteException.noSchemaFoundInQuery);
      }
    }
  }

  bool tableExists(tb.Table? table) {
    for (final query in _joinList!) {
      if (table!.name == query.table!.name) {
        return true;
      }
    }
    return false;
  }

  Field field(String name) {
    return table!.field(name);
  }

  String build() {
    if (hasFields) {
      final buffer = new StringBuffer();
      if (hasJoin) {
        final bf = new StringBuffer();
        final bq = new StringBuffer();
        for (final q in joinList!) {
          if (q.hasFields) {
            bf.write(', ${q.fieldsWithAlias}');
          }
          final tb = q.table!;
          final type = q.type.toString().split('.').last;
          bq.write(' $type JOIN ${tb.name} as ${tb.alias} ON ${q.conditions}');
        }
        buffer.write('SELECT $fieldsWithAlias');
        buffer.write(bf.toString());
        buffer.write(' FROM ${table!.name} as ${table!.alias}');
        buffer.write(bq.toString());
      } else {
        if (hasFields) {
          buffer.write(
              'SELECT $fieldsWithAlias FROM ${table!.name} as ${table!.alias}');
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
    throw SQLiteException.noFieldsInQuery;
  }
}
