import 'dart:isolate';
import 'dart:ui';

extension SendPortUtils on SendPort {
  void bindIsolate(String name) {
    final result = IsolateNameServer.registerPortWithName(this, name);
    if (!result) {
      IsolateNameServer.removePortNameMapping(name);
      bindIsolate(name);
    }
  }
}
