import 'package:flutter/widgets.dart';

class PanImage extends StatelessWidget {
  final EdgeInsetsGeometry margin, padding;
  final double width, height;
  final Alignment alignment;
  final String jpg;
  final String png;
  final BoxFit fit;

  const PanImage({
    Key key,
    this.png,
    this.jpg,
    this.width,
    this.height,
    this.fit,
    this.margin,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final asset = png != null ? '$png.png' : '$jpg.jpg';
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment ?? Alignment.center,
      child: Image.asset(
        'assets/images/$asset',
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}
