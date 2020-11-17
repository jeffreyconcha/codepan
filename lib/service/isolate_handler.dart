import 'dart:isolate';
import 'package:codepan/utils/codepan_utils.dart';

typedef IsolateImplementation = void Function(SendPort sp);

abstract class IsolateHandler {
  final String name;
  Isolate _isolate;
  ReceivePort _mrp;
  SendPort _isp;

  IsolateImplementation get implementation;

  IsolateHandler(this.name);

  Future<void> initialize() async {
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
      receiveFromIsolate(data);
    }
  }

  void receiveFromIsolate(dynamic data);

  void sendToIsolate(dynamic data) {
    _isp?.send(data);
  }
}
