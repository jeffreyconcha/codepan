import 'package:codepan/data/models/entities/transaction.dart';
import 'package:codepan/utils/search_handler.dart';
import 'package:flutter/foundation.dart';

abstract class MasterData extends TransactionData implements Searchable {
  final int? webId;
  final String? name;

  @override
  List<String?> get searchable => [name];

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
