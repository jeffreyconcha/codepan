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
}
