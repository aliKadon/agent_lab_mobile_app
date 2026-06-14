import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorageBase {
  const KeyValueStorageBase._();

  static SharedPreferences? _sharedPrefs;

  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  static KeyValueStorageBase? _instance;

  static KeyValueStorageBase get instance => _instance ?? const KeyValueStorageBase._();

  Future<bool> clearCommon() => _sharedPrefs!.clear();

  static Future<void> removeCommon(String key) async {
    await _sharedPrefs?.remove(key);
  }

  T? getCommon<T>(String key) {
    try {
      switch (T) {
        case const (String):
          return _sharedPrefs!.getString(key) as T?;
        case const (int):
          return _sharedPrefs!.getInt(key) as T?;
        case const (bool):
          return _sharedPrefs!.getBool(key) as T?;
        case const (double):
          return _sharedPrefs!.getDouble(key) as T?;
        case const (List<String>):
          return _sharedPrefs!.getStringList(key) as T?;
        default:
          return _sharedPrefs!.get(key) as T?;
      }
    } on Exception {
      return null;
    }
  }

  Future<bool> setCommon<T>(String key, T value) {
    switch (T) {
      case const (String):
        return _sharedPrefs!.setString(key, value as String);
      case const (int):
        return _sharedPrefs!.setInt(key, value as int);
      case const (bool):
        return _sharedPrefs!.setBool(key, value as bool);
      case const (double):
        return _sharedPrefs!.setDouble(key, value as double);
      case const (List<String>):
        return _sharedPrefs!.setStringList(key, value as List<String>);
      default:
        return _sharedPrefs!.setString(key, value as String);
    }
  }
}
