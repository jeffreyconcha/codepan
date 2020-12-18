import 'package:codepan/utils/codepan_utils.dart';
import 'string.dart';

extension DynamicUtils on dynamic {
  bool get isEnum => PanUtils.isEnum(this);

  String get enumValue => PanUtils.enumValue(this);

  String toCapitalizedWords() {
    return enumValue.toSnake().replaceAll('_', ' ').capitalize();
  }
}
