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
      unselectedItemColor: iconColor,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );

  // ── Reader Mode (Light Theme) ───────────────────────────────────
  static const Color lightBackgroundColor = Color(0xFFF4E9D8);
  static const Color lightSurfaceColor = Color(0xFFEAD9C4);
  static const Color lightPrimaryText = Color(0xFF1C1A18);
  static const Color lightSecondaryText = Color(0xFF5A4632);
  static const Color lightMutedColor = Color(0xFFA6937C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: lightPrimaryText,
        letterSpacing: -1.0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightPrimaryText,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        color: lightPrimaryText,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: lightSecondaryText,
        height: 1.6,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        color: lightSecondaryText,
        letterSpacing: 0.1,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackgroundColor,
      selectedItemColor: lightPrimaryText,
      unselectedItemColor: lightMutedColor,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
