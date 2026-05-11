import 'dart:math';

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:quran/quran.dart';

const String _lastReadQuranAsset = 'assets/images/app_assets/quran.png';

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
  static const double _estimatedCarouselPageSize = 198;

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
    double width = MediaQuery.of(context).size.width;
    double viewportFraction = 1;
    const double threshold = 450.0;

    if (width > threshold) {
      double scaledWidth = (width - threshold) / 1100;
      viewportFraction = 1.0 * exp(-scaledWidth);
    } else {
      viewportFraction = 1;
    }

    final List<ReadingEntry> entries = widget.entries;
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final int activeIndex = entries.isEmpty
        ? 0
        : _currentPage.clamp(0, entries.length - 1).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            ExpandableCarousel.builder(
              itemCount: entries.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                    final ReadingEntry entry = entries[itemIndex];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final Animation<Offset> offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: _LastReadEntryCard(
                        key: ValueKey<String>(
                          '${entry.surah}-${entry.verse}-${entry.timestamp.microsecondsSinceEpoch}',
                        ),
                        entry: entry,
                        showIndicatorSpace: entries.length > 1,
                      ),
                    );
                  },
              options: ExpandableCarouselOptions(
                showIndicator: false,
                estimatedPageSize: _estimatedCarouselPageSize,
                enableInfiniteScroll: false,
                viewportFraction: viewportFraction,
                initialPage: 0,
                onPageChanged: (int index, _) {
                  if (!mounted) return;
                  final int normalizedIndex = index
                      .clamp(0, entries.length - 1)
                      .toInt();
                  setState(() {
                    _currentPage = normalizedIndex;
                  });
                },
              ),
            ),
            if (entries.length > 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 34),
                      child: _CarouselPillsIndicator(
                        itemCount: entries.length,
                        activeIndex: activeIndex,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 14 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive
                ? colors.accentGold
                : colors.onPrimaryMuted.withAlpha(170),
            borderRadius: BorderRadius.circular(999),
            boxShadow: isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: colors.accentGold.withAlpha(78),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _LastReadEntryCard extends StatelessWidget {
  const _LastReadEntryCard({
    super.key,
    required this.entry,
    required this.showIndicatorSpace,
  });

  final ReadingEntry entry;
  final bool showIndicatorSpace;

  @override
  Widget build(BuildContext context) {
    final int keySurah = entry.surah;
    final int verse = entry.verse;
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ReadPage(chapter: keySurah, startVerse: verse),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: colors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(color: colors.onPrimary.withAlpha(36)),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -20,
                  top: -6,
                  bottom: -10,
                  width: 158,
                  child: Opacity(
                    opacity: 0.84,
                    child: Image.asset(
                      _lastReadQuranAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    136,
                    showIndicatorSpace ? 38 : 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getSurahName(keySurah),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ayah $verse',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onPrimaryMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: SizedBox(
                          width: 112,
                          child: Divider(
                            height: 1,
                            color: colors.onPrimary.withAlpha(52),
                          ),
                        ),
                      ),
                      Text(
                        'Resume ->',
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
      ),
    );
  }
}
