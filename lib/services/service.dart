import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/models/entities/transaction.dart';

abstract class ServiceFor<T extends TransactionData> {
  final SqliteAdapter db;

  DatabaseEntity get entity;

  TableSchema get schema => db.schema.of(entity);

  const ServiceFor({
    required this.db,
  });

  T? fromQuery(Map<String, dynamic>? record);

  Future<T?> getRecord(
    int id, [
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
    return fromQuery(record);
  }

  Future<List<T>> loadRecords() async {
    final list = <T>[];
    final query = SqliteQuery.all(
      schema: schema,
      where: {
        'isDeleted': false,
      },
      type: JoinType.left,
    );
    final records = await db.read(query.build());
    for (final record in records) {
      final data = fromQuery(record);
      if (data != null) {
        list.add(data);
      }
    }
    return list;
  }
}
