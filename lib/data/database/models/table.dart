import 'package:codepan/data/database/models/field.dart';
import 'package:codepan/data/database/schema.dart';
import 'package:codepan/data/database/sqlite_query.dart';
import 'package:codepan/data/database/sqlite_statement.dart';
import 'package:codepan/extensions/dynamic.dart';
import 'package:codepan/extensions/string.dart';
import 'package:inflection3/inflection3.dart';

class Table<T extends DatabaseEntity> {
  final String name;
  final T? entity;
  int? joinIndex;

  String get alias {
    final int max = 3;
    final buffer = StringBuffer();
    final vowels = RegExp(r'[aeiuo]');
    final raw = name.replaceAll(DatabaseSchema.tableSuffix, '');
    List<String> list = raw.split('_');
    for (final word in list) {
      final lower = word.toLowerCase();
      final first = lower.substring(0, 1);
      final rest = lower.substring(1, word.length);
      final consonants = rest.replaceAllMapped(vowels, (match) => '');
      final result = word != list.first
          ? '${first.toUpperCase()}$consonants'
          : '$first$consonants';
      if (result.length >= max) {
        buffer.write(result.substring(0, max));
      } else {
        buffer.write(result);
      }
    }
    if (joinIndex != null) {
      buffer.write('$joinIndex');
    }
    return buffer.toString();
  }

  /// References the field of the table when using condition in queries.
  /// It automatically adds the prefix for joining multiple tables.
  /// <br/><br/>
  /// Only use this as the __field__ part of the condition
  /// and not as _value_ part.
  String rawField(String name) {
    return field(name).field;
  }

  /// References the field of the table when using condition in queries.
  /// It automatically adds the prefix for joining multiple tables.
  /// <br/><br/>
  /// Only use this as the __value__ part of the condition
  /// and not as _field_ part.
  Field field(String name) {
    return Field(
      field: name,
      table: this,
    );
  }

  Field order({
    required String field,
    Order order = Order.ascending,
    bool collate = false,
  }) {
    return Field.order(
      field: field,
      order: order,
      collate: collate,
      table: this,
    );
  }

  Table(
    this.name, {
    this.entity,
  });

  void setJoinNumber(int joinIndex) {
    this.joinIndex = joinIndex;
  }

  String? asForeignKey() {
    final buffer = StringBuffer();
    final name = entity.enumValue;
    final snake = SNAKE_CASE.convert(name);
    final words = snake.split('_');
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (i < words.length - 1) {
        buffer.write('${word.capitalize()}');
      } else {
        final singular = SINGULAR.convert(word);
        buffer.write('${singular.capitalize()}');
        buffer.write('${SqliteStatement.id.capitalize()}');
      }
    }
    return buffer.toString().decapitalize();
  }
}
