import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_display.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equran/l10n/app_localizations.dart';
import 'package:like_button/like_button.dart';
import 'package:quran/quran.dart' as quran;

enum _SavedAyahFilter { all, favourites, notes }

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({required this.color, this.opacity = 0.06});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withAlpha((255 * opacity.clamp(0.0, 1.0)).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const double tileSize = 80;

    for (double x = 0; x < size.width + tileSize; x += tileSize) {
      for (double y = 0; y < size.height + tileSize; y += tileSize) {
        _drawStar(
          canvas,
          paint,
          Offset(x + tileSize / 2, y + tileSize / 2),
          36,
        );
        _drawStar(
          canvas,
          paint,
          Offset(x + tileSize / 2, y + tileSize / 2),
          22,
        );
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45 - 90) * (math.pi / 180);
      final double innerAngle = angle + (22.5 * math.pi / 180);
      final Offset outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final Offset innerPoint = Offset(
        center.dx + (radius * 0.5) * math.cos(innerAngle),
        center.dy + (radius * 0.5) * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}

class FavouritesList extends StatefulWidget {
  const FavouritesList({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<FavouritesList> createState() => _FavouritesListState();
}

class _FavouritesListState extends State<FavouritesList> {
  final ScrollController _fallbackScrollController = ScrollController();
  _SavedAyahFilter _filter = _SavedAyahFilter.all;
  String? _folderFilter;
  String? _tagFilter;

  @override
  void dispose() {
    _fallbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ScrollController scrollController =
        PrimaryScrollController.maybeOf(context) ?? _fallbackScrollController;

    return ColoredBox(
      color: colors.background,
      child: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: QuranBookmarksDB().listener,
        builder: (BuildContext context, Box<dynamic> bookmarksBox, _) {
          return ValueListenableBuilder<Box<dynamic>>(
            valueListenable: FavouritesDB().listener,
            builder: (BuildContext context, Box<dynamic> favouritesBox, _) {
              return ValueListenableBuilder<Box<dynamic>>(
                valueListenable: QuranBookmarkFoldersDB().listener,
                builder: (BuildContext context, Box<dynamic> foldersBox, _) {
                  final List<QuranBookmarkEntry> allItems =
                      const QuranBookmarkService()
                          .bookmarkEntriesWithLegacyFallback();
                  final List<QuranBookmarkEntry> searched = allItems
                      .where(_matchesSearch)
                      .toList(growable: false);
                  final List<QuranBookmarkEntry> items = searched
                      .where(_matchesFilter)
                      .toList(growable: false);
                  final bool showEmpty = allItems.isEmpty || items.isEmpty;

                  return SafeArea(
                    top: false,
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: allItems.isNotEmpty,
                      interactive: true,
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: _BookmarkLibraryHeader(
                              selected: _filter,
                              selectedFolder: _folderFilter,
                              selectedTag: _tagFilter,
                              allItems: searched,
                              totalSavedCount: allItems.length,
                              onSelected: (filter) => setState(() {
                                _filter = filter;
                                _folderFilter = null;
                                _tagFilter = null;
                              }),
                              onFolderSelected: (folder) => setState(() {
                                _filter = _SavedAyahFilter.all;
                                _folderFilter = folder;
                                _tagFilter = null;
                              }),
                              onTagSelected: (tag) => setState(() {
                                _filter = _SavedAyahFilter.all;
                                _folderFilter = null;
                                _tagFilter = tag;
                              }),
                              onManageFolders: () =>
                                  _showFolderManager(context),
                              onCreateFolder: () async {
                                final String? folder =
                                    await _showFolderNameDialog(context);
                                if (folder == null) return;
                                await const QuranBookmarkService().createFolder(
                                  folder,
                                );
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          if (showEmpty)
                            SliverToBoxAdapter(
                              child: _BookmarkEmptyState(
                                isSearching: widget.searchQuery
                                    .trim()
                                    .isNotEmpty,
                                hasLibraryItems: allItems.isNotEmpty,
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                if (index.isOdd) {
                                  return const SizedBox(height: 12);
                                }
                                return _BookmarkRow(entry: items[index ~/ 2]);
                              }, childCount: items.length * 2 - 1),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 28)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool _matchesFilter(QuranBookmarkEntry entry) {
    if (_folderFilter != null) return entry.folder == _folderFilter;
    if (_tagFilter != null) return entry.tags.contains(_tagFilter);
    return switch (_filter) {
      _SavedAyahFilter.all => true,
      _SavedAyahFilter.favourites => entry.isFavourite,
      _SavedAyahFilter.notes => entry.note.trim().isNotEmpty,
    };
  }

  bool _matchesSearch(QuranBookmarkEntry entry) {
    final String query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    final String haystack = <String>[
      quran.getSurahName(entry.surah),
      quran.getSurahNameArabic(entry.surah),
      entry.surah.toString(),
      entry.verse.toString(),
      entry.note,
      entry.folder,
      ...entry.tags,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }
}

class _BookmarkLibraryHeader extends StatelessWidget {
  const _BookmarkLibraryHeader({
    required this.selected,
    required this.selectedFolder,
    required this.selectedTag,
    required this.allItems,
    required this.totalSavedCount,
    required this.onSelected,
    required this.onFolderSelected,
    required this.onTagSelected,
    required this.onManageFolders,
    required this.onCreateFolder,
  });

  final _SavedAyahFilter selected;
  final String? selectedFolder;
  final String? selectedTag;
  final List<QuranBookmarkEntry> allItems;
  final int totalSavedCount;
  final ValueChanged<_SavedAyahFilter> onSelected;
  final ValueChanged<String?> onFolderSelected;
  final ValueChanged<String?> onTagSelected;
  final VoidCallback onManageFolders;
  final VoidCallback onCreateFolder;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final int noteCount = allItems
        .where((QuranBookmarkEntry entry) => entry.note.trim().isNotEmpty)
        .length;
    final int favouriteCount = allItems
        .where((QuranBookmarkEntry entry) => entry.isFavourite)
        .length;
    final List<String> folders = const QuranBookmarkService().folders();
    final List<String> tags = const QuranBookmarkService().tags();
    final List<String> customFolders = folders
        .where((folder) => folder != QuranBookmarkService.defaultFolder)
        .toList(growable: false);
    final int unsortedCount = _folderCount(
      allItems,
      QuranBookmarkService.defaultFolder,
    );

    final BorderRadius radius = BorderRadius.circular(20);

    return Material(
      color: colors.background.withAlpha(0),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colors.primaryGradientStart,
              colors.primaryGradientEnd,
            ],
          ),
          borderRadius: radius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withAlpha(36),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -38,
              top: -18,
              width: 190,
              height: 190,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _IslamicPatternPainter(
                    color: colors.onPrimary,
                    opacity: 0.05,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colors.onPrimary.withAlpha(28),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.onPrimary.withAlpha(38),
                          ),
                        ),
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          color: colors.onPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          localizations.personalLibrary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.onPrimary.withAlpha(31),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: colors.onPrimary.withAlpha(28),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            localizations.savedCount(totalSavedCount),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Divider(height: 1, color: colors.onPrimary.withAlpha(31)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: <Widget>[
                        _FilterChipButton(
                          label: localizations.all,
                          count: allItems.length,
                          selected:
                              selected == _SavedAyahFilter.all &&
                              selectedFolder == null &&
                              selectedTag == null,
                          onTap: () => onSelected(_SavedAyahFilter.all),
                        ),
                        const SizedBox(width: 7),
                        _FilterChipButton(
                          label: localizations.favourites,
                          count: favouriteCount,
                          selected: selected == _SavedAyahFilter.favourites,
                          onTap: () => onSelected(_SavedAyahFilter.favourites),
                        ),
                        const SizedBox(width: 7),
                        _FilterChipButton(
                          label: localizations.notes,
                          count: noteCount,
                          selected: selected == _SavedAyahFilter.notes,
                          onTap: () => onSelected(_SavedAyahFilter.notes),
                        ),
                        if (customFolders.isNotEmpty ||
                            unsortedCount > 0) ...<Widget>[
                          const SizedBox(width: 7),
                          _FilterChipButton(
                            label: localizations.folders,
                            selected: selectedFolder != null,
                            onTap: () => onFolderSelected(
                              selectedFolder == null
                                  ? (customFolders.isNotEmpty
                                        ? customFolders.first
                                        : QuranBookmarkService.defaultFolder)
                                  : null,
                            ),
                          ),
                        ],
                        if (tags.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 7),
                          _FilterChipButton(
                            label: localizations.tags,
                            selected: selectedTag != null,
                            onTap: () => onTagSelected(
                              selectedTag == null ? tags.first : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FolderChipStrip(
                    folders: folders,
                    allItems: allItems,
                    selectedFolder: selectedFolder,
                    onFolderSelected: onFolderSelected,
                    onManageFolders: onManageFolders,
                  ),
                  if (tags.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    _TagChipStrip(
                      tags: tags,
                      selectedTag: selectedTag,
                      onTagSelected: onTagSelected,
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onCreateFolder,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      backgroundColor: colors.mint,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(localizations.addNewFolder),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _folderCount(List<QuranBookmarkEntry> items, String folder) {
    return items.where((entry) => entry.folder == folder).length;
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    return _LibraryOptionChip(
      label: label,
      count: count,
      selected: selected,
      onTap: onTap,
      selectedColor: colors.primary,
      selectedTextColor: colors.onPrimary,
      foregroundColor: colors.onPrimaryMuted,
      textStyle: theme.textTheme.labelMedium,
    );
  }
}

class _FolderChipStrip extends StatelessWidget {
  const _FolderChipStrip({
    required this.folders,
    required this.allItems,
    required this.selectedFolder,
    required this.onFolderSelected,
    required this.onManageFolders,
  });

  final List<String> folders;
  final List<QuranBookmarkEntry> allItems;
  final String? selectedFolder;
  final ValueChanged<String?> onFolderSelected;
  final VoidCallback onManageFolders;

  @override
  Widget build(BuildContext context) {
    final List<String> visibleFolders = folders.isEmpty
        ? <String>[QuranBookmarkService.defaultFolder]
        : folders;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: <Widget>[
          for (final String folder in visibleFolders) ...<Widget>[
            _LibraryOptionChip(
              icon: Icons.folder_outlined,
              label: _folderLabel(context, folder),
              count: _folderCount(folder),
              selected: selectedFolder == folder,
              onTap: () =>
                  onFolderSelected(selectedFolder == folder ? null : folder),
            ),
            const SizedBox(width: 7),
          ],
          if (visibleFolders.length > 1) ...<Widget>[
            _LibraryOptionChip(
              icon: Icons.tune_rounded,
              label: AppLocalizations.of(context)!.manageFolders,
              selected: false,
              onTap: onManageFolders,
            ),
          ],
        ],
      ),
    );
  }

  int _folderCount(String folder) {
    return allItems.where((entry) => entry.folder == folder).length;
  }
}

class _TagChipStrip extends StatelessWidget {
  const _TagChipStrip({
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: <Widget>[
          for (final String tag in tags) ...<Widget>[
            _LibraryOptionChip(
              label: '#$tag',
              selected: selectedTag == tag,
              onTap: () => onTagSelected(selectedTag == tag ? null : tag),
            ),
            if (tag != tags.last) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _LibraryOptionChip extends StatelessWidget {
  const _LibraryOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.icon,
    this.selectedColor,
    this.selectedTextColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    final Color activeColor = selectedColor ?? colors.primary;
    final Color activeTextColor = selectedTextColor ?? colors.onPrimary;
    final Color textColor = selected
        ? activeTextColor
        : foregroundColor ?? colors.onPrimaryMuted;

    return Material(
      color: colors.background.withAlpha(0),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? activeColor : colors.onPrimary.withAlpha(26),
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? activeColor.withAlpha(210)
                  : colors.onPrimary.withAlpha(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 15, color: textColor),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: (textStyle ?? Theme.of(context).textTheme.labelSmall)
                      ?.copyWith(color: textColor, fontWeight: FontWeight.w900),
                ),
                if (count != null) ...<Widget>[
                  const SizedBox(width: 5),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? textColor.withAlpha(220)
                          : colors.onPrimaryMuted.withAlpha(170),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({required this.entry});

  final QuranBookmarkEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String preview = _previewText(context, entry);
    final String arabicSnippet = quranVerseText(entry.surah, entry.verse);
    final bool hasMeta =
        entry.folder != QuranBookmarkService.defaultFolder ||
        entry.tags.isNotEmpty;
    final BorderRadius radius = BorderRadius.circular(16);

    return Material(
      color: colors.background.withAlpha(0),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) =>
                ReadPage(chapter: entry.surah, startVerse: entry.verse),
          ),
        ),
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: Border.all(color: colors.border.withAlpha(145)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colors.shadow.withAlpha(22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(width: 3, color: colors.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                colors.primaryGradientStart,
                                colors.primaryGradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.verse.toString(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                localizedSurahAyahLabel(
                                  localizations,
                                  entry.surah,
                                  entry.verse,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                arabicSnippet,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style:
                                    const TextStyle(
                                      fontFamily: 'Hafs',
                                      fontSize: 15,
                                      height: 1.3,
                                    ).copyWith(
                                      color: colors.textPrimary.withAlpha(102),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                  height: 1.24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (hasMeta) ...<Widget>[
                                const SizedBox(height: 7),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 5,
                                  children: <Widget>[
                                    if (entry.folder !=
                                        QuranBookmarkService.defaultFolder)
                                      _BookmarkMetaChip(
                                        label: _folderLabel(
                                          context,
                                          entry.folder,
                                        ),
                                      ),
                                    for (final String tag in entry.tags.take(3))
                                      _BookmarkMetaChip(label: '#$tag'),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 36,
                              height: 34,
                              child: Center(
                                child: LikeButton(
                                  size: 22,
                                  isLiked: entry.isFavourite,
                                  circleColor: CircleColor(
                                    start: colors.primary,
                                    end: colors.primaryGradientStart,
                                  ),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: colors.primary,
                                    dotSecondaryColor: colors.accentGold,
                                  ),
                                  likeBuilder: (bool liked) {
                                    return Icon(
                                      liked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: liked
                                          ? colors.primary
                                          : colors.textMuted,
                                      size: 22,
                                    );
                                  },
                                  onTap: (bool liked) async {
                                    if (liked) {
                                      await const QuranBookmarkService()
                                          .removeFavourite(
                                            entry.surah,
                                            entry.verse,
                                          );
                                      return false;
                                    }
                                    await const QuranBookmarkService()
                                        .saveFavourite(
                                          entry.surah,
                                          entry.verse,
                                        );
                                    return true;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              height: 34,
                              child: PopupMenuButton<_BookmarkAction>(
                                tooltip: localizations.folderTagsAndNote,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  color: colors.textMuted,
                                ),
                                onSelected: (action) async {
                                  switch (action) {
                                    case _BookmarkAction.edit:
                                    case _BookmarkAction.folder:
                                    case _BookmarkAction.tags:
                                      await _showBookmarkEditor(context, entry);
                                    case _BookmarkAction.delete:
                                      if (!context.mounted) return;
                                      final bool confirmed =
                                          await _confirmDeleteBookmark(context);
                                      if (!confirmed) return;
                                      await const QuranBookmarkService()
                                          .deleteBookmark(
                                            entry.surah,
                                            entry.verse,
                                          );
                                  }
                                },
                                itemBuilder: (context) =>
                                    <PopupMenuEntry<_BookmarkAction>>[
                                      PopupMenuItem<_BookmarkAction>(
                                        value: _BookmarkAction.edit,
                                        child: Text(localizations.editNote),
                                      ),
                                      PopupMenuItem<_BookmarkAction>(
                                        value: _BookmarkAction.folder,
                                        child: Text(localizations.moveToFolder),
                                      ),
                                      PopupMenuItem<_BookmarkAction>(
                                        value: _BookmarkAction.tags,
                                        child: Text(localizations.editTags),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem<_BookmarkAction>(
                                        value: _BookmarkAction.delete,
                                        child: Text(localizations.delete),
                                      ),
                                    ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _previewText(BuildContext context, QuranBookmarkEntry entry) {
    final String note = entry.note.trim();
    if (note.isNotEmpty) return note;
    final List<String> details = <String>[];
    if (entry.folder != QuranBookmarkService.defaultFolder) {
      details.add(_folderLabel(context, entry.folder));
    }
    if (entry.tags.isNotEmpty) {
      details.add(entry.tags.map((tag) => '#$tag').join(' '));
    }
    if (details.isNotEmpty) return details.join(' • ');
    return AppLocalizations.of(context)!.savedAyah;
  }
}

enum _BookmarkAction { edit, folder, tags, delete }

class _BookmarkMetaChip extends StatelessWidget {
  const _BookmarkMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.mint.withAlpha(150),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.border.withAlpha(160)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BookmarkEmptyState extends StatelessWidget {
  const _BookmarkEmptyState({
    required this.isSearching,
    required this.hasLibraryItems,
  });

  final bool isSearching;
  final bool hasLibraryItems;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withAlpha(190),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withAlpha(135)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primarySoft.withAlpha(28),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primarySoft.withAlpha(80)),
                  ),
                  child: Icon(
                    isSearching
                        ? Icons.search_off_rounded
                        : Icons.bookmark_add_outlined,
                    color: colors.primarySoft,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isSearching || hasLibraryItems
                      ? localizations.noMatchingSavedAyahs
                      : localizations.saveAyahsNotesHere,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.savedAyahLibraryHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.35,
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

Future<void> _showBookmarkEditor(
  BuildContext context,
  QuranBookmarkEntry entry,
) async {
  final TextEditingController noteController = TextEditingController(
    text: entry.note,
  );
  final TextEditingController folderController = TextEditingController(
    text: entry.folder,
  );
  final TextEditingController tagsController = TextEditingController(
    text: entry.tags.join(', '),
  );
  bool isFavourite = entry.isFavourite;
  String selectedFolder = entry.folder;
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final EquranColors colors = context.equranColors;
        final AppLocalizations localizations = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final List<String> folders = const QuranBookmarkService().folders();
            if (!folders.contains(selectedFolder)) {
              selectedFolder = QuranBookmarkService.defaultFolder;
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      localizedSurahAyahLabel(
                        localizations,
                        entry.surah,
                        entry.verse,
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    EquranSurfaceCard(
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                      backgroundColor: colors.surfaceSoft,
                      child: Text(
                        quranVerseText(entry.surah, entry.verse),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Hafs',
                          color: colors.textPrimary,
                          fontSize: 22,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localizations.favourites),
                      value: isFavourite,
                      onChanged: (value) => setSheetState(() {
                        isFavourite = value;
                      }),
                    ),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: localizations.privateNote,
                        hintText: localizations.writeReflectionHint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedFolder,
                            decoration: InputDecoration(
                              labelText: localizations.folders,
                            ),
                            items: <DropdownMenuItem<String>>[
                              for (final String folder in folders)
                                DropdownMenuItem<String>(
                                  value: folder,
                                  child: Text(_folderLabel(context, folder)),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setSheetState(() {
                                selectedFolder = value;
                                folderController.text = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: localizations.createFolder,
                          onPressed: () async {
                            final String? folder = await _showFolderNameDialog(
                              context,
                            );
                            if (folder == null) return;
                            final String created =
                                await const QuranBookmarkService().createFolder(
                                  folder,
                                );
                            setSheetState(() {
                              selectedFolder = created;
                              folderController.text = created;
                            });
                          },
                          icon: const Icon(Icons.create_new_folder_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _showFolderManager(context),
                        icon: const Icon(Icons.folder_copy_outlined),
                        label: Text(localizations.manageFolders),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagsController,
                      decoration: InputDecoration(
                        labelText: localizations.tags,
                        hintText: localizations.tagsHint,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: () {
                            const QuranBookmarkService().deleteBookmark(
                              entry.surah,
                              entry.verse,
                            );
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(localizations.delete),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            const QuranBookmarkService().saveBookmarkDetails(
                              entry.surah,
                              entry.verse,
                              isFavourite: isFavourite,
                              note: noteController.text,
                              folder: selectedFolder,
                              tags: _parseTags(tagsController.text),
                            );
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(localizations.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    noteController.dispose();
    folderController.dispose();
    tagsController.dispose();
  }
}

List<String> _parseTags(String value) {
  final Set<String> tags = <String>{};
  for (final String tag in value.split(',')) {
    final String cleanTag = tag.trim();
    if (cleanTag.isNotEmpty) tags.add(cleanTag);
  }
  return tags.toList(growable: false)..sort();
}

String _folderLabel(BuildContext context, String folder) {
  return folder == QuranBookmarkService.defaultFolder
      ? AppLocalizations.of(context)!.unsorted
      : folder;
}

Future<bool> _confirmDeleteBookmark(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final AppLocalizations localizations = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(localizations.removeSavedAyah),
        content: Text(localizations.removeSavedAyahDetailsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.remove),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

Future<String?> _showFolderNameDialog(
  BuildContext context, {
  String initialValue = '',
  String? title,
}) async {
  final TextEditingController controller = TextEditingController(
    text: initialValue == QuranBookmarkService.defaultFolder
        ? ''
        : initialValue,
  );
  try {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final AppLocalizations localizations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(title ?? localizations.newFolder),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: localizations.folderName,
              hintText: localizations.folderNameHint,
            ),
            onSubmitted: (_) {
              final String value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.of(context).pop(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                final String value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

Future<void> _showFolderManager(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final AppLocalizations localizations = AppLocalizations.of(context)!;
          final List<String> folders = const QuranBookmarkService().folders();
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        localizations.libraryFolders,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final String? name = await _showFolderNameDialog(
                          context,
                        );
                        if (name == null) return;
                        await const QuranBookmarkService().createFolder(name);
                        setSheetState(() {});
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: Text(localizations.newFolder),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final String folder in folders)
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(_folderLabel(context, folder)),
                    subtitle: Text(
                      folder == QuranBookmarkService.defaultFolder
                          ? localizations.defaultSavedAyahDestination
                          : localizations.savedAyahCollection,
                    ),
                    trailing: folder == QuranBookmarkService.defaultFolder
                        ? null
                        : PopupMenuButton<_FolderAction>(
                            onSelected: (action) async {
                              switch (action) {
                                case _FolderAction.rename:
                                  final String? name =
                                      await _showFolderNameDialog(
                                        context,
                                        initialValue: folder,
                                        title: localizations.renameFolder,
                                      );
                                  if (name == null) return;
                                  await const QuranBookmarkService()
                                      .renameFolder(folder, name);
                                  setSheetState(() {});
                                case _FolderAction.delete:
                                  final bool confirmed =
                                      await _confirmDeleteFolder(
                                        context,
                                        folder,
                                      );
                                  if (!confirmed) return;
                                  await const QuranBookmarkService()
                                      .deleteFolder(folder);
                                  setSheetState(() {});
                              }
                            },
                            itemBuilder: (context) =>
                                <PopupMenuEntry<_FolderAction>>[
                                  PopupMenuItem<_FolderAction>(
                                    value: _FolderAction.rename,
                                    child: Text(localizations.rename),
                                  ),
                                  PopupMenuItem<_FolderAction>(
                                    value: _FolderAction.delete,
                                    child: Text(localizations.delete),
                                  ),
                                ],
                          ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

enum _FolderAction { rename, delete }

Future<bool> _confirmDeleteFolder(BuildContext context, String folder) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final AppLocalizations localizations = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(
          localizations.deleteFolderQuestion(_folderLabel(context, folder)),
        ),
        content: Text(localizations.deleteFolderBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.delete),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}
