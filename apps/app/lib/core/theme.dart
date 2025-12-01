import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF146C94);
  static const accent = Color(0xFF19A7CE);
  static const bg = Color(0xFFF7F7F7);
  static const text = Color(0xFF1B1B1B);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: bg,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          surfaceTintColor: Colors.white,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
