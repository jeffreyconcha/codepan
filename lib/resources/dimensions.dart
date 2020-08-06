import 'package:flutter/widgets.dart';

class Dimension {
  static const double baseline = 360;
  final BuildContext context;
  final bool isSafeArea;

  const Dimension.of(
    this.context, {
    this.isSafeArea = false,
  });

  double at(double dp) {
    if (context != null) {
      final data = MediaQuery.of(context);
      final size = data.size;
      final width = size.width;
      final height = size.height;
      final reference = width < height ? width : height;
      return dp * (reference / baseline);
    }
    return dp;
  }

  double scale(double dp) {
    if (context != null) {
      final data = MediaQuery.of(context);
      return at(dp) * data.textScaleFactor;
    }
    return dp;
  }

  double get statusBarHeight {
    if (context != null) {
      final data = MediaQuery.of(context);
      return data.padding.top;
    }
    return double.infinity;
  }

  double get max {
    final mw = maxWidth;
    final mh = maxHeight;
    return mh > mw ? mh : mw;
  }

  double get min {
    final mw = maxWidth;
    final mh = maxHeight;
    return mh < mw ? mh : mw;
  }

  double get maxHeight {
    if (context != null) {
      final data = MediaQuery.of(context);
      final padding = isSafeArea ? data.padding.top : 0;
      return data.size.height - padding;
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
