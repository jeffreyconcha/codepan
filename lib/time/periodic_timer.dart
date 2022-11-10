import 'dart:async';

import 'package:codepan/time/time.dart';
import 'package:flutter/cupertino.dart';

class PeriodicTimer {
  final ValueChanged<Timer>? runner;
  final Duration interval;
  late final Time _time;
  Timer? _timer;
  int _tick = 0;

  int get tick => _tick;

  bool get isActive => _timer?.isActive ?? false;

  Time get time => _time;

  PeriodicTimer({
    required this.interval,
    this.runner,
    bool autoStart = true,
  }) {
    _time = Time.now();
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

  void reset([bool autoStart = true]) {
    _tick = 0;
    if (autoStart) {
      _initialize();
    }
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
