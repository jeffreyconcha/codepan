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

  double? get deviceRatio {
    if (context != null) {
      final data = MediaQuery.of(context);
      final size = data.size;
      return size.width / size.height;
    }
    return null;
  }

  double at(double dp) {
    final sw = min;
    final ratio = sw <= boundary ? (sw / baseline) : maxRatio;
    return dp * ratio;
  }

  double scale(double dp) {
    if (context != null) {
      final data = MediaQuery.of(context);
      return at(dp) * data.textScaleFactor;
    }
    return dp;
  }

  double viewPortFraction(double fraction) {
    final sw = min;
    if (sw > boundary) {
      final ratio = boundary / sw;
      return ratio * fraction;
    }
    return fraction;
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
