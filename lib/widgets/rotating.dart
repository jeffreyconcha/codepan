import 'dart:math';

import 'package:flutter/cupertino.dart';

class Rotating extends StatefulWidget {
  final Widget child;

  const Rotating({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<Rotating> createState() => _RotatingState();
}

class _RotatingState extends State<Rotating>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * pi * 2,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
