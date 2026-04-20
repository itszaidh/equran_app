import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildLightTheme(Color seedColor) {
    final ColorScheme baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final ColorScheme colorScheme = baseScheme.copyWith(
      surface: const Color(0xFFF3EFE8),
      surfaceContainerLowest: const Color(0xFFFFFDF9),
      surfaceContainerLow: const Color(0xFFFCF8F1),
      surfaceContainer: const Color(0xFFF7F1E8),
      surfaceContainerHigh: const Color(0xFFEFE7DC),
      surfaceContainerHighest: const Color(0xFFE7DDD0),
      primaryContainer: Color.alphaBlend(
        Colors.white.withAlpha((0.56 * 255).round()),
        baseScheme.primaryContainer,
      ),
      secondaryContainer: Color.alphaBlend(
        Colors.white.withAlpha((0.60 * 255).round()),
        baseScheme.secondaryContainer,
      ),
      tertiaryContainer: Color.alphaBlend(
        Colors.white.withAlpha((0.60 * 255).round()),
        baseScheme.tertiaryContainer,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF3EFE8),
      canvasColor: const Color(0xFFF3EFE8),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerLow,
        ),
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
