typedef Validator<E> = num Function(E);

enum Type {
  max,
  min,
}

extension ListUtils<E> on List<E> {
  Future<void> asyncLoop(Future<void> action(E element)) async {
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
}
