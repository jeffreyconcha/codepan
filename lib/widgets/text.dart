import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:codepan/config/properties.dart';
import 'package:codepan/resources/colors.dart';

class PanText extends StatelessWidget {
  final double width, height, fontSize, fontHeight, radius, borderWidth;
  final Color fontColor, background, borderColor;
  final EdgeInsetsGeometry margin, padding;
  final String text, fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Alignment alignment;
  final TextAlign textAlign;

  const PanText({
    Key key,
    this.text,
    this.fontSize,
    this.fontHeight,
    this.fontColor = Default.fontColor,
    this.fontFamily = Default.fontFamily,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
    this.background = C.none,
    this.textAlign = TextAlign.center,
    this.radius = 0,
    this.margin,
    this.padding,
    this.borderWidth,
    this.borderColor,
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
      alignment: alignment,
      child: Text(
        text,
        style: TextStyle(
            color: fontColor,
            fontFamily: fontFamily,
            fontStyle: fontStyle,
            fontWeight: fontWeight,
            height: fontHeight,
            fontSize: fontSize),
        textAlign: textAlign,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
