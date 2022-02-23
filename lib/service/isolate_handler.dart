import 'dart:isolate';
import 'dart:ui';

import 'package:codepan/utils/codepan_utils.dart';

typedef IsolateImplementation = void Function(SendPort msp);

abstract class IsolateHandler {
  final String name;
  Isolate? _isolate;
  late ReceivePort _mrp;
  SendPort? _isp;

  IsolateImplementation get implementation;

  IsolateHandler(this.name);

  Future<void> start() async {
    this._mrp = ReceivePort();
    this._isolate = await Isolate.spawn(
      implementation,
      _mrp.sendPort,
    );
    _mrp.listen(_listener);
  }

  void stop() {
    _isolate?.kill();
  }

  void bindPort(SendPort sp) {
    PanUtils.bindIsolatePort(sp, name);
  }

  void _listener(dynamic data) {
    if (data is SendPort) {
      this._isp = data;
    } else {
      final sp = IsolateNameServer.lookupPortByName(name);
      sp?.send(data);
      receiveFromIsolate(data);
    }
  }

  void receiveFromIsolate(dynamic data);

  void sendToIsolate(dynamic data) {
    _isp?.send(data);
  }
}
