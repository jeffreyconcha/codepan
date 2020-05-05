import 'package:flutter/widgets.dart';

class IconImage extends StatelessWidget {
  final EdgeInsetsGeometry margin, padding;
  final double width, height;
  final Alignment alignment;
  final String icon;
  final BoxFit fit;

  const IconImage(
      {Key key,
      this.icon,
      this.width,
      this.height,
      this.fit,
      this.margin,
      this.padding,
        this.alignment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment ?? Alignment.center,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/$icon.png'), fit: fit)),
    );
  }
}
