import 'dart:async';

import 'package:codepan/extensions/num.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:system_clock/system_clock.dart';
import 'dart:math';

import 'package:vector_math/vector_math.dart';

const defaultSensitivity = 0.5;
const defaultAllowance = 300;

class MotionDetector {
  final ValueChanged<DeviceOrientation>? onOrientationChanged;
  final double sensitivity;
  final int allowanceTime;
  late final StreamSubscription<AccelerometerEvent> _subscription;
  DeviceOrientation _current = DeviceOrientation.portraitUp;
  Duration _motionUpdate = Duration.zero;
  Duration _sensorUpdate = Duration.zero;
  double _x = 0;
  double _y = 0;
  double _z = 0;
  int _rotation = 0;

  DeviceOrientation get orientation {
    if (_rotation.isBetween(-60, 60)) {
      return DeviceOrientation.portraitUp;
    } else if (_rotation.isBetween(-180, -120)) {
      return DeviceOrientation.portraitDown;
    } else if (_rotation.isBetween(120, 180)) {
      return DeviceOrientation.portraitDown;
    } else if (_rotation.isBetween(-119, -61)) {
      return DeviceOrientation.landscapeRight;
    } else if (_rotation.isBetween(61, 119)) {
      return DeviceOrientation.landscapeLeft;
    } else {
      return DeviceOrientation.portraitUp;
    }
  }

  MotionDetector({
    this.sensitivity = defaultSensitivity,
    this.allowanceTime = defaultAllowance,
    this.onOrientationChanged,
  }) {
    _subscription = accelerometerEvents.listen(_onSensorChanged);
  }

  void _onSensorChanged(AccelerometerEvent event) {
    final elapsed = SystemClock.elapsedRealtime();
    final cx = event.x;
    final cy = event.y;
    final cz = event.z;
    final dx = (cx - _x).abs();
    final dy = (cy - _y).abs();
    final dz = (cz - _z).abs();
    if (dx >= sensitivity || dy >= sensitivity || dz >= sensitivity) {
      _motionUpdate = elapsed;
    }
    _x = cx;
    _y = cy;
    _z = cz;
    _sensorUpdate = elapsed;
    final vector = sqrt(cx * cx + cy * cy + cz * cz);
    final vx = cx / vector;
    final vy = cy / vector;
    final vz = cz / vector;
    final value = degrees(acos(vz));
    if (!value.isNaN) {
      final inclination = value.round();
      if (inclination.isBetween(26, 154)) {
        final rd = degrees(atan2(vx, vy));
        if (!rd.isNaN) {
          _rotation = rd.round();
        }
        final newOrientation = orientation;
        if (newOrientation != _current) {
          onOrientationChanged?.call(newOrientation);
          _current = newOrientation;
        }
      }
    }
  }

  void close() {
    _subscription.cancel();
  }
}
