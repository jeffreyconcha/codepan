import 'package:codepan/utils/codepan_utils.dart';

extension MapUtils on Map<String, dynamic> {
  int getInt(String key) {
    final value = this[key];
    return PanUtils.parseInt(value);
  }

  double getDouble(String key) {
    final value = this[key];
    return PanUtils.parseDouble(value);
  }

  bool getBool(String key) {
    final value = this[key];
    return PanUtils.parseBool(value);
  }
}
