import 'package:codepan/data/models/entities/master.dart';
import 'package:codepan/data/models/entities/transaction.dart';

typedef AsyncTypeConverter<T, N> = Future<N?> Function(T item, int index);
typedef TypeConverter<T, N> = N? Function(T item, int index);
typedef UnevenTypeConverter<T, N> = List<N>? Function(T item, int index);
typedef AsyncLooper<T> = Future<void> Function(T item, int index);
typedef Looper<T> = void Function(T item, int index);
typedef Validator<T> = num Function(T item);

enum Type {
  max,
  min,
}

extension ListUtils<T> on List<T> {
  Future<void> loop(Looper<T> action) async {
    int index = 0;
    for (T element in this) {
      action(element, index);
      index++;
    }
  }

  Future<void> asyncLoop(AsyncLooper<T> action) async {
    int index = 0;
    for (T element in this) {
      await action(element, index);
      index++;
    }
  }

  T? max(Validator<T> validator) {
    return _best(validator, Type.max);
  }

  T? min(Validator<T> validator) {
    return _best(validator, Type.min);
  }

  T? _best(Validator<T> validator, Type type) {
    if (isNotEmpty) {
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
    return null;
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
    TypeConverter<T, N> action, {
    bool sort = false,
  }) {
    final list = <N>[];
    int index = 0;
    for (T element in this) {
      final transformed = action(element, index);
      if (transformed != null) {
        list.add(transformed);
      }
      index++;
    }
    return sort ? (list..sort()) : list;
  }

  List<N> unevenTransform<N>(
    UnevenTypeConverter<T, N> action, {
    bool sort = false,
  }) {
    final list = <N>[];
    int index = 0;
    for (T element in this) {
      final transformed = action(element, index);
      if (transformed != null) {
        list.addAll(transformed);
      }
      index++;
    }
    return sort ? (list..sort()) : list;
  }

  Future<List<N>> asyncTransform<N>(
    AsyncTypeConverter<T, N> action, {
    bool sort = false,
  }) async {
    final list = <N>[];
    int index = 0;
    for (T element in this) {
      final transformed = await action(element, index);
      if (transformed != null) {
        list.add(transformed);
      }
      index++;
    }
    return sort ? (list..sort()) : list;
  }

  void addIfAbsent(T element) {
    if (!this.contains(element)) {
      add(element);
    }
  }
}

typedef Identifier<K, T> = K? Function(T item);

extension MasterListUtils<T extends MasterData> on List<T> {
  Map<K, T> toCachedMap<K>(Identifier<K, T> identifier) {
    final map = <K, T>{};
    this.loop((item, index) {
      final id = identifier.call(item);
      if (id != null) {
        map.putIfAbsent(id, () => item);
      }
    });
    return map;
  }
}
