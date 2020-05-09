import 'package:flutter/widgets.dart';

class Dimension {
  final double baseline = 360;
  final BuildContext _context;

  Dimension(this._context);

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
