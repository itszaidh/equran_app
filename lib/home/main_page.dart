import 'package:equran/backend/library.dart';
import 'package:equran/utils/debouncer.dart';
import 'package:equran/widgets/library.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _surahScrollController = ScrollController();
  final ScrollController _juzScrollController = ScrollController();
  final ScrollController _favouritesScrollController = ScrollController();
  late final TabController _tabController;

  String _searchQuery = '';
  int _selectedSegment = 0;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _surahScrollController.dispose();
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
            : 14;
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
          ),
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
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
        Expanded(
          child: _buildSegmentPager(horizontalPadding),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Row(
      children: <Widget>[
        Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
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
                    hintText: 'Surah name or number...',
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey<String>('header-title'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _scrollToTop,
                    child: Text(
                      'eQuran',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _showSearch
              ? const SizedBox(
                  key: ValueKey<String>('search-button-hidden'),
                  width: 0,
                )
              : IconButton(
                  key: const ValueKey<String>('search-button'),
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search_rounded),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(150),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.primary.withAlpha(46),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withAlpha(18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    colorScheme.primaryContainer.withAlpha(245),
                    colorScheme.tertiaryContainer.withAlpha(225),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.primary.withAlpha(42),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: colorScheme.onPrimaryContainer,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overlayColor: WidgetStatePropertyAll(
                colorScheme.primary.withAlpha(16),
              ),
              splashBorderRadius: BorderRadius.circular(14),
              tabs: <Widget>[
                _buildTabLabel(Icons.menu_book_outlined, 'Surah'),
                _buildTabLabel(Icons.layers_outlined, 'Juz'),
                _buildTabLabel(Icons.favorite_border_rounded, 'Saved'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabLabel(IconData icon, String label) {
    return Tab(
      height: 42,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 19),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSegmentPager(double horizontalPadding) {
    return TabBarView(
      controller: _tabController,
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
            controller: _juzScrollController,
            child: const JuzCardList(
              key: ValueKey<String>('juz-list'),
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
                  child: const FavouritesList(),
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

  Widget? _buildLastReadCard() {
    if (SettingsDB().get("showLastRead", defaultValue: true) != true) {
      return null;
    }

    return ValueListenableBuilder(
      valueListenable: BookmarkDB().listener,
      builder: (BuildContext context, Box<dynamic> box, child) {
        final entries = box.values.whereType<ReadingEntry>().toList();
        Widget currentChild = const SizedBox.shrink();

        if (entries.isNotEmpty) {
          entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final latest = entries.first;
          currentChild = LastReadCard(
            key: ValueKey<String>(
              '${latest.surah}-${latest.verse}-${latest.timestamp.microsecondsSinceEpoch}',
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: currentChild,
        );
      },
    );
  }

  void _scrollToTop() {
    final ScrollController scrollController = switch (_selectedSegment) {
      0 => _surahScrollController,
      1 => _juzScrollController,
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
