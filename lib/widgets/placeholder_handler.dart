import 'package:flutter/material.dart';

typedef ChildBuilder = Widget Function(BuildContext context);

class PlaceholderHandler extends StatelessWidget {
  final Widget child, placeholder;
  final EdgeInsets margin, padding;
  final double width, height;
  final ChildBuilder builder;
  final Alignment alignment;
  final bool condition;
  final Color color;

  const PlaceholderHandler({
    Key key,
    this.child,
    this.builder,
    this.placeholder,
    this.condition = false,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      child: condition ? child ?? builder?.call(context) : placeholder,
    );
  }
}
