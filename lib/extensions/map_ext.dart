import 'package:codepan/utils/codepan_utils.dart';
import 'package:html_unescape/html_unescape.dart';

const prefixKey = '\$prefix';

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

  dynamic get(String key) {
    final value = this[getKey(key)];
    if (value is String) {
      final unescape = HtmlUnescape();
      return unescape.convert(value);
    }
    return value;
  }

  bool hasKey(String key) {
    return this.containsKey(getKey(key));
  }

  void setPrefix(String prefix) {
    this[prefixKey] = prefix;
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
