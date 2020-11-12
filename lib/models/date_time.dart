import 'package:flutter/foundation.dart';

class DateTimeData {
  final String date;
  final String time;

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
