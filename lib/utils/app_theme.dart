import 'package:equran/theme/equran_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const String defaultScheme = 'default';
  static const String fancyBlueScheme = 'fancyBlue';
  static const String fancyPurpleScheme = 'fancyPurple';

  static ThemeData buildLightTheme(Color seedColor, {String? schemeId}) {
    assert(seedColor.a >= 0);
    return switch (schemeId) {
      fancyBlueScheme => EquranTheme.fancyBlueLight(),
      fancyPurpleScheme => EquranTheme.fancyPurpleLight(),
      _ => EquranTheme.light(),
    };
  }

  static ThemeData buildDarkTheme(Color seedColor, {String? schemeId}) {
    assert(seedColor.a >= 0);
    return switch (schemeId) {
      fancyBlueScheme => EquranTheme.fancyBlueDark(),
      fancyPurpleScheme => EquranTheme.fancyPurpleDark(),
      _ => EquranTheme.dark(),
    };
  }
}
