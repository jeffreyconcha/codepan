import 'package:codepan/utils/codepan_utils.dart';

extension DurationUtils on Duration {
  String format({
    bool isReadable = false,
    bool withSeconds = true,
    bool isAbbreviated = false,
  }) {
    return PanUtils.formatDuration(
      this,
      isReadable: isReadable,
      withSeconds: withSeconds,
      isAbbreviated: isAbbreviated,
    );
  }

  Duration difference(Duration other) {
    final difference = this.inMilliseconds - other.inMilliseconds;
    return Duration(milliseconds: difference);
  }
}
