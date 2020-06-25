import 'package:flutter/cupertino.dart';

class PanScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final EdgeInsets padding;
  final Widget child;

  const PanScrollView({
    Key key,
    this.child,
    this.padding,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVertical = scrollDirection == Axis.vertical;
    return LayoutBuilder(
      builder: (context, constraints) {
        final mw = constraints.maxWidth;
        final mh = constraints.maxHeight;
        final max = mh > mw ? mh : mw;
        return SingleChildScrollView(
          padding: padding,
          scrollDirection: scrollDirection,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isVertical ? max : 0,
              minWidth: !isVertical ? max : 0,
            ),
            child: isVertical
                ? IntrinsicHeight(
                    child: child,
                  )
                : IntrinsicWidth(
                    child: child,
                  ),
          ),
        );
      },
    );
  }
}
