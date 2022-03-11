import 'package:flutter/widgets.dart';

const double baseline = 360;
const double boundary = 480;
const double maxRatio = 480 / 360;

class Dimension {
  final BuildContext context;
  final bool isSafeArea;

  MediaQueryData get data => MediaQuery.of(context);

  const Dimension.of(
    this.context, {
    this.isSafeArea = false,
  });

  double get deviceRatio => max / min;

  double get pixelRatio => data.devicePixelRatio;

  Orientation get orientation => data.orientation;

  double at(double dp) {
    final sw = min;
    final ratio = sw <= boundary ? (sw / baseline) : maxRatio;
    return dp * ratio;
  }

  double scale(double dp) {
    return at(dp) * data.textScaleFactor;
  }

  double viewPortFraction(double fraction) {
    final sw = min;
    if (sw > boundary) {
      final ratio = boundary / sw;
      return ratio * fraction;
    }
    return fraction;
  }

  double get statusBarHeight => data.padding.top;

  double get bottomPadding => data.padding.bottom;

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
    final padding = isSafeArea ? data.padding.top : 0;
    return data.size.height - padding;
  }

  double get maxWidth {
    return data.size.width;
  }
}
