import 'package:flutter/widgets.dart';

const double baseline = 360;
const double boundary = 480;
const double maxRatio = 480 / 360;

class Dimension {
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
      final ratio = reference <= boundary ? (reference / baseline) : maxRatio;
      return dp * ratio;
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
    return 0;
  }

  double get bottomPadding {
    if (context != null) {
      final data = MediaQuery.of(context);
      return data.padding.bottom;
    }
    return 0;
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
