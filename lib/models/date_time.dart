import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const String dateFormat = 'yyyy-MM-dd';
const String timeFormat = 'HH:mm:ss';
const String locale = 'en_US';

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

  String get display => DateFormat.yMMMMd(locale).add_jm().format(value);

  String get displayDate => DateFormat.yMMMMd(locale).format(value);

  String get displayTime => DateFormat.jm(locale).format(value);

  String get dayOfTheWeek => DateFormat.EEEE(locale).format(value);

  String get dayOfTheMonth => DateFormat.d(locale).format(value);

  String get monthInYear => DateFormat.MMMM(locale).format(value);

  String get abbreviatedWeekday => DateFormat.E(locale).format(value);

  String get abbreviatedMonth => DateFormat.MMM(locale).format(value);

  String get history => ago.format(value);

  DateTime get value => DateTime.parse('$date $time');

  bool get isNewMinute {
    if (time != null) {
      final split = time.split(':');
      return split.last == '00';
    }
    return null;
  }

  const DateTimeData({
    this.date = '0000-00-00',
    this.time = '00:00:00',
  });

  factory DateTimeData.from(DateTime input) {
    final date = DateFormat(dateFormat);
    final time = DateFormat(timeFormat);
    return DateTimeData(
      date: date.format(input),
      time: time.format(input),
    );
  }

  factory DateTimeData.parse(String input) {
    final value = DateTime.parse(input);
    return DateTimeData.from(value);
  }

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

  bool isAfter(DateTimeData other) {
    return value.isAfter(other.value);
  }

  bool isBefore(DateTimeData other) {
    return value.isBefore(other.value);
  }

  DateTimeData add(Duration duration) {
    final sum = value.add(duration);
    return DateTimeData.from(sum);
  }
}
