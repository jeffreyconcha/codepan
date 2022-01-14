import 'package:flutter/cupertino.dart';

class CircleContainer extends StatelessWidget {
  final EdgeInsets? margin, padding;
  final Alignment alignment;
  final double? diameter;
  final Widget? child;
  final Color? color;

  const CircleContainer({
    Key? key,
    this.child,
    this.color,
    this.diameter,
    this.margin,
    this.padding,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: child,
    );
  }
}
