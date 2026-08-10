import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sawari/resources/Translations/app_translations.dart';
import 'package:sawari/resources/route/routes.dart';

import 'Theme/darkMode.dart';
import 'Theme/lightMode.dart';
import 'firebase_options.dart';
import 'services/splash_services.dart'; // Import your new service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Let SplashServices handle all the messy logic and return the states
  final appStates = await SplashServices.initializeAppStates();

  runApp(MyApp(
    initialTheme: appStates['theme'],
    initialLocale: appStates['locale'],
    initialRoute: appStates['route'],
  ));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;
  final Locale initialLocale;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialTheme,
    required this.initialLocale,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sawari',
      debugShowCheckedModeBanner: false,

      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: initialTheme,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),

      initialRoute: initialRoute,
      getPages: AppRoutes.appRoutes(),
    );
  }
}