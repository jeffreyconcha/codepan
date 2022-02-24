import 'package:codepan/extensions/duration.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/time/time_range.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const String dateFormat = 'yyyy-MM-dd';
const String timeFormat = 'HH:mm:ss';
const String locale = 'en_US';
const int millisecondsEpoch = 62170012800000;

class Time extends Equatable {
  final String? _date;
  final String? _time;

  String? get date => DateFormat(dateFormat, locale).format(value);

  String? get time => DateFormat(timeFormat, locale).format(value);

  @override
  List<Object?> get props => [milliseconds];

  String get display => DateFormat.yMMMMd(locale).add_jm().format(value);

  String get displayDate => DateFormat.yMMMMd(locale).format(value);

  String get displayWeekdayDate => '$displayWeekday, $displayDate';

  String get displayTime => DateFormat.jm(locale).format(value);

  String get displayTimeWithSeconds => DateFormat.jms(locale).format(value);

  String get displayWeekday {
    return this != Time.today()
        ? DateFormat.EEEE(locale).format(value)
        : Strings.today;
  }

  String get displayDay => DateFormat.d(locale).format(value);

  String get displayMonth => DateFormat.MMMM(locale).format(value);

  String get displayYear => DateFormat.y(locale).format(value);

  String get displayMonthDay => DateFormat.MMMMd(locale).format(value);

  String get abbrWeekday {
    return this != Time.today()
        ? DateFormat.E(locale).format(value)
        : Strings.today;
  }

  String get abbrMonth => DateFormat.MMM(locale).format(value);

  String get abbrMonthDay => DateFormat.MMMd(locale).format(value);

  String get abbrWeekdayDate => '$abbrWeekday, $abbrDate';

  String get abbrDate => DateFormat.yMMMd(locale).format(value);

  String get history => ago.format(value);

  DateTime get value => DateTime.parse('$_date $_time');

  String get timezone => value.timeZoneName;

  String get timezoneValue => value.timeZoneOffset.format(withSeconds: false);

  int get millisecondsSinceEpoch => value.millisecondsSinceEpoch;

  int get milliseconds => millisecondsSinceEpoch + millisecondsEpoch;

  bool? get isNewMinute {
    final split = _time!.split(':');
    return split.last == '00';
  }

  const Time({
    String? date = '0000-00-00',
    String? time = '00:00:00',
  })  : _date = date,
        _time = time;

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

  Time toFirstDayOfMonth() {
    final first = DateTime.utc(
      value.year,
      value.month,
      1,
      value.hour,
      value.minute,
      value.second,
    );
    return Time.value(first);
  }

  TimeRange thisWeek() {
    return toRange(duration: const Duration(days: 6));
  }

  TimeRange thisMonth() {
    return TimeRange(
      start: this.toFirstDayOfMonth(),
      end: this,
    );
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