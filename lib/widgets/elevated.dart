import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Elevated extends StatelessWidget {
  final double? width, height, shadowBlurRadius, spreadRadius;
  final EdgeInsets? padding, margin;
  final Color? color, shadowColor;
  final Offset? shadowOffset;
  final Alignment? alignment;
  final double radius;
  final Widget child;

  const Elevated({
    Key? key,
    required this.child,
    this.shadowColor,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.margin,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.radius = 0,
    this.alignment,
    this.spreadRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor ?? t.shadowColor,
            blurRadius: shadowBlurRadius ?? d.at(10),
            spreadRadius: spreadRadius ?? d.at(2),
            offset: shadowOffset ?? Offset.zero,
          )
        ],
      ),
      child: child,
    );
  }
}
