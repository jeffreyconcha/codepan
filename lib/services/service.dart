import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/data/models/entities/entity.dart';
import 'package:http/http.dart';

abstract class Gettable {
  Future<bool> getData({
    required Client client,
  });
}

abstract class Synchronizable<T extends EntityData> {
  Future<bool> syncData({
    required Client client,
    T data,
  });
}

abstract class Fetchable<T extends EntityData> {
  Future<List<T>> fetchData({
    required Client client,
  });
}

abstract class ServiceFor<T extends EntityData> {
  final SqliteAdapter db;

  const ServiceFor({
    required this.db,
  });

  Future<T> fromId(int id);

  Future<List<T>> get data;
}
