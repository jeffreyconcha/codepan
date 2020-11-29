import 'package:codepan/utils/codepan_utils.dart';

extension DynamicUtils on dynamic {
  bool isEnum() {
    return PanUtils.isEnum(this);
  }
}
