import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:equran/backend/library.dart'
    show AndroidAudioDisplayMode, SettingsDB;
import 'package:equran/duas/duas_page.dart';
import 'package:equran/duas/tasbih_page.dart';
import 'package:equran/home/downloads.dart';
import 'package:equran/home/main_page.dart';
import 'package:equran/home/player.dart';
import 'package:equran/home/settings.dart';
import 'package:equran/home_dashboard/home_dashboard_page.dart';
import 'package:equran/prayer/prayer_times_page.dart';
import 'package:equran/prayer/qibla_page.dart';
import 'package:equran/reading_plans/reading_plans_page.dart';
import 'package:equran/services/frame_rate_policy_manager.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:flutter/material.dart';

const EdgeInsets _drawerTilePadding = EdgeInsets.symmetric(horizontal: 12);
const int _homeDestinationIndex = 0;
const int _quranDestinationIndex = 1;
const int _playerDestinationIndex = 2;
const int _duasDestinationIndex = 3;
const int _downloadsDestinationIndex = 4;
const int _prayerDestinationIndex = 5;
const int _settingsDestinationIndex = 6;
const List<int> _bottomDestinationIndices = <int>[
  _homeDestinationIndex,
  _quranDestinationIndex,
  _prayerDestinationIndex,
  _duasDestinationIndex,
];
const List<int> _drawerDestinationIndices = <int>[
  _homeDestinationIndex,
  _quranDestinationIndex,
  _playerDestinationIndex,
  _duasDestinationIndex,
  _prayerDestinationIndex,
];
const String _homePointerRefreshBlocker = 'home.userPointerActive';
const String _drawerRefreshBlocker = 'home.drawerOpenOrAnimating';
const String _routeTransitionRefreshBlocker = 'home.routeTransitionActive';
const String _secondaryRouteRefreshBlocker = 'home.settingsOrDownloadsActive';
const String _homePointerPolicySource = 'home_pointer';

class Destinations {
  const Destinations(
    this.label,
    this.icon,
    this.selectedIcon,
    this.destination,
  );

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Widget destination;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _previousPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<QuranSearchRequest?> _quranSearchRequest =
      ValueNotifier<QuranSearchRequest?>(null);

  late final List<Destinations> _pageDestinations;

  @override
  void initState() {
    super.initState();
    _pageDestinations = <Destinations>[
      Destinations(
        'Home',
        const Icon(Icons.home_outlined),
        const Icon(Icons.home_rounded),
        HomeDashboardPage(
          onMenuPressed: _openDrawerFromDashboard,
          onOpenQuran: () => _onItemTapped(_quranDestinationIndex),
          onOpenPlayer: () => _onItemTapped(_playerDestinationIndex),
          onOpenPrayerTimes: () => _onItemTapped(_prayerDestinationIndex),
          onOpenQibla: _openQiblaPage,
          onOpenDuas: () => _onItemTapped(_duasDestinationIndex),
          onOpenTasbih: _openTasbihPage,
          onOpenReadingPlans: _openReadingPlansPage,
          onOpenDownloads: () => _onItemTapped(_downloadsDestinationIndex),
          onOpenSearch: _openQuranTextSearch,
        ),
      ),
      Destinations(
        'Quran',
        const Icon(Icons.menu_book_outlined),
        const Icon(Icons.menu_book_rounded),
        MainPage(searchRequestListenable: _quranSearchRequest),
      ),
      Destinations(
        'Player',
        const Icon(Icons.library_music_outlined),
        const Icon(Icons.library_music),
        const PlayerPage(),
      ),
      Destinations(
        'Duas',
        const Icon(Icons.auto_stories_outlined),
        const Icon(Icons.auto_stories_rounded),
        DuasPage(),
      ),
      Destinations(
        'Downloads',
        const Icon(Icons.download_outlined),
        const Icon(Icons.download_rounded),
        const DownloadsPage(),
      ),
      Destinations(
        'Prayer Times',
        const Icon(Icons.access_time_outlined),
        const Icon(Icons.schedule_rounded),
        const PrayerTimesPage(),
      ),
      Destinations(
        'Settings',
        const Icon(Icons.settings_outlined),
        const Icon(Icons.settings),
        const SettingsPage(),
      ),
    ];
  }

  @override
  void dispose() {
    _quranSearchRequest.dispose();
    FrameRatePolicyManager.instance.setPointerActive(
      false,
      source: _homePointerPolicySource,
      reason: 'home_disposed',
    );
    FrameRatePolicyManager.instance.setDrawerOpen(
      false,
      reason: 'home_disposed',
    );
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      false,
      reason: 'home_disposed',
    );
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      false,
      reason: 'home_disposed',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tabletLayout = ResponsiveNav.isTablet(context);
    final double navIconSize = ResponsiveNav.iconSize(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final EquranColors equranColors = context.equranColors;
    final bool showSecondaryBackButton = _isSecondaryPage(_selectedIndex);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleGlobalPointerDown(),
      onPointerUp: (_) => _handleGlobalPointerReleased(),
      onPointerCancel: (_) => _handleGlobalPointerReleased(),
      onPointerSignal: (_) => AndroidAudioDisplayMode.notifyUserActivity(),
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: _handleDrawerChanged,
        drawer: showSecondaryBackButton
            ? null
            : NavigationDrawerTheme(
                data: NavigationDrawerTheme.of(context).copyWith(
                  labelTextStyle: WidgetStatePropertyAll(
                    ResponsiveNav.drawerLabelStyle(context),
                  ),
                  tileHeight: ResponsiveNav.drawerTileHeight(context),
                  indicatorColor: colorScheme.secondaryContainer.withValues(
                    alpha: 0.45,
                  ),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: NavigationDrawer(
                  onDestinationSelected: (index) {
                    _onDrawerDestinationSelected(index);
                  },
                  selectedIndex: _selectedDrawerIndex,
                  tilePadding: _drawerTilePadding,
                  children: <Widget>[
                    SizedBox(height: tabletLayout ? 76 : 64),
                    ..._drawerDestinationIndices.map((int destinationIndex) {
                      final Destinations destination =
                          _pageDestinations[destinationIndex];
                      return NavigationDrawerDestination(
                        label: Text(destination.label),
                        icon: IconTheme(
                          data: IconThemeData(
                            color: colorScheme.onSurfaceVariant,
                            size: navIconSize,
                          ),
                          child: destination.icon,
                        ),
                        selectedIcon: IconTheme(
                          data: IconThemeData(
                            color: colorScheme.onSecondaryContainer,
                            size: navIconSize,
                          ),
                          child: destination.selectedIcon,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const Divider(indent: 18, endIndent: 18),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Settings',
                            iconSize: navIconSize,
                            color: _selectedIndex == _settingsDestinationIndex
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            onPressed: _openSettingsFromDrawer,
                            icon: const Icon(Icons.settings_outlined),
                          ),
                          IconButton(
                            tooltip: 'Downloads',
                            iconSize: navIconSize,
                            color: _selectedIndex == _downloadsDestinationIndex
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            onPressed: _openDownloadsFromDrawer,
                            icon: const Icon(Icons.download_outlined),
                          ),
                          IconButton(
                            tooltip: 'Toggle theme',
                            iconSize: navIconSize,
                            color: colorScheme.onSurfaceVariant,
                            onPressed: _toggleQuickTheme,
                            icon: Icon(
                              theme.brightness == Brightness.dark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        appBar: _selectedIndex >= _duasDestinationIndex
            ? AppBar(
                toolbarHeight: ResponsiveNav.toolbarHeight(context),
                leading: showSecondaryBackButton
                    ? IconButton(
                        tooltip: 'Back',
                        onPressed: _returnToPreviousPage,
                        icon: const Icon(Icons.arrow_back_rounded),
                      )
                    : null,
                title: Text(_pageDestinations[_selectedIndex].label),
                centerTitle: true,
                backgroundColor: equranColors.primary,
                foregroundColor: equranColors.onPrimary,
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: equranColors.onPrimary,
                  size: navIconSize,
                ),
                actions: <Widget>[
                  if (_pageDestinations[_selectedIndex].destination
                      is PrayerTimesPage)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: IconButton(
                        tooltip: 'Qibla',
                        onPressed: _openQiblaPage,
                        icon: const Icon(Icons.explore_outlined),
                      ),
                    ),
                ],
              )
            : null,
        body: _pageDestinations[_selectedIndex].destination,
        bottomNavigationBar: tabletLayout ? null : _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final EquranColors colors = context.equranColors;
    final int navIndex = switch (_selectedIndex) {
      _homeDestinationIndex => 0,
      _quranDestinationIndex => 1,
      _prayerDestinationIndex => 2,
      _duasDestinationIndex => 3,
      _ => 4,
    };

    return ColoredBox(
      color: colors.primary,
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 68,
          selectedIndex: navIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) {
            if (index == 4) {
              _openDrawerFromDashboard();
              return;
            }
            _onItemTapped(_bottomDestinationIndices[index]);
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Quran',
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule_rounded),
              label: 'Prayer',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Duas',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  int? get _selectedDrawerIndex {
    final int drawerIndex = _drawerDestinationIndices.indexOf(_selectedIndex);
    return drawerIndex < 0 ? null : drawerIndex;
  }

  void _handleGlobalPointerDown() {
    FrameRatePolicyManager.instance.setPointerActive(
      true,
      source: _homePointerPolicySource,
      reason: 'home_pointer_down',
    );
    AndroidAudioDisplayMode.notifyUserActivity();
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _homePointerRefreshBlocker,
        reason: 'home pointer down',
      ),
    );
  }

  void _handleGlobalPointerReleased() {
    FrameRatePolicyManager.instance.setPointerActive(
      false,
      source: _homePointerPolicySource,
      reason: 'home_pointer_released',
    );
    AndroidAudioDisplayMode.notifyUserActivity();
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        return AndroidAudioDisplayMode.removeLowRefreshBlocker(
          _homePointerRefreshBlocker,
          reason: 'home pointer settled',
        );
      }),
    );
  }

  void _handleDrawerChanged(bool isOpened) {
    FrameRatePolicyManager.instance.setDrawerOpen(
      isOpened,
      reason: isOpened ? 'drawer_open' : 'drawer_closed',
    );
    if (isOpened) {
      unawaited(
        AndroidAudioDisplayMode.addLowRefreshBlocker(
          _drawerRefreshBlocker,
          reason: 'drawer opened',
        ),
      );
      return;
    }

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        return AndroidAudioDisplayMode.removeLowRefreshBlocker(
          _drawerRefreshBlocker,
          reason: 'drawer closed',
        );
      }),
    );
  }

  void _openDrawerFromDashboard() {
    AndroidAudioDisplayMode.notifyUserActivity();
    FrameRatePolicyManager.instance.setDrawerOpen(
      true,
      reason: 'dashboard_drawer_opening',
    );
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _drawerRefreshBlocker,
        reason: 'dashboard drawer opening',
      ),
    );
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openQuranTextSearch() {
    _onItemTapped(_quranDestinationIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quranSearchRequest.value = QuranSearchRequest(
        mode: QuranSearchMode.quranText,
        nonce: DateTime.now().microsecondsSinceEpoch,
      );
    });
  }

  void _onDrawerDestinationSelected(int index) {
    final int destinationIndex = _drawerDestinationIndices[index];
    _onItemTapped(destinationIndex);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _openSettingsFromDrawer() {
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      true,
      reason: 'settings_route',
    );
    _scaffoldKey.currentState?.closeDrawer();
    _pushDrawerPage(_settingsDestinationIndex);
  }

  void _openDownloadsFromDrawer() {
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      true,
      reason: 'downloads_route',
    );
    _scaffoldKey.currentState?.closeDrawer();
    _pushDrawerPage(_downloadsDestinationIndex);
  }

  void _pushDrawerPage(int index) {
    final Destinations destination = _pageDestinations[index];
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'opening_${destination.label.toLowerCase()}',
    );
    if (_isSecondaryPage(index)) {
      FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
        true,
        reason: '${destination.label.toLowerCase()}_route',
      );
    }
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _routeTransitionRefreshBlocker,
        reason: 'opening ${destination.label}',
      ),
    );
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _secondaryRouteRefreshBlocker,
        reason: '${destination.label} route active',
      ),
    );
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        FrameRatePolicyManager.instance.setRouteTransitionActive(
          false,
          reason: '${destination.label.toLowerCase()}_push_settled',
        );
        return AndroidAudioDisplayMode.removeLowRefreshBlocker(
          _routeTransitionRefreshBlocker,
          reason: '${destination.label} push transition settled',
        );
      }),
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: ResponsiveNav.toolbarHeight(context),
                  title: Text(destination.label),
                  centerTitle: true,
                  iconTheme: IconThemeData(
                    size: ResponsiveNav.iconSize(context),
                  ),
                ),
                body: destination.destination,
              );
            },
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            true,
            reason: '${destination.label.toLowerCase()}_pop_transition',
          );
          unawaited(
            AndroidAudioDisplayMode.addLowRefreshBlocker(
              _routeTransitionRefreshBlocker,
              reason: '${destination.label} pop transition',
            ),
          );
          unawaited(
            Future<void>.delayed(const Duration(milliseconds: 450), () async {
              FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
                false,
                reason: '${destination.label.toLowerCase()}_route_closed',
              );
              FrameRatePolicyManager.instance.setRouteTransitionActive(
                false,
                reason: '${destination.label.toLowerCase()}_pop_settled',
              );
              await AndroidAudioDisplayMode.removeLowRefreshBlocker(
                _secondaryRouteRefreshBlocker,
                reason: '${destination.label} route closed',
              );
              await AndroidAudioDisplayMode.removeLowRefreshBlocker(
                _routeTransitionRefreshBlocker,
                reason: '${destination.label} pop transition settled',
              );
            }),
          );
        });
  }

  void _onItemTapped(int index) {
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      _isSecondaryPage(index),
      reason: _isSecondaryPage(index)
          ? '${_pageDestinations[index].label.toLowerCase()}_tab_visible'
          : 'primary_tab_visible',
    );
    setState(() {
      if (_isSecondaryPage(index) && !_isSecondaryPage(_selectedIndex)) {
        _previousPageIndex = _selectedIndex;
      }
      _selectedIndex = index;
    });
  }

  bool _isSecondaryPage(int index) {
    return index == _downloadsDestinationIndex ||
        index == _settingsDestinationIndex;
  }

  void _returnToPreviousPage() {
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      false,
      reason: 'secondary_tab_closed',
    );
    setState(() {
      _selectedIndex = _isSecondaryPage(_previousPageIndex)
          ? _homeDestinationIndex
          : _previousPageIndex;
    });
  }

  void _openReadingPlansPage() {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'reading_plans_route_opening',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ReadingPlansPage(),
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            false,
            reason: 'reading_plans_route_closed',
          );
        });
  }

  void _openTasbihPage() {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'tasbih_route_opening',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const TasbihPage(),
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            false,
            reason: 'tasbih_route_closed',
          );
        });
  }

  void _openQiblaPage() {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'qibla_route_opening',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const QiblaPage(),
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            false,
            reason: 'qibla_route_closed',
          );
        });
  }

  Future<void> _toggleQuickTheme() async {
    final ThemeData theme = Theme.of(context);
    final AdaptiveThemeMode mode = AdaptiveTheme.of(context).mode;
    final bool isDark = mode.isSystem
        ? theme.brightness == Brightness.dark
        : mode.isDark;
    final AdaptiveThemeMode nextMode = isDark
        ? AdaptiveThemeMode.light
        : AdaptiveThemeMode.dark;

    await SettingsDB().put('themeMode', nextMode.isDark ? 'dark' : 'light');
    if (!mounted) return;
    AdaptiveTheme.of(context).setThemeMode(nextMode);
  }
}
