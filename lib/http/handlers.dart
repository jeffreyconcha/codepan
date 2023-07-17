import 'dart:typed_data';

abstract class InitHandler<I, O> {
  final bool allowEmpty;

  const InitHandler(this.allowEmpty);

  O init(I body);
}

abstract class DataInitHandler
    extends InitHandler<Map<String, dynamic>, List<Map<String, dynamic>>> {
  const DataInitHandler(super.allowEmpty);
}

class ByteInitHandler extends InitHandler<Uint8List, Uint8List> {
  const ByteInitHandler(super.allowEmpty);

  @override
  Uint8List init(Uint8List body) {
    return body;
  }
}
