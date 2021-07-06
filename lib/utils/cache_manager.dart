typedef Creator<T> = Future<T> Function(int key);

class CacheManager<T> {
  final map = <int, T>{};
  final Creator<T> creator;

  CacheManager(this.creator);

  Future<T> getCached(int key) async {
    final data = map[key];
    if (data != null) {
      return data;
    }
    return await creator.call(key);
  }
}
