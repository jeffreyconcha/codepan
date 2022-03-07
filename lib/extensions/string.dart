import 'package:inflection3/inflection3.dart';

const _true = <String>['true', 'yes', 'on', '1'];
const _false = <String>['false', 'no', 'off', '0'];
const _loweredInTitle = <String>['of', 'and', 'or', 'is', 'are', 'a', 'with'];
const _punctuations = <String>[',', '.', '?', '!', ';', ':'];

extension StringUtils on String {
  String getInitials([int max = 2]) {
    final buffer = StringBuffer();
    var count = 0;
    for (final word in this.split(' ')) {
      buffer.write(word.substring(0, 1));
      count++;
      if (count >= max) {
        break;
      }
    }
    return buffer.toString().toUpperCase();
  }

  bool equalsIgnoreCase(String? other) {
    if (other != null) {
      return this.toLowerCase() == other.toLowerCase();
    }
    return false;
  }

  String capitalize([bool isSentence = false]) {
    if (!isSentence) {
      final space = ' ';
      if (this.contains(space)) {
        final buffer = StringBuffer();
        final words = this.split(space);
        for (int i = 0; i < words.length; i++) {
          final word = words[i];
          if (_loweredInTitle.contains(word) && i != 0) {
            buffer.write(word);
          } else {
            buffer.write('${word[0].toUpperCase()}${word.substring(1)}');
          }
          if (i < words.length - 1) {
            buffer.write(space);
          }
        }
        return buffer.toString();
      }
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  String decapitalize() {
    return '${this[0].toLowerCase()}${this.substring(1)}';
  }

  String? nullify() {
    if ((this == 'null' || this.isEmpty)) {
      return null;
    }
    return this;
  }

  String complete(
    dynamic input, {
    String? identifier,
    bool withQuotes = false,
    bool isSpannable = false,
  }) {
    final buffer = StringBuffer();
    final id = identifier ?? '\$';
    final separator = ' ';
    final list = <String>[];
    if (input is String) {
      list.add(input);
    } else if (input is List<String>) {
      list.addAll(input);
    }
    final iterator = list.iterator;
    final words = this.split(separator);
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.contains(id) && iterator.moveNext()) {
        final replacement =
            withQuotes ? '\"${iterator.current}\"' : iterator.current;

        if (isSpannable) {
          buffer.write('<s>$replacement</s>');
        } else {
          buffer.write(replacement);
        }
        final code = word.runes.last;
        final last = String.fromCharCode(code);
        if (_punctuations.contains(last)) {
          buffer.write(last);
        }
      } else {
        buffer.write(word);
      }
      if (i < words.length - 1) {
        buffer.write(separator);
      }
    }
    return buffer.toString();
  }

  String toSnake() {
    return SNAKE_CASE.convert(this);
  }

  String _wordToPast(String word) {
    final dash = '-';
    if (word.contains(dash)) {
      final first = word.split(dash).first;
      final past = PAST.convert(first);
      return word.replaceAll(first, past);
    }
    return PAST.convert(word);
  }

  String toPast() {
    final space = ' ';
    if (this.contains(space)) {
      final words = this.split(space);
      final buffer = StringBuffer();
      final length = words.length;
      for (int i = 0; i < length; i++) {
        final word = words[i];
        if (i == 0) {
          buffer.write(_wordToPast(word));
        } else {
          buffer.write(word);
        }
        if (i < length - 1) {
          buffer.write(space);
        }
      }
      return buffer.toString();
    }
    return _wordToPast(this);
  }

  String toSingular() {
    return SINGULAR.convert(this);
  }

  String toPlural() {
    return PLURAL.convert(this);
  }

  bool? toBool() {
    if (_true.contains(this)) {
      return true;
    } else if (_false.contains(this)) {
      return false;
    }
    return null;
  }

  int count(String separator) {
    final split = this.split(separator);
    return split.length - 1;
  }

  String hideCharAt({
    required int index,
    required int count,
    String replacement = '*',
  }) {
    if (index + count <= this.length) {
      int _index = index;
      final buffer = StringBuffer();
      buffer.write(this.substring(0, _index));
      for (int i = 0; i < count; i++) {
        buffer.write(replacement);
        _index++;
      }
      buffer.write(this.substring(_index, this.length));
      return buffer.toString();
    }
    throw Exception('Invalid parameters, length is only ${this.length}.');
  }

  String get alphaNumeric {
    return this.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }

  String get alphabets {
    return this.replaceAll(RegExp(r'[^A-Za-z]'), '');
  }

  int get numbers {
    final numeric = this.replaceAll(RegExp(r'[^0-9]'), '');
    return int.parse(numeric);
  }

  String get last {
    if (this.isNotEmpty) {
      return substring(length - 1, length);
    }
    return '';
  }
}
