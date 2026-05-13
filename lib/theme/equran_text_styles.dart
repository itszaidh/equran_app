import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EquranTextStyles {
  const EquranTextStyles._();

  static TextTheme buildTextTheme(Brightness brightness) {
    final TextTheme base = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 42,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 36,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 13,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13.5,
        height: 1.42,
        letterSpacing: 0,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.35,
        letterSpacing: 0,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11.5,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }

  static TextStyle arabicDisplay(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Hafs',
      fontSize: 30,
      height: 1.7,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicBody(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Hafs',
      fontSize: 24,
      height: 1.75,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle arabicSmall(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Hafs',
      fontSize: 19,
      height: 1.55,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
