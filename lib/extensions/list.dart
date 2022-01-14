extension ListUtils<E> on List<E> {
  Future<void> asyncLoop(Future<void> action(E element)) async {
    for (E element in this) {
      await action(element);
    }
  }
}
