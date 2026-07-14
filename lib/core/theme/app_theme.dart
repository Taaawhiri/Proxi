import 'package:flutter/material.dart';

/// Proxi brand colors: deep space navy + radar/signal cyan-green.
class AppColors {
  AppColors._();

  static const Color radarGreen = Color(0xFF00E5A0);
  static const Color deepNavy = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF141C2F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.radarGreen,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.deepNavy,
        colorSchemeSeed: AppColors.radarGreen,
      );
}
