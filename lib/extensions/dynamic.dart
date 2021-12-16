import 'package:codepan/utils/codepan_utils.dart';

import 'string.dart';

extension DynamicUtils on dynamic {
  bool get isEnum => PanUtils.isEnum(this);

  String get enumValue => PanUtils.enumValue(this);

  String toWords({
    bool allCaps = false,
  }) {
    final words = enumValue.toSnake().replaceAll('_', ' ');
    if (allCaps) {
      return words.toUpperCase();
    }
    return words;
  }

  String toCapitalizedWords() {
    return toWords().capitalize();
  }
}
