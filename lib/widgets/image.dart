import 'package:flutter/widgets.dart';

class PanImage extends StatelessWidget {
  final EdgeInsetsGeometry margin, padding;
  final double width, height;
  final Alignment alignment;
  final String icon;
  final BoxFit fit;

  const PanImage({
    Key key,
    @required this.icon,
    this.width,
    this.height,
    this.fit,
    this.margin,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment ?? Alignment.center,
      child: Image.asset(
        'assets/images/$icon.png',
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}
