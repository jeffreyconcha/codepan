import 'field.dart';
import 'package:codepan/extensions/string_ext.dart';

class Table {
  final String name;

  String get alias {
    if (name != null) {
      final int max = 3;
      final buffer = StringBuffer();
      final vowels = RegExp(r'[aeiuo]');
      final raw = name.replaceAll('_tb', '');
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
      return buffer.toString();
    }
    return null;
  }

  Field field(String name) {
    return Field(name)..setAlias(alias);
  }

  Table(this.name);
}
