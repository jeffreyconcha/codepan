import 'package:codepan/resources/strings.dart';
import 'package:codepan/time/time.dart';
import 'package:codepan/widgets/dialogs/menu_dialog.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TimePeriod {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastWeek,
  lastMonth,
  last7Days,
  last30Days,
  custom,
}

extension TimePeriodExt on TimePeriod {
  String get title {
    switch (this) {
      case TimePeriod.today:
        return Strings.today;
      case TimePeriod.yesterday:
        return Strings.yesterday;
      case TimePeriod.thisWeek:
        return Strings.thisWeek;
      case TimePeriod.thisMonth:
        return Strings.thisMonth;
      case TimePeriod.lastWeek:
        return Strings.lastWeek;
      case TimePeriod.lastMonth:
        return Strings.lastMonth;
      case TimePeriod.last7Days:
        return Strings.last7Days;
      case TimePeriod.last30Days:
        return Strings.last30Days;
      case TimePeriod.custom:
        return Strings.custom;
    }
  }
}

class TimeRange extends Equatable {
  final TimePeriod? period;
  final Time _start;
  final Time _end;

  Time get start => _start;

  Time get end => _end;

  @override
  List<Object?> get props {
    return [
      start,
      end,
    ];
  }

  String get displayDate {
    if (start != end) {
      if (start.isSameYear(end)) {
        if (start.isSameMonth(end)) {
          if (start.trimmedDate == end.trimmedDate) {
            return start.displayDate;
          }
          final range = '${start.displayDay} - ${end.displayDay}';
          return '${start.displayMonth} $range, ${start.displayYear}';
        }
        final range = '${start.displayMonthDay} - ${end.displayMonthDay}';
        return '$range ${start.displayYear}';
      }
    }
    return start.displayDate;
  }

  String get displayTime => '${start.displayTime} - ${end.displayTime}';

  String get abbrDate {
    if (start != end) {
      if (start.isSameYear(end)) {
        if (start.isSameMonth(end)) {
          if (start.trimmedDate == end.trimmedDate) {
            return start.abbrDate;
          }
          final range = '${start.displayDay} - ${end.displayDay}';
          return '${start.abbrMonth} $range, ${start.displayYear}';
        }
        final range = '${start.abbrMonthDay} - ${end.abbrMonthDay}';
        return '$range, ${start.displayYear}';
      }
    }
    return start.abbrDate;
  }

  String get displayPeriod {
    if (period != null) {
      switch (period) {
        case TimePeriod.today:
        case TimePeriod.yesterday:
          return '${period?.title}, $displayDate';
        default:
          return '${period?.title} (${displayDate.split(',').first})';
      }
    }
    return displayDate;
  }

  String get abbrPeriod {
    if (period != null) {
      switch (period) {
        case TimePeriod.today:
        case TimePeriod.yesterday:
          return '${period?.title}, $abbrDate';
        default:
          return '${period?.title} (${abbrDate.split(',').first})';
      }
    }
    return abbrDate;
  }

  bool get isValid => start <= end;

  bool get isZero => start.isZero && end.isZero;

  bool get isTimeZero => start.isTimeZero && end.isTimeZero;

  bool get isDateZero => start.isDateZero && end.isDateZero;

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
    required Time? start,
    required Time? end,
    this.period,
  })  : _start = start ?? Time.zero,
        _end = end ?? Time.zero;

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
      period: TimePeriod.today,
    );
  }

  factory TimeRange.yesterday() {
    final yesterday = Time.yesterday();
    return TimeRange(
      start: yesterday,
      end: yesterday,
      period: TimePeriod.yesterday,
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

  factory TimeRange.period({
    required TimePeriod period,
    required Time time,
  }) {
    return time.toPeriod(period);
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

class TimePeriodWrapper implements Selectable {
  final TimePeriod period;

  const TimePeriodWrapper({
    required this.period,
  });

  @override
  dynamic get identifier => period;

  @override
  List<String?> get searchable => [title];

  @override
  String? get title => period.title;
}
