

import '../../local_storage/key_value_storage_service.dart';
import 'local_datasource.dart';

class LocalDataSourceImp implements LocalDataSource {
  final KeyValueStorageService? _keyValueStorageService;

  LocalDataSourceImp({
    KeyValueStorageService? keyValueStorageService,
  }) : _keyValueStorageService = keyValueStorageService;

  final String themeKey = 'theme';
  final String appLanguage = 'appLanguage';
  final String userInfo = 'user_info';
  final String sessionIdKey = 'sessionId';
  final String ondSessionIdKey = 'OndsessionId';
  final String userSearches = 'user_searches';
  final String inAppReviewShown = 'in_app_review_shown';

  @override
  Future<bool> clearSharedPreferences() async {
    await _keyValueStorageService?.clear();
    return true;
  }

  @override
  Future<bool> saveSessionId(String params) async {
    await _keyValueStorageService?.setStringValue(sessionIdKey, params);
    return true;
  }

  @override
  Future<bool> saveOndSessionId(String params) async {
    await _keyValueStorageService?.setStringValue(ondSessionIdKey, params);
    return true;
  }

  @override
  Future<String?> getOndSessionId() async {
    final ondSessionId = _keyValueStorageService?.getStringValue(ondSessionIdKey);
    return ondSessionId;
  }

  @override
  Future<String?> getSessionId() async {
    final sessionId = _keyValueStorageService?.getStringValue(sessionIdKey);
    return sessionId;
  }

  @override
  Future<String?> getTheme() async {
    final email = _keyValueStorageService?.getStringValue(themeKey);
    return email;
  }

  @override
  Future<bool> saveTheme(String theme) async {
    await _keyValueStorageService?.setStringValue(themeKey, theme);
    return true;
  }

  @override
  Future<String?> getUserInfo() async {
    final email = _keyValueStorageService?.getStringValue(userInfo);
    return email;
  }

  @override
  Future<bool> saveUserInfo(String user) async {
    await _keyValueStorageService?.setStringValue(userInfo, user);
    return true;
  }

  @override
  Future<String?> getAppLanguage() async {
    final deviceLanguage = _keyValueStorageService?.getStringValue(appLanguage);
    return deviceLanguage;
  }

  @override
  Future<bool> saveAppLanguage(String lang) async {
    await _keyValueStorageService?.setStringValue(appLanguage, lang);
    return true;
  }

  @override
  Future<bool> clearUserInfo() async {
    await _keyValueStorageService?.removeValue(sessionIdKey);
    await _keyValueStorageService?.removeValue(ondSessionIdKey);
    await _keyValueStorageService?.removeValue(userInfo);
    return true;
  }

  @override
  Future<bool> saveUserSearch(String recentSearch) async {
    final currentList = await getUserSearches() ?? [];

    currentList.remove(recentSearch);

    currentList.insert(0, recentSearch);

    const maxItems = 20;
    final trimmedList = currentList.take(maxItems).toList();

    await _keyValueStorageService?.setListOfStringValue(userSearches, trimmedList);
    return true;
  }

  @override
  Future<List<String>?> getUserSearches() async {
    final list = _keyValueStorageService?.getListOfStringValue(userSearches);
    return list;
  }

  @override
  Future<bool> removeUserSearch(String search) async {
    final currentList = await getUserSearches();

    if (currentList == null || currentList.isEmpty) {
      return false;
    }

    final updatedList = List<String>.from(currentList)..remove(search);

    await _keyValueStorageService?.setListOfStringValue(userSearches, updatedList);
    return true;
  }

  @override
  Future<bool?> getInAppReviewShown() async {
    final inAppReviewShownRes = _keyValueStorageService?.getBoolValue(inAppReviewShown);
    return inAppReviewShownRes;
  }

  @override
  Future<bool> saveInAppReviewShown(bool shown) async {
    await _keyValueStorageService?.setBoolValue(inAppReviewShown, shown);
    return true;
  }
}
