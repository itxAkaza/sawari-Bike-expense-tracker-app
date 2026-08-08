import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/colors/app_colors.dart';

class LightTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    primaryColor: AppColors.accLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.lineLight,

    // Applies Poppins font globally across the light theme
    fontFamily: GoogleFonts.poppins().fontFamily,

    // Color Scheme for modern Material components
    colorScheme: const ColorScheme.light(
      primary: AppColors.accLight,
      secondary: AppColors.accDeepLight,
      surface: AppColors.cardLight,
      error: AppColors.redLight,
      onPrimary: Colors.white,
      onSurface: AppColors.inkLight,
    ),

    // Global AppBar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.inkLight),
      titleTextStyle: TextStyle(
        color: AppColors.inkLight,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Global Text styling
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.inkLight),
      bodyMedium: TextStyle(color: AppColors.inkLight),
      titleLarge: TextStyle(
        color: AppColors.inkLight,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Global Bottom Navigation styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // From navbg css
      selectedItemColor: AppColors.accLight,
      unselectedItemColor: AppColors.mutLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}