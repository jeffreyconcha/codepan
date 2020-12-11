import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/models/date_time.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as ago;

const _urlPattern =
    r'(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';

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

  static DateTimeData now() {
    final now = DateTime.now();
    return formatDateTime(now);
  }

  static DateTimeData formatDateTime(DateTime input) {
    final date = DateFormat('yyyy-MM-dd');
    final time = DateFormat('HH:mm:ss');
    return DateTimeData(
      date: date.format(input),
      time: time.format(input),
    );
  }

  static String getFormattedDateAndTime() {
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

  static String formatDateAndTime(String date, String time) {
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
    bool withSeconds = true,
    bool isReadable = false,
    bool isAbbreviated = false,
  }) {
    String format(int n) => n.toString().padLeft(2, "0");
    final h = duration.inHours.remainder(24);
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    final hs = isReadable
        ? h > 1
            ? ' hrs '
            : ' hr '
        : ':';
    final ms = isReadable
        ? m > 1
            ? ' mins '
            : ' min '
        : ':';
    final ss = isReadable
        ? s > 1
            ? ' secs'
            : ' sec'
        : ':';
    final hours = isReadable ? '$h' : format(h);
    final minutes = isReadable ? '$m' : format(m);
    final seconds = isReadable ? '$s' : format(s);
    final buffer = StringBuffer();
    if (h != 0) {
      buffer.write('$hours');
      buffer.write(!isAbbreviated ? hs : 'h ');
    }
    if (!isReadable || m != 0) {
      buffer.write('$minutes');
      buffer.write(!isAbbreviated ? ms : 'm ');
    }
    if (!isReadable || (withSeconds && s != 0) || duration.inSeconds < 60) {
      buffer.write('$seconds');
      if (isReadable) {
        buffer.write(!isAbbreviated ? ss : 's');
      }
    }
    return buffer.toString().trim();
  }

  static String getTimeHistory(String date, String time) {
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final value = format.parse('$date $time');
    return ago.format(value);
  }

  static String getDayOfTheWeek(String date, String time) {
    final dt = DateTime.parse('$date $time');
    final format = DateFormat.EEEE('en_US');
    return format.format(dt);
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
      _urlPattern,
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
      return binary.toBool();
    } else if (input is String) {
      return input.toBool();
    }
    return false;
  }

  static String camelToSnake(String text) {
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

  static RelativeRect getWidgetPosition(GlobalKey key) {
    final context = key.currentContext;
    final RenderBox bar = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    return RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(
          bar.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
        bar.localToGlobal(
          bar.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
  }

  static String getPercentage(int progress, int max) {
    final percentage = ((progress / max) * 100);
    if (!percentage.isNaN && !percentage.isInfinite) {
      return '${percentage.round()}%';
    }
    return '0%';
  }

  static bool isEnum(dynamic data) {
    final array = data.toString().split('.');
    return array.length == 2 && array[0] == data.runtimeType.toString();
  }

  static String enumValue(dynamic data) {
    return data.toString().split('.').last;
  }
}
