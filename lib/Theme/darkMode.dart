import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/colors/app_colors.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    primaryColor: AppColors.accDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.lineDark,

    // Applies Poppins font globally across the dark theme
    fontFamily: GoogleFonts.poppins().fontFamily,

    // Color Scheme for modern Material components
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accDark,
      secondary: AppColors.accDeepDark,
      surface: AppColors.cardDark,
      error: AppColors.redDark,
      onPrimary: AppColors.inkLight, // Dark text on bright green buttons
      onSurface: AppColors.inkDark,
    ),

    // Global AppBar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.inkDark),
      titleTextStyle: TextStyle(
        color: AppColors.inkDark,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Global Text styling
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.inkDark),
      bodyMedium: TextStyle(color: AppColors.inkDark),
      titleLarge: TextStyle(
        color: AppColors.inkDark,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Global Bottom Navigation styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xE00E1310), // From navbg css rgba(14,19,16,.88)
      selectedItemColor: AppColors.accDark,
      unselectedItemColor: AppColors.mutDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}