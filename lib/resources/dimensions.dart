import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double defaultWidthBaseline = 360;
const double defaultWidthBoundary = 480;

class Dimension {
  final double baseline, boundary;
  final BuildContext context;
  final bool isSafeArea;

  MediaQueryData get data => MediaQuery.of(context);

  double get maxRatio => boundary / baseline;

  const Dimension.of(
    this.context, {
    this.isSafeArea = false,
    this.baseline = defaultWidthBaseline,
    this.boundary = defaultWidthBoundary,
  });

  double get deviceRatio => max / min;

  double get pixelRatio => data.devicePixelRatio;

  Orientation get orientation => data.orientation;

  double at(double dp) {
    final sw = min;
    final ratio = sw <= boundary ? (sw / baseline) : maxRatio;
    return dp * ratio;
  }

  double scale(double dp) => at(dp) * data.textScaleFactor;

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

  double get max => m.max(maxWidth, maxHeight);

  double get min => m.min(maxWidth, maxHeight);

  double get maxHeight {
    final padding = isSafeArea ? data.padding.top : 0;
    return data.size.height - padding;
  }

  double get maxWidth {
    return data.size.width;
  }
}