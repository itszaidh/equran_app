import 'dart:async';

import 'package:equran/backend/library.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/debouncer.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:equran/search/quran_text_search_results.dart';
import 'package:equran/services/frame_rate_policy_manager.dart';
import 'package:equran/widgets/library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum QuranSearchMode { surahs, quranText }

class QuranSearchRequest {
  const QuranSearchRequest({required this.mode, required this.nonce});

  final QuranSearchMode mode;
  final int nonce;
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.searchRequestListenable});

  final ValueListenable<QuranSearchRequest?>? searchRequestListenable;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _surahScrollController = ScrollController();
  final ScrollController _quranTextScrollController = ScrollController();
  final ScrollController _juzScrollController = ScrollController();
  final ScrollController _favouritesScrollController = ScrollController();
  late final TabController _tabController;

  String _searchQuery = '';
  int _selectedSegment = 0;
  int _lastHandledSearchRequestNonce = -1;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChanged);
    widget.searchRequestListenable?.addListener(_handleExternalSearchRequest);
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchRequestListenable != widget.searchRequestListenable) {
      oldWidget.searchRequestListenable?.removeListener(
        _handleExternalSearchRequest,
      );
      widget.searchRequestListenable?.addListener(_handleExternalSearchRequest);
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    widget.searchRequestListenable?.removeListener(
      _handleExternalSearchRequest,
    );
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _surahScrollController.dispose();
    _quranTextScrollController.dispose();
    _juzScrollController.dispose();
    _favouritesScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width >= 1400
        ? 36
        : width >= 1100
        ? 28
        : EquranSpacing.pagePadding;
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: _topBarDecoration(),
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: _buildTopBar(theme),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            10,
            horizontalPadding,
            15,
          ),
          child: _buildSectionHeader(theme),
        ),
        Expanded(child: _buildSegmentPager(horizontalPadding)),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final EquranColors colors = context.equranColors;
    return Row(
      children: <Widget>[
        Builder(
          builder: (context) => IconButton(
            onPressed: () => _openDrawer(context),
            style: ResponsiveNav.iconButtonStyle(context),
            icon: Icon(
              Icons.menu_rounded,
              color: colors.onPrimary,
              size: ResponsiveNav.iconSize(context),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _showSearch
                ? SearchBar(
                    key: const ValueKey<String>('header-search'),
                    controller: _searchController,
                    leading: const Icon(Icons.search_rounded),
                    trailing: <Widget>[
                      IconButton(
                        tooltip: 'Close search',
                        onPressed: _closeSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                    hintText: _searchHint,
                    hintStyle: WidgetStatePropertyAll(
                      theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onChanged: _changeSearchQuery,
                    elevation: const WidgetStatePropertyAll(0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey<String>('header-title'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _scrollToTop,
                    child: Text(
                      'Quran',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Row(
            key: ValueKey<bool>(_showSearch),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _showSearch
                  ? const SizedBox(
                      key: ValueKey<String>('search-button-hidden'),
                      width: 0,
                    )
                  : IconButton(
                      key: const ValueKey<String>('search-button'),
                      onPressed: _openSearch,
                      color: colors.onPrimary,
                      icon: const Icon(Icons.search_rounded),
                    ),
              _showSearch
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Search Quran text',
                      onPressed: () {
                        _tabController.animateTo(1);
                        _openSearch();
                      },
                      color: colors.onPrimary,
                      icon: const Icon(Icons.travel_explore_rounded),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDrawer(BuildContext context) {
    AndroidAudioDisplayMode.notifyUserActivity();
    FrameRatePolicyManager.instance.setDrawerOpen(
      true,
      reason: 'main_drawer_opening',
    );
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        'home.drawerOpenOrAnimating',
        reason: 'main drawer opening',
      ),
    );
    Scaffold.of(context).openDrawer();
  }

  BoxDecoration _topBarDecoration() {
    final EquranColors colors = context.equranColors;

    return BoxDecoration(
      color: colors.primary,
      border: Border(bottom: BorderSide(color: colors.primaryStrong)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colors.shadow.withAlpha(24),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    final EquranColors colors = context.equranColors;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.textSecondary,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overlayColor: WidgetStatePropertyAll(colors.primary.withAlpha(14)),
            splashBorderRadius: BorderRadius.circular(AppRadii.pill),
            tabs: <Widget>[
              _buildTabLabel(Icons.menu_book_outlined, 'Sura'),
              _buildTabLabel(Icons.travel_explore_rounded, 'Text'),
              _buildTabLabel(Icons.layers_outlined, 'Juz'),
              _buildTabLabel(Icons.favorite_border_rounded, 'Bookmark'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabLabel(IconData icon, String label) {
    return Tab(
      height: 42,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 19),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentPager(double horizontalPadding) {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: PrimaryScrollController(
            controller: _surahScrollController,
            child: QuranCardList(
              key: const ValueKey<String>('surah-list'),
              searchQuery: _searchQuery,
              header: _buildLastReadCard(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: PrimaryScrollController(
            controller: _quranTextScrollController,
            child: QuranTextSearchResults(
              searchQuery: _searchQuery,
              onSearchSelected: _useSearchQuery,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: PrimaryScrollController(
            controller: _juzScrollController,
            child: JuzCardList(
              key: ValueKey<String>('juz-list'),
              searchQuery: _searchQuery,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ValueListenableBuilder(
            key: const ValueKey<String>('page-list'),
            valueListenable: FavouritesDB().listener,
            builder: (BuildContext context, Box<dynamic> box, child) {
              if (box.length == 0) {
                return const SizedBox.shrink();
              } else {
                return PrimaryScrollController(
                  controller: _favouritesScrollController,
                  child: FavouritesList(searchQuery: _searchQuery),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _changeSearchQuery(String value) {
    _debouncer.call(() {
      if (!mounted) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  void _openSearch() {
    setState(() {
      _showSearch = true;
    });
  }

  void _useSearchQuery(String value) {
    _debouncer.cancel();
    _searchController.text = value;
    _searchController.selection = TextSelection.collapsed(offset: value.length);
    setState(() {
      _showSearch = true;
      _searchQuery = value;
    });
  }

  void _closeSearch() {
    _debouncer.cancel();
    setState(() {
      _showSearch = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _handleTabChanged() {
    if (_selectedSegment == _tabController.index) return;
    setState(() {
      _selectedSegment = _tabController.index;
    });
  }

  void _handleExternalSearchRequest() {
    final QuranSearchRequest? request = widget.searchRequestListenable?.value;
    if (request == null || request.nonce == _lastHandledSearchRequestNonce) {
      return;
    }
    _lastHandledSearchRequestNonce = request.nonce;
    final int targetIndex = switch (request.mode) {
      QuranSearchMode.surahs => 0,
      QuranSearchMode.quranText => 1,
    };

    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
    setState(() {
      _selectedSegment = targetIndex;
      _showSearch = true;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  String get _searchHint => switch (_selectedSegment) {
    1 => "Arabic word or translation...",
    2 => "Juz number or surah name...",
    3 => "Saved ayah, surah, note, or number...",
    _ => "Surah name or number...",
  };

  Widget? _buildLastReadCard() {
    if (SettingsDB().get("showLastRead", defaultValue: true) != true) {
      return null;
    }

    return ValueListenableBuilder(
      valueListenable: BookmarkDB().listener,
      builder: (BuildContext context, Box<dynamic> box, child) {
        final entries = LastReadCard.displayReadingHistory(box.values);
        Widget currentChild = const SizedBox.shrink(
          key: ValueKey<String>('last-read-empty'),
        );

        if (entries.isNotEmpty) {
          currentChild = LastReadCard(
            key: const ValueKey<String>('last-read-card'),
            entries: entries,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: currentChild,
        );
      },
    );
  }

  void _scrollToTop() {
    final ScrollController scrollController = switch (_selectedSegment) {
      0 => _surahScrollController,
      1 => _quranTextScrollController,
      2 => _juzScrollController,
      _ => _favouritesScrollController,
    };
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
