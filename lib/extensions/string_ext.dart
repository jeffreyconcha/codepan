// ignore: sdk_version_extension_methods
extension StringUtils on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  String nullify() {
    if (this != null && (this == 'null' || this.isEmpty)) {
      return null;
    }
    return this;
  }
}
