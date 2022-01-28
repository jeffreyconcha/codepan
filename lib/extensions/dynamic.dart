import 'package:codepan/utils/codepan_utils.dart';

import 'string.dart';

extension DynamicUtils on dynamic {
  bool get isEnum => PanUtils.isEnum(this);

  String get enumValue => PanUtils.enumValue(this);

  String get snake => enumValue.toSnake();

  String toWords({
    bool allCaps = false,
    String separator = ' ',
  }) {
    final words = snake.replaceAll('_', separator);
    if (allCaps) {
      return words.toUpperCase();
    }
    return words;
  }

  String toCapitalizedWords() {
    return toWords().capitalize();
  }
}
