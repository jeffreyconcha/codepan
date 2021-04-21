import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class PanButton extends StatelessWidget {
  final double? fontSize, fontHeight, radius, borderWidth, width, height;
  final Color? fontColor, background, borderColor, splashColor, highlightColor;
  final EdgeInsetsGeometry? margin, padding;
  final BoxConstraints? constraints;
  final String? text, fontFamily;
  final VoidCallback? onPressed;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Alignment alignment;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final Widget? child;

  const PanButton({
    Key? key,
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
    this.constraints,
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
            borderRadius: BorderRadius.circular(radius!),
            side: BorderSide(color: borderColor!, width: borderWidth!),
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
