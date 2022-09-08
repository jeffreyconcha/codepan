import 'package:codepan/resources/colors.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/wrapper.dart';
import 'package:flutter/material.dart';

enum OverflowState {
  collapse,
  expand,
  initial,
}

typedef OnTextOverflow = Widget Function(int lines);

class PanText extends StatelessWidget {
  final double? width, height, fontSize, fontHeight, radius;
  final Color? fontColor, hintFontColor;
  final OnTextOverflow? onTextOverflow;
  final String? text, hint, fontFamily;
  final EdgeInsets? margin, padding;
  final TextDirection textDirection;
  final BoxConstraints? constraints;
  final OverflowState overflowState;
  final bool isRequired, isScalable;
  final List<InlineSpan>? children;
  final TextDecoration? decoration;
  final SpannableText? spannable;
  final int? maxLines, maxLength;
  final TextOverflow? overflow;
  final FontWeight fontWeight;
  final List<Shadow>? shadows;
  final Alignment? alignment;
  final TextStyle? textStyle;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final BoxBorder? border;
  final Color background;

  const PanText({
    Key? key,
    this.alignment,
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
    this.isScalable = true,
    this.margin,
    this.maxLines,
    this.maxLength,
    this.onTextOverflow,
    this.overflow,
    this.overflowState = OverflowState.initial,
    this.padding,
    this.radius = 0,
    this.shadows,
    this.spannable,
    this.text,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.width,
    this.textStyle,
    this.hintFontColor,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    String? _text = this.text;
    final hasText = _text?.isNotEmpty ?? false;
    if (maxLength != null && _text != null) {
      if (_text.length > maxLength!) {
        _text = '${_text.substring(0, maxLength)}...';
      }
    }
    final style = textStyle ??
        TextStyle(
          color: hasText ? fontColor : hintFontColor,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          fontWeight: fontWeight,
          height: fontHeight,
          fontSize: fontSize != null
              ? isScalable
                  ? fontSize
                  : fontSize! / mq.textScaleFactor
              : null,
          decoration: decoration,
          shadows: shadows,
        );
    List<InlineSpan>? spanList;
    if (spannable != null) {
      spanList = [];
      spanList.addAll(spannable!.toSpanList(_text));
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
    final text = hasText ? _text : hint;
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
    return IfElseBuilder(
      condition: (text != null && text.isNotEmpty) || children != null,
      ifBuilder: (context) {
        return Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          alignment: alignment,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius!),
            border: border,
          ),
          constraints: constraints,
          child: WrapperBuilder(
            condition: onTextOverflow != null,
            child: rich,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final painter = TextPainter(
                    maxLines: maxLines,
                    textAlign: textAlign,
                    textDirection: textDirection,
                    text: span,
                  );
                  painter.layout(maxWidth: constraints.maxWidth);
                  Widget? overflowWidget;
                  if (painter.didExceedMaxLines ||
                      overflowState == OverflowState.expand) {
                    final lines = painter.computeLineMetrics();
                    overflowWidget = onTextOverflow!.call(lines.length);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      child,
                      Container(
                        child: overflowWidget,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class SpannableText {
  final List<String> identifiers;
  final TextStyle style;

  const SpannableText({
    required this.identifiers,
    required this.style,
  });

  List<TextSpan> toSpanList(String? text) {
    final list = <TextSpan>[];
    int index = 0;
    int start = 0;
    int matchCount = 0;
    final standard = '\$';
    String? _text = text;
    for (final identifier in identifiers) {
      _text = _text?.replaceAll(identifier, standard);
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
              style: style,
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
