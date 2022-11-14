import 'dart:io';

extension DirectoryUtils on Directory {
  File file(String name) {
    final slash = Platform.pathSeparator;
    return File('$path$slash$name');
  }

  Directory of(String name) {
    final slash = Platform.pathSeparator;
    return Directory('$path$slash$name');
  }
}
