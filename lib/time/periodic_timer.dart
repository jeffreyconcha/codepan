import 'dart:async';

import 'package:flutter/cupertino.dart';

class PeriodicTimer {
  final ValueChanged<Timer>? runner;
  final Duration interval;
  Timer? _timer;
  int _tick = 0;

  int get tick => _tick;

  bool get isActive => _timer?.isActive ?? false;

  PeriodicTimer({
    required this.interval,
    this.runner,
    bool autoStart = true,
  }) {
    if (autoStart) {
      _initialize();
    }
  }

  void _initialize() {
    _timer = Timer.periodic(interval, (timer) {
      runner?.call(timer);
      _tick++;
    });
  }

  void reset() {
    _tick = 0;
    _initialize();
  }

  void start() {
    if (!(_timer?.isActive ?? false)) {
      _initialize();
    }
  }

  void stop() {
    _timer?.cancel();
  }
}
