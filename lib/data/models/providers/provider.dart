import 'package:codepan/data/models/entities/entity.dart';
import 'package:codepan/data/models/entities/transaction.dart';

abstract class RemoteProvider<T extends EntityData> {
  T fromJson(Map<String, dynamic> json);
}

abstract class LocalProvider<T extends TransactionData> {
  T fromQuery(Map<String, dynamic> record);
}
