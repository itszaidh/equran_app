import 'dart:math' as math;

import 'package:equran/theme/equran_colors.dart';
import 'package:flutter/material.dart';

class SurahNumberBadge extends StatelessWidget {
  const SurahNumberBadge({
    super.key,
    required this.number,
    this.size = 44,
    this.textStyle,
    this.active = false,
  });

  final int number;
  final double size;
  final TextStyle? textStyle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _DiamondNumberBadge(
      label: number.toString(),
      size: size,
      textStyle: textStyle,
      active: active,
    );
  }
}

class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.label, this.size = 44});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _DiamondNumberBadge(label: label, size: size);
  }
}

class _DiamondNumberBadge extends StatelessWidget {
  const _DiamondNumberBadge({
    required this.label,
    required this.size,
    this.textStyle,
    this.active = false,
  });

  final String label;
  final double size;
  final TextStyle? textStyle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final double diamondSize = size * 0.78;
    final double fontSize = label.length >= 3
        ? (size * 0.29).clamp(10.8, 12.4).toDouble()
        : (size * 0.36).clamp(13.0, 15.5).toDouble();
    final Color borderColor = active
        ? colors.accentGold.withValues(alpha: 0.95)
        : colors.accentGold;

    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: diamondSize,
            height: diamondSize,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: borderColor, width: active ? 1.4 : 1.2),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: colors.textPrimary,
                      )
                      .merge(textStyle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
