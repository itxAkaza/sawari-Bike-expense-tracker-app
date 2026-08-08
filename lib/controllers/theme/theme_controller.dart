import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {

  // This checks the current active theme and swaps it
  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }
}