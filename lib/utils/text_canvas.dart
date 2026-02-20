import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class CanvasLayer {
  void paint(Canvas canvas, Size size);
}

class TextCanvas implements CanvasLayer {
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
    if (textAlign == TextAlign.right || textAlign == TextAlign.end) {
      final contentWidth = _painter.size.width + offset.dx;
      final dx = size.width - contentWidth;
      _painter.paint(canvas, Offset(dx, offset.dy));
    } else {
      _painter.paint(canvas, offset);
    }
  }
}

class StackPainter extends CustomPainter {
  final List<CanvasLayer> children;

  const StackPainter({
    required this.children,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    for (final child in children) {
      child.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
