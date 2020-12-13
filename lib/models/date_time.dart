import 'package:codepan/utils/codepan_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class DateTimeData extends Equatable {
  final String date;
  final String time;

  @override
  List<Object> get props {
    return [
      date,
      time,
    ];
  }

  String get displayDate => PanUtils.formatDate(date);

  String get displayTime => PanUtils.formatTime(time);

  String get dayOfTheWeek => PanUtils.getDayOfTheWeek(date, time);

  String get dayOfTheMonth => PanUtils.getDayOfTheMonth(date, time);

  String get monthInYear => PanUtils.getMonthInYear(date, time);

  String get history => PanUtils.getTimeHistory(date, time);

  DateTime get value => DateTime.parse('$date $time');

  String get abbreviatedWeekday {
    return PanUtils.getDayOfTheWeek(
      date,
      time,
      isAbbreviated: true,
    );
  }

  String get abbreviatedMonth {
    return PanUtils.getMonthInYear(
      date,
      time,
      isAbbreviated: true,
    );
  }

  bool get isNewMinute {
    final array = time.split(':');
    if (array[2] == '00') {
      return true;
    }
    return false;
  }

  const DateTimeData({
    @required this.date,
    this.time = '00:00:00',
  });

  Map<String, String> toMap() {
    return {
      'date': date,
      'time': time,
    };
  }

  Duration difference(DateTimeData other) {
    return value.difference(other?.value);
  }

  bool isEqual(DateTimeData other) {
    return date == other?.date && time == other?.time;
  }

  bool isGreaterThan(DateTimeData other) {
    final duration = difference(other);
    return !duration.isNegative && !isEqual(other);
  }

  bool isLessThan(DateTimeData other) {
    final duration = difference(other);
    return duration.isNegative;
  }

  DateTimeData add(Duration duration) {
    final sum = value.add(duration);
    return PanUtils.formatDateTime(sum);
  }
}
