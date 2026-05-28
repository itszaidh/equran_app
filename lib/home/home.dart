import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:equran/backend/library.dart'
    show AndroidAudioDisplayMode, SettingsDB;
import 'package:equran/duas/asma_ul_husna_page.dart';
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
import 'package:equran/prayer/prayer_times_settings_page.dart';
import 'package:equran/prayer/qibla_page.dart';
import 'package:equran/reading_plans/reading_plans_page.dart';
import 'package:equran/services/frame_rate_policy_manager.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:flutter/material.dart';
import 'package:equran/l10n/app_localizations.dart';

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

  List<Destinations> _getDestinations(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return <Destinations>[
      Destinations(
        localizations.home,
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
          onOpenStats: _openStatisticsPage,
        ),
      ),
      Destinations(
        localizations.quran,
        const Icon(Icons.menu_book_outlined),
        const Icon(Icons.menu_book_rounded),
        MainPage(searchRequestListenable: _quranSearchRequest),
      ),
      Destinations(
        localizations.prayer,
        const Icon(Icons.access_time_outlined),
        const Icon(Icons.schedule_rounded),
        const PrayerTimesPage(),
      ),
      Destinations(
        localizations.duas,
        const Icon(Icons.auto_stories_outlined),
        const Icon(Icons.auto_stories_rounded),
        DuasPage(),
      ),
      Destinations(
        localizations.more,
        const Icon(Icons.grid_view_outlined),
        const Icon(Icons.grid_view_rounded),
        MorePage(
          onOpenPlayer: _openPlayerPage,
          onOpenQibla: _openQiblaPage,
          onOpenDownloads: _openDownloadsPage,
          onOpenSearch: _openQuranTextSearch,
          onOpenReadingPlans: _openReadingPlansPage,
          onOpenTasbih: _openTasbihPage,
          onOpenAsmaUlHusna: _openAsmaUlHusnaPage,
          onOpenSettings: _openSettingsPage,
          onOpenStats: _openStatisticsPage,
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
    final List<Destinations> destinations = _getDestinations(context);

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
                title: Text(destinations[_selectedIndex].label),
                centerTitle: true,
                backgroundColor: _selectedIndex == _prayerDestinationIndex
                    ? Colors.transparent
                    : equranColors.background,
                foregroundColor: equranColors.textPrimary,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                titleTextStyle: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(
                      color: equranColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                iconTheme: IconThemeData(
                  color: equranColors.textSecondary,
                  size: navIconSize,
                ),
                actionsIconTheme: IconThemeData(
                  color: equranColors.textSecondary,
                  size: navIconSize,
                ),
                actions: <Widget>[
                  if (destinations[_selectedIndex].destination
                      is PrayerTimesPage) ...<Widget>[
                    IconButton(
                      tooltip: AppLocalizations.of(
                        context,
                      )!.prayerTimesSettings,
                      onPressed: _openPrayerSettingsPage,
                      icon: const Icon(Icons.settings_outlined),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: IconButton(
                        tooltip: AppLocalizations.of(context)!.qibla,
                        onPressed: _openQiblaPage,
                        icon: const Icon(Icons.explore_outlined),
                      ),
                    ),
                  ],
                ],
              )
            : null,
        body: destinations[_selectedIndex].destination,
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final EquranColors colors = context.equranColors;
    final localizations = AppLocalizations.of(context)!;
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
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: localizations.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: localizations.quran,
            ),
            NavigationDestination(
              icon: const Icon(Icons.schedule_outlined),
              selectedIcon: const Icon(Icons.schedule_rounded),
              label: localizations.prayer,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: localizations.duas,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: localizations.more,
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
              final EquranColors colors = context.equranColors;
              return Scaffold(
                appBar: showAppBar
                    ? AppBar(
                        toolbarHeight: ResponsiveNav.toolbarHeight(context),
                        title: Text(label),
                        centerTitle: true,
                        backgroundColor: colors.background,
                        foregroundColor: colors.textPrimary,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        surfaceTintColor: Colors.transparent,
                        titleTextStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                        iconTheme: IconThemeData(
                          color: colors.textSecondary,
                          size: ResponsiveNav.iconSize(context),
                        ),
                        actionsIconTheme: IconThemeData(
                          color: colors.textSecondary,
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
    final localizations = AppLocalizations.of(context)!;
    _pushSecondaryPage(
      label: localizations.player,
      page: const PlayerPage(),
      reason: 'player_route',
      showAppBar: false,
    );
  }

  void _openDownloadsPage() {
    final localizations = AppLocalizations.of(context)!;
    _pushSecondaryPage(
      label: localizations.downloads,
      page: const DownloadsPage(),
      reason: 'downloads_route',
    );
  }

  void _openSettingsPage() {
    final localizations = AppLocalizations.of(context)!;
    _pushSecondaryPage(
      label: localizations.settings,
      page: const SettingsPage(),
      reason: 'settings_route',
    );
  }

  void _openStatisticsPage() {
    final localizations = AppLocalizations.of(context)!;
    _pushSecondaryPage(
      label: localizations.statistics,
      page: const StatisticsPage(),
      reason: 'statistics_route',
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

  void _openAsmaUlHusnaPage() {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'asma_ul_husna_route_opening',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const AsmaUlHusnaPage(),
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            false,
            reason: 'asma_ul_husna_route_closed',
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

  void _openPrayerSettingsPage() {
    FrameRatePolicyManager.instance.setRouteTransitionActive(
      true,
      reason: 'prayer_settings_route_opening',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PrayerTimesSettingsPage(),
          ),
        )
        .whenComplete(() {
          FrameRatePolicyManager.instance.setRouteTransitionActive(
            false,
            reason: 'prayer_settings_route_closed',
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
