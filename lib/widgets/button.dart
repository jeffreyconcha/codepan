import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class PanButton extends StatelessWidget {
  final Color? fontColor, splashColor, highlightColor, hintFontColor;
  final double? fontSize, fontHeight, width, height;
  final VoidCallback? onTap, onLongPress;
  final String? text, fontFamily, hint;
  final Color borderColor, background;
  final EdgeInsets? margin, padding;
  final BoxConstraints? constraints;
  final double borderWidth, radius;
  final BoxDecoration? decoration;
  final FontWeight fontWeight;
  final Alignment alignment;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final Widget? child;

  const PanButton({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.borderColor = PanColors.none,
    this.borderWidth = 0,
    this.child,
    this.constraints,
    this.fontColor,
    this.fontFamily,
    this.fontHeight,
    this.fontSize,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.hintFontColor,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.padding = EdgeInsets.zero,
    this.radius = 0,
    this.highlightColor = PanColors.highlight,
    this.splashColor = PanColors.splash,
    this.text,
    this.textAlign = TextAlign.center,
    this.hint,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: constraints,
      child: Material(
        color: PanColors.none,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: splashColor,
          highlightColor: highlightColor,
          child: Ink(
            width: width,
            height: height,
            padding: padding,
            decoration: decoration ??
                BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                ),
            child: IfElseBuilder(
              condition: child != null,
              ifBuilder: (context) {
                return child!;
              },
              elseBuilder: (context) {
                return PanText(
                  text: text ?? '',
                  fontSize: fontSize,
                  fontColor: fontColor,
                  fontWeight: fontWeight,
                  fontFamily: fontFamily,
                  textAlign: textAlign,
                  alignment: alignment,
                  hintFontColor: hintFontColor,
                  hint: hint,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
