import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Instagram inspired
  static const Color primaryBlue = Color(0xFF0095F6);     // Instagram blue
  static const Color secondaryPurple = Color(0xFF833AB4); // Instagram purple
  static const Color accentPink = Color(0xFFE1306C);      // Instagram pink
  static const Color accentOrange = Color(0xFFF77737);    // Instagram orange
  static const Color accentYellow = Color(0xFFFCAF45);    // Instagram yellow
  static const Color accentRed = Color(0xFFFD1D1D);       // Instagram red

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Instagram light background
  static const Color backgroundDark = Color(0xFF121212);  // Instagram dark background
  static const Color cardLight = Color(0xFFFFFFFF);       // Pure white for cards
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF262626);     // Instagram primary text
  static const Color textSecondary = Color(0xFF8E8E8E);   // Instagram secondary text
  static const Color textHighlight = Color(0xFF0095F6);   // Instagram blue for highlights
  static const Color darkModeText = Color(0xFFF5F6F7);    // Light gray for dark mode

  // Status Colors
  static const Color success = Color(0xFF00C851);         // Success green
  static const Color warning = Color(0xFFFFB800);         // Warning yellow
  static const Color error = Color(0xFFED4956);           // Instagram error red
  static const Color info = Color(0xFF0095F6);            // Instagram blue for info

  // Dark Mode Specific
  static const Color darkModeAccent = Color(0xFFE1306C);  // Instagram pink for dark mode

  // Common Typography
  static const String fontFamily = 'Roboto';              // Instagram uses Roboto

  // Instagram Gradient Colors
  static const List<Color> instagramGradient = [
    Color(0xFF833AB4),  // Purple
    Color(0xFFE1306C),  // Pink
    Color(0xFFF77737),  // Orange
    Color(0xFFFCAF45),  // Yellow
    Color(0xFFFD1D1D),  // Red
  ];

  static ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    brightness: Brightness.light,
    primaryColor: accentPink,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    colorScheme: ColorScheme.light(
      primary: accentPink,
      secondary: secondaryPurple,
      surface: white,
      background: backgroundLight,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPink,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12),
      headlineSmall: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEFEFEF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDBDBDB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentPink),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFDBDBDB)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: textPrimary,
      unselectedItemColor: textSecondary,
      backgroundColor: white,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEFEFEF),
      selectedColor: accentPink,
      labelStyle: const TextStyle(color: textPrimary),
      secondaryLabelStyle: const TextStyle(color: white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    primaryColor: darkModeAccent,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme.dark(
      primary: darkModeAccent,
      secondary: secondaryPurple,
      surface: const Color(0xFF1E1E1E),
      background: backgroundDark,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: darkModeText,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkModeAccent,
        foregroundColor: darkModeText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkModeText, fontSize: 16),
      bodyMedium: TextStyle(color: darkModeText, fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12),
      headlineSmall: TextStyle(color: darkModeText, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: darkModeText),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkModeAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3A)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: darkModeText,
      unselectedItemColor: Color(0xFF8E8E8E),
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: darkModeAccent,
      labelStyle: const TextStyle(color: darkModeText),
      secondaryLabelStyle: const TextStyle(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
