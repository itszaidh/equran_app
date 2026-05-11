import 'package:equran/backend/surah_model.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:equran/widgets/number_badge.dart';
import 'package:flutter/material.dart';

class QuranCard extends StatelessWidget {
  final Surah surah;
  final bool compact;
  final bool reduceTitleSize;

  const QuranCard({
    super.key,
    required this.surah,
    this.compact = false,
    this.reduceTitleSize = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final bool tabletLayout = ResponsiveNav.isTablet(context);
    final bool compactText = compact && reduceTitleSize;
    final double verticalPadding = compact
        ? (tabletLayout ? 14 : 12)
        : (tabletLayout ? 17 : 15);
    final TextStyle? titleStyle =
        (compactText
                ? theme.textTheme.titleSmall
                : compact
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleMedium)
            ?.copyWith(fontWeight: FontWeight.w600);
    final TextStyle? arabicTitleStyle =
        (compactText
                ? theme.textTheme.titleSmall
                : compact
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleMedium)
            ?.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Hafs',
              fontSize: compactText
                  ? 19
                  : compact
                  ? 22
                  : 21,
              height: 1.1,
            );
    final TextStyle? versesStyle =
        (compactText
                ? theme.textTheme.bodySmall
                : compact
                ? theme.textTheme.bodyMedium
                : theme.textTheme.bodyLarge)
            ?.copyWith(color: colors.textSecondary);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ReadPage(chapter: surah.id)),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.divider)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: verticalPadding,
          ),
          child: Row(
            children: <Widget>[
              NumberBadge(label: surah.id.toString(), size: compact ? 34 : 38),
              const SizedBox(width: EquranSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      surah.transliteration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${surah.englishName} • ${surah.verses} verses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: versesStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EquranSpacing.m),
              Text(
                surah.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: arabicTitleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
