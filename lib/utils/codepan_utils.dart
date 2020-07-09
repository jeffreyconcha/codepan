import 'package:codepan/model/date_time.dart';
import 'package:intl/intl.dart';

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
}
