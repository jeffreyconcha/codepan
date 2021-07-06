typedef Creator<T> = T Function();

class CacheManager<T> {
  final map = <int, T>{};
  final Creator<T> creator;

  CacheManager(this.creator);

  T getCached(int key) {
    final data = map[key];
    if (data != null) {
      return data;
    }
    return creator.call();
  }
}
