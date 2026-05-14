import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CredColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color cardDark = Color(0xFF141414);
  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF8E8E93);
  static const Color accent = Color(0xFFD4A574);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFD4AF37);
  static const Color shimmer = Color(0xFF3A3A3A);
  static const Color divider = Color(0xFF2C2C2E);
  static const Color tabActive = Color(0xFFFFFFFF);
  static const Color tabInactive = Color(0xFF6E6E73);
}

class CredTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CredColors.background,
      colorScheme: const ColorScheme.dark(
        surface: CredColors.background,
        primary: CredColors.primary,
        secondary: CredColors.secondary,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: CredColors.primary,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: CredColors.primary,
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CredColors.primary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CredColors.primary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: CredColors.secondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: CredColors.secondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CredColors.tabInactive,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CredColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CredColors.background,
        selectedItemColor: CredColors.tabActive,
        unselectedItemColor: CredColors.tabInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}