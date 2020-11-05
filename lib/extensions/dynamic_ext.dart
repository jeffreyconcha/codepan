extension DynamicUtils on dynamic {
  int toInt() {
    if (this is int) {
      return this;
    }
    return int.tryParse(this.toString());
  }

  double toDouble() {
    if (this is double) {
      return this;
    }
    return double.tryParse(this.toString());
  }
}
