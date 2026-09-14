import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luxury Light Palette (Parchment, Deep Forest Emerald, Royal Gold)
  static const Color lightBg = Color(0xFFF9F7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF3EEE3);
  static const Color lightPrimary = Color(0xFF065A35); // Emerald Green
  static const Color lightPrimaryContainer = Color(0xFFE2F3EA);
  static const Color lightSecondary = Color(0xFFB88E4F); // Royal Gold
  static const Color lightTextPrimary = Color(0xFF1E2522);
  static const Color lightTextSecondary = Color(0xFF6B7570);
  static const Color lightBorder = Color(0xFFE8E2D5);

  // Luxury Dark Palette (Obsidian-Emerald, Mint Glow, Warm Gold)
  static const Color darkBg = Color(0xFF0B1410);
  static const Color darkSurface = Color(0xFF13221C);
  static const Color darkSurfaceSubtle = Color(0xFF1A2D25);
  static const Color darkPrimary = Color(0xFF34D399); // Luminous Mint
  static const Color darkPrimaryContainer = Color(0xFF143828);
  static const Color darkSecondary = Color(0xFFF3C766); // Warm Radiant Gold
  static const Color darkTextPrimary = Color(0xFFF0FDF4);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E3A2E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: lightTextPrimary,
        primaryContainer: lightPrimaryContainer,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: lightBorder, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: lightPrimary),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: lightPrimary,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.amiri(
          fontSize: 22,
          height: 1.85,
          color: lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightPrimary,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: lightSecondary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 15,
          height: 1.65,
          color: lightTextSecondary,
        ),
        labelMedium: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: lightPrimary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onPrimary: Colors.black87,
        onSecondary: Colors.black87,
        onSurface: darkTextPrimary,
        primaryContainer: darkPrimaryContainer,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkPrimary),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: darkPrimary,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.amiri(
          fontSize: 22,
          height: 1.85,
          color: darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkPrimary,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: darkSecondary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 15,
          height: 1.65,
          color: darkTextSecondary,
        ),
        labelMedium: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: darkPrimary,
        ),
      ),
    );
  }
}
