import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:quran/quran.dart';

const String equranResumeQuranAsset = 'assets/images/app_assets/quran.png';
const String equranResumePlayerAsset = 'assets/images/app_assets/player.png';

class LastReadCard extends StatefulWidget {
  const LastReadCard({super.key, required this.entries});

  final List<ReadingEntry> entries;

  static List<ReadingEntry> displayReadingHistory(Iterable<dynamic> values) {
    final rawEntries = values.whereType<ReadingEntry>().toList();

    // Keep one record per surah: latest ayah read only.
    final Map<int, ReadingEntry> latestPerSurah = <int, ReadingEntry>{};
    for (final entry in rawEntries) {
      final ReadingEntry? current = latestPerSurah[entry.surah];
      if (current == null || entry.timestamp.isAfter(current.timestamp)) {
        latestPerSurah[entry.surah] = entry;
      }
    }

    final entries = latestPerSurah.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.take(7).toList();
  }

  @override
  State<LastReadCard> createState() => _LastReadCardState();
}

class _LastReadCardState extends State<LastReadCard> {
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant LastReadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries.isEmpty) {
      _currentPage = 0;
      return;
    }

    final int maxPage = widget.entries.length - 1;
    if (_currentPage > maxPage) {
      _currentPage = maxPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ReadingEntry> entries = widget.entries;
    if (entries.isEmpty) return const SizedBox.shrink();
    final int activeIndex = _currentPage.clamp(0, entries.length - 1).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExpandableCarousel.builder(
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
            final ReadingEntry entry = entries[itemIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EquranResumeImageCard(
                key: ValueKey<String>(
                  '${entry.surah}-${entry.verse}-${entry.timestamp.microsecondsSinceEpoch}',
                ),
                primary: getSurahName(entry.surah),
                subtitle: 'Ayah ${entry.verse}',
                actionText: 'Resume ->',
                trailingAssetPath: equranResumeQuranAsset,
                trailingRightOffset: -24,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ReadPage(chapter: entry.surah, startVerse: entry.verse),
                  ),
                ),
              ),
            );
          },
          options: ExpandableCarouselOptions(
            showIndicator: false,
            estimatedPageSize: 158,
            enableInfiniteScroll: false,
            viewportFraction: 1,
            initialPage: 0,
            onPageChanged: (int index, _) {
              if (!mounted) return;
              setState(() {
                _currentPage = index.clamp(0, entries.length - 1).toInt();
              });
            },
          ),
        ),
        if (entries.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _CarouselPillsIndicator(
              itemCount: entries.length,
              activeIndex: activeIndex,
            ),
          ),
      ],
    );
  }
}

class _CarouselPillsIndicator extends StatelessWidget {
  const _CarouselPillsIndicator({
    required this.itemCount,
    required this.activeIndex,
  });

  final int itemCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(itemCount, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 14 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive
                ? colors.accentGold
                : colors.onPrimaryMuted.withAlpha(150),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class EquranResumeImageCard extends StatelessWidget {
  const EquranResumeImageCard({
    super.key,
    required this.primary,
    required this.subtitle,
    required this.actionText,
    required this.trailingAssetPath,
    required this.onTap,
    this.trailingRightOffset = 4,
  });

  final String primary;
  final String subtitle;
  final String actionText;
  final String trailingAssetPath;
  final VoidCallback onTap;
  final double trailingRightOffset;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 340;
        final double artWidth = compact ? 120 : 144;
        final double textRightPadding =
            (compact ? 102 : 124) +
            (trailingRightOffset > 0 ? trailingRightOffset * 0.65 : 0);

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: colors.heroGradient,
                borderRadius: BorderRadius.circular(AppRadii.large),
                border: Border.all(color: colors.onPrimary.withAlpha(36)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colors.primaryStrong.withAlpha(
                      Theme.of(context).brightness == Brightness.light
                          ? 34
                          : 54,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 3,
                    top: -8,
                    bottom: -8,
                    width: artWidth,
                    child: Image.asset(
                      trailingAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 16 : 18,
                      17,
                      textRightPadding,
                      16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onPrimaryMuted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 104,
                            child: Divider(
                              height: 1,
                              color: colors.onPrimary.withAlpha(52),
                            ),
                          ),
                        ),
                        Text(
                          actionText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
