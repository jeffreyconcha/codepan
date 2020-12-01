import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter/foundation.dart';

class DateTimeData {
  final String date;
  final String time;

  String get displayDate => PanUtils.formatDate(date);

  String get displayTime => PanUtils.formatTime(time);

  String get dayOfTheWeek => PanUtils.getDayOfTheWeek(date, time);

  String get history => PanUtils.getTimeHistory(date, time);

  bool get isNewMinute {
    final array = time.split(':');
    if (array[2] == '00') {
      return true;
    }
    return false;
  }

  const DateTimeData({
    @required this.date,
    @required this.time,
  });

  Map<String, String> toMap() {
    return {
      'date': date,
      'time': time,
    };
  }
}
