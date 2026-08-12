import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF1565C0);
  static const _primaryLight = Color(0xFF1E88E5);
  static const _functional = Color(0xFF0277BD);
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF5F7FA);
  static const _surfaceContainer = Color(0xFFEEF2F7);
  static const _onBackground = Color(0xFF1A1A2E);
  static const _onSurface = Color(0xFF2D3748);
  static const _onSurfaceVariant = Color(0xFF718096);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primary,
      secondary: _functional,
      surface: _surface,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
      surfaceContainerHighest: _surfaceContainer,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFBBDEFB),
    ),
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: _onSurface,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _onBackground),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _onBackground),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onBackground),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _onBackground),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onBackground),
      bodyLarge: TextStyle(fontSize: 16, color: _onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: _onSurface),
      bodySmall: TextStyle(fontSize: 12, color: _onSurfaceVariant),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primary,
      unselectedItemColor: _onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: _onSurfaceVariant),
    ),
    iconTheme: const IconThemeData(color: _onSurfaceVariant),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}