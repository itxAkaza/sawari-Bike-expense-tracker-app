import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  static const String _isGuestKey = 'is_guest';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email'; // Email Key added
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _currencyKey = 'app_currency';
  static const String _petrolPriceKey = 'petrol_price';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _warnDaysKey = 'warn_days';
  static const String _warnKmKey = 'warn_km';

  // --- Save Data (Called during AuthController Login/Register) ---
  static Future<void> saveUserSettings({
    required bool isGuest,
    required String userName,
    required String userEmail, // Email required for saving
    String theme = 'auto',
    String language = 'en',
    String currency = 'PKR - Rs.',
    double petrolPrice = 272.5,
    bool notifications = true,
    int warnDays = 7,
    int warnKm = 100,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, isGuest);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail); // Email Saved
    await prefs.setString(_themeKey, theme);
    await prefs.setString(_languageKey, language);
    await prefs.setString(_currencyKey, currency);
    await prefs.setDouble(_petrolPriceKey, petrolPrice);
    await prefs.setBool(_notificationsKey, notifications);
    await prefs.setInt(_warnDaysKey, warnDays);
    await prefs.setInt(_warnKmKey, warnKm);
  }

  // --- Individual Updaters ---
  static Future<void> updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<void> updateLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }

  static Future<void> updateSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is double) await prefs.setDouble(key, value);
  }

  // --- Read Data (Instant Load for Controllers) ---
  static Future<Map<String, dynamic>> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isGuest': prefs.getBool(_isGuestKey) ?? true,
      'userName': prefs.getString(_userNameKey) ?? 'Guest',
      'userEmail': prefs.getString(_userEmailKey) ?? '', // Email Read
      'theme': prefs.getString(_themeKey) ?? 'auto',
      'language': prefs.getString(_languageKey) ?? 'en',
      'currency': prefs.getString(_currencyKey) ?? 'PKR - Rs.',
      'petrolPrice': prefs.getDouble(_petrolPriceKey) ?? 272.5,
      'notificationsEnabled': prefs.getBool(_notificationsKey) ?? true,
      'warnDays': prefs.getInt(_warnDaysKey) ?? 7,
      'warnKm': prefs.getInt(_warnKmKey) ?? 100,
    };
  }

  // --- Clear Data on Logout ---
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}