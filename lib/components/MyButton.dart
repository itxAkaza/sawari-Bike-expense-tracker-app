import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/colors/app_colors.dart';


class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double width;
  final bool isGhost;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.height = 55,
    this.width = double.infinity,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adjust text color depending on theme and button style
    final textColor = isGhost
        ? (isDark ? AppColors.mutDark : AppColors.mutLight)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: isLoading ? null : onTap, // Disable taps while loading
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isGhost
                ? Border.all(color: isDark ? AppColors.lineDark : AppColors.lineLight)
                : null,
            // Apply gradient only if it is a primary button
            gradient: isGhost
                ? null
                : const LinearGradient(
              colors: [AppColors.btnGradStart, AppColors.btnGradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isGhost
                ? []
                : [
              BoxShadow(
                color: AppColors.accLight.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SpinKitThreeBounce(
              color: textColor,
              size: 20,
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text.tr, // GetX Localization applied automatically
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Render Icon only if one is provided
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}