import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF0F0F10);
  static const Color surfaceColor = Color(0xFF1A1A1C);
  static const Color accentColor = Color(0xFFF5F5F7);
  static const Color secondaryTextColor = Color(0xFF86868B);
  // Slightly brighter than before (was 0xFF333336) for better icon visibility
  static const Color mutedColor = Color(0xFF4A4A4F);
  // Dedicated icon color — visible but still minimal
  static const Color iconColor = Color(0xFF5C5C62);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: accentColor,
        letterSpacing: -1.0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: accentColor,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        color: accentColor,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: secondaryTextColor,
        height: 1.6,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        color: secondaryTextColor,
        letterSpacing: 0.1,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: accentColor,
      // Improved from 0xFF333336 — icons are now subtly visible
      unselectedItemColor: iconColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
