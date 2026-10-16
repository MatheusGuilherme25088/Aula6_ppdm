import 'package:flutter/material.dart';

class AppTheme {
  // Cores do app (tema escuro com laranja)
  static const fundo = Color(0xFF121212);
  static const superficie = Color(0xFF1E1E1E);
  static const superficieAlta = Color(0xFF2A2A2A);
  static const borda = Color(0xFF333333);
  static const laranja = Color(0xFFFF7A1A);
  static const laranjaEscuro = Color(0xFFE85D04);
  static const laranjaTransparente = Color(0x26FF7A1A);
  static const texto = Color(0xFFF5F5F5);
  static const textoSuave = Color(0xFFA0A0A0);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: laranja,
        brightness: Brightness.dark,
        primary: laranja,
        onPrimary: Colors.white,
        secondary: laranjaEscuro,
        surface: superficie,
        onSurface: texto,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: fundo,
        foregroundColor: texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: superficieAlta,
        contentTextStyle: TextStyle(color: texto),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        hintStyle: const TextStyle(color: textoSuave),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: laranja, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: laranja,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}