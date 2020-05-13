import 'package:flutter/widgets.dart';

class Dimension {
  static const double BASELINE = 360;
  final BuildContext context;

  const Dimension.of(this.context);

  double at(double dp) {
    if (context != null) {
      MediaQueryData data = MediaQuery.of(context);
      Size size = data.size;
      return dp * (size.width / BASELINE);
    }
    return dp;
  }

  double get maxHeight {
    if (context != null) {
      MediaQueryData data = MediaQuery.of(context);
      print(data.size);
      return data.size.height;
    }
    return double.infinity;
  }

  double get maxWidth {
    if (context != null) {
      MediaQueryData data = MediaQuery.of(context);
      print(data.size);
      return data.size.width;
    }
    return double.infinity;
  }
}
