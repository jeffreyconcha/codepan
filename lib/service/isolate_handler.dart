import 'dart:isolate';
import 'dart:ui';

import 'package:codepan/extensions/extensions.dart';

typedef IsolateRunner<T extends MainPort> = void Function(T port);

abstract class MainPort {
  final SendPort msp;

  const MainPort({
    required this.msp,
  });

  void send(Object? message) {
    msp.send(message);
  }
}

abstract class IsolateHandler<T extends MainPort> {
  final ReceivePort mrp;
  final String name;
  final T port;
  Isolate? _isolate;
  SendPort? _isp;

  IsolateRunner<T> get runner;

  IsolateHandler({
    required this.name,
    required this.mrp,
    required this.port,
  });

  Future<void> start() async {
    _isolate = await Isolate.spawn<T>(runner, port);
    mrp.listen(_listener);
  }

  void stop() {
    _isolate?.kill();
  }

  void bindPort(SendPort sp) {
    sp.bindIsolate(name);
  }

  void _listener(dynamic data) {
    if (data is SendPort) {
      this._isp = data;
    } else {
      IsolateNameServer.lookupPortByName(name)?.send(data);
      receiveFromIsolate(data);
    }
  }

  void receiveFromIsolate(dynamic data);

  void sendToIsolate(dynamic data) {
    _isp?.send(data);
  }
}
