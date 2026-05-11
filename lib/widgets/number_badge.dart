import 'dart:math' as math;

import 'package:equran/theme/equran_colors.dart';
import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.label, this.size = 44});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colors.accentGold, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
