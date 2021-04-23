import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PanIcon extends StatelessWidget {
  final EdgeInsetsGeometry? margin, padding;
  final Color? color, background;
  final double? width, height;
  final String? package;
  final Alignment alignment;
  final bool isInternal;
  final String icon;
  final BoxFit fit;

  const PanIcon({
    Key? key,
    required this.icon,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.isInternal = false,
    this.width,
    this.height,
    this.color,
    this.background,
    this.margin,
    this.padding,
    this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _package = isInternal ? 'codepan' : null;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      color: background,
      child: SvgPicture.asset(
        'assets/icons/$icon.svg',
        color: color,
        fit: fit,
        alignment: alignment,
        package: package ?? _package,
      ),
    );
  }
}
