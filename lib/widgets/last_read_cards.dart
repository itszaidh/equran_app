import 'dart:math';

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_text_styles.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:quran/quran.dart';

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

  Future<void> _handleMenuAction(String value, ReadingEntry entry) async {
    if (value == 'delete') {
      await BookmarkDB().delete(entry.surah);
    }
  }

  @override
  State<LastReadCard> createState() => _LastReadCardState();
}

class _LastReadCardState extends State<LastReadCard> {
  static const double _estimatedCarouselPageSize = 164;

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
                        onMenuAction: widget._handleMenuAction,
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
                      padding: const EdgeInsets.only(bottom: 14),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withAlpha(88),
            borderRadius: BorderRadius.circular(999),
            boxShadow: isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(34),
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
    required this.onMenuAction,
    required this.showIndicatorSpace,
  });

  final ReadingEntry entry;
  final Future<void> Function(String value, ReadingEntry entry) onMenuAction;
  final bool showIndicatorSpace;

  @override
  Widget build(BuildContext context) {
    final int keySurah = entry.surah;
    final int verse = entry.verse;
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return Card(
      margin: const EdgeInsets.fromLTRB(0, 2, 0, 14),
      elevation: 0,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
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
          ),
          child: Stack(
            children: <Widget>[
              const Positioned(
                right: -18,
                top: 6,
                width: 180,
                height: 130,
                child: EquranOpenBookMark(opacity: 0.50),
              ),
              Positioned(
                top: 0,
                right: 74,
                child: _BookmarkRibbon(
                  color: colors.accentGold.withAlpha(100),
                  edgeColor: colors.goldSoft.withAlpha(160),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Last Read',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onPrimaryMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        PopupMenuButton<String>(
                          tooltip: 'More options',
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: colors.onPrimary,
                          ),
                          onSelected: (value) => onMenuAction(value, entry),
                          itemBuilder: (BuildContext context) =>
                              const <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline_rounded),
                                    title: Text('Delete'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      getSurahNameArabic(keySurah),
                      textDirection: TextDirection.rtl,
                      style: EquranTextStyles.arabicBody(
                        context,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verse $verse',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Continue to read',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colors.onPrimary,
                        ),
                      ],
                    ),
                    if (showIndicatorSpace) const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkRibbon extends StatelessWidget {
  const _BookmarkRibbon({required this.color, required this.edgeColor});

  final Color color;
  final Color edgeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 58),
      painter: _BookmarkRibbonPainter(color: color, edgeColor: edgeColor),
    );
  }
}

class _BookmarkRibbonPainter extends CustomPainter {
  const _BookmarkRibbonPainter({required this.color, required this.edgeColor});

  final Color color;
  final Color edgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint edge = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 9)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, edge);
  }

  @override
  bool shouldRepaint(covariant _BookmarkRibbonPainter oldDelegate) {
    return color != oldDelegate.color || edgeColor != oldDelegate.edgeColor;
  }
}
