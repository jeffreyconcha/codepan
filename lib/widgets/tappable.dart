import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
  final VoidCallback? onTap, onLongPress, onDoubleTap, onTapCancel;
  final Color? splashColor, highlightColor, hoverColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Widget? child;
  final Color color;

  const Tappable({
    super.key,
    this.child,
    this.color = Colors.transparent,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onTapCancel,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          child: child,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onTapCancel: onTapCancel,
        splashColor: splashColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
      ),
    );
  }
}
