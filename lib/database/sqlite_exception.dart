import 'package:sqflite_sqlcipher/sqflite.dart';

class SQLiteException extends DatabaseException {
  static const String DATABASE_NOT_OPENED = "Database is not open, "
      "client did not call await openDatabase().";

  static const String INVALID_SQLITE_ENTITY = "Invalid argument, please pass an "
          "instance of SQLiteEntity";

  static const String NO_FIELD_VALUES = "No fields and values added in query";

  static const String NO_CONDITIONS = "No conditions added in query.";

  static const String NO_FIELDS = "No fields added in query.";

  SQLiteException(String message) : super(message);
}
