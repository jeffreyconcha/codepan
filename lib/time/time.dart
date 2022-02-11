import 'package:codepan/extensions/duration.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const String dateFormat = 'yyyy-MM-dd';
const String timeFormat = 'HH:mm:ss';
const String locale = 'en_US';
const int zeroInMillisecondsEpoch = -62170012800000;

class Time extends Equatable {
  final String? date;
  final String? time;

  @override
  List<Object?> get props => [milliseconds];

  String get display => DateFormat.yMMMMd(locale).add_jm().format(value);

  String get displayDate => DateFormat.yMMMMd(locale).format(value);

  String get shortDate => DateFormat.yMMMd(locale).format(value);

  String get displayTime => DateFormat.jm(locale).format(value);

  String get displayTimeWithSeconds => DateFormat.jms(locale).format(value);

  String get dayOfTheWeek => DateFormat.EEEE(locale).format(value);

  String get dayOfTheMonth => DateFormat.d(locale).format(value);

  String get monthInYear => DateFormat.MMMM(locale).format(value);

  String get abbreviatedWeekday => DateFormat.E(locale).format(value);

  String get abbreviatedMonth => DateFormat.MMM(locale).format(value);

  String get history => ago.format(value);

  DateTime get value => DateTime.parse('$date $time');

  String get timezone => value.timeZoneName;

  String get timezoneValue => value.timeZoneOffset.format(withSeconds: false);

  int get milliseconds => value.millisecondsSinceEpoch;

  bool? get isNewMinute {
    final split = time!.split(':');
    return split.last == '00';
  }

  const Time({
    this.date = '0000-00-00',
    this.time = '00:00:00',
  });

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

  factory Time.millis(int timestamp) {
    final value = DateTime.fromMillisecondsSinceEpoch(timestamp);
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

  bool isZero() {
    return milliseconds <= zeroInMillisecondsEpoch;
  }

  bool isNotZero() {
    return !isZero();
  }

  Duration difference(Time other) {
    return value.difference(other.value);
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

  @override
  String toString() {
    return '$date $time';
  }
}

class TimeRange {
  final Time start;
  final Time end;

  DateTimeRange get value {
    return DateTimeRange(
      start: start.value,
      end: end.value,
    );
  }

  const TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.now() {
    final now = Time.now();
    return TimeRange(
      start: now,
      end: now,
    );
  }

  factory TimeRange.today() {
    final today = Time.today();
    return TimeRange(
      start: today,
      end: today,
    );
  }

  factory TimeRange.week() {
    final today = Time.today();
    return TimeRange(
      start: today.subtract(
        Duration(
          days: 6,
        ),
      ),
      end: today,
    );
  }

  factory TimeRange.value(DateTimeRange? range) {
    return TimeRange(
      start: Time.value(range?.start),
      end: Time.value(range?.end),
    );
  }
}