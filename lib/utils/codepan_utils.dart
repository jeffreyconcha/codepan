import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/extensions/num.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/time/time.dart';
import 'package:codepan/time/time_range.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as dp;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as lt;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _urlPattern =
    r'(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';
const printError = _printError;
const printLarge = _printLarge;
const printPost = _printPost;
const century = const Duration(days: 365 * 100);

void _printPost(String url, Map<String, dynamic> params) {
  final encoder = JsonEncoder.withIndent('  ');
  debugPrint('$url\n${encoder.convert(params)}');
}

void _printError(dynamic error, StackTrace stacktrace) {
  debugPrint('${error?.toString()}: ${stacktrace.toString()}');
}

void _printLarge(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

List<int> range(int min, int max) {
  final list = <int>[];
  for (int i = min; i <= max; i++) {
    list.add(i);
  }
  return list;
}

enum AddressAttribute {
  street,
  subLocality,
  locality,
  administrativeArea,
  country,
}

class PanUtils {
  @deprecated
  static String formatMoney(double input) {
    final nf = NumberFormat('#,###.##', 'en_US');
    return nf.format(input);
  }

  @deprecated
  static String formatDouble(String format, double input) {
    final nf = NumberFormat(format, 'en_US');
    return nf.format(input);
  }

  static Future<Directory> getAppDirectory() async {
    final slash = Platform.pathSeparator;
    final info = await PackageInfo.fromPlatform();
    final root = await getApplicationDocumentsDirectory();
    if (Platform.isWindows || Platform.isMacOS) {
      return Directory('${root.path}$slash${info.appName}');
    } else {
      return root;
    }
  }

  static Future<File> getFile({
    required String fileName,
    String? folder,
    List<String> folders = const [],
  }) async {
    final root = await getAppDirectory();
    final slash = Platform.pathSeparator;
    if (folder != null) {
      folders.add(folder);
    }
    if (folders.isNotEmpty) {
      final buffer = StringBuffer(root.path);
      for (final folder in folders) {
        buffer.write('$slash$folder');
      }
      final dir = Directory(buffer.toString());
      if (!await dir.exists()) {
        await dir.create();
      }
      return dir.file(fileName);
    } else {
      return File('${root.path}$slash$fileName');
    }
  }

  static Future<Directory> getDirectory(String folder) async {
    final slash = Platform.pathSeparator;
    final root = await getAppDirectory();
    final dir = Directory('${root.path}$slash$folder');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return true;
      default:
        return false;
    }
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

  static int? parseInt(dynamic input) {
    return input is int ? input : int.tryParse(input.toString());
  }

  static double? parseDouble(dynamic input) {
    return input is double ? input : double.tryParse(input.toString());
  }

  static bool? parseBool(dynamic input) {
    if (input is bool) {
      return input;
    } else if (input is int) {
      final binary = parseInt(input);
      return binary?.toBool();
    } else if (input is String) {
      return input.toBool();
    }
    return false;
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

  static Future<Time> showDatePicker(
    BuildContext context, {
    Time? initialDate,
  }) async {
    final t = Theme.of(context);
    final today = Time.today();
    final firstDate = today.subtract(century);
    final lastDate = today.add(century);
    final initial = initialDate?.isNotZero ?? false ? initialDate : today;
    final data = await dp.showDatePicker(
      context: context,
      initialDate: initial!.value,
      firstDate: firstDate.value,
      lastDate: lastDate.value,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: t.primaryColor,
              onPrimary: Colors.white,
              onSurface: PanColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    return Time.value(data);
  }

  static Future<TimeRange> showDateRangePicker(
    BuildContext context, {
    TimeRange? initialDateRange,
  }) async {
    final t = Theme.of(context);
    final today = Time.today();
    final firstDate = today.subtract(century);
    final lastDate = today.add(century);
    final data = await dp.showDateRangePicker(
      context: context,
      firstDate: firstDate.value,
      lastDate: lastDate.value,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: t.primaryColor,
              onPrimary: Colors.white,
              onSurface: PanColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    return TimeRange.value(data);
  }

  static Future<lt.LatLng?> getCoordinatesFromAddress(String? address) async {
    if (address?.isNotEmpty ?? false) {
      try {
        final list = await locationFromAddress(address!);
        if (list.isNotEmpty) {
          final first = list.first;
          final latitude = first.latitude;
          final longitude = first.longitude;
          if (isLatLngValid(latitude, longitude)) {
            return lt.LatLng(latitude, longitude);
          }
        }
      } catch (error) {
        print(error);
      }
    }
    return null;
  }

  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    List<AddressAttribute> attrs = AddressAttribute.values,
  }) async {
    final buffer = StringBuffer();
    try {
      final places = await placemarkFromCoordinates(latitude, longitude);
      if (places.isNotEmpty) {
        final place = places.first;
        for (final attr in attrs) {
          switch (attr) {
            case AddressAttribute.street:
              if (place.street?.isNotEmpty ?? false) {
                buffer.write(place.street);
                if (_hasNextAttribute(attr, attrs, place)) {
                  buffer.write(', ');
                }
              }
              break;
            case AddressAttribute.subLocality:
              if (place.subLocality?.isNotEmpty ?? false) {
                buffer.write(place.subLocality);
                if (_hasNextAttribute(attr, attrs, place)) {
                  buffer.write(', ');
                }
              }
              break;
            case AddressAttribute.locality:
              if (place.locality?.isNotEmpty ?? false) {
                buffer.write(place.locality);
                if (_hasNextAttribute(attr, attrs, place)) {
                  buffer.write(', ');
                }
              }
              break;
            case AddressAttribute.administrativeArea:
              if (place.administrativeArea?.isNotEmpty ?? false) {
                buffer.write(place.administrativeArea);
                if (_hasNextAttribute(attr, attrs, place)) {
                  buffer.write(', ');
                }
              }
              break;
            case AddressAttribute.country:
              if (place.country?.isNotEmpty ?? false) {
                buffer.write(place.country);
                if (_hasNextAttribute(attr, attrs, place)) {
                  buffer.write(', ');
                }
              }
              break;
          }
        }
      }
    } catch (error, stackTrace) {
      printError(error, stackTrace);
    }
    return buffer.toString();
  }

  static bool _hasNextAttribute(
    AddressAttribute attr,
    List<AddressAttribute> attrs,
    Placemark place,
  ) {
    if (attr != attrs.last) {
      final nextIndex = attrs.indexOf(attr) + 1;
      switch (attrs[nextIndex]) {
        case AddressAttribute.street:
          if (place.street?.isNotEmpty ?? false) {
            return true;
          }
          break;
        case AddressAttribute.subLocality:
          if (place.subLocality?.isNotEmpty ?? false) {
            return true;
          }
          break;
        case AddressAttribute.locality:
          if (place.locality?.isNotEmpty ?? false) {
            return true;
          }
          break;
        case AddressAttribute.administrativeArea:
          if (place.administrativeArea?.isNotEmpty ?? false) {
            return true;
          }
          break;
        case AddressAttribute.country:
          if (place.country?.isNotEmpty ?? false) {
            return true;
          }
          break;
      }
    }
    return false;
  }

  static Future<String?> getAddress(
    dynamic point, {
    List<AddressAttribute> attrs = AddressAttribute.values,
  }) async {
    if (point is Position) {
      return await getAddressFromCoordinates(
        point.latitude,
        point.longitude,
        attrs: attrs,
      );
    }
    if (point is LatLng) {
      return await getAddressFromCoordinates(
        point.latitude,
        point.longitude,
        attrs: attrs,
      );
    }
    if (point is lt.LatLng) {
      return await getAddressFromCoordinates(
        point.latitude,
        point.longitude,
        attrs: attrs,
      );
    }
    return null;
  }

  static bool isLatLngValid(
    double? latitude,
    double? longitude,
  ) {
    if (latitude != null && longitude != null) {
      return latitude.isBetween(-90, 90) && longitude.isBetween(-180, 180);
    }
    return false;
  }

  static void redirect(String? link) async {
    if (link?.isNotEmpty ?? false) {
      final url = link!.contains('http') ? link : 'https://$link';
      final uri = Uri.parse(url);
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e, s) {
        printError(e, s);
      }
    }
  }
}
