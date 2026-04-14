import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildLightTheme(Color seedColor) {
    final ColorScheme baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final ColorScheme colorScheme = baseScheme.copyWith(
      surface: const Color(0xFFF5F0E6),
      surfaceContainerLowest: const Color(0xFFFFFBF5),
      surfaceContainerLow: const Color(0xFFF8F2E8),
      surfaceContainer: const Color(0xFFF2EBE0),
      surfaceContainerHigh: const Color(0xFFECE4D8),
      surfaceContainerHighest: const Color(0xFFE4DACB),
      primaryContainer: Color.alphaBlend(
        Colors.white.withOpacity(0.42),
        baseScheme.primaryContainer,
      ),
      secondaryContainer: Color.alphaBlend(
        Colors.white.withOpacity(0.28),
        baseScheme.secondaryContainer,
      ),
      tertiaryContainer: Color.alphaBlend(
        Colors.white.withOpacity(0.32),
        baseScheme.tertiaryContainer,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F2E9),
      canvasColor: const Color(0xFFF7F2E9),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerLow),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  static ThemeData buildDarkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
