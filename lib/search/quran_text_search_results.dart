import 'dart:async';

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/search/quran_text_search_service.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

class QuranTextSearchResults extends StatefulWidget {
  const QuranTextSearchResults({
    super.key,
    required this.searchQuery,
    this.onSearchSelected,
  });

  final String searchQuery;
  final ValueChanged<String>? onSearchSelected;

  @override
  State<QuranTextSearchResults> createState() => _QuranTextSearchResultsState();
}

class _QuranTextSearchResultsState extends State<QuranTextSearchResults>
    with AutomaticKeepAliveClientMixin {
  final QuranTextSearchService _searchService = const QuranTextSearchService();
  final ScrollController _fallbackScrollController = ScrollController();
  Future<List<QuranTextSearchResult>>? _searchFuture;
  String _loadedQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshSearch();
  }

  @override
  void didUpdateWidget(covariant QuranTextSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery.trim() != widget.searchQuery.trim()) {
      _refreshSearch();
    }
  }

  @override
  void dispose() {
    _fallbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final String query = widget.searchQuery.trim();
    final ScrollController scrollController =
        PrimaryScrollController.maybeOf(context) ?? _fallbackScrollController;

    if (query.length < 2) {
      return _RecentQuranSearches(
        onSearchSelected: widget.onSearchSelected,
        scrollController: scrollController,
      );
    }

    return FutureBuilder<List<QuranTextSearchResult>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SearchLoadingState(scrollController: scrollController);
        }

        final List<QuranTextSearchResult> results =
            snapshot.data ?? const <QuranTextSearchResult>[];
        if (results.isEmpty) {
          return _EmptySearchState(query: query);
        }

        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          interactive: true,
          child: ListView.separated(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final QuranTextSearchResult result = results[index];
              return _QuranTextSearchTile(result: result, searchQuery: query);
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _refreshSearch() {
    final String query = widget.searchQuery.trim();
    _loadedQuery = query;
    if (query.length < 2) {
      setState(() {
        _searchFuture = null;
      });
      return;
    }

    setState(() {
      _searchFuture = _searchService.search(query).then((results) {
        if (_loadedQuery == query) {
          unawaited(_searchService.storeRecentQuery(query, results.length));
        }
        return results;
      });
    });
  }
}

class _QuranTextSearchTile extends StatelessWidget {
  const _QuranTextSearchTile({required this.result, required this.searchQuery});

  final QuranTextSearchResult result;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final String surahName = quran.getSurahNameEnglish(result.surah);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  ReadPage(chapter: result.surah, startVerse: result.verse),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: colors.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colors.shadow.withAlpha(12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.mint,
                        borderRadius: BorderRadius.circular(AppRadii.small),
                      ),
                      child: Text(
                        '$surahName ${result.verse}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      result.translationMatch
                          ? Icons.translate_rounded
                          : Icons.menu_book_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.arabicPreview,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Hafs',
                    height: 1.65,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.translationPreview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: colors.textSecondary,
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

class _RecentQuranSearches extends StatelessWidget {
  const _RecentQuranSearches({
    required this.scrollController,
    this.onSearchSelected,
  });

  final ScrollController scrollController;
  final ValueChanged<String>? onSearchSelected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: RecentSearchesDB().listener,
      builder: (context, box, child) {
        final List<RecentSearchEntry> entries = const QuranTextSearchService()
            .recentQuranTextSearches();

        if (entries.isEmpty) {
          return const _EmptyModeState();
        }

        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          interactive: true,
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            children: <Widget>[
              const SizedBox(height: 12),
              const _RecentSearchHeader(),
              const SizedBox(height: 10),
              ...entries.map(
                (RecentSearchEntry entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentSearchTile(
                    entry: entry,
                    onTap: onSearchSelected == null
                        ? null
                        : () => onSearchSelected!(entry.query),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentSearchHeader extends StatelessWidget {
  const _RecentSearchHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Recent Quran text searches',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({required this.entry, this.onTap});

  final RecentSearchEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      tileColor: colorScheme.surfaceContainerLow,
      leading: const Icon(Icons.history_rounded),
      title: Text(entry.query),
      subtitle: Text('${entry.resultCount} results'),
      trailing: onTap == null
          ? null
          : Icon(
              Icons.north_west_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120),
        Center(
          child: SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyModeState extends StatelessWidget {
  const _EmptyModeState();

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.travel_explore_rounded,
      title: 'Search Quran text',
      message:
          'Use this tab for Arabic words or translation text. Surah search stays in the Surahs tab.',
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.search_off_rounded,
      title: 'No Quran text results',
      message: 'No ayahs matched "$query". Try another Arabic word or phrase.',
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 44, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
