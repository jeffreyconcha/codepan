import 'package:flutter/material.dart';

class PanConditional extends StatelessWidget {
  final Widget child, alternative;
  final double width, height;
  final bool condition;

  const PanConditional({
    Key key,
    @required this.condition,
    this.width,
    this.height,
    this.child,
    this.alternative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: condition ? child : alternative,
    );
  }
}
