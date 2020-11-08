import 'package:codepan/database/schema.dart';

abstract class EntityData {
  const EntityData();

  dynamic get entity;

  DatabaseSchema get schemaInstance;

  String get table => schemaInstance.tableName(entity);

  String get unique => schemaInstance.unique(entity);

  List<String> get uniqueGroup => schemaInstance.uniqueGroup(entity);
}
