import 'package:codepan/data/database/initializer.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';

class SqliteCache {
  static final Map<String, SqliteAdapter> cache = Map();

  static Future<SqliteAdapter> getDatabase({
    required String name,
    required String password,
    required int version,
    required DatabaseInitializer initializer,
    String? libraryPath,
  }) async {
    if (!cache.containsKey(name)) {
      final db = SqliteAdapter(
        name: name,
        password: password,
        version: version,
        libraryPath: libraryPath,
        initializer: initializer,
      );
      await db.openConnection();
      await db.checkVersion();
      cache[name] = db;
    }
    return cache[name]!;
  }
}
