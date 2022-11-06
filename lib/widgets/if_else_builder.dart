import 'package:flutter/material.dart';

class IfElseBuilder extends StatelessWidget {
  final WidgetBuilder? ifBuilder, elseBuilder;
  final BoxConstraints? constraints;
  final Widget? ifChild, elseChild;
  final EdgeInsets? margin, padding;
  final BoxDecoration? decoration;
  final double? width, height;
  final Alignment? alignment;
  final bool? condition;
  final Color? color;

  const IfElseBuilder({
    super.key,
    this.ifChild,
    this.elseChild,
    this.ifBuilder,
    this.elseBuilder,
    this.condition,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.alignment,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: decoration,
      constraints: constraints,
      child: condition ?? false
          ? ifBuilder?.call(context) ?? ifChild
          : elseBuilder?.call(context) ?? elseChild,
    );
  }
}
