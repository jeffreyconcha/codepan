import 'package:codepan/data/models/entities/entity.dart';
import 'package:flutter/foundation.dart';

abstract class BaseFactory<T extends EntityData> {
  final Map<String, dynamic> map;

  const BaseFactory(this.map);

  T get product => create(map);

  @protected
  T create(Map<String, dynamic> json);
}
