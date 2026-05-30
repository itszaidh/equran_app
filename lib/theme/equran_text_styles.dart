import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:equran/backend/settings_db.dart';

class EquranTextStyles {
  const EquranTextStyles._();

  static TextTheme buildTextTheme(Brightness brightness, {Locale? locale}) {
    final TextTheme base = _baseFontTextThemeForLocale(
      ThemeData(brightness: brightness).textTheme,
      locale,
    );

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 43,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 37,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 31,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 23,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 21,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14.5,
        height: 1.42,
        letterSpacing: 0,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.35,
        letterSpacing: 0,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12.5,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }

  static ThemeData localizeTheme(ThemeData theme, Locale locale) {
    if (locale.languageCode == 'ar' || locale.languageCode == 'ur') {
      return theme.copyWith(
        textTheme: GoogleFonts.notoNaskhArabicTextTheme(theme.textTheme),
        primaryTextTheme: GoogleFonts.notoNaskhArabicTextTheme(
          theme.primaryTextTheme,
        ),
      );
    }
    return theme;
  }

  static TextTheme _baseFontTextThemeForLocale(
    TextTheme textTheme,
    Locale? locale,
  ) {
    if (locale?.languageCode == 'ar' || locale?.languageCode == 'ur') {
      return GoogleFonts.notoNaskhArabicTextTheme(textTheme);
    }
    return GoogleFonts.interTextTheme(textTheme);
  }

  static String get activeFontFamily {
    return SettingsDB().quranScriptStyle == 'indopak' ? 'QuranIndoPak' : 'Hafs';
  }

  static TextStyle arabicDisplay(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['Hafs'],
      fontSize: 30,
      height: 1.7,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicBody(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['Hafs'],
      fontSize: 24,
      height: 1.75,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicSmall(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['Hafs'],
      fontSize: 19,
      height: 1.55,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
