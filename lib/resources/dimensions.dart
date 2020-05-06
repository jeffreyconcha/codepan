import 'package:flutter/widgets.dart';

mixin Dimension {
  final double baseline = 360;
  BuildContext _context;

  void setDimensionContext(BuildContext context) {
    this._context = context;
  }

  double dimen(double dp) {
    if (_context != null) {
      MediaQueryData data = MediaQuery.of(_context);
      Size size = data.size;
      return dp * (size.width / baseline);
    }
    return dp;
  }

  double get maxHeight {
    if (_context != null) {
      MediaQueryData data = MediaQuery.of(_context);
      print(data.size);
      return data.size.height;
    }
    return double.infinity;
  }

  double get maxWidth {
    if (_context != null) {
      MediaQueryData data = MediaQuery.of(_context);
      print(data.size);
      return data.size.width;
    }
    return double.infinity;
  }
}
