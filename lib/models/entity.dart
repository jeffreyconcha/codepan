import 'package:codepan/database/schema.dart';
import 'package:equatable/equatable.dart';

abstract class EntityData extends Equatable {
  const EntityData();

  TableSchema get schemaInstance;

  String get table => schemaInstance.tableName;

  String get unique => schemaInstance.unique;

  List<String> get uniqueGroup => schemaInstance.uniqueGroup;
}
