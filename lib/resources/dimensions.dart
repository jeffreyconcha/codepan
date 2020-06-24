import 'package:flutter/widgets.dart';

class Dimension {
  static const double BASELINE = 360;
  final BuildContext context;

  const Dimension.of(this.context);

  double at(double dp) {
    if (context != null) {
      final data = MediaQuery.of(context);
      final size = data.size;
      final width = size.width;
      final height = size.height;
      final reference = width < height ? width : height;
      return dp * (reference / BASELINE);
    }
    return dp;
  }

  double get maxHeight {
    if (context != null) {
      final data = MediaQuery.of(context);
      return data.size.height;
    }
    return double.infinity;
  }

  double get maxWidth {
    if (context != null) {
      final data = MediaQuery.of(context);
      return data.size.width;
    }
    return double.infinity;
  }
}
