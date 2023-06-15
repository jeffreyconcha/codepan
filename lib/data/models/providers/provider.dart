import 'package:codepan/data/models/entities/entity.dart';

abstract class RemoteProvider<T extends EntityData> {
  final Map<String, dynamic> json;

  const RemoteProvider(this.json);

  T create();
}
