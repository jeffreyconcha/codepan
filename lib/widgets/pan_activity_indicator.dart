library nuts_activity_indicator;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class PanActivityIndicator extends StatefulWidget {
  final double relativeWidth, startRatio, endRatio;
  final Color activeColor, inactiveColor;
  final Duration animationDuration;
  final bool isAnimating;
  final double radius;
  final int tickCount;

  const PanActivityIndicator({
    Key? key,
    this.isAnimating = true,
    this.radius = 10,
    this.startRatio = 0.5,
    this.endRatio = 1.0,
    this.tickCount = 12,
    this.activeColor = const Color(0xFF9D9D9D),
    this.inactiveColor = const Color(0xFFE5E5EA),
    this.animationDuration = const Duration(seconds: 1),
    this.relativeWidth = 1,
  }) : super(key: key);

  @override
  _PanActivityIndicatorState createState() => _PanActivityIndicatorState();
}

class _PanActivityIndicatorState extends State<PanActivityIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    if (widget.isAnimating) {
      _animController!.repeat();
    }
  }

  @override
  void didUpdateWidget(PanActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _animController!.repeat();
      } else {
        _animController!.stop();
      }
    }
  }

  @override
  void dispose() {
    _animController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.radius * 2,
      width: widget.radius * 2,
      child: CustomPaint(
        painter: _PanActivityIndicatorPainter(
          animationController: _animController,
          radius: widget.radius,
          tickCount: widget.tickCount,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          relativeWidth: widget.relativeWidth,
          startRatio: widget.startRatio,
          endRatio: widget.endRatio,
        ),
      ),
    );
  }
}

class _PanActivityIndicatorPainter extends CustomPainter {
  final int _halfTickCount;
  final Animation<double>? animationController;
  final Color? activeColor;
  final Color? inactiveColor;
  final double relativeWidth;
  final int tickCount;
  final double radius;
  final RRect _tickRRect;
  final double startRatio;
  final double endRatio;

  _PanActivityIndicatorPainter({
    required this.radius,
    required this.tickCount,
    this.animationController,
    this.activeColor,
    this.inactiveColor,
    required this.relativeWidth,
    required this.startRatio,
    required this.endRatio,
  })  : _halfTickCount = tickCount ~/ 2,
        _tickRRect = RRect.fromLTRBXY(
          -radius * endRatio,
          relativeWidth * radius / 10,
          -radius * startRatio,
          -relativeWidth * radius / 10,
          2,
          2,
        ),
        super(repaint: animationController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2);
    final activeTick = (tickCount * animationController!.value).floor();
    for (int i = 0; i < tickCount; ++i) {
      paint.color = Color.lerp(
        activeColor,
        inactiveColor,
        ((i + activeTick) % tickCount) / _halfTickCount,
      )!;
      canvas
        ..drawRRect(_tickRRect, paint)
        ..rotate(-math.pi * 2 / tickCount);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PanActivityIndicatorPainter oldPainter) {
    return oldPainter.animationController != animationController;
  }
}
