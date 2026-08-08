import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/colors/app_colors.dart';


class MyTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;

  const MyTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically check if the app is in Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: isDark ? AppColors.inkDark : AppColors.inkLight,
        ),
      ),
      decoration: InputDecoration(
        hintText: hintText.tr, // GetX Localization applied automatically
        hintStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: isDark ? AppColors.mutDark : AppColors.mutLight,
          ),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,

        // Default State Border
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.lineDark : AppColors.lineLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),

        // Active/Focused State Border
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.accDark : AppColors.accLight,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),

        // Error State Border
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.redDark : AppColors.redLight,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),

        // Focused Error State Border
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.redDark : AppColors.redLight,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}