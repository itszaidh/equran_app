import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:like_button/like_button.dart';
import 'package:quran/quran.dart' as quran;

enum _SavedAyahFilter { all, favourites, notes }

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
    final ScrollController scrollController =
        PrimaryScrollController.maybeOf(context) ?? _fallbackScrollController;

    return ValueListenableBuilder<Box<dynamic>>(
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

                return Scrollbar(
                  controller: scrollController,
                  thumbVisibility: allItems.isNotEmpty,
                  interactive: true,
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 28),
                    itemCount: showEmpty ? 2 : items.length + 1,
                    separatorBuilder: (context, index) => index == 0
                        ? const SizedBox(height: 10)
                        : const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _BookmarkLibraryHeader(
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
                          onManageFolders: () => _showFolderManager(context),
                          onCreateFolder: () async {
                            final String? folder = await _showFolderNameDialog(
                              context,
                            );
                            if (folder == null) return;
                            await const QuranBookmarkService().createFolder(
                              folder,
                            );
                          },
                        );
                      }
                      if (showEmpty) {
                        return _BookmarkEmptyState(
                          isSearching: widget.searchQuery.trim().isNotEmpty,
                          hasLibraryItems: allItems.isNotEmpty,
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
      },
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

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Personal Library',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Saved ayahs, notes, and reflections',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.mint.withAlpha(160),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: colors.border.withAlpha(180)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    '$totalSavedCount saved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <Widget>[
                _FilterChipButton(
                  label: 'All',
                  count: allItems.length,
                  selected:
                      selected == _SavedAyahFilter.all &&
                      selectedFolder == null &&
                      selectedTag == null,
                  onTap: () => onSelected(_SavedAyahFilter.all),
                ),
                const SizedBox(width: 7),
                _FilterChipButton(
                  label: 'Favourites',
                  count: favouriteCount,
                  selected: selected == _SavedAyahFilter.favourites,
                  onTap: () => onSelected(_SavedAyahFilter.favourites),
                ),
                const SizedBox(width: 7),
                _FilterChipButton(
                  label: 'Notes',
                  count: noteCount,
                  selected: selected == _SavedAyahFilter.notes,
                  onTap: () => onSelected(_SavedAyahFilter.notes),
                ),
                if (customFolders.isNotEmpty || unsortedCount > 0) ...<Widget>[
                  const SizedBox(width: 7),
                  _FilterChipButton(
                    label: 'Folders',
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
                    label: 'Tags',
                    selected: selectedTag != null,
                    onTap: () =>
                        onTagSelected(selectedTag == null ? tags.first : null),
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
            onCreateFolder: onCreateFolder,
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
        ],
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
    required this.onCreateFolder,
    required this.onManageFolders,
  });

  final List<String> folders;
  final List<QuranBookmarkEntry> allItems;
  final String? selectedFolder;
  final ValueChanged<String?> onFolderSelected;
  final VoidCallback onCreateFolder;
  final VoidCallback onManageFolders;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
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
              label: _folderLabel(folder),
              count: _folderCount(folder),
              selected: selectedFolder == folder,
              onTap: () =>
                  onFolderSelected(selectedFolder == folder ? null : folder),
            ),
            const SizedBox(width: 7),
          ],
          _LibraryOptionChip(
            icon: Icons.add_rounded,
            label: 'Folder',
            selected: false,
            onTap: onCreateFolder,
            borderColor: colors.primary.withAlpha(140),
            foregroundColor: colors.primary,
          ),
          if (visibleFolders.length > 1) ...<Widget>[
            const SizedBox(width: 7),
            _LibraryOptionChip(
              icon: Icons.tune_rounded,
              label: 'Manage',
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
    this.borderColor,
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
  final Color? borderColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    final Color activeColor = selectedColor ?? colors.mint.withAlpha(210);
    final Color activeTextColor = selectedTextColor ?? colors.primary;
    final Color textColor = selected
        ? activeTextColor
        : foregroundColor ?? colors.textSecondary;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? activeColor : colors.surface.withAlpha(190),
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? (selectedColor ?? colors.primary).withAlpha(190)
                  : borderColor ?? colors.border.withAlpha(180),
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
                          : colors.textMuted,
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
    final String preview = _previewText(entry);
    final bool hasMeta =
        entry.folder != QuranBookmarkService.defaultFolder ||
        entry.tags.isNotEmpty;

    return EquranSurfaceCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ReadPage(chapter: entry.surah, startVerse: entry.verse),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                Text(
                  '${quran.getSurahName(entry.surah)} • Ayah ${entry.verse}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
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
                if (hasMeta) ...<Widget>[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: <Widget>[
                      if (entry.folder != QuranBookmarkService.defaultFolder)
                        _BookmarkMetaChip(label: _folderLabel(entry.folder)),
                      for (final String tag in entry.tags.take(3))
                        _BookmarkMetaChip(label: '#$tag'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: LikeButton(
                size: 23,
                isLiked: entry.isFavourite,
                circleColor: CircleColor(
                  start: colors.primary.withAlpha(180),
                  end: colors.primary,
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
                    color: liked ? colors.primary : colors.textMuted,
                    size: 23,
                  );
                },
                onTap: (bool liked) async {
                  if (liked) {
                    await const QuranBookmarkService().removeFavourite(
                      entry.surah,
                      entry.verse,
                    );
                    return false;
                  }
                  await const QuranBookmarkService().saveFavourite(
                    entry.surah,
                    entry.verse,
                  );
                  return true;
                },
              ),
            ),
          ),
          PopupMenuButton<_BookmarkAction>(
            tooltip: 'Saved ayah actions',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) async {
              switch (action) {
                case _BookmarkAction.edit:
                case _BookmarkAction.folder:
                case _BookmarkAction.tags:
                  await _showBookmarkEditor(context, entry);
                case _BookmarkAction.delete:
                  if (!context.mounted) return;
                  final bool confirmed = await _confirmDeleteBookmark(context);
                  if (!confirmed) return;
                  await const QuranBookmarkService().deleteBookmark(
                    entry.surah,
                    entry.verse,
                  );
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<_BookmarkAction>>[
              PopupMenuItem<_BookmarkAction>(
                value: _BookmarkAction.edit,
                child: Text('Edit note'),
              ),
              PopupMenuItem<_BookmarkAction>(
                value: _BookmarkAction.folder,
                child: Text('Move to folder'),
              ),
              PopupMenuItem<_BookmarkAction>(
                value: _BookmarkAction.tags,
                child: Text('Edit tags'),
              ),
              PopupMenuDivider(),
              PopupMenuItem<_BookmarkAction>(
                value: _BookmarkAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _previewText(QuranBookmarkEntry entry) {
    final String note = entry.note.trim();
    if (note.isNotEmpty) return note;
    final List<String> details = <String>[];
    if (entry.folder != QuranBookmarkService.defaultFolder) {
      details.add(_folderLabel(entry.folder));
    }
    if (entry.tags.isNotEmpty) {
      details.add(entry.tags.map((tag) => '#$tag').join(' '));
    }
    if (details.isNotEmpty) return details.join(' • ');
    return 'Saved ayah';
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedFolder,
                            decoration: const InputDecoration(
                              labelText: 'Folder',
                            ),
                            items: <DropdownMenuItem<String>>[
                              for (final String folder in folders)
                                DropdownMenuItem<String>(
                                  value: folder,
                                  child: Text(_folderLabel(folder)),
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
                          tooltip: 'Create folder',
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
                        label: const Text('Manage folders'),
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
                              folder: selectedFolder,
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

String _folderLabel(String folder) {
  return folder == QuranBookmarkService.defaultFolder
      ? QuranBookmarkService.defaultFolderLabel
      : folder;
}

Future<bool> _confirmDeleteBookmark(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove saved ayah?'),
      content: const Text(
        'This will remove the note, tags, folder, and favourite state for this ayah.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

Future<String?> _showFolderNameDialog(
  BuildContext context, {
  String initialValue = '',
  String title = 'New folder',
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
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Folder name',
              hintText: 'Reflections',
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
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
                        'Library folders',
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
                      label: const Text('New'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final String folder in folders)
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(_folderLabel(folder)),
                    subtitle: Text(
                      folder == QuranBookmarkService.defaultFolder
                          ? 'Default destination for saved ayahs'
                          : 'Saved ayah collection',
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
                                        title: 'Rename folder',
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
                                const <PopupMenuEntry<_FolderAction>>[
                                  PopupMenuItem<_FolderAction>(
                                    value: _FolderAction.rename,
                                    child: Text('Rename'),
                                  ),
                                  PopupMenuItem<_FolderAction>(
                                    value: _FolderAction.delete,
                                    child: Text('Delete'),
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
    builder: (context) => AlertDialog(
      title: Text('Delete ${_folderLabel(folder)}?'),
      content: const Text(
        'Saved ayahs in this folder will be moved to Unsorted.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed == true;
}
