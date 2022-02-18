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

  void set({
    required String key,
    required dynamic value,
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
    }
  }

  T? get<T>(String key) {
    final value = prefs.get(key);
    if (value != null) {
      return value as T;
    }
    return null;
  }
}
