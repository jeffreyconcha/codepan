import 'package:codepan/models/transaction.dart';
import 'package:flutter/foundation.dart';

abstract class MasterData extends TransactionData {
  final int? webId;
  final String? name;

  const MasterData({
    int? id,
    String? dateCreated,
    String? timeCreated,
    String? dateUpdated,
    String? timeUpdated,
    bool? isDeleted,
    this.webId,
    this.name,
  }) : super(
          id: id,
          dateCreated: dateCreated,
          timeCreated: timeCreated,
          dateUpdated: dateUpdated,
          timeUpdated: timeUpdated,
          isDeleted: isDeleted,
        );

  @override
  Map<String, dynamic> get map {
    return super.map
      ..addAll({
        'webId': webId,
        'name': name,
      });
  }

  @override
  bool get isNull => id == null && webId == null;

  @protected
  Map<String, dynamic> filtered([Map<String, dynamic>? map]) {
    final filtered = map ?? <String, dynamic>{};
    filtered.addAll(this.map);
    filtered.removeWhere((key, value) {
      return value == null;
    });
    return filtered;
  }

  @override
  Map<String, dynamic> toMap() => filtered();

  @override
  MasterData copyWith({
    int? id,
    String? dateCreated,
    String? timeCreated,
    String? dateUpdated,
    String? timeUpdated,
    bool? isDeleted,
    int? webId,
    String? name,
  });
}
