import 'package:codepan/data/database/initializer.dart';
import 'package:codepan/data/database/sqlite_adapter.dart';

class SqliteCache {
  static final Map<String, SqliteAdapter> cache = Map();

  static Future<SqliteAdapter> getDatabase({
    required String name,
    required String password,
    required int version,
    required DatabaseInitializer initializer,
  }) async {
    if (!cache.containsKey(name)) {
      final db = SqliteAdapter(
          name: name,
          password: password,
          version: version,
          schema: initializer.schema,
          onCreate: (db, version) async {
            await initializer.onCreate(db, version);
          },
          onUpgrade: (db, ov, nv) async {
            await initializer.onUpgrade(db, ov, nv);
          },
          onDowngrade: (db, ov, nv) async {
            await initializer.onDowngrade(db, ov, nv);
          });
      await db.openConnection();
      await db.checkVersion();
      cache[name] = db;
    }
    return cache[name]!;
  }
}
