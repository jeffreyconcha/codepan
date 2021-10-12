import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum OverflowState {
  collapse,
  expand,
  initial,
}

typedef OnTextOverflow = Widget Function(int lines);

class PanText extends StatelessWidget {
  final double? width, height, fontSize, fontHeight, radius;
  final EdgeInsetsGeometry? margin, padding;
  final Color? fontColor, hintFontColor;
  final OnTextOverflow? onTextOverflow;
  final String? text, hint, fontFamily;
  final TextDirection textDirection;
  final BoxConstraints? constraints;
  final OverflowState overflowState;
  final List<InlineSpan>? children;
  final TextDecoration? decoration;
  final SpannableText? spannable;
  final TextOverflow? overflow;
  final FontWeight fontWeight;
  final List<Shadow>? shadows;
  final Alignment? alignment;
  final TextStyle? textStyle;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final BoxBorder? border;
  final Color background;
  final bool isRequired;
  final int? maxLines;

  const PanText({
    Key? key,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.border,
    this.children,
    this.constraints,
    this.decoration,
    this.fontColor,
    this.fontFamily,
    this.fontHeight,
    this.fontSize,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.height,
    this.isRequired = false,
    this.margin,
    this.maxLines,
    this.onTextOverflow,
    this.overflow,
    this.overflowState = OverflowState.initial,
    this.padding,
    this.radius = 0,
    this.shadows,
    this.spannable,
    this.text,
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.width,
    this.textStyle,
    this.hintFontColor,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasText = this.text?.isNotEmpty ?? false;
    final style = textStyle ??
        TextStyle(
          color: hasText ? fontColor : hintFontColor,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          fontWeight: fontWeight,
          height: fontHeight,
          fontSize: fontSize,
          decoration: decoration,
          shadows: shadows,
        );
    List<InlineSpan>? spanList;
    if (spannable != null) {
      spanList = [];
      spanList.addAll(
        _toSpannable(spannable!),
      );
    }
    if (children != null) {
      spanList ??= [];
      spanList.addAll(children!);
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
    final text = hasText ? this.text : hint;
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
      condition: (text != null && text!.isNotEmpty) || children != null,
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
                  overflowWidget = onTextOverflow!.call(lines.length);
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
          borderRadius: BorderRadius.circular(radius!),
          border: border,
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
    String? _text = text;
    for (final identifier in spannable.identifiers) {
      _text = _text!.replaceAll(identifier, standard);
    }
    final clean = _text?.replaceAll(standard, '');
    final buffer = StringBuffer();
    _text?.runes.forEach((code) {
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
              text: clean!.substring(start, end),
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
    required this.identifiers,
    required this.style,
  });
}
