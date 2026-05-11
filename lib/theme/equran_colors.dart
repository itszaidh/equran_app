import 'package:flutter/material.dart';

@immutable
class EquranColors extends ThemeExtension<EquranColors> {
  const EquranColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSoft,
    required this.primary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    required this.mint,
    required this.paleGreen,
    required this.accentGold,
    required this.goldSoft,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.warning,
    required this.warningSurface,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceSoft;
  final Color primary;
  final Color primaryStrong;
  final Color primarySoft;
  final Color primaryGradientStart;
  final Color primaryGradientEnd;
  final Color mint;
  final Color paleGreen;
  final Color accentGold;
  final Color goldSoft;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color onPrimary;
  final Color onPrimaryMuted;
  final Color warning;
  final Color warningSurface;
  final Color shadow;

  static const EquranColors light = EquranColors(
    background: Color(0xFFFAFAF7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF6F7F3),
    surfaceSoft: Color(0xFFFBFBF8),
    primary: Color(0xFF176B55),
    primaryStrong: Color(0xFF145D4A),
    primarySoft: Color(0xFF247B62),
    primaryGradientStart: Color(0xFF1E735D),
    primaryGradientEnd: Color(0xFF8FC5A5),
    mint: Color(0xFFEAF6EF),
    paleGreen: Color(0xFFF5FBF7),
    accentGold: Color(0xFFD6A84F),
    goldSoft: Color(0xFFE8D6A8),
    border: Color(0xFFE5E7DF),
    divider: Color(0xFFE8E8E2),
    textPrimary: Color(0xFF1E2420),
    textSecondary: Color(0xFF69716B),
    textMuted: Color(0xFF8A918B),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFEAF6EF),
    warning: Color(0xFF9B6A16),
    warningSurface: Color(0xFFFFF7E2),
    shadow: Color(0xFF14241E),
  );

  static const EquranColors dark = EquranColors(
    background: Color(0xFF07110E),
    surface: Color(0xFF111A17),
    surfaceAlt: Color(0xFF17211E),
    surfaceSoft: Color(0xFF0C1713),
    primary: Color(0xFF1E7A61),
    primaryStrong: Color(0xFF125B49),
    primarySoft: Color(0xFF7ED6B2),
    primaryGradientStart: Color(0xFF145F4D),
    primaryGradientEnd: Color(0xFF2A8A6D),
    mint: Color(0xFF183027),
    paleGreen: Color(0xFF10221B),
    accentGold: Color(0xFFD6A84F),
    goldSoft: Color(0xFF66542E),
    border: Color(0xFF26332E),
    divider: Color(0xFF23302A),
    textPrimary: Color(0xFFF3F7F4),
    textSecondary: Color(0xFFB8C2BC),
    textMuted: Color(0xFF83908A),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryMuted: Color(0xFFDDEEE6),
    warning: Color(0xFFE0B866),
    warningSurface: Color(0xFF2D2414),
    shadow: Color(0xFF000000),
  );

  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      primaryGradientStart,
      primary,
      primaryGradientEnd,
    ],
  );

  LinearGradient get softSurfaceGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color.alphaBlend(primary.withAlpha(18), surface),
      surface,
      Color.alphaBlend(accentGold.withAlpha(12), surface),
    ],
  );

  @override
  EquranColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceSoft,
    Color? primary,
    Color? primaryStrong,
    Color? primarySoft,
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    Color? mint,
    Color? paleGreen,
    Color? accentGold,
    Color? goldSoft,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onPrimary,
    Color? onPrimaryMuted,
    Color? warning,
    Color? warningSurface,
    Color? shadow,
  }) {
    return EquranColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryGradientStart:
          primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      mint: mint ?? this.mint,
      paleGreen: paleGreen ?? this.paleGreen,
      accentGold: accentGold ?? this.accentGold,
      goldSoft: goldSoft ?? this.goldSoft,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryMuted: onPrimaryMuted ?? this.onPrimaryMuted,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  EquranColors lerp(ThemeExtension<EquranColors>? other, double t) {
    if (other is! EquranColors) return this;
    Color blend(Color a, Color b) => Color.lerp(a, b, t)!;

    return EquranColors(
      background: blend(background, other.background),
      surface: blend(surface, other.surface),
      surfaceAlt: blend(surfaceAlt, other.surfaceAlt),
      surfaceSoft: blend(surfaceSoft, other.surfaceSoft),
      primary: blend(primary, other.primary),
      primaryStrong: blend(primaryStrong, other.primaryStrong),
      primarySoft: blend(primarySoft, other.primarySoft),
      primaryGradientStart: blend(
        primaryGradientStart,
        other.primaryGradientStart,
      ),
      primaryGradientEnd: blend(primaryGradientEnd, other.primaryGradientEnd),
      mint: blend(mint, other.mint),
      paleGreen: blend(paleGreen, other.paleGreen),
      accentGold: blend(accentGold, other.accentGold),
      goldSoft: blend(goldSoft, other.goldSoft),
      border: blend(border, other.border),
      divider: blend(divider, other.divider),
      textPrimary: blend(textPrimary, other.textPrimary),
      textSecondary: blend(textSecondary, other.textSecondary),
      textMuted: blend(textMuted, other.textMuted),
      onPrimary: blend(onPrimary, other.onPrimary),
      onPrimaryMuted: blend(onPrimaryMuted, other.onPrimaryMuted),
      warning: blend(warning, other.warning),
      warningSurface: blend(warningSurface, other.warningSurface),
      shadow: blend(shadow, other.shadow),
    );
  }
}

extension EquranColorsContext on BuildContext {
  EquranColors get equranColors {
    return Theme.of(this).extension<EquranColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? EquranColors.dark
            : EquranColors.light);
  }
}
