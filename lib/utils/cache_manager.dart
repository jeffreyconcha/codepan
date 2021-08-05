typedef Creator<K, V> = Future<V> Function(K key);

class CacheManager<K, V> {
  final Creator<K, V>? creator;
  final map = <K, V>{};

  CacheManager({
    this.creator,
  });

  void add(K key, V value) {
    map.putIfAbsent(key, () => value);
  }

  Future<V?> getCached(K key) async {
    final data = map[key];
    if (data != null) {
      return data;
    }
    if (creator != null) {
      return map[key] = await creator!.call(key);
    }
    return null;
  }
}
