extension DurationUtils on Duration {
  String format({
    bool isReadable = false,
    bool withSeconds = true,
    bool isAbbreviated = false,
  }) {
    String format(int n) => n.toString().padLeft(2, "0");
    final num h = this.inHours;
    final num m = this.inMinutes.remainder(60);
    final num s = this.inSeconds.remainder(60);
    final hs = isReadable
        ? h > 1
            ? ' hrs '
            : ' hr '
        : ':';
    final ms = isReadable
        ? m > 1
            ? ' mins '
            : ' min '
        : ':';
    final ss = isReadable
        ? s > 1
            ? ' secs'
            : ' sec'
        : ':';
    final hours = isReadable ? '$h' : format(h as int);
    final minutes = isReadable ? '$m' : format(m as int);
    final seconds = isReadable ? '$s' : format(s as int);
    final buffer = StringBuffer();
    if (h != 0) {
      buffer.write('$hours');
      buffer.write(!isAbbreviated ? hs : 'h ');
    }
    if (!isReadable || m != 0) {
      buffer.write('$minutes');
      buffer.write(!isAbbreviated ? ms : 'm ');
    }
    if (!isReadable || (withSeconds && s != 0) || this.inSeconds < 60) {
      buffer.write('$seconds');
      if (isReadable) {
        buffer.write(!isAbbreviated ? ss : 's');
      }
    }
    return buffer.toString().trim();
  }

  Duration difference(Duration other) {
    final difference = this.inMilliseconds - other.inMilliseconds;
    return Duration(milliseconds: difference);
  }
}
