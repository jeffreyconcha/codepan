import 'package:codepan/database/sqlite_adapter.dart';

abstract class DatabaseInitializer {
  Future<void> onCreate(SQLiteAdapter db, int version);

  Future<void> onUpgrade(SQLiteAdapter db, int ov, int nv);

  Future<void> onDowngrade(SQLiteAdapter db, int ov, int nv);
}
