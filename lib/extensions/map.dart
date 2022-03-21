import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:html_unescape/html_unescape.dart';

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

  double? getDouble(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      return PanUtils.parseDouble(value);
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

  List? getList(String key) {
    if (hasKey(key)) {
      final value = getValue(key);
      if (value is List) {
        return value;
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
          if (value.snake == element.snake) {
            return element;
          }
        }
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
        final unescape = HtmlUnescape();
        return unescape.convert(value).replaceAll('\n ', '\n');
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
    String prefix, {
    String separator = '.',
  }) {
    this[prefixFallbackKey] = prefix;
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
      if (prefix != null) {
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
