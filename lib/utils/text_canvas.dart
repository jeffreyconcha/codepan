import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TextCanvas extends CustomPainter {
  final ui.TextDirection textDirection;
  final TextAlign textAlign;
  final TextStyle style;
  final String text;
  final Offset offset;
  TextPainter _painter;

  TextCanvas({
    @required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.textDirection = ui.TextDirection.ltr,
    this.offset = const Offset(0, 0),
  }) {
    _painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
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
