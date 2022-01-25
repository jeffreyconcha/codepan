import 'dart:io';

extension DirectoryUtils on Directory {
  File file(String name) => File('$path/$name');
}
