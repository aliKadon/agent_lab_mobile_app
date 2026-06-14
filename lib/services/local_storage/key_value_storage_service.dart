
import 'key_value_storage_base.dart';

class KeyValueStorageService {
  final _keyValueStorage = KeyValueStorageBase.instance;

  Future<void> setStringValue(String key, String value) async {
    await _keyValueStorage.setCommon<String>(key, value);
  }

  String? getStringValue(String key) {
    return _keyValueStorage.getCommon<String>(key);
  }

  List<String>? getListOfStringValue(String key) {
    return _keyValueStorage.getCommon<List<String>>(key);
  }

  Future<void> setListOfStringValue(String key, List<String> value) async {
    await _keyValueStorage.setCommon<List<String>>(key, value);
  }

  Future<void> setBoolValue(String key, bool value) async {
    await _keyValueStorage.setCommon<bool>(key, value);
  }

  bool? getBoolValue(String key) {
    return _keyValueStorage.getCommon<bool>(key);
  }

  Future<void> clear() async {
    await _keyValueStorage.clearCommon();
  }

  void resetKeys() {
    _keyValueStorage.clearCommon();
  }

  Future<void> removeValue(String key) async {
    await KeyValueStorageBase.removeCommon(key);
  }
}
