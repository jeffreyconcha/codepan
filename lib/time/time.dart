import 'package:codepan/extensions/duration.dart';
import 'package:codepan/extensions/map.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/time/time_range.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const String defaultDate = '0000-00-00';
const String defaultTime = '00:00:00';
const String dateFormat = 'yyyy-MM-dd';
const String timeFormat = 'HH:mm:ss';
const String locale = 'en_US';
const int millisecondsEpoch = 62170012800000;

class Time extends Equatable {
  final String _date;
  final String _time;

  String get date => DateFormat(dateFormat, locale).format(value);

  String get time => DateFormat(timeFormat, locale).format(value);

  @override
  List<Object?> get props => [milliseconds];

  String get display => '$displayDate, $displayTime';

  String get displayDate => DateFormat.yMMMMd(locale).format(value);

  String get displayDateNoYear => DateFormat.MMMMd(locale).format(value);

  String get displayWeekdayDate => '$displayWeekday, $displayDate';

  String get displayRealWeekdayDate => '$displayRealWeekday, $displayDate';

  String get displayTime => DateFormat.jm(locale).format(value);

  String get displayTimeWithSeconds => DateFormat.jms(locale).format(value);

  String get displayWeekday {
    return isToday ? Strings.today : displayRealWeekday;
  }

  String get displayRealWeekday {
    return DateFormat.EEEE(locale).format(value);
  }

  String get displayDay => DateFormat.d(locale).format(value);

  String get displayMonth => DateFormat.MMMM(locale).format(value);

  String get displayYear => DateFormat.y(locale).format(value);

  String get displayMonthDay => DateFormat.MMMMd(locale).format(value);

  String get displayNumeric => DateFormat('M/d/yy - h:mm a').format(value);

  String get displayMonthYear {
    final today = Time.today();
    if (this.isBetween(today.toMonth())) {
      return Strings.thisMonth;
    }
    return '$displayMonth $displayYear';
  }

  String get abbrWeekday {
    return isToday ? Strings.today : abbrRealWeekday;
  }

  String get abbrRealWeekday {
    return DateFormat.E(locale).format(value);
  }

  String get abbrMonth => DateFormat.MMM(locale).format(value);

  String get abbrMonthDay => DateFormat.MMMd(locale).format(value);

  String get abbrMonthYear {
    final today = Time.today();
    final first = today.toFirstDayOfThisMonth();
    final last = first.subtract(Duration(days: 1));
    if (this.isBetween(today.toMonth())) {
      return Strings.thisMonth;
    } else if (this.isBetween(last.toMonth())) {
      return Strings.lastMonth;
    }
    return '$abbrMonth $displayYear';
  }

  String get abbr => '$abbrDate, $displayTime';

  String get abbrWeekdayDate => '$abbrWeekday, $abbrDate';

  String get abbrRealWeekdayDate => '$abbrRealWeekday, $abbrDate';

  String get abbrDate => DateFormat.yMMMd(locale).format(value);

  String get abbrDateNoYear => DateFormat.MMMd(locale).format(value);

  String get displayHistory => ago.format(value);

  String get displayFromNow =>
      ago.format(value, enableFromNow: true).replaceAll('from now', '');

  DateTime get value {
    final date = _date.isNotEmpty ? _date : defaultDate;
    final time = _time.isNotEmpty ? _time : defaultTime;
    return DateTime.parse('$date $time');
  }

  String get timezone => value.timeZoneName;

  String get timezoneValue => value.timeZoneOffset.format(withSeconds: false);

  int get millisecondsSinceEpoch => value.millisecondsSinceEpoch;

  int get milliseconds => millisecondsSinceEpoch + millisecondsEpoch;

  bool get isToday => trimmedDate == Time.today();

  bool get isYesterday => trimmedDate == Time.yesterday();

  bool get isThisMonth {
    final now = Time.now();
    return this.isBetween(now.toMonth());
  }

  Time get trimmedDate => Time(date: date);

  Time get trimmedTime => Time(time: time);

  int get noOfDaysInMonth {
    final start = DateTime(value.year, value.month, 0);
    final end = DateTime(value.year, value.month + 1, 0);
    return end.difference(start).inDays;
  }

  int get noOfDaysInYear {
    final start = DateTime(value.year, 0, 0);
    final end = DateTime(value.year + 1, 0, 0);
    return end.difference(start).inDays;
  }

  bool? get isNewMinute {
    final split = _time.split(':');
    return split.last == '00';
  }

  const Time({
    String? date = defaultDate,
    String? time = defaultTime,
  })  : _date = date ?? defaultDate,
        _time = time ?? defaultTime;

  factory Time.value(DateTime? input) {
    if (input != null) {
      final date = DateFormat(dateFormat);
      final time = DateFormat(timeFormat);
      return Time(
        date: date.format(input),
        time: time.format(input),
      );
    }
    return Time();
  }

  factory Time.stamp(int stamp) {
    final value = DateTime.fromMillisecondsSinceEpoch(stamp);
    return Time.value(value);
  }

  factory Time.parse(String input) {
    final value = DateTime.parse(input);
    return Time.value(value);
  }

  factory Time.now() {
    final value = DateTime.now();
    return Time.value(value);
  }

  factory Time.today() {
    final value = DateTime.now();
    final date = DateFormat(dateFormat);
    return Time(
      date: date.format(value),
    );
  }

  factory Time.yesterday() {
    final duration = Duration(days: 1);
    return Time.today().subtract(duration);
  }

  factory Time.fromTimeOfDay(TimeOfDay input) {
    String format(int value) => value < 10 ? '0$value' : '$value';
    final time = '${format(input.hour)}:${format(input.minute)}:00';
    return Time(time: time);
  }

  factory Time.fromMap(Map<String, dynamic> map) {
    return Time(
      date: map.get('date'),
      time: map.get('time'),
    );
  }

  Map<String, String?> toMap() {
    return {
      'date': date,
      'time': time,
    };
  }

  Duration get duration {
    return Duration(milliseconds: milliseconds);
  }

  bool get isZero => milliseconds == 0;

  bool get isNotZero => !isZero;

  bool get isTimeZero => time == defaultTime;

  bool get isDateZero => date == defaultDate;

  Duration difference(Time other) {
    return value.difference(other.value);
  }

  Time toFirstDayOfYear() {
    final first = DateTime.utc(
      value.year,
      1,
      1,
      value.hour,
      value.minute,
      value.second,
    );
    return Time.value(first);
  }

  Time toFirstDayOfThisWeek() {
    for (final d in range(0, 6)) {
      final date = this.subtract(Duration(days: d));
      if (date.abbrWeekday.toLowerCase() == 'mon') {
        return date;
      }
    }
    return this;
  }

  Time toFirstDayOfThisMonth() {
    final time = DateTime.utc(
      value.year,
      value.month,
      1,
      value.hour,
      value.minute,
      value.second,
    );
    return Time.value(time);
  }

  Time toLastDayOfThisMonth() {
    final first = toFirstDayOfThisMonth();
    return first.add(
      Duration(days: first.noOfDaysInMonth - 1),
    );
  }

  Time toFirstDayOfLastMonth() {
    int month = value.month - 1;
    int year = value.year;
    if (month == 0) {
      month = 1;
      year -= 1;
    }
    final time = DateTime.utc(
      year,
      month,
      1,
      value.hour,
      value.minute,
      value.second,
    );
    return Time.value(time);
  }

  Time toLastDayOfLastMonth() {
    final first = toFirstDayOfLastMonth();
    return first.add(
      Duration(days: first.noOfDaysInMonth - 1),
    );
  }

  TimeRange toPastWeek() {
    return toRange(duration: const Duration(days: 6));
  }

  TimeRange toMonth() {
    return TimeRange(
      start: toFirstDayOfThisMonth(),
      end: toLastDayOfThisMonth(),
    );
  }

  TimeRange toPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return TimeRange.today();
      case TimePeriod.yesterday:
        return TimeRange.yesterday();
      case TimePeriod.thisWeek:
        return TimeRange(
          start: toFirstDayOfThisWeek(),
          end: this,
          period: period,
        );
      case TimePeriod.thisMonth:
        return TimeRange(
          start: toFirstDayOfThisMonth(),
          end: this,
          period: period,
        );
      case TimePeriod.lastWeek:
        final date = this.subtract(
          const Duration(days: 7),
        );
        final start = date.toFirstDayOfThisWeek();
        return TimeRange(
          start: start,
          end: start.add(
            const Duration(days: 6),
          ),
          period: period,
        );
      case TimePeriod.lastMonth:
        return TimeRange(
          start: toFirstDayOfLastMonth(),
          end: toLastDayOfLastMonth(),
          period: period,
        );
      case TimePeriod.last7Days:
        final start = this.subtract(
          const Duration(days: 6),
        );
        return TimeRange(
          start: start,
          end: this,
          period: period,
        );
      case TimePeriod.last30Days:
        final start = this.subtract(
          const Duration(days: 29),
        );
        return TimeRange(
          start: start,
          end: this,
          period: period,
        );
      case TimePeriod.last3Months:
        final v = value;
        final dt = DateTime(
          v.year,
          v.month - 3,
          v.day,
        );
        return TimeRange(
          start: Time.value(dt),
          end: this,
          period: period,
        );
      case TimePeriod.last6Months:
        final v = value;
        final dt = DateTime(
          v.year,
          v.month - 6,
          v.day,
        );
        return TimeRange(
          start: Time.value(dt),
          end: this,
          period: period,
        );
      case TimePeriod.fromTheBeginning:
        return TimeRange(
          start: Time.zero,
          end: this,
          period: period,
        );
      default:
        return TimeRange(
          start: this,
          end: this,
          period: period,
        );
    }
  }

  TimeRange toRange({
    required Duration duration,
    bool onward = false,
  }) {
    return TimeRange(
      start: onward ? add(duration) : subtract(duration),
      end: this,
    );
  }

  bool isEqual(Time other) {
    return this == other;
  }

  bool isAfter(Time other) {
    return this > other;
  }

  bool isBefore(Time other) {
    return this < other;
  }

  bool isBetween(TimeRange range) {
    return this >= range.start && this <= range.end;
  }

  bool isAfterOrEqual(Time other) {
    return this >= other;
  }

  bool isBeforeOrEquals(Time other) {
    return this <= other;
  }

  bool isWithin(Duration duration) {
    final now = Time.now();
    return this >= now.subtract(duration);
  }

  bool isSameMonth(Time other) {
    return value.month == other.value.month;
  }

  bool isSameYear(Time other) {
    return value.year == other.value.year;
  }

  bool isSameDate(Time other) {
    return date == other.date;
  }

  Time add(Duration duration) {
    final result = value.add(duration);
    return Time.value(result);
  }

  Time subtract(Duration duration) {
    final result = value.subtract(duration);
    return Time.value(result);
  }

  bool operator <(Time other) {
    return value.isBefore(other.value);
  }

  bool operator >(Time other) {
    return value.isAfter(other.value);
  }

  bool operator <=(Time other) {
    return value.isBefore(other.value) || this == other;
  }

  bool operator >=(Time other) {
    return value.isAfter(other.value) || this == other;
  }

  Time operator +(Time other) {
    return add(other.duration);
  }

  Time operator -(Time other) {
    return subtract(other.duration);
  }

  @override
  String toString() {
    return '$_date $_time';
  }

  static const zero = const Time();
}

class TimeController extends ValueNotifier<Time> {
  TimeController({
    required Time time,
  }) : super(time);

  void setTime(Time value) {
    this.value = value;
    notifyListeners();
  }
}
