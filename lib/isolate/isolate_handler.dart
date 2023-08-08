import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:codepan/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';

typedef IsolateRunner<T extends MainPort> = void Function(T port);

typedef PortCreator<T extends MainPort> = Future<T> Function(SendPort msp);

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
  final ValueChanged<SendPort>? onConnected;
  late final ReceivePort _mrp;
  final PortCreator<T> creator;
  final String name;
  Isolate? _isolate;
  SendPort? _isp;

  IsolateRunner<T> get runner;

  IsolateHandler({
    required this.name,
    required this.creator,
    this.onConnected,
  }) : _mrp = ReceivePort();

  Future<void> start() async {
    _isolate = await Isolate.spawn<T>(
      runner,
      await creator(_mrp.sendPort),
    );
    _mrp.listen(_listener);
  }

  void stop() {
    _isolate?.kill();
  }

  void bindPort(SendPort sp) {
    sp.bindIsolate(name);
  }

  void _listener(dynamic data) {
    if (data is SendPort) {
      onConnected?.call(data);
      _isp = data;
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
