import 'dart:async';

import 'package:flutter/cupertino.dart';

class PeriodicTimer {
  final Duration interval;
  final ValueChanged<Timer> runner;
  Timer? _timer;
  int _tick = 0;

  int get tick => _tick;

  PeriodicTimer({
    required this.interval,
    required this.runner,
    bool autoStart = true,
  }) {
    if (autoStart) {
      _initialize();
    }
  }

  void _initialize() {
    _timer = Timer.periodic(interval, (timer) {
      runner(timer);
      _tick++;
    });
  }

  void reset() {
    _tick = 0;
    _initialize();
  }

  void start() {
    _initialize();
  }

  void stop() {
    _timer?.cancel();
  }
}
