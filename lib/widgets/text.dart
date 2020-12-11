import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  final OverflowState overflowState;
  final BoxConstraints constraints;
  final TextDecoration decoration;
  final List<InlineSpan> children;
  final String text, fontFamily;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final List<Shadow> shadows;
  final FontStyle fontStyle;
  final Alignment alignment;
  final TextAlign textAlign;
  final SpannableText spannable;
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
    this.constraints,
    this.spannable,
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
    List<InlineSpan> spanList;
    if (spannable != null) {
      spanList = [];
      spanList.addAll(
        _toSpannable(spannable),
      );
    }
    if (children != null) {
      spanList ??= [];
      spanList.addAll(children);
    }
    if (isRequired) {
      spanList ??= [];
      spanList.add(
        TextSpan(
          text: '*',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      );
    }
    final span = TextSpan(
      text: spannable != null ? null : text ?? '',
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
    return PlaceholderHandler(
      condition: (text != null && text.isNotEmpty) || children != null,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        alignment: alignment,
        child: PlaceholderHandler(
          condition: onTextOverflow != null,
          childBuilder: (context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final painter = TextPainter(
                  maxLines: maxLines,
                  textAlign: textAlign,
                  textDirection: textDirection,
                  text: span,
                );
                painter.layout(maxWidth: constraints.maxWidth);
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
                    Container(
                      child: overflowWidget,
                    ),
                  ],
                );
              },
            );
          },
          placeholderBuilder: (context) {
            return rich;
          },
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        constraints: constraints,
      ),
    );
  }

  List<InlineSpan> _toSpannable(SpannableText spannable) {
    final list = <InlineSpan>[];
    int index = 0;
    int start = 0;
    int matchCount = 0;
    final standard = '\$';
    String _text = text;
    for (final identifier in spannable.identifiers) {
      _text = _text.replaceAll(identifier, standard);
    }
    final clean = _text?.replaceAll(standard, '');
    final buffer = StringBuffer();
    _text?.runes?.forEach((code) {
      final character = String.fromCharCode(code);
      if (character == standard) {
        matchCount++;
        if (matchCount.isOdd) {
          start = index - matchCount + 1;
          list.add(
            TextSpan(
              text: buffer.toString(),
            ),
          );
        } else {
          final end = index - matchCount + 1;
          list.add(
            TextSpan(
              text: clean.substring(start, end),
              style: spannable.style,
            ),
          );
        }
        buffer.clear();
      } else {
        buffer.write(character);
      }
      index++;
    });
    final remaining = buffer.toString();
    if (remaining.isNotEmpty) {
      list.add(
        TextSpan(
          text: buffer.toString(),
        ),
      );
    }
    return list;
  }
}

class SpannableText {
  final List<String> identifiers;
  final TextStyle style;

  const SpannableText({
    @required this.identifiers,
    @required this.style,
  });
}
