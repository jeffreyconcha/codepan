import 'package:codepan/model/date_time.dart';
import 'package:intl/intl.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

class PanUtils {
  static Map<String, String> getDateTime() {
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd');
    final time = DateFormat('HH:mm:ss');
    return {
      'date': date.format(now),
      'time': time.format(now),
    };
  }

  static DateTimeData splitDateTime(String input, {String pattern = ' '}) {
    if (input != null) {
      final data = input.split(pattern);
      if (data != null && data.length == 2) {
        return DateTimeData(
          date: data[0],
          time: data[1],
        );
      }
    }
    return null;
  }

  static String formatMoney(double input) {
    if (input == null) return null;
    final nf = NumberFormat('#,###.00', 'en_US');
    return nf.format(input);
  }

  static String formatDuration(Duration duration, {bool withHours = false}) {
    String format(int n) => n.toString().padLeft(2, "0");
    String seconds = format(duration.inSeconds.remainder(60));
    String minutes = format(duration.inMinutes.remainder(60));
    if (withHours) {
      String hours = format(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String getTimeHistory(String date, String time) {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final value = format.parse('$date $time');
    return ago.format(value);
  }
}
