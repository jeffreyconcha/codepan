import 'package:sqflite_sqlcipher/sqflite.dart';

class SqliteException extends DatabaseException {
  static const String databaseNotOpened = 'Database is not open, '
      'client did not call await openDatabase().';
  static const String invalidSqliteEntity = 'Invalid argument, please pass an '
      'instance of SqliteEntity';
  static const String noFieldValues = 'No fields and values added in query';
  static const String noConditions = 'No conditions added in query.';
  static const String noFields = 'No fields added in query.';
  static const String initializationFailed = 'Failed to initialize database.';
  static const String invalidConditionList =
      'Cannot combine OR and AND conditions.';
  static const String unknownEntity = 'Unknown entity.';
  static const String noSchemaFoundInQuery =
      'No table schema found. Please provide an instance of \"TableSchema\" to the '
      'main query to join tables using foreign keys.';
  static const String invalidTableType =
      'Invalid table type, table can only be a type of String, Table or TableSchema.';
  static const String noFieldsInQuery = 'No fields found in query.';

  SqliteException(super.message);

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
