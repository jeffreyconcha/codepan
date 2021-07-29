import 'package:codepan/utils/codepan_utils.dart';

class ProgressData {
  final int? current;
  final int? max;

  String get percentValue => PanUtils.getPercentage(current!, max!);

  String get value => '$current/$max';

  double get percentage => current!.toDouble() / max!.toDouble();

  const ProgressData({
    required this.current,
    required this.max,
  });

  static const zero = ProgressData(current: 0, max: 0);
}
