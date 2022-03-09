import 'package:flutter/cupertino.dart';

typedef AsyncCreator<K, V> = Future<V> Function(K key);
typedef Creator<K, V> = V Function(K key);

class CacheAsyncManager<K, V> {
  final AsyncCreator<K, V> creator;
  final _map = <K, V>{};

  CacheAsyncManager({
    required this.creator,
  });

  void add(K key, V value) {
    _map.putIfAbsent(key, () => value);
  }

  void clear() {
    _map.clear();
  }

  V? get(K key) => _map[key];

  bool contains(K key) => _map.containsKey(key);

  V? tryGet(K key, ValueChanged<V?> onCreated) {
    if (!_map.containsKey(key)) {
      getCached(key).then((value) {
        onCreated.call(value);
      });
    }
    return _map[key];
  }

  Future<V?> getCached(K key) async {
    final data = _map[key];
    if (data != null) {
      return data;
    }
    return _map[key] = await creator.call(key);
  }
}

class CacheManager<K, V> {
  final Creator<K, V> creator;
  final _map = <K, V>{};

  CacheManager({
    required this.creator,
  });

  void add(K key, V value) {
    _map.putIfAbsent(key, () => value);
  }

  void clear() {
    _map.clear();
  }

  V? get(K key) => _map[key];

  bool contains(K key) => _map.containsKey(key);

  V? getCached(K key) {
    final data = _map[key];
    if (data != null) {
      return data;
    }
    return _map[key] = creator.call(key);
  }
}
