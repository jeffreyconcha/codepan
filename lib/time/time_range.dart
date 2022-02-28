import 'package:codepan/time/time.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TimeRange extends Equatable {
  final Time start;
  final Time end;

  @override
  List<Object?> get props {
    return [
      start,
      end,
    ];
  }

  String get displayRange {
    if (start != end) {
      if (start.isSameYear(end)) {
        if (start.isSameMonth(end)) {
          final range = '${start.displayDay} - ${end.displayDay}';
          return '${start.displayMonth} $range, ${start.displayYear}';
        }
        final range = '${start.displayMonthDay} - ${end.displayMonthDay}';
        return '$range ${start.displayYear}';
      }
    }
    return start.displayDate;
  }

  String get abbrRange {
    if (start != end) {
      if (start.isSameYear(end)) {
        if (start.isSameMonth(end)) {
          final range = '${start.displayDay} - ${end.displayDay}';
          return '${start.abbrMonth} $range, ${start.displayYear}';
        }
        final range = '${start.abbrMonthDay} - ${end.abbrMonthDay}';
        return '$range, ${start.displayYear}';
      }
    }
    return start.abbrDate;
  }

  bool get isValid => start <= end;

  bool get isZero => start.isZero || end.isZero;

  bool get isNotZero => !isZero;

  Duration get duration =>
      isValid ? end.difference(start) + Duration(days: 1) : Duration.zero;

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
    return Time.today().toRange(
      duration: const Duration(days: 6),
    );
  }

  factory TimeRange.value(DateTimeRange? range) {
    return TimeRange(
      start: Time.value(range?.start),
      end: Time.value(range?.end),
    );
  }

  List<Time> toList() {
    final list = <Time>[];
    Time current = Time.value(start.value);
    while (current <= end) {
      list.add(current);
      current = current.add(const Duration(days: 1));
    }
    return list;
  }
}

class TimeRangeController extends ValueNotifier<TimeRange> {
  TimeRangeController({
    required TimeRange range,
  }) : super(range);

  void setTimeRange(TimeRange range) {
    this.value = range;
    notifyListeners();
  }
}
