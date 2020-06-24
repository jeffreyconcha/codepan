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
        return SingleChildScrollView(
          padding: padding,
          scrollDirection: scrollDirection,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isVertical ? constraints.maxHeight : 0,
              minWidth: !isVertical ? constraints.maxWidth : 0,
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
