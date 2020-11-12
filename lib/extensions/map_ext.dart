import 'package:codepan/utils/codepan_utils.dart';

extension MapUtils on Map<String, dynamic> {
  int toInt(String key) {
    final value = this[key];
    return PanUtils.parseInt(value);
  }

  double toDouble(String key) {
    final value = this[key];
    return PanUtils.parseDouble(value);
  }

  bool toBool(String key) {
    final value = this[key];
    return PanUtils.parseBool(value);
  }
}
