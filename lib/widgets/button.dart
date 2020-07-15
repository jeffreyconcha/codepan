import 'package:codepan/config/properties.dart';
import 'package:flutter/material.dart';
import 'package:codepan/widgets/text.dart';
import 'package:codepan/resources/colors.dart';

class PanButton extends StatelessWidget {
  final Color fontColor, background, borderColor, splashColor, highlightColor;
  final double fontSize, fontHeight, radius, borderWidth, width, height;
  final EdgeInsetsGeometry margin, padding;
  final String text, fontFamily;
  final VoidCallback onPressed;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Alignment alignment;
  final FocusNode focusNode;
  final Widget child;
  final TextAlign textAlign;

  const PanButton({
    Key key,
    this.text,
    this.fontSize,
    this.fontHeight,
    this.fontColor,
    this.fontFamily,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.textAlign = TextAlign.center,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.radius = 0,
    this.borderWidth = 0,
    this.borderColor = PanColors.none,
    this.onPressed,
    this.width,
    this.height,
    this.child,
    this.focusNode,
    this.highlightColor,
    this.splashColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var child = this.child != null
        ? this.child
        : PanText(
            text: text ?? '',
            fontSize: fontSize,
            fontColor: fontColor,
            fontWeight: fontWeight,
            fontFamily: fontFamily,
            textAlign: textAlign,
            alignment: alignment,
          );
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: SizedBox(
        width: width,
        height: height,
        child: FlatButton(
          color: background,
          focusNode: focusNode,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          padding: padding,
          child: child,
          onPressed: onPressed,
          splashColor: splashColor,
          highlightColor: highlightColor,
        ),
      ),
    );
  }
}
