import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TextCanvas extends CustomPainter {
  final ui.TextDirection textDirection;
  final double? textScaleFactor;
  final TextAlign textAlign;
  final TextStyle? style;
  final Offset offset;
  final String text;
  late TextPainter _painter;

  TextCanvas({
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.textDirection = ui.TextDirection.ltr,
    this.offset = const Offset(0, 0),
    this.textScaleFactor,
  }) {
    _painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
      textScaleFactor: textScaleFactor!,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _painter.layout(maxWidth: size.width);
    _painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
