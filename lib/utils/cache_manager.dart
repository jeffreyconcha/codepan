typedef AsyncCreator<K, V> = Future<V> Function(K key);
typedef Creator<K, V> = V Function(K key);

class CacheAsyncManager<K, V> {
  final AsyncCreator<K, V>? creator;
  final map = <K, V>{};

  CacheAsyncManager({
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

class CacheManager<K, V> {
  final Creator<K, V>? creator;
  final map = <K, V>{};

  CacheManager({
    this.creator,
  });

  void add(K key, V value) {
    map.putIfAbsent(key, () => value);
  }

  V? getCached(K key) {
    final data = map[key];
    if (data != null) {
      return data;
    }
    if (creator != null) {
      return map[key] = creator!.call(key);
    }
    return null;
  }
}
