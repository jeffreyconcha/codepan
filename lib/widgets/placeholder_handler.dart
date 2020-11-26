import 'package:flutter/material.dart';

typedef WidgetBuilder = Widget Function(BuildContext context);

class PlaceholderHandler extends StatelessWidget {
  final Widget child, placeholder;
  final EdgeInsets margin, padding;
  final double width, height;
  final WidgetBuilder childBuilder, placeholderBuilder;
  final Alignment alignment;
  final bool condition;
  final Color color;

  const PlaceholderHandler({
    Key key,
    this.child,
    this.placeholder,
    this.childBuilder,
    this.placeholderBuilder,
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
      child: condition
          ? child ?? childBuilder?.call(context)
          : placeholder ?? placeholderBuilder?.call(context),
    );
  }
}
