abstract class LocalDataSource {
  ///This method will clear all the shared preferences
  ///[Output] : [bool] returns true on successful operation and false on failure
  Future<bool> clearSharedPreferences();

  /// This method gets the theme from local storage
  /// Input : []
  /// Output : [String] contains the theme
  Future<String?> getTheme();

  /// This method saves the theme pref in local storage
  /// Input : [String] contains theme (light, dark)
  /// Output : [bool] specifies whether the saving operation is successful or not
  Future<bool> saveTheme(String params);

  /// This method gets the user info from local storage
  /// Input : []
  /// Output : [String] contains the info
  Future<String?> getUserInfo();

  /// This method saves the user info in local storage
  /// Input : [String] contains user info
  /// Output : [bool] specifies whether the saving operation is successful or not
  Future<bool> saveUserInfo(String params);

  /// This method gets the language code from local storage
  /// Input : []
  /// Output : [String] contains the language code
  Future<String?> getAppLanguage();

  /// This method saves the language pref in local storage
  /// Input : [String] contains language code (en, ar)
  /// Output : [bool] specifies whether the saving operation is successful or not
  Future<bool> saveAppLanguage(String params);

  /// This method saves the session id local storage
  /// Input : [String] contains session id
  /// Output : [bool] specifies whether the saving operation is successful or not
  Future<bool> saveSessionId(String params);

  /// This method saves the ond session id local storage
  /// Input : [String] contains ond session id
  /// Output : [bool] specifies whether the saving operation is successful or not
  Future<bool> saveOndSessionId(String params);

  /// This method gets the session id from local storage
  /// Input : []
  /// Output : [String] contains the session id
  Future<String?> getSessionId();

  /// This method gets the ond session id from local storage
  /// Input : []
  /// Output : [String] contains the ond session id
  Future<String?> getOndSessionId();

  /// This method clears user details from local storage
  /// Input : []
  /// Output : [bool] contains confirmation
  Future<bool> clearUserInfo();

  /// This method saves user recent searches in local storage
  /// Input : [String] contains recent search query
  /// Output : [bool] specifies whether the saving operation is successful
  Future<bool> saveUserSearch(String newValue);

  /// This method gets the recent user searches from local storage
  /// Input : []
  /// Output : [List<String>] contains recent user searches
  Future<List<String>?> getUserSearches();

  /// This method remove a user search from local storage
  /// Input : [String] contains the search query to remove
  /// Output : [bool] specifies whether the removing operation is successful
  Future<bool> removeUserSearch(String search);

  /// This method saves in app review shown value in local storage
  /// Input : [bool] contains in app review shown value
  /// Output : [bool] specifies whether the saving operation is successful
  Future<bool> saveInAppReviewShown(bool shown);

  /// This method gets the in app review shown value from local storage
  /// Input : []
  /// Output : [String] contains the in app review shown value
  Future<bool?> getInAppReviewShown();
}
