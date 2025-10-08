import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    return _preferences.getString(key);
  }

  static Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  static bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  static Future<bool> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  static int? getInt(String key) {
    return _preferences.getInt(key);
  }

  static Future<bool> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }
}
