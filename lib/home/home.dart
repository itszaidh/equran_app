import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:equran/backend/library.dart'
    show AndroidAudioDisplayMode, SettingsDB;
import 'package:equran/duas/duas_page.dart';
import 'package:equran/duas/tasbih_page.dart';
import 'package:equran/home/downloads.dart';
import 'package:equran/home/main_page.dart';
import 'package:equran/home/more_page.dart';
import 'package:equran/home/player.dart';
import 'package:equran/home/quran_stats_page.dart';
import 'package:equran/home/settings.dart';
import 'package:equran/home_dashboard/home_dashboard_page.dart';
import 'package:equran/prayer/prayer_times_page.dart';
import 'package:equran/prayer/qibla_page.dart';
import 'package:equran/reading_plans/reading_plans_page.dart';
import 'package:equran/services/frame_rate_policy_manager.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:flutter/material.dart';

const int _homeDestinationIndex = 0;
const int _quranDestinationIndex = 1;
const int _prayerDestinationIndex = 2;
const int _duasDestinationIndex = 3;
const int _moreDestinationIndex = 4;
const List<int> _bottomDestinationIndices = <int>[
  _homeDestinationIndex,
  _quranDestinationIndex,
  _prayerDestinationIndex,
  _duasDestinationIndex,
  _moreDestinationIndex,
];
const String _homePointerRefreshBlocker = 'home.userPointerActive';
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
          onOpenMore: () => _onItemTapped(_moreDestinationIndex),
          onOpenQuran: () => _onItemTapped(_quranDestinationIndex),
          onOpenPlayer: _openPlayerPage,
          onOpenPrayerTimes: () => _onItemTapped(_prayerDestinationIndex),
          onOpenQibla: _openQiblaPage,
          onOpenDuas: () => _onItemTapped(_duasDestinationIndex),
          onOpenTasbih: _openTasbihPage,
          onOpenReadingPlans: _openReadingPlansPage,
          onOpenDownloads: _openDownloadsPage,
          onOpenSearch: _openQuranTextSearch,
          onOpenStats: _openQuranStatsPage,
        ),
      ),
      Destinations(
        'Quran',
        const Icon(Icons.menu_book_outlined),
        const Icon(Icons.menu_book_rounded),
        MainPage(searchRequestListenable: _quranSearchRequest),
      ),
      Destinations(
        'Prayer',
        const Icon(Icons.access_time_outlined),
        const Icon(Icons.schedule_rounded),
        const PrayerTimesPage(),
      ),
      Destinations(
        'Duas',
        const Icon(Icons.auto_stories_outlined),
        const Icon(Icons.auto_stories_rounded),
        DuasPage(),
      ),
      Destinations(
        'More',
        const Icon(Icons.grid_view_outlined),
        const Icon(Icons.grid_view_rounded),
        MorePage(
          onOpenPlayer: _openPlayerPage,
          onOpenQibla: _openQiblaPage,
          onOpenDownloads: _openDownloadsPage,
          onOpenSearch: _openQuranTextSearch,
          onOpenReadingPlans: _openReadingPlansPage,
          onOpenTasbih: _openTasbihPage,
          onOpenSettings: _openSettingsPage,
          onOpenStats: _openQuranStatsPage,
          onToggleTheme: () => unawaited(_toggleQuickTheme()),
        ),
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
    final double navIconSize = ResponsiveNav.iconSize(context);
    final EquranColors equranColors = context.equranColors;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleGlobalPointerDown(),
      onPointerUp: (_) => _handleGlobalPointerReleased(),
      onPointerCancel: (_) => _handleGlobalPointerReleased(),
      onPointerSignal: (_) => AndroidAudioDisplayMode.notifyUserActivity(),
      child: Scaffold(
        appBar:
            (_selectedIndex == _prayerDestinationIndex ||
                _selectedIndex == _duasDestinationIndex ||
                _selectedIndex == _moreDestinationIndex)
            ? AppBar(
                toolbarHeight: ResponsiveNav.toolbarHeight(context),
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
        bottomNavigationBar: _buildBottomNavigation(),
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

  void _openQuranTextSearch() {
    _onItemTapped(_quranDestinationIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quranSearchRequest.value = QuranSearchRequest(
        mode: QuranSearchMode.quranText,
        nonce: DateTime.now().microsecondsSinceEpoch,
      );
    });
  }

  void _pushSecondaryPage({
    required String label,
    required Widget page,
    required String reason,
    bool showAppBar = true,
  }) {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: '${reason}_opening',
    );
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      true,
      reason: '${reason}_route',
    );
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _routeTransitionRefreshBlocker,
        reason: 'opening $label',
      ),
    );
    unawaited(
      AndroidAudioDisplayMode.addLowRefreshBlocker(
        _secondaryRouteRefreshBlocker,
        reason: '$label route active',
      ),
    );
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        FrameRatePolicyManager.instance.setRouteTransitionActive(
          false,
          reason: '${reason}_push_settled',
        );
        return AndroidAudioDisplayMode.removeLowRefreshBlocker(
          _routeTransitionRefreshBlocker,
          reason: '$label push transition settled',
        );
      }),
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Scaffold(
                appBar: showAppBar
                    ? AppBar(
                        toolbarHeight: ResponsiveNav.toolbarHeight(context),
                        title: Text(label),
                        centerTitle: true,
                        iconTheme: IconThemeData(
                          size: ResponsiveNav.iconSize(context),
                        ),
                      )
                    : null,
                body: page,
              );
            },
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            true,
            reason: '${reason}_pop_transition',
          );
          unawaited(
            AndroidAudioDisplayMode.addLowRefreshBlocker(
              _routeTransitionRefreshBlocker,
              reason: '$label pop transition',
            ),
          );
          unawaited(
            Future<void>.delayed(const Duration(milliseconds: 450), () async {
              FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
                false,
                reason: '${reason}_route_closed',
              );
              FrameRatePolicyManager.instance.setRouteTransitionActive(
                false,
                reason: '${reason}_pop_settled',
              );
              await AndroidAudioDisplayMode.removeLowRefreshBlocker(
                _secondaryRouteRefreshBlocker,
                reason: '$label route closed',
              );
              await AndroidAudioDisplayMode.removeLowRefreshBlocker(
                _routeTransitionRefreshBlocker,
                reason: '$label pop transition settled',
              );
            }),
          );
        });
  }

  void _onItemTapped(int index) {
    FrameRatePolicyManager.instance.setSettingsOrDownloadsVisible(
      false,
      reason: 'primary_tab_visible',
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openPlayerPage() {
    _pushSecondaryPage(
      label: 'Player',
      page: const PlayerPage(),
      reason: 'player_route',
      showAppBar: false,
    );
  }

  void _openDownloadsPage() {
    _pushSecondaryPage(
      label: 'Downloads',
      page: const DownloadsPage(),
      reason: 'downloads_route',
    );
  }

  void _openSettingsPage() {
    _pushSecondaryPage(
      label: 'Settings',
      page: const SettingsPage(),
      reason: 'settings_route',
    );
  }

  void _openQuranStatsPage() {
    _pushSecondaryPage(
      label: 'Quran Stats',
      page: const QuranStatsPage(),
      reason: 'quran_stats_route',
    );
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
