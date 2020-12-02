import 'dart:io';

extension FileUtils on File {
  String get name {
    final separator = Platform.pathSeparator;
    return this?.path?.split(separator)?.last;
  }
}
