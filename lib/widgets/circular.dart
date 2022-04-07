import 'package:flutter/material.dart';

class Circular extends StatelessWidget {
  final EdgeInsets? margin, padding;
  final double? diameter;
  final Widget? child;
  final Color? color;
  final Border? border;

  const Circular({
    Key? key,
    this.child,
    this.color,
    this.diameter,
    this.margin,
    this.padding,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: border,
      ),
      child: child != null
          ? ClipOval(
              child: child,
            )
          : null,
    );
  }
}
