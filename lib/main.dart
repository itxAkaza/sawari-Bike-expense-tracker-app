import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sawari/resources/Translations/app_translations.dart';
import 'package:sawari/resources/assets/image_assets.dart';
import 'package:sawari/resources/route/routes.dart';
import 'package:sawari/resources/route/routes_names.dart';
import 'package:sawari/screens/home/homeScreen.dart';
import 'package:sawari/services/notifiction_service.dart';
import 'package:sawari/user_prefernce/userPrefrence.dart';

import 'Theme/darkMode.dart';
import 'Theme/lightMode.dart';
import 'firebase_options.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 1. Read local preferences instantly
  final prefs = await UserPreference.getUserSettings();
  final bool notificationsEnabled = prefs['notificationsEnabled'] ?? true;

  // 2. Pass the user's preference to the service
  await NotificationServices().initNotification(notificationsEnabled);

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sawari',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),


      initialRoute: RoutesNames.loginScreen,
      getPages: AppRoutes.appRoutes(),
    );
  }
}









