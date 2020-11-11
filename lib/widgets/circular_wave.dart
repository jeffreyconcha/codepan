import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularWave extends StatefulWidget {
  final Duration duration;
  final double radius;
  final int waveCount;
  final Color color;

  const CircularWave({
    Key key,
    @required this.radius,
    @required this.waveCount,
    @required this.color,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  _CircularWaveState createState() => _CircularWaveState();
}

class _CircularWaveState extends State<CircularWave>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double _waveRadius = 0.0;

  double get waveGap => widget.radius / widget.waveCount;

  double get radius => widget.radius;

  Color get color => widget.color.withOpacity(0.5);

  Duration get duration => widget.duration;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener(
      (status) {
        switch (status) {
          case AnimationStatus.completed:
            _controller.reset();
            break;
          case AnimationStatus.dismissed:
            _controller.forward();
            break;
          default:
            break;
        }
      },
    );
    final tween = Tween(begin: 0.0, end: waveGap);
    _animation = tween.animate(_controller)
      ..addListener(() {
        setState(() {
          _waveRadius = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomPaint(
        size: Size.fromRadius(radius),
        painter: CircularWavePainter(
          waveRadius: _waveRadius,
          waveGap: waveGap,
          color: color,
        ),
      ),
    );
  }
}

class CircularWavePainter extends CustomPainter {
  final double waveRadius, waveGap;
  final Color color;
  Paint _wavePaint;

  CircularWavePainter({
    @required this.waveRadius,
    @required this.waveGap,
    @required this.color,
  }) {
    _wavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2.0;
    final cy = size.height / 2.0;
    final maxRadius = math.sqrt(cx * cx + cy * cy);
    double radius = waveRadius;
    while (radius < maxRadius) {
      final opacity = 1 - (radius / maxRadius);
      _wavePaint.color = color.withOpacity(opacity);
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        _wavePaint,
      );
      radius += waveGap;
    }
  }

  @override
  bool shouldRepaint(CircularWavePainter oldDelegate) {
    return oldDelegate.waveRadius != waveRadius;
  }
}
