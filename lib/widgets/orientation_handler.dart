import 'dart:math' as math;
import 'package:flutter/material.dart';

class OrientationHandler extends StatelessWidget {
  final Widget child;

  const OrientationHandler({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final max = math.max<double>(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final min = math.min<double>(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final ratio = max / min;
        return SingleChildScrollView(
          child: Container(
            height: constraints.maxWidth * ratio,
            child: child,
          ),
        );
      },
    );
  }
}
