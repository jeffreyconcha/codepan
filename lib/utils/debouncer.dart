import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final ValueChanged<bool>? statusNotifier;
  final int milliseconds;
  bool _isActive = false;
  Timer? _timer;

  Debouncer({
    this.milliseconds = 500,
    this.statusNotifier,
  });

  void run(VoidCallback action) {
    cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      action.call();
      statusNotifier?.call(false);
      _isActive = false;
    });
  }

  void cancel() {
    _timer?.cancel();
    if (!_isActive) {
      statusNotifier?.call(true);
      _isActive = true;
    }
  }
}
