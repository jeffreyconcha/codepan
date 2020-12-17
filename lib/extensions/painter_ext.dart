import 'dart:ui' as ui;
import 'package:flutter/material.dart';

extension CustomPainterUtils on CustomPainter {
  Future<ui.Image> renderImage({
    @required int width,
    @required int height,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.save();
    final size = Size(
      width.toDouble(),
      height.toDouble(),
    );
    this.paint(canvas, size);
    canvas.restore();
    final picture = recorder.endRecording();
    return picture.toImage(width.floor(), height.floor());
  }
}
