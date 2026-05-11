import 'package:equran/theme/equran_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildLightTheme(Color seedColor) {
    assert(seedColor.alpha >= 0);
    return EquranTheme.light();
  }

  static ThemeData buildDarkTheme(Color seedColor) {
    assert(seedColor.alpha >= 0);
    return EquranTheme.dark();
  }
}
