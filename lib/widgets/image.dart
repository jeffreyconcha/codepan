import 'package:flutter/widgets.dart';

class PanImage extends StatelessWidget {
  final Alignment? alignment;
  final EdgeInsetsGeometry? margin, padding;
  final double? width, height;
  final String image;
  final BoxFit? fit;

  const PanImage({
    Key? key,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.margin,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final asset = !image.contains('.') ? '$image.png' : image;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: Image.asset(
        'assets/images/$asset',
        fit: fit,
        width: width,
        height: height,
        alignment: alignment ?? Alignment.center,
      ),
    );
  }
}
