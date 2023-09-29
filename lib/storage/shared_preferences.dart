import 'package:codepan/extensions/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  final SharedPreferences prefs;

  const SharedPreferencesManager({
    required this.prefs,
  });

  static Future<SharedPreferencesManager> create() async {
    return SharedPreferencesManager(
      prefs: await SharedPreferences.getInstance(),
    );
  }

  void setAll(Map<String, dynamic> data) {
    data.forEach((key, value) {
      set(key: key, value: value);
    });
  }

  void set<T>({
    required String key,
    required T value,
  }) {
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else {
      prefs.setString(key, value.toCapitalizedWords());
    }
  }

  T? get<T>(String key) {
    final value = prefs.get(key);
    if (value != null) {
      return value as T;
    }
    return null;
  }

  T? getEnum<T>({
    required String key,
    required List<T> values,
  }) {
    final value = prefs.get(key);
    if (value is String) {
      for (final element in values) {
        if (value.snake.replaceAll('_', '') ==
            element.snake.replaceAll('_', '')) {
          return element;
        }
      }
    }
    return null;
  }
}
