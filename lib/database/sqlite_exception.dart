import 'package:sqflite_sqlcipher/sqflite.dart';

class SQLiteException extends DatabaseException {
  static const String databaseNotOpened = 'Database is not open, '
      'client did not call await openDatabase().';
  static const String invalidSqliteEntity = 'Invalid argument, please pass an '
      'instance of SQLiteEntity';
  static const String noFieldValues = 'No fields and values added in query';
  static const String noConditions = 'No conditions added in query.';
  static const String noFields = 'No fields added in query.';
  static const String initializationFailed = 'Failed to initialize database.';
  static const String invalidConditionList =
      'Cannot combine OR and AND conditions.';
  static const String unknownEntity = 'Unknown entity.';
  static const String invalidForeignKeyName =
      'Invalid foreign key name, please follow the proper convention.';

  SQLiteException(String message) : super(message);

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
