import 'package:flutter/foundation.dart';

class DateTimeData {
  final String date;
  final String time;

  bool isNewMinute() {
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
