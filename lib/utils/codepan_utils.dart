import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:codepan/models/date_time.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const urlPattern =
    r'(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';
const trueValues = <String>[
  'true',
  'yes',
  'on',
];
const falseValues = <String>[
  'false',
  'no',
  'off',
];

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

  static String getFormattedDateTime() {
    final now = DateTime.now();
    final format = DateFormat.yMMMMd('en_US').add_jm();
    return format.format(now);
  }

  static String formatDate(String input) {
    final date = DateTime.parse(input);
    final format = DateFormat.yMMMMd('en_US');
    return format.format(date);
  }

  static String formatTime(String input) {
    final time = DateTime.parse('0000-00-00 $input');
    final format = DateFormat.jm();
    return format.format(time);
  }

  static String formatDateTime(String date, String time) {
    final dt = DateTime.parse('$date $time');
    final format = DateFormat.yMMMMd('en_US').add_jm();
    return format.format(dt);
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

  static String formatDouble(String format, double input) {
    if (input == null) return null;
    final nf = NumberFormat(format, 'en_US');
    return nf.format(input);
  }

  static String formatDuration(
    Duration duration, {
    bool isReadable = false,
  }) {
    String format(int n) => n.toString().padLeft(2, "0");
    int h = duration.inHours.remainder(24);
    int m = duration.inMinutes.remainder(60);
    int s = duration.inSeconds.remainder(60);
    String hs = isReadable
        ? h > 1
            ? ' hrs '
            : ' hr '
        : ':';
    String ms = isReadable
        ? m > 1
            ? ' mins '
            : ' min '
        : ':';
    String ss = isReadable
        ? s > 1
            ? ' secs'
            : ' sec'
        : ':';
    String hours = isReadable ? '$h' : format(h);
    String minutes = isReadable ? '$m' : format(m);
    String seconds = isReadable ? '$s' : format(s);
    final buffer = StringBuffer();
    if (h != 0) {
      buffer.write('$hours');
      buffer.write(hs);
    }
    if (!isReadable || m != 0) {
      buffer.write('$minutes');
      buffer.write(ms);
    }
    if (!isReadable || s != 0) {
      buffer.write('$seconds');
      if (isReadable) {
        buffer.write(ss);
      }
    }
    return buffer.toString();
  }

  static String getTimeHistory(String date, String time) {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final value = format.parse('$date $time');
    return ago.format(value);
  }

  static Future<File> getFile({
    String folder,
    @required String fileName,
  }) async {
    final root = await getApplicationDocumentsDirectory();
    if (folder != null) {
      final dir = Directory('${root.path}/$folder');
      if (!await dir.exists()) {
        await dir.create();
      }
      return File('${dir.path}/$fileName');
    } else {
      return File('${root.path}/$fileName');
    }
  }

  static Future<Directory> getDirectory(
    String folder,
  ) async {
    final root = await getApplicationDocumentsDirectory();
    if (folder != null) {
      final dir = Directory('${root.path}/$folder');
      if (!await dir.exists()) {
        await dir.create();
      }
      return dir;
    }
    return root;
  }

  static void printLarge(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile;
  }

  static bool isValidUrl(String url) {
    final match = RegExp(
      urlPattern,
      caseSensitive: false,
    ).firstMatch(url);
    return match != null;
  }

  static void bindIsolatePort(SendPort sp, String name) {
    final result = IsolateNameServer.registerPortWithName(sp, name);
    if (!result) {
      IsolateNameServer.removePortNameMapping(name);
      bindIsolatePort(sp, name);
    }
  }

  static int parseInt(dynamic input) {
    return input is int ? input : int.tryParse(input.toString());
  }

  static double parseDouble(dynamic input) {
    return input is double ? input : double.tryParse(input.toString());
  }

  static bool parseBool(dynamic input) {
    if (input is bool) {
      return input;
    } else if (input is int) {
      final binary = parseInt(input);
      return binary == 1;
    } else if (input is String) {
      if (trueValues.contains(input)) {
        return true;
      } else if (falseValues.contains(input)) {
        return false;
      }
    }
    return null;
  }

  static String camelToUnderscore(String text) {
    final buffer = StringBuffer();
    text?.runes?.forEach((code) {
      final character = String.fromCharCode(code);
      if (character == character.toUpperCase()) {
        buffer.write('_');
      }
      buffer.write(character.toLowerCase());
    });
    return buffer.toString();
  }
}
