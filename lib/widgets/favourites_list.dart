import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

enum _SavedAyahFilter { all, favourites, notes, collections }

class FavouritesList extends StatefulWidget {
  const FavouritesList({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<FavouritesList> createState() => _FavouritesListState();
}

class _FavouritesListState extends State<FavouritesList> {
  final ScrollController _fallbackScrollController = ScrollController();
  _SavedAyahFilter _filter = _SavedAyahFilter.all;

  @override
  void dispose() {
    _fallbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController =
        PrimaryScrollController.maybeOf(context) ?? _fallbackScrollController;

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: QuranBookmarksDB().listener,
      builder: (BuildContext context, Box<dynamic> bookmarksBox, _) {
        return ValueListenableBuilder<Box<dynamic>>(
          valueListenable: FavouritesDB().listener,
          builder: (BuildContext context, Box<dynamic> favouritesBox, _) {
            final List<QuranBookmarkEntry> allItems =
                const QuranBookmarkService()
                    .bookmarkEntriesWithLegacyFallback();
            final List<QuranBookmarkEntry> searched = allItems
                .where(_matchesSearch)
                .toList(growable: false);
            final List<QuranBookmarkEntry> items = searched
                .where(_matchesFilter)
                .toList(growable: false);

            if (allItems.isEmpty || items.isEmpty) {
              return _BookmarkEmptyState(
                isSearching: widget.searchQuery.trim().isNotEmpty,
                hasLibraryItems: allItems.isNotEmpty,
              );
            }

            return Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              interactive: true,
              child: ListView.separated(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 28),
                itemCount: items.length + 1,
                separatorBuilder: (context, index) => index == 0
                    ? const SizedBox(height: 10)
                    : const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _BookmarkLibraryHeader(
                      selected: _filter,
                      allItems: searched,
                      onSelected: (filter) => setState(() {
                        _filter = filter;
                      }),
                    );
                  }
                  return _BookmarkRow(entry: items[index - 1]);
                },
              ),
            );
          },
        );
      },
    );
  }

  bool _matchesFilter(QuranBookmarkEntry entry) {
    return switch (_filter) {
      _SavedAyahFilter.all => true,
      _SavedAyahFilter.favourites => entry.isFavourite,
      _SavedAyahFilter.notes => entry.note.trim().isNotEmpty,
      _SavedAyahFilter.collections =>
        entry.folder != 'Default' || entry.tags.isNotEmpty,
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
    required this.allItems,
    required this.onSelected,
  });

  final _SavedAyahFilter selected;
  final List<QuranBookmarkEntry> allItems;
  final ValueChanged<_SavedAyahFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    final int noteCount = allItems
        .where((QuranBookmarkEntry entry) => entry.note.trim().isNotEmpty)
        .length;
    final int collectionCount = allItems
        .where(
          (QuranBookmarkEntry entry) =>
              entry.folder != 'Default' || entry.tags.isNotEmpty,
        )
        .length;
    final int favouriteCount = allItems
        .where((QuranBookmarkEntry entry) => entry.isFavourite)
        .length;

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      backgroundColor: colors.surfaceSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              EquranIconBadge(
                icon: Icons.bookmark_border_rounded,
                size: 34,
                backgroundColor: colors.mint,
                foregroundColor: colors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Personal Library',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${allItems.length} saved',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _FilterChipButton(
                label: 'All ${allItems.length}',
                selected: selected == _SavedAyahFilter.all,
                onTap: () => onSelected(_SavedAyahFilter.all),
              ),
              _FilterChipButton(
                label: 'Favourites $favouriteCount',
                selected: selected == _SavedAyahFilter.favourites,
                onTap: () => onSelected(_SavedAyahFilter.favourites),
              ),
              _FilterChipButton(
                label: 'Notes $noteCount',
                selected: selected == _SavedAyahFilter.notes,
                onTap: () => onSelected(_SavedAyahFilter.notes),
              ),
              _FilterChipButton(
                label: 'Collections $collectionCount',
                selected: selected == _SavedAyahFilter.collections,
                onTap: () => onSelected(_SavedAyahFilter.collections),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      side: BorderSide(color: selected ? colors.primary : colors.border),
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.textSecondary,
        fontWeight: FontWeight.w800,
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
    final String preview = _previewText(entry);

    return EquranSurfaceCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ReadPage(chapter: entry.surah, startVerse: entry.verse),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: colors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadii.medium),
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${quran.getSurahName(entry.surah)} ${entry.verse}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (entry.isFavourite)
                      Icon(
                        Icons.favorite_rounded,
                        color: colors.primary,
                        size: 17,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Edit bookmark',
            onPressed: () => _showBookmarkEditor(context, entry),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
    );
  }

  String _previewText(QuranBookmarkEntry entry) {
    final String note = entry.note.trim();
    if (note.isNotEmpty) return note;
    final List<String> details = <String>[];
    if (entry.folder != 'Default') details.add(entry.folder);
    if (entry.tags.isNotEmpty) {
      details.add(entry.tags.map((tag) => '#$tag').join(' '));
    }
    if (details.isNotEmpty) return details.join(' • ');
    return 'Saved ayah';
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: EquranSurfaceCard(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              EquranIconBadge(
                icon: isSearching
                    ? Icons.search_off_rounded
                    : Icons.bookmark_add_outlined,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                isSearching || hasLibraryItems
                    ? 'No matching saved ayahs.'
                    : 'Save ayahs, notes, and reflections here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Favourite ayahs quickly, or add folders, tags, and private notes from the reading options.',
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
    text: entry.folder == 'Default' ? '' : entry.folder,
  );
  final TextEditingController tagsController = TextEditingController(
    text: entry.tags.join(', '),
  );
  bool isFavourite = entry.isFavourite;
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final EquranColors colors = context.equranColors;
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      '${quran.getSurahName(entry.surah)} • Ayah ${entry.verse}',
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
                      title: const Text('Favourite'),
                      value: isFavourite,
                      onChanged: (value) => setSheetState(() {
                        isFavourite = value;
                      }),
                    ),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      minLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Private note',
                        hintText: 'Write a reflection...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: folderController,
                      decoration: const InputDecoration(
                        labelText: 'Folder',
                        hintText: 'Default',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'gratitude, duas',
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
                          label: const Text('Delete'),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            const QuranBookmarkService().saveBookmarkDetails(
                              entry.surah,
                              entry.verse,
                              isFavourite: isFavourite,
                              note: noteController.text,
                              folder: folderController.text,
                              tags: _parseTags(tagsController.text),
                            );
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Save'),
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
