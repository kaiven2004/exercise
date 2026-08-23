import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF007AFF);
  static const primaryDark = Color(0xFF0056CC);
  static const accent = Color(0xFF34C759);
  static const accentWarm = Color(0xFFFF9500);
  static const accentRed = Color(0xFFFF3B30);
  static const accentPurple = Color(0xFFAF52DE);
  static const accentTeal = Color(0xFF5AC8DA);

  static const bgMain = Color(0xFFF2F2F7);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgGrouped = Color(0xFFE5E5EA);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF3C3C43);
  static const textTertiary = Color(0xFF999999);
  static const separator = Color(0xFFC6C6C8);
  static const divider = Color(0xFFD2D2D7);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: bgCard,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: bgGrouped,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF007AFF20),
      error: accentRed,
    ),
    scaffoldBackgroundColor: bgMain,
    appBarTheme: const AppBarTheme(
      backgroundColor: bgCard,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: separator, width: 0.5)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
      headlineSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 17, color: textSecondary),
      bodyMedium: TextStyle(fontSize: 15, color: textSecondary),
      bodySmall: TextStyle(fontSize: 13, color: textTertiary),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textSecondary),
      labelSmall: TextStyle(fontSize: 12, color: textTertiary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: primary,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      
      
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: bgGrouped,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.5)),
      hintStyle: const TextStyle(color: textTertiary),
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
    chipTheme: ChipThemeData(backgroundColor: bgGrouped, selectedColor: primary, labelStyle: const TextStyle(fontSize: 13, color: textSecondary), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
  );

  static const LinearGradient strengthGradient = LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF00C7FE)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient functionalGradient = LinearGradient(colors: [Color(0xFF34C759), Color(0xFF30D158)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient yogaGradient = LinearGradient(colors: [Color(0xFFAF52DE), Color(0xFF5856D6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
}





