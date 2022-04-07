import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';

class Elevated extends StatelessWidget {
  final double? width, height, shadowBlurRadius, spreadRadius;
  final EdgeInsets? padding, margin;
  final Color? color, shadowColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Offset? shadowOffset;
  final BoxShape boxShape;
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
    this.color = Colors.white,
    this.width,
    this.height,
    this.radius = 0,
    this.spreadRadius,
    this.borderRadius,
    this.boxShadow,
    this.boxShape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final _borderRadius =
        boxShape == BoxShape.rectangle ? BorderRadius.circular(radius) : null;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? _borderRadius,
        shape: boxShape,
        boxShadow: boxShadow ??
            <BoxShadow>[
              BoxShadow(
                color: shadowColor ?? t.shadowColor,
                blurRadius: shadowBlurRadius ?? d.at(10),
                spreadRadius: spreadRadius ?? d.at(2),
                offset: shadowOffset ?? Offset.zero,
              )
            ],
      ),
      child: boxShape == BoxShape.rectangle
          ? ClipRRect(
              child: child,
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
            )
          : ClipOval(
              child: child,
            ),
    );
  }
}
