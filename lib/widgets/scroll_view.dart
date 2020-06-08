import 'package:flutter/cupertino.dart';

class PanScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final EdgeInsets padding;
  final bool disableGlow;
  final Widget child;

  const PanScrollView({
    Key key,
    this.child,
    this.scrollDirection,
    this.padding,
    this.disableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: disableGlow ? DisableScrollGlow() : ScrollBehavior(),
      child: SingleChildScrollView(
        child: child,
        padding: padding,
        scrollDirection: scrollDirection,
      ),
    );
  }
}

class DisableScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
