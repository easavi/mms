import 'package:flutter/material.dart';

class AppTheme {
  static const darkGray = Color(0xFF1A1A1A);
  static const orange = Color(0xFFFF5722);
  static const greenLime = Color(0xFF7CB342);
  static const cyan = Color(0xFF00BCD4);

  // Additional color getters for easier access
  static Color get backgroundColor => darkGray;
  static Color get cardColor => Colors.grey[900]!;
  static Color get dangerColor => orange;
  static Color get confirmColor => greenLime;
  static Color get accentColor => cyan;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      surface: darkGray,
      primary: cyan,
      secondary: greenLime,
      error: orange,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: darkGray,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGray,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: cyan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cyan,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: cyan),
      ),
    ),
  );
}
