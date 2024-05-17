import 'package:codepan/data/database/mixin/query_properties.dart';
import 'package:codepan/data/database/models/field.dart';
import 'package:codepan/data/database/models/table.dart' as tb;
import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_exception.dart';
import 'package:codepan/extensions/dynamic.dart';

enum JoinType {
  left,
  right,
  inner,
  outer,
}

enum JoinOption {
  all,
  none,
}

enum Order {
  ascending,
  descending,
}

class SqliteQuery with QueryProperties {
  List<SqliteQuery>? _joinList;
  RecursiveJoin? _recursive;
  List<Field>? _orderList;
  List<Field>? _groupList;
  TableSchema? _schema;
  late bool _randomOrder;
  late tb.Table _table;
  JoinType? _type;
  int? _limit, _offset;

  JoinType? get type => _type;

  tb.Table get table => _table;

  TableSchema? get schema => _schema;

  List<SqliteQuery>? get joinList => _joinList;

  List<Field>? get groupList => _groupList;

  List<Field>? get orderList => _orderList;

  int? get limit => _limit;

  int? get offset => _offset;

  bool get hasJoin => _joinList?.isNotEmpty ?? false;

  bool get hasOrder => _orderList?.isNotEmpty ?? false;

  bool get hasGroup => _groupList?.isNotEmpty ?? false;

  bool get hasLimit => _limit != null && _limit != 0;

  bool get hasOffset => _offset != null && _offset != 0;

  /// select - Can only be a list of String or Field.
  /// table - Can only be a type of Table or TableSchema.
  /// orderBy - Can only be a list of String or Field.
  /// groupBy - Can only be a list of String or Field.
  SqliteQuery({
    required List<dynamic>? select,
    required dynamic from,
    dynamic where,
    List<dynamic>? orderBy,
    List<dynamic>? groupBy,
    bool randomOrder = false,
    RecursiveJoin? recursive,
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
      throw SqliteException(SqliteException.invalidTableType);
    }
    addFields(select, table: _table);
    addConditions(where, table: _table);
    _addOrders(orderBy, table: _table);
    _addGroups(groupBy, table: _table);
    this._randomOrder = randomOrder;
    this._recursive = recursive;
    this._limit = limit;
  }

  factory SqliteQuery.all({
    required TableSchema schema,
    dynamic where,
    List<dynamic>? orderBy,
    List<dynamic>? groupBy,
    bool randomOrder = false,
    int? limit,
    JoinType type = JoinType.left,
    RecursiveJoin? recursive,
  }) {
    return SqliteQuery(
      select: schema.fields,
      from: schema,
      where: where,
      orderBy: orderBy,
      groupBy: groupBy,
      randomOrder: randomOrder,
      limit: limit,
      recursive: recursive,
    )..joinAllForeignKeys(
        type: type,
      );
  }

  void _addOrders(List<dynamic>? input, {tb.Table? table}) {
    input?.forEach((field) {
      if (field is Field) {
        _addOrder(field, table: table);
      } else if (field is String) {
        final f = Field.order(field: field);
        _addOrder(f, table: table);
      }
    });
  }

  void _addOrder(
    Field f, {
    tb.Table? table,
  }) {
    final field = !f.hasAlias ? f.copyWith(table: table) : f;
    _orderList ??= [];
    _orderList!.add(field);
  }

  void _addGroups(List<dynamic>? input, {tb.Table? table}) {
    input?.forEach((field) {
      if (field is Field) {
        _addGroup(field, table: table);
      } else if (field is String) {
        final f = Field(
          field: field,
        );
        _addGroup(f, table: table);
      }
    });
  }

  void _addGroup(
    Field f, {
    tb.Table? table,
  }) {
    _groupList ??= [];
    _groupList!.add(f.copyWith(
      table: table,
    ));
  }

  void _setJoinType(JoinType type) {
    this._type = type;
  }

  void join({
    required SqliteQuery query,
    JoinType type = JoinType.left,
  }) {
    query._setJoinType(type);
    _joinList ??= [];
    final table = query.table;
    final count = _getTableCount(table);
    if (count > 0) {
      table.setJoinNumber(count + 1);
      if (count == 1) {
        _setFirstTable(table);
      }
    }
    _joinList!.add(query);
  }

  void _setFirstTable(tb.Table table) {
    if (hasJoin) {
      for (final query in _joinList!) {
        final other = query.table;
        if (table.entity == other.entity) {
          other.setJoinNumber(1);
          break;
        }
      }
    }
  }

  int _getTableCount(tb.Table table) {
    if (hasJoin) {
      int count = 0;
      for (final query in _joinList!) {
        final other = query.table;
        if (table.entity == other.entity) {
          count++;
        }
      }
      return count;
    }
    return 0;
  }

  void joinAllForeignKeys({
    JoinType type = JoinType.left,
    JoinOption option = JoinOption.all,
  }) {
    if (schema != null) {
      joinForeignKeys(
        foreignKeys: schema!.foreignKeys,
        table: _table,
        type: type,
        option: option,
      );
    } else {
      throw SqliteException(SqliteException.noSchemaFoundInQuery);
    }
  }

  void joinForeignKeys({
    required Iterable<Field> foreignKeys,
    tb.Table? table,
    JoinType type = JoinType.left,
    JoinOption option = JoinOption.all,
  }) {
    if (foreignKeys.isNotEmpty) {
      _recursive?.useJoin();
      final localTable = table ?? this._table;
      if (schema != null) {
        final all = schema!.dbSchema;
        for (final field in foreignKeys) {
          final foreignTable = field.reference!;
          final schema = all.of(foreignTable.entity!);
          join(
            query: SqliteQuery(
              select: option == JoinOption.all ? schema.fields : [],
              from: foreignTable,
              where: {
                'id': localTable.field(field.field),
              },
            ),
            type: type,
          );
          if ((_recursive?.canJoin ?? false) && schema.foreignKeys.isNotEmpty) {
            joinForeignKeys(
              foreignKeys: schema.foreignKeys,
              table: foreignTable,
              option: option,
              type: type,
            );
          }
        }
      } else {
        throw SqliteException(SqliteException.noSchemaFoundInQuery);
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
        for (final q in joinList!) {
          if (q.hasFields) {
            bf.write(', ${q.fieldsWithAlias}');
          }
          final tb = q.table;
          final type = q.type.toWords(allCaps: true);
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
      if (hasOffset) {
        buffer.write(' OFFSET $offset');
      }
      return buffer.toString();
    }
    throw SqliteException.noFieldsInQuery;
  }
}

class RecursiveJoin {
  late int _limit;

  RecursiveJoin({
    required int levelLimit,
  }) : _limit = levelLimit;

  void useJoin() {
    if (_limit != 0) {
      _limit--;
    }
  }

  bool get canJoin => _limit != 0;
}
