import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:html_unescape/html_unescape.dart';

const prefixKey = '\$prefix';
const prefixSeparator = '\$prefixSeparator';
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
      final value = this[getKey(key)];
      return PanUtils.parseInt(value);
    }
    return null;
  }

  double? getDouble(String key) {
    if (hasKey(key)) {
      final value = this[getKey(key)];
      return PanUtils.parseDouble(value);
    }
    return null;
  }

  bool? getBool(String key) {
    if (hasKey(key)) {
      final value = this[getKey(key)];
      return PanUtils.parseBool(value);
    }
    return null;
  }

  List? getList(String key) {
    if (hasKey(key)) {
      final value = this[getKey(key)];
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
      final value = this[getKey(key)];
      for (final element in values) {
        if (value == element.enumValue) {
          return element;
        }
      }
    }
    return null;
  }

  dynamic get(String key) {
    if (hasKey(key)) {
      final value = this[getKey(key)];
      final split = key.toSnake().split('_');
      if (boolPrefixes.contains(split.first)) {
        return PanUtils.parseBool(value);
      } else if (value is String) {
        final unescape = HtmlUnescape();
        return unescape.convert(value);
      }
      return value;
    }
    return null;
  }

  bool hasKey(String key) {
    final _key = getKey(key);
    return this.containsKey(_key);
  }

  bool hasKeyWithValue(String key) {
    final _key = getKey(key);
    if (this.containsKey(_key)) {
      return this[_key] != null;
    }
    return false;
  }

  void setPrefix(
    String prefix, {
    int? index,
    String? separator = '.',
  }) {
    if (index != null && index != 0) {
      this[prefixKey] = '$prefix.$index';
    } else {
      this[prefixKey] = prefix;
    }
    this[prefixSeparator] = separator;
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
      final separator = this[prefixSeparator];
      if (prefix != null) {
        return '$prefix$separator$key';
      }
    }
    return key;
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
