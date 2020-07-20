import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:codepan/resources/colors.dart';

enum OverflowState {
  expand,
  collapse,
  initial,
}

typedef OnTextOverflow = Widget Function(int lines);

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
  final OverflowState overflowState;
  final List<InlineSpan> children;
  final bool isRequired;
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
    this.overflowState = OverflowState.initial,
    this.isRequired = false,
    this.children,
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
    final required = TextSpan(
      text: '*',
      style: TextStyle(
        color: Colors.red,
      ),
    );
    List<InlineSpan> spanList;
    if (isRequired) {
      if (children != null) {
        children.add(required);
      } else {
        spanList = [required];
      }
    } else {
      spanList = children;
    }
    final span = TextSpan(
      text: text ?? '',
      style: style,
      children: spanList,
    );
    final maxLines =
        overflowState != OverflowState.expand ? this.maxLines : null;
    final overflow =
        overflowState != OverflowState.expand ? this.overflow : null;
    final rich = Text.rich(
      span,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
    );
    final child = onTextOverflow != null
        ? LayoutBuilder(
            builder: (ctx, c) {
              final painter = TextPainter(
                maxLines: maxLines,
                textAlign: textAlign,
                textDirection: textDirection,
                text: span,
              );
              painter.layout(maxWidth: c.maxWidth);
              var overflowWidget;
              if (painter.didExceedMaxLines ||
                  overflowState == OverflowState.expand) {
                final lines = painter.computeLineMetrics();
                overflowWidget = onTextOverflow.call(lines.length);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  rich,
                  Container(child: overflowWidget),
                ],
              );
            },
          )
        : rich;
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
