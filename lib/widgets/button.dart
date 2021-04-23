import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class PanButton extends StatelessWidget {
  final Color? fontColor, splashColor, highlightColor;
  final double? fontSize, fontHeight, width, height;
  final Color borderColor, background;
  final BoxConstraints? constraints;
  final double borderWidth, radius;
  final String? text, fontFamily;
  final VoidCallback? onPressed;
  final FontWeight fontWeight;
  final FocusNode? focusNode;
  final Alignment alignment;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Widget? child;

  const PanButton({
    Key? key,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.borderColor = PanColors.none,
    this.borderWidth = 0,
    this.child,
    this.constraints,
    this.focusNode,
    this.fontColor,
    this.fontFamily,
    this.fontHeight,
    this.fontSize,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.height,
    this.highlightColor,
    this.margin,
    this.onPressed,
    this.padding = const EdgeInsets.all(0),
    this.radius = 0,
    this.splashColor,
    this.text,
    this.textAlign = TextAlign.center,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
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
          onPressed: onPressed,
          splashColor: splashColor,
          highlightColor: highlightColor,
          child: PlaceholderHandler(
            condition: child != null,
            childBuilder: (context) {
              return child!;
            },
            placeholderBuilder: (context) {
              return PanText(
                text: text ?? '',
                fontSize: fontSize,
                fontColor: fontColor,
                fontWeight: fontWeight,
                fontFamily: fontFamily,
                textAlign: textAlign,
                alignment: alignment,
              );
            },
          ),
        ),
      ),
    );
  }
}
