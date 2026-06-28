import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: b,
      primary: dark ? const Color(0xFF2DD4BF) : AppColors.primary,
      surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
    final card = dark ? AppColors.cardDark : AppColors.cardLight;
    final line = dark ? AppColors.lineDark : AppColors.lineLight;
    final ink = dark ? AppColors.inkDark : AppColors.inkLight;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      fontFamily: 'Roboto',
      textTheme: Typography.material2021().black.apply(
        bodyColor: ink, displayColor: ink,
      ).merge(dark ? Typography.material2021().white.apply(bodyColor: ink, displayColor: ink) : null),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0, scrolledUnderElevation: 0,
        foregroundColor: ink,
      ),
      cardColor: card,
      dividerColor: line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: ink,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: dark ? AppColors.surfaceDark : AppColors.surfaceLight),
    );
  }
}
