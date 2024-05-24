import 'dart:math' as m;

extension NumExt on num {
  bool isBetween(num start, num end) {
    final min = m.min(start, end);
    final max = m.max(start, end);
    return this >= min && this <= max;
  }
}
