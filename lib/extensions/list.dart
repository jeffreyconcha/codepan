import 'package:codepan/data/models/entities/master.dart';
import 'package:codepan/data/models/entities/transaction.dart';
import 'package:flutter/foundation.dart';

typedef AsyncTypeConverter<E, N> = Future<N> Function(E);
typedef TypeConverter<E, N> = N Function(E);
typedef Validator<E> = num Function(E);

enum Type {
  max,
  min,
}

extension ListUtils<E> on List<E> {
  Future<void> asyncLoop(AsyncValueSetter<E> action) async {
    for (E element in this) {
      await action(element);
    }
  }

  E max(Validator<E> validator) {
    return _best(validator, Type.max);
  }

  E min(Validator<E> validator) {
    return _best(validator, Type.min);
  }

  E _best(Validator<E> validator, Type type) {
    int index = 0;
    num? oldValue;
    for (final element in this) {
      final current = validator(element);
      if (oldValue == null ||
          (type == Type.max ? current > oldValue : current < oldValue)) {
        oldValue = current;
        index = indexOf(element);
      }
    }
    return elementAt(index);
  }

  String get text => toText();

  String toText([String separator = ', ']) {
    final buffer = StringBuffer();
    this.forEach((element) {
      if (element is MasterData) {
        buffer.write(element.name);
      } else {
        buffer.write(element);
      }
      if (this.last != element) {
        buffer.write(separator);
      }
    });
    return buffer.toString();
  }

  List<int> get idList {
    final list = <int>[];
    this.forEach((element) {
      if (element is TransactionData) {
        final id = element.id;
        if (id != null) list.add(id);
      }
    });
    return list;
  }

  List<N> transform<N>(
    TypeConverter<E, N> action, {
    bool sort = false,
  }) {
    final list = <N>[];
    for (E element in this) {
      list.add(action(element));
    }
    return sort ? (list..sort()) : list;
  }

  Future<List<N>> asyncTransform<N>(
    AsyncTypeConverter<E, N> action, {
    bool sort = false,
  }) async {
    final list = <N>[];
    for (E element in this) {
      list.add(await action(element));
    }
    return sort ? (list..sort()) : list;
  }
}
