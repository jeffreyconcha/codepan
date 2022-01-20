import 'package:codepan/data/database/sqlite_binder.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/data/models/entities/entity.dart';
import 'package:codepan/time/time.dart';
import 'package:flutter/foundation.dart';

abstract class TransactionData extends EntityData
    implements Comparable<TransactionData> {
  final String? dateCreated, timeCreated, dateUpdated, timeUpdated;
  final bool? isDeleted;
  final int? id;

  const TransactionData({
    this.id,
    this.dateCreated,
    this.timeCreated,
    this.dateUpdated,
    this.timeUpdated,
    this.isDeleted,
  });

  @override
  List<Object?> get props => [id];

  @protected
  Map<String, dynamic> get map {
    final map = <String, dynamic>{
      'id': id,
      'dateCreated': dateCreated,
      'timeCreated': timeCreated,
      'dateUpdated': dateUpdated,
      'timeUpdated': timeUpdated,
      'isDeleted': isDeleted,
    };
    return map;
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

  Time? get createdAt {
    if (dateCreated != null && timeCreated != null) {
      return Time(
        date: dateCreated,
        time: timeCreated,
      );
    }
    return null;
  }

  Time? get updatedAt {
    if (dateUpdated != null && timeUpdated != null) {
      return Time(
        date: dateUpdated,
        time: timeUpdated,
      );
    }
    return null;
  }

  bool get hasId => id != null && id != 0;

  SQLiteStatement toStatement() {
    return SQLiteStatement.fromMap(toMap());
  }

  Map<String, dynamic> toMap();

  @override
  int compareTo(TransactionData other) {
    if (dateCreated != null &&
        timeCreated != null &&
        other.dateCreated != null &&
        other.timeCreated != null) {
      final dt1 = Time.parse('$dateCreated $timeCreated');
      final dt2 = Time.parse('${other.dateCreated} ${other.timeCreated}');
      if (dt1.isBefore(dt2)) {
        return -1;
      }
      if (dt1.isAfter(dt2)) {
        return 1;
      }
    }
    return 0;
  }

  TransactionData copyWith({
    int? id,
    String? dateCreated,
    String? timeCreated,
    String? dateUpdated,
    String? timeUpdated,
    bool? isDeleted,
  });

  Future<T> insertForId<T extends TransactionData>(
    SQLiteBinder binder, {
    UpdatePriority priority = UpdatePriority.unique,
  }) async {
    return binder.insertForId(
      data: this,
      priority: priority,
    );
  }

  Future<int?> insert(
    SQLiteBinder binder, {
    UpdatePriority priority = UpdatePriority.unique,
    bool ignoreId = false,
  }) {
    return binder.insertData(
      data: this,
      priority: priority,
      ignoreId: ignoreId,
    );
  }
}
