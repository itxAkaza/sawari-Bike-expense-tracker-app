import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {

  // Swap between English and Urdu
  void toggleLanguage() {
    if (Get.locale?.languageCode == 'en') {
      // Switch to Urdu
      Get.updateLocale(const Locale('ur', 'PK'));
    } else {
      // Switch to English
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}