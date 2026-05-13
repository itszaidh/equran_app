import 'package:equran/theme/equran_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const String defaultScheme = 'default';
  static const String fancyBlueScheme = 'fancyBlue';
  static const String fancyPurpleScheme = 'fancyPurple';
  static const String sepiaScheme = 'sepia';
  static const String blackScheme = 'black';
  static const String redScheme = 'red';

  static ThemeData buildLightTheme(Color seedColor, {String? schemeId}) {
    assert(seedColor.a >= 0);
    return switch (schemeId) {
      fancyBlueScheme => EquranTheme.fancyBlueLight(),
      fancyPurpleScheme => EquranTheme.fancyPurpleLight(),
      sepiaScheme => EquranTheme.sepiaLight(),
      blackScheme => EquranTheme.blackLight(),
      redScheme => EquranTheme.redLight(),
      _ => EquranTheme.light(),
    };
  }

  static ThemeData buildDarkTheme(Color seedColor, {String? schemeId}) {
    assert(seedColor.a >= 0);
    return switch (schemeId) {
      fancyBlueScheme => EquranTheme.fancyBlueDark(),
      fancyPurpleScheme => EquranTheme.fancyPurpleDark(),
      sepiaScheme => EquranTheme.sepiaDark(),
      blackScheme => EquranTheme.blackDark(),
      redScheme => EquranTheme.redDark(),
      _ => EquranTheme.dark(),
    };
  }
}
