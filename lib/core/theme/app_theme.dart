import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Proxi brand colors: deep space navy + radar/signal cyan-green.
class AppColors {
  AppColors._();

  static const Color radarGreen = Color(0xFF00E5A0);
  static const Color deepNavy = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF141C2F);
}

class AppTheme {
  AppTheme._();

  /// Radius scale used across the app for a more expressive, Material You
  /// look (larger, softer corners than classic Material 2).
  static const double radiusM = 16;
  static const double radiusL = 24;
  static const double radiusPill = 100;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark, scaffoldBackground: AppColors.deepNavy);

  static ThemeData _build(Brightness brightness, {Color? scaffoldBackground}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: AppColors.radarGreen,
      scaffoldBackgroundColor: scaffoldBackground,
    );
    final colorScheme = base.colorScheme;
    final textTheme = GoogleFonts.outfitTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: const StadiumBorder()),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
    );
  }
}
