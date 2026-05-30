import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:equran/backend/settings_db.dart';
import 'package:quran/quran.dart' as quran;

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
    final String style = SettingsDB().quranScriptStyle;
    if (style == 'indopak') {
      return 'QuranIndoPak';
    } else if (style == 'qpc-hafs') {
      return 'UthmanicHafs';
    }
    return 'UthmanicHafs';
  }

  static bool _isAppDarkMode() {
    final String? themeMode = SettingsDB().get('themeMode') as String?;
    return themeMode == 'dark' ||
        (themeMode == null) ||
        (themeMode == 'auto' &&
            PlatformDispatcher.instance.platformBrightness == Brightness.dark);
  }

  static String fontFamilyForPage(int page) {
    final String style = SettingsDB().quranScriptStyle;
    if (style == 'indopak') {
      return 'QuranIndoPak';
    } else if (style == 'qpc-hafs') {
      return 'UthmanicHafs';
    } else if (style == 'qpc-v4') {
      final String suffix = _isAppDarkMode() ? 'dark' : 'light';
      return 'QPCV4_Page_${page}_$suffix';
    }
    return 'UthmanicHafs';
  }

  static const Map<String, int> _qpcV4PageOffsets = {
    '5:77': 120,
    '5:83': 121,
    '5:90': 122,
    '6:131': 145,
    '55:17': 531,
    '55:18': 531,
    '55:41': 532,
    '55:68': 533,
    '55:69': 533,
    '68:16': 564,
    '69:35': 567,
    '70:40': 569,
    '74:18': 575,
    '79:16': 583,
    '80:41': 586,
    '80:42': 586,
    '83:5': 588,
    '83:6': 588,
    '83:34': 589,
    '84:25': 590,
    '87:11': 592,
    '87:12': 592,
    '87:13': 592,
    '87:14': 592,
    '87:15': 592,
    '88:23': 593,
    '88:24': 593,
    '88:25': 593,
    '88:26': 593,
    '89:23': 594,
    '90:19': 595,
    '90:20': 595,
    '92:10': 596,
    '92:11': 596,
    '92:12': 596,
    '92:13': 596,
    '92:14': 596,
    '94:3': 597,
    '94:4': 597,
    '94:5': 597,
    '94:6': 597,
    '94:7': 597,
    '94:8': 597,
    '96:13': 598,
    '96:14': 598,
    '96:15': 598,
    '96:16': 598,
    '96:17': 598,
    '96:18': 598,
    '96:19': 598,
    '98:6': 599,
    '98:7': 599,
    '100:6': 600,
    '100:7': 600,
    '100:8': 600,
    '100:9': 600,
  };

  static int getPageNumber(int chapter, int verse) {
    if (SettingsDB().quranScriptStyle == 'qpc-v4') {
      final String key = '$chapter:$verse';
      if (_qpcV4PageOffsets.containsKey(key)) {
        return _qpcV4PageOffsets[key]!;
      }
    }
    return quran.getPageNumber(chapter, verse);
  }

  static String fontFamilyForVerse(int chapter, int verse) {
    final String style = SettingsDB().quranScriptStyle;
    if (style == 'indopak') {
      return 'QuranIndoPak';
    } else if (style == 'qpc-hafs') {
      return 'UthmanicHafs';
    } else if (style == 'qpc-v4') {
      final int page = getPageNumber(chapter, verse);
      final String suffix = _isAppDarkMode() ? 'dark' : 'light';
      return 'QPCV4_Page_${page}_$suffix';
    }
    return 'UthmanicHafs';
  }

  static TextStyle arabicDisplay(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['UthmanicHafs'],
      fontSize: 30,
      height: 1.7,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicBody(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['UthmanicHafs'],
      fontSize: 24,
      height: 1.75,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicSmall(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: activeFontFamily,
      fontFamilyFallback: const <String>['UthmanicHafs'],
      fontSize: 19,
      height: 1.55,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
