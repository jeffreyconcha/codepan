import 'package:codepan/data/models/entities/entity.dart';
import 'package:flutter/foundation.dart';

abstract class BaseFactory<T extends EntityData> {
  final Map<String, dynamic> map;

  const BaseFactory(this.map);

  T create() => convert(map);

  @protected
  T convert(Map<String, dynamic> json);
}
