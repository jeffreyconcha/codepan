import 'package:codepan/database/schema.dart';

abstract class Entity {
  const Entity();

  dynamic get entity;

  DatabaseSchema get schema;

  String get table => schema.tableName(entity);

  String get unique => schema.unique(entity);

  List<String> get uniqueGroup => schema.uniqueGroup(entity);
}
