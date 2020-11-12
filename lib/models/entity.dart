import 'package:codepan/database/schema.dart';

abstract class EntityData {
  const EntityData();

  TableSchema get schemaInstance;

  String get table => schemaInstance.tableName;

  String get unique => schemaInstance.unique;

  List<String> get uniqueGroup => schemaInstance.uniqueGroup;
}
