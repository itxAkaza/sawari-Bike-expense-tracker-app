import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sawari/resources/route/routes_names.dart';
import 'package:sawari/services/notifiction_service.dart';
import 'package:sawari/user_prefernce/userPrefrence.dart';

class SplashServices {

  /// Runs all boot-up checks and returns the initial states for the app
  static Future<Map<String, dynamic>> initializeAppStates() async {
    // 1. Read local preferences
    final prefs = await UserPreference.getUserSettings();
    final bool notificationsEnabled = prefs['notificationsEnabled'] ?? true;

    // We assume 'isFirstTime' is true if it hasn't been set to false yet
    final bool isFirstTime = prefs['isFirstTime'] ?? true;

    // 2. Parse Theme
    ThemeMode initialTheme = ThemeMode.system;
    if (prefs['theme'] == 'light') initialTheme = ThemeMode.light;
    if (prefs['theme'] == 'dark') initialTheme = ThemeMode.dark;

    // 3. Parse Language
    Locale initialLocale = const Locale('en', 'US');
    if (prefs['language'] == 'ur') initialLocale = const Locale('ur', 'PK');

    // 4. Check Auth & First Time State for Routing
    User? currentUser = FirebaseAuth.instance.currentUser;
    String initialRoute;

    if (currentUser != null) {
      initialRoute = RoutesNames.homeBottomBarScreen;
    } else if (isFirstTime) {
      initialRoute = RoutesNames.introScreen;
    } else {
      initialRoute = RoutesNames.loginScreen;
    }

    // 5. Initialize Notifications
    await NotificationServices().initNotification(notificationsEnabled);

    return {
      'theme': initialTheme,
      'locale': initialLocale,
      'route': initialRoute,
    };
  }



  /// Call this when the user interacts with the IntroScreen to never show it again
  static Future<void> markIntroAsSeen() async
  {
    await UserPreference.setFirstTime(false);
  }


}