import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/models/entities/transaction.dart';
import 'package:flutter/cupertino.dart';

typedef Parser<T> = T? Function(Map<String, dynamic> record);

abstract class ServiceFor<T extends TransactionData> {
  final SqliteAdapter db;

  DatabaseEntity get entity;

  TableSchema get schema => db.schema.of(entity);

  Future<List<T>> get records => loadRecords();

  const ServiceFor(this.db);

  T? parse(Map<String, dynamic>? record);

  @protected
  List<T> recordsToList(
    List<Map<String, dynamic>> records, [
    Parser<T>? parser,
  ]) {
    final list = <T>[];
    for (final record in records) {
      final data = parser?.call(record) ?? parse(record);
      if (data != null) {
        list.add(data);
      }
    }
    return list;
  }

  Future<T?> getRecord(
    int? id, [
    bool isWebId = false,
  ]) async {
    final query = SqliteQuery.all(
      schema: schema,
      where: {
        '${isWebId ? 'webId' : 'id'}': id,
      },
      type: JoinType.left,
    );
    final record = await db.getRecord(query.build());
    return parse(record);
  }

  Future<List<T>> loadRecords() async {
    final query = SqliteQuery.all(
      schema: schema,
      where: {
        'isDeleted': false,
      },
      type: JoinType.left,
    );
    final records = await db.read(query.build());
    return recordsToList(records);
  }
}
