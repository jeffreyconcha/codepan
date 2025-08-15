import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/utils/codepan_utils.dart';

const prefixFallbackKey = '\$prefixFallback';
const fallbackSeparatorKey = '\$fallbackSeparator';
const prefixKey = '\$prefix';
const separatorKey = '\$separator';
const boolPrefixes = <String>[
  'is',
  'has',
  'with',
  'did',
  'can',
];

extension MapUtils on Map<String, dynamic> {
  int? getInt(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      return PanUtils.parseInt(value);
    }
    return null;
  }

  int? optInt(List<String> keys) {
    for (final key in keys) {
      if (hasKey(key)) {
        return getInt(key);
      }
    }
    return null;
  }

  double? getDouble(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      return PanUtils.parseDouble(value);
    }
    return null;
  }

  double? optDouble(List<String> keys) {
    for (final key in keys) {
      if (hasKey(key)) {
        return getDouble(key);
      }
    }
    return null;
  }

  bool? getBool(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      return PanUtils.parseBool(value);
    }
    return null;
  }

  bool? optBool(List<String> keys) {
    for (final key in keys) {
      if (hasKey(key)) {
        return getBool(key);
      }
    }
    return null;
  }

  List<T>? getList<T>(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      if (value is List) {
        final list = <T>[];
        value.loop((item, index) {
          list.add(item as T);
        });
        return list;
      }
    }
    return null;
  }

  List<T>? optList<T>(List<String> keys) {
    for (final key in keys) {
      if (hasKey(key)) {
        return getList<T>(key);
      }
    }
    return null;
  }

  T? getEnum<T>({
    required String key,
    required List<T> values,
  }) {
    if (hasKey(key)) {
      final value = getValue(key);
      if (value is String) {
        for (final element in values) {
          if (value.snake.replaceAll('_', '') ==
              element.snake.replaceAll('_', '')) {
            return element;
          }
        }
      }
    }
    return null;
  }

  dynamic opt(List<String> keys) {
    for (final key in keys) {
      if (hasKey(key)) {
        return get(key);
      }
    }
    return null;
  }

  dynamic get(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      final split = key.toSnake().split('_');
      if (boolPrefixes.contains(split.first)) {
        return PanUtils.parseBool(value);
      } else if (value is String) {
        if (value.trim().isNotEmpty) {
          return value.unescaped.trim();
        }
        return null;
      }
      return value;
    }
    return null;
  }

  dynamic getValue(String key) {
    final _key = getKey(key);
    final value = this[_key];
    if (value != null) {
      return value;
    }
    final fallbackKey = getFallbackKey(_key);
    if (fallbackKey != null) {
      return this[fallbackKey];
    }
    return null;
  }

  bool isNotNull(String key) {
    return !isNull(key);
  }

  bool isNull(String key) {
    return get(key) == null;
  }

  bool hasKey(String key) {
    final _key = getKey(key);
    if (this.containsKey(_key)) {
      return true;
    }
    final fallbackKey = getFallbackKey(_key);
    if (fallbackKey != null) {
      return this.containsKey(fallbackKey);
    }
    return false;
  }

  bool hasKeyWithValue(String key) {
    final _key = getKey(key);
    if (this.containsKey(_key)) {
      return this[_key] != null;
    }
    final fallbackKey = getFallbackKey(_key);
    if (fallbackKey != null) {
      return this[fallbackKey] != null;
    }
    return false;
  }

  void setPrefix(
    String prefix, {
    int? index,
    String separator = '.',
  }) {
    if (index != null && index != 0) {
      this[prefixKey] = '$prefix$index';
    } else {
      this[prefixKey] = prefix;
    }
    this[separatorKey] = separator;
  }

  void setPrefixFallback(
    dynamic prefix, {
    String separator = '.',
  }) {
    assert(prefix is String || prefix is List<String>,
        'Prefix should only be a type of String or List<String>');
    if (prefix is String) {
      this[prefixFallbackKey] = prefix;
    } else if (prefix is List<String>) {
      final buffer = StringBuffer();
      prefix.loop((item, index) {
        buffer.write(item);
        if (index < prefix.length - 1) {
          buffer.write(',');
        }
      });
      this[prefixFallbackKey] = buffer.toString();
    }
    this[fallbackSeparatorKey] = separator;
  }

  void addPrefix(dynamic additional) {
    if (this.containsKey(prefixKey) && additional != null) {
      final prefix = this[prefixKey];
      this[prefixKey] = '$prefix${additional.toString()}';
    }
  }

  String getKey(String key) {
    if (this.containsKey(prefixKey)) {
      final prefix = this[prefixKey];
      final separator = this[separatorKey];
      if (prefix != null) {
        return '$prefix$separator$key';
      }
    }
    return key;
  }

  String? getFallbackKey(String key) {
    if (this.containsKey(prefixFallbackKey)) {
      final prefix = this[prefixFallbackKey];
      final separator = this[fallbackSeparatorKey];
      if (prefix is String) {
        if (prefix.contains(',')) {
          final prefixes = prefix.split(',');
          for (final p in prefixes) {
            final fk = '$p$separator$key';
            if (this.containsKey(fk)) {
              return fk;
            }
          }
        }
        return '$prefix$separator$key';
      }
    }
    return null;
  }

  Map<String, dynamic> copy() {
    return Map.of(this);
  }

  Future<void> asyncLoop(Future<void> action(String key, dynamic value)) async {
    for (final map in this.entries) {
      await action(map.key, map.value);
    }
  }
}

extension MapStringUtils on Map {
  void clean() {
    this.removeWhere((key, value) => value == null);
  }
}
