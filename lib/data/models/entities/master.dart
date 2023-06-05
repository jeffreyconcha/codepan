import 'package:codepan/data/models/entities/transaction.dart';
import 'package:codepan/widgets/dialogs/menu_dialog.dart';
import 'package:flutter/foundation.dart';

abstract class MasterData extends TransactionData implements Selectable {
  final int? webId;
  final String? name;

  @override
  List<Object?> get props => [webId];

  @override
  String? get title => name;

  @override
  dynamic get identifier => id;

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

  bool get hasWebId => webId != null && webId != 0;

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
  Map<String, dynamic> toMap();

  @override
  String toString() {
    return '${this.runtimeType}($id, $webId, $name)';
  }
}
