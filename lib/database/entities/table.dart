import 'field.dart';
import 'package:codepan/extensions/string.dart';

class Table {
  final String name;

  String get alias {
    if (name != null) {
      final int max = 3;
      final buffer = StringBuffer();
      final vowels = RegExp(r'[aeiuo]');
      final raw = name.replaceAll('_tb', '');
      buffer.write(raw.substring(0, 1));
      final rest = raw.substring(1, raw.length);
      List<String> list = rest.split('_');
      for (final word in list) {
        final text = word.replaceAllMapped(vowels, (match) => '').toLowerCase();
        int m = word == list.first ? max - 1 : max;
        final consonants = word != list.first ? text.capitalize() : text;
        if (consonants.length > m) {
          buffer.write(consonants.substring(0, m));
        } else {
          buffer.write(consonants);
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
