import 'package:flutter/material.dart';

class PlaceholderHandler extends StatelessWidget {
  final Widget child;
  final Widget placeholder;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double width;
  final double height;
  final bool condition;

  const PlaceholderHandler({
    Key key,
    @required this.child,
    this.placeholder,
    this.condition = false,
    this.margin,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: condition ? child : placeholder,
    );
  }
}
