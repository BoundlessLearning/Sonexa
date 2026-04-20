import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF6750A4);

  static ThemeData light() {
    return ThemeData(
      colorSchemeSeed: _seedColor,
      brightness: Brightness.light,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 1),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorSchemeSeed: _seedColor,
      brightness: Brightness.dark,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 1),
    );
  }
}
