import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:html_unescape/html_unescape.dart';

const prefixKey = '\$prefix';
const boolPrefixes = <String>[
  'is',
  'has',
  'with',
  'did',
  'can',
];

extension MapUtils on Map<String, dynamic> {
  int getInt(String key) {
    final value = this[getKey(key)];
    return PanUtils.parseInt(value);
  }

  double getDouble(String key) {
    final value = this[getKey(key)];
    return PanUtils.parseDouble(value);
  }

  bool getBool(String key) {
    final value = this[getKey(key)];
    return PanUtils.parseBool(value);
  }

  T getEnum<T>({
    @required String key,
    @required List<T> values,
  }) {
    final value = this[getKey(key)];
    for (final element in values) {
      if (value == element.enumValue()) {
        return element;
      }
    }
    return null;
  }

  dynamic get(String key) {
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

  bool hasKey(String key) {
    return this.containsKey(getKey(key));
  }

  void setPrefix(
    String prefix, {
    int index,
  }) {
    if (index != null && index != 0) {
      this[prefixKey] = '$prefix.$index';
    } else {
      this[prefixKey] = prefix;
    }
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
      if (prefix != null) {
        return '$prefix.$key';
      }
    }
    return key;
  }
}
