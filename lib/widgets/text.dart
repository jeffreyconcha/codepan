import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:codepan/resources/colors.dart';

typedef OnTextOverflow = void Function(int lines);

class PanText extends StatelessWidget {
  final double width, height, fontSize, fontHeight, radius, borderWidth;
  final Color fontColor, background, borderColor;
  final EdgeInsetsGeometry margin, padding;
  final OnTextOverflow onTextOverflow;
  final TextDirection textDirection;
  final TextDecoration decoration;
  final String text, fontFamily;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final FontStyle fontStyle;
  final Alignment alignment;
  final TextAlign textAlign;
  final List<Shadow> shadows;
  final Widget overflowWidget;
  final int maxLines;

  const PanText({
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
    this.textDirection = TextDirection.ltr,
    this.overflow,
    this.decoration,
    this.radius = 0,
    this.margin,
    this.padding,
    this.borderWidth,
    this.borderColor,
    this.width,
    this.height,
    this.maxLines,
    this.shadows,
    this.onTextOverflow,
    this.overflowWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: fontColor,
      fontFamily: fontFamily,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      height: fontHeight,
      fontSize: fontSize,
      decoration: decoration,
      shadows: shadows,
    );
    final child = overflowWidget != null
        ? LayoutBuilder(
            builder: (ctx, c) {
              final span = TextSpan(
                text: text ?? '',
                style: style,
              );
              final painter = TextPainter(
                maxLines: maxLines,
                textAlign: textAlign,
                textDirection: textDirection,
                text: span,
              );
              painter.layout(maxWidth: c.maxWidth);
              if (painter.didExceedMaxLines) {
                if (onTextOverflow != null) {
                  final lines = painter.computeLineMetrics();
                  onTextOverflow.call(lines.length);
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text.rich(
                    span,
                    overflow: overflow,
                    maxLines: maxLines,
                    textAlign: textAlign,
                    textDirection: textDirection,
                  ),
                  overflowWidget,
                ],
              );
            },
          )
        : Text(
            text ?? '',
            style: style,
            overflow: overflow,
            maxLines: maxLines,
            textAlign: textAlign,
            textDirection: textDirection,
          );
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      child: child,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
