import 'dart:typed_data';

abstract class InitHandler<Input, Output> {
  final bool allowEmpty;

  const InitHandler(this.allowEmpty);

  Output init(Input body);
}

abstract class DataInitHandler
    extends InitHandler<Map<String, dynamic>, List<Map<String, dynamic>>> {
  const DataInitHandler(super.allowEmpty);
}

class DataInitException {
  final String? message;

  const DataInitException(this.message);

  @override
  String toString() => '$message';
}

class ByteInitHandler extends InitHandler<Uint8List, Uint8List> {
  const ByteInitHandler(super.allowEmpty);

  @override
  Uint8List init(Uint8List body) {
    return body;
  }
}
