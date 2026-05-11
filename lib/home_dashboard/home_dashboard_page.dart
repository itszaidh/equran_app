import 'dart:async';

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_notification_service.dart';
import 'package:equran/prayer/prayer_settings_store.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({
    super.key,
    required this.onMenuPressed,
    required this.onOpenQuran,
    required this.onOpenPlayer,
    required this.onOpenPrayerTimes,
    required this.onOpenQibla,
    required this.onOpenDuas,
    required this.onOpenDownloads,
    required this.onOpenSearch,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onOpenQuran;
  final VoidCallback onOpenPlayer;
  final VoidCallback onOpenPrayerTimes;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenDuas;
  final VoidCallback onOpenDownloads;
  final VoidCallback onOpenSearch;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final PrayerSettingsStore _prayerStore = PrayerSettingsStore();
  final PrayerTimesService _prayerService = const PrayerTimesService();
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  PrayerExactAlarmPermissionStatus? _exactAlarmPermission;

  @override
  void initState() {
    super.initState();
    _scheduleMinuteClock();
    unawaited(_loadExactAlarmStatus());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Material(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _now = DateTime.now();
            });
            await _loadExactAlarmStatus();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildHeader(theme, colors)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: _DashboardReactiveShell(
                        now: _now,
                        exactAlarmPermission: _exactAlarmPermission,
                        prayerStore: _prayerStore,
                        prayerService: _prayerService,
                        actions: widget,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    final String greeting = _greetingFor(_now);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Menu',
            onPressed: widget.onMenuPressed,
            icon: const Icon(Icons.menu_rounded),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDashboardDate(_now),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search Quran text',
            onPressed: widget.onOpenSearch,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  void _scheduleMinuteClock() {
    _clockTimer?.cancel();
    final DateTime now = DateTime.now();
    final Duration untilNextMinute = Duration(
      minutes: 1,
      seconds: -now.second,
      milliseconds: -now.millisecond,
      microseconds: -now.microsecond,
    );
    _clockTimer = Timer(untilNextMinute, () {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
      _scheduleMinuteClock();
    });
  }

  Future<void> _loadExactAlarmStatus() async {
    final PrayerTimeSettings settings = _prayerStore.getSettings();
    if (!settings.reminderSettings.remindersEnabled) return;
    final PrayerExactAlarmPermissionStatus status =
        await PrayerNotificationService().checkExactAlarmPermission();
    if (!mounted) return;
    setState(() {
      _exactAlarmPermission = status;
    });
  }
}

class _DashboardReactiveShell extends StatelessWidget {
  const _DashboardReactiveShell({
    required this.now,
    required this.exactAlarmPermission,
    required this.prayerStore,
    required this.prayerService,
    required this.actions,
  });

  final DateTime now;
  final PrayerExactAlarmPermissionStatus? exactAlarmPermission;
  final PrayerSettingsStore prayerStore;
  final PrayerTimesService prayerService;
  final HomeDashboardPage actions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: SettingsDB().listener,
      builder: (context, settingsBox, settingsChild) {
        return ValueListenableBuilder<Box<dynamic>>(
          valueListenable: ResumeStateDB().listener,
          builder: (context, resumeBox, resumeChild) {
            return ValueListenableBuilder<Box<dynamic>>(
              valueListenable: QuranBookmarksDB().listener,
              builder: (context, bookmarksBox, bookmarksChild) {
                return ValueListenableBuilder<Box<dynamic>>(
                  valueListenable: FavouritesDB().listener,
                  builder:
                      (context, legacyFavouritesBox, legacyFavouritesChild) {
                        return ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: ReadingPlansDB().listener,
                          builder: (context, plansBox, plansChild) {
                            return ValueListenableBuilder<Box<dynamic>>(
                              valueListenable: QuranActivityDB().listener,
                              builder: (context, activityBox, activityChild) {
                                return ValueListenableBuilder<Box<dynamic>>(
                                  valueListenable: QuranStatsDB().listener,
                                  builder: (context, statsBox, statsChild) {
                                    return _DashboardContent(
                                      now: now,
                                      exactAlarmPermission:
                                          exactAlarmPermission,
                                      prayerStore: prayerStore,
                                      prayerService: prayerService,
                                      actions: actions,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.now,
    required this.exactAlarmPermission,
    required this.prayerStore,
    required this.prayerService,
    required this.actions,
  });

  final DateTime now;
  final PrayerExactAlarmPermissionStatus? exactAlarmPermission;
  final PrayerSettingsStore prayerStore;
  final PrayerTimesService prayerService;
  final HomeDashboardPage actions;

  @override
  Widget build(BuildContext context) {
    final _DashboardSummary summary = _DashboardSummary.load(
      now: now,
      prayerStore: prayerStore,
      prayerService: prayerService,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 760;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _PrayerDashboardCard(
              prayerSummary: summary.prayerSummary,
              exactAlarmPermission: exactAlarmPermission,
              onOpenPrayerTimes: actions.onOpenPrayerTimes,
            ),
            const SizedBox(height: 12),
            _ResponsiveTwoColumn(
              wide: wide,
              children: <Widget>[
                _ContinueReadingCard(entry: summary.latestReading),
                _ContinueListeningCard(
                  entry: summary.latestListening,
                  onOpenPlayer: actions.onOpenPlayer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ResponsiveTwoColumn(
              wide: wide,
              children: <Widget>[
                _DailyGoalCard(activity: summary.todayActivity),
                _ReadingPlanCard(plan: summary.activePlan),
              ],
            ),
            const SizedBox(height: 12),
            _QuickActionsCard(actions: actions),
            const SizedBox(height: 12),
            _ResponsiveTwoColumn(
              wide: wide,
              children: <Widget>[
                _DailyAyahCard(ayah: summary.dailyAyah),
                _StatsPreviewCard(
                  stats: summary.stats,
                  activity: summary.todayActivity,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _BookmarksPreviewCard(bookmarks: summary.bookmarks),
          ],
        );
      },
    );
  }
}

class _DashboardSummary {
  const _DashboardSummary({
    required this.latestReading,
    required this.latestListening,
    required this.prayerSummary,
    required this.todayActivity,
    required this.activePlan,
    required this.dailyAyah,
    required this.stats,
    required this.bookmarks,
  });

  final ResumeStateEntry? latestReading;
  final ResumeStateEntry? latestListening;
  final _PrayerSummary prayerSummary;
  final QuranActivityDay? todayActivity;
  final ReadingPlanEntry? activePlan;
  final _DailyAyah dailyAyah;
  final QuranStatsSnapshot? stats;
  final List<QuranBookmarkEntry> bookmarks;

  static _DashboardSummary load({
    required DateTime now,
    required PrayerSettingsStore prayerStore,
    required PrayerTimesService prayerService,
  }) {
    final List<ResumeStateEntry> resumeEntries = ResumeStateDB().box.values
        .whereType<ResumeStateEntry>()
        .toList(growable: false);
    final ResumeStateEntry? latestReading =
        _latestResume(resumeEntries, 'reading') ?? _legacyReadingResume();
    final ResumeStateEntry? latestListening = _latestResume(
      resumeEntries,
      'listening',
    );
    final List<ReadingPlanEntry> plans =
        ReadingPlansDB().box.values
            .whereType<ReadingPlanEntry>()
            .where((ReadingPlanEntry plan) => plan.active)
            .toList(growable: false)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final String todayKey = _dateKey(now);
    final dynamic activityValue = QuranActivityDB().get(todayKey);
    final dynamic statsValue = QuranStatsDB().get('summary');

    return _DashboardSummary(
      latestReading: latestReading,
      latestListening: latestListening,
      prayerSummary: _PrayerSummary.load(
        now: now,
        store: prayerStore,
        service: prayerService,
      ),
      todayActivity: activityValue is QuranActivityDay ? activityValue : null,
      activePlan: plans.isEmpty ? null : plans.first,
      dailyAyah: _DailyAyah.forDate(now),
      stats: statsValue is QuranStatsSnapshot ? statsValue : null,
      bookmarks: const QuranBookmarkService()
          .bookmarkEntriesWithLegacyFallback()
          .take(3)
          .toList(growable: false),
    );
  }

  static ResumeStateEntry? _latestResume(
    List<ResumeStateEntry> entries,
    String kind,
  ) {
    final List<ResumeStateEntry> filtered =
        entries
            .where((ResumeStateEntry entry) => entry.kind == kind)
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered.isEmpty ? null : filtered.first;
  }

  static ResumeStateEntry? _legacyReadingResume() {
    final List<ReadingEntry> entries =
        BookmarkDB().box.values.whereType<ReadingEntry>().toList(
          growable: false,
        )..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (entries.isEmpty) return null;
    final ReadingEntry entry = entries.first;
    return ResumeStateEntry(
      id: 'legacy-reading:${entry.surah}',
      kind: 'reading',
      surah: entry.surah,
      ayah: entry.verse,
      title: quran.getSurahName(entry.surah),
      subtitle: 'Ayah ${entry.verse}',
      updatedAt: entry.timestamp,
    );
  }
}

class _PrayerSummary {
  const _PrayerSummary({
    required this.location,
    required this.day,
    required this.nextPrayer,
  });

  final PrayerLocation? location;
  final PrayerDay? day;
  final NextPrayer? nextPrayer;

  static _PrayerSummary load({
    required DateTime now,
    required PrayerSettingsStore store,
    required PrayerTimesService service,
  }) {
    final PrayerLocation? location = store.getLocation();
    if (location == null) {
      return const _PrayerSummary(location: null, day: null, nextPrayer: null);
    }

    final PrayerTimeSettings settings = store.getSettings();
    final DateTime todayDate = service.calendarDateForInstant(
      instant: now,
      location: location,
      settings: settings,
    );
    final PrayerDay today = service.calculateDay(
      date: todayDate,
      location: location,
      settings: settings,
    );
    final PrayerDay tomorrow = service.calculateDay(
      date: DateTime(todayDate.year, todayDate.month, todayDate.day + 1),
      location: location,
      settings: settings,
    );
    return _PrayerSummary(
      location: location,
      day: today,
      nextPrayer: service.nextPrayer(day: today, tomorrow: tomorrow, now: now),
    );
  }
}

class _DailyAyah {
  const _DailyAyah({
    required this.surah,
    required this.verse,
    required this.arabic,
    required this.translation,
  });

  final int surah;
  final int verse;
  final String arabic;
  final String translation;

  static _DailyAyah forDate(DateTime date) {
    final int days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(2020)).inDays;
    final int globalAyah = (days.abs() % quran.totalVerseCount) + 1;
    final _AyahRef ref = _ayahRefFromGlobalIndex(globalAyah);
    final int translationIndex = _translationIndex();
    return _DailyAyah(
      surah: ref.surah,
      verse: ref.verse,
      arabic: quranVerseText(ref.surah, ref.verse),
      translation: quran.getVerseTranslation(
        ref.surah,
        ref.verse,
        translation: quran.Translation.values[translationIndex],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.gradient = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    final Color base = colors.surfaceContainerLow;
    final BoxDecoration decoration = BoxDecoration(
      color: base,
      gradient: gradient
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.alphaBlend(
                  colors.primary.withAlpha(gradient ? 28 : 0),
                  base,
                ),
                Color.alphaBlend(colors.tertiary.withAlpha(18), base),
                base,
              ],
            )
          : null,
      borderRadius: BorderRadius.circular(AppRadii.large),
      border: Border.all(
        color: colors.outlineVariant.withAlpha(isLight ? 150 : 115),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colors.shadow.withAlpha(isLight ? 18 : 26),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: Ink(
          decoration: decoration,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _PrayerDashboardCard extends StatelessWidget {
  const _PrayerDashboardCard({
    required this.prayerSummary,
    required this.exactAlarmPermission,
    required this.onOpenPrayerTimes,
  });

  final _PrayerSummary prayerSummary;
  final PrayerExactAlarmPermissionStatus? exactAlarmPermission;
  final VoidCallback onOpenPrayerTimes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final PrayerDay? day = prayerSummary.day;
    final NextPrayer? nextPrayer = prayerSummary.nextPrayer;

    if (day == null || nextPrayer == null) {
      return _DashboardCard(
        gradient: true,
        onTap: onOpenPrayerTimes,
        child: _EmptyCardContent(
          icon: Icons.access_time_rounded,
          title: 'Prayer times',
          message: 'Choose a location to show the next prayer here.',
          actionLabel: 'Set up',
        ),
      );
    }

    final PrayerTimeSettings settings = day.settings;
    final String methodLabel = prayerMethodDisplayLabel(
      settings: settings,
      effectiveMethod: day.effectiveMethod,
    );
    final bool exactAlarmDenied =
        exactAlarmPermission == PrayerExactAlarmPermissionStatus.denied;

    return _DashboardCard(
      gradient: true,
      onTap: onOpenPrayerTimes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _IconTile(icon: Icons.access_time_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Next prayer',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      prayerSummary.location?.displayLabel ?? 'Saved location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nextPrayer.entry.kind.label,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoPill(
                icon: Icons.hourglass_bottom_rounded,
                label: _formatCountdown(nextPrayer.countdown),
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: _formatTime(
                  nextPrayer.entry.time,
                  settings.use24HourFormat,
                ),
              ),
              _InfoPill(icon: Icons.calculate_outlined, label: methodLabel),
            ],
          ),
          const SizedBox(height: 14),
          _CompactPrayerTimes(
            day: day,
            use24HourFormat: settings.use24HourFormat,
          ),
          if (exactAlarmDenied) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Exact alarm permission is off. Prayer reminders may be delayed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.error,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.entry});

  final ResumeStateEntry? entry;

  @override
  Widget build(BuildContext context) {
    final ResumeStateEntry? current = entry;
    if (current == null || current.surah == null || current.ayah == null) {
      return const _DashboardCard(
        child: _EmptyCardContent(
          icon: Icons.menu_book_outlined,
          title: 'Continue reading',
          message: 'Your last read ayah will appear here.',
        ),
      );
    }

    return _DashboardCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ReadPage(chapter: current.surah!, startVerse: current.ayah),
        ),
      ),
      child: _ResumeCardContent(
        icon: Icons.menu_book_rounded,
        label: 'Continue reading',
        title: current.title.isEmpty
            ? quran.getSurahName(current.surah!)
            : current.title,
        subtitle: current.subtitle.isEmpty
            ? 'Ayah ${current.ayah}'
            : current.subtitle,
      ),
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({
    required this.entry,
    required this.onOpenPlayer,
  });

  final ResumeStateEntry? entry;
  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    final ResumeStateEntry? current = entry;
    if (current == null) {
      return _DashboardCard(
        onTap: onOpenPlayer,
        child: const _EmptyCardContent(
          icon: Icons.graphic_eq_rounded,
          title: 'Continue listening',
          message: 'Start a recitation and it will be resumable here.',
          actionLabel: 'Open player',
        ),
      );
    }

    return _DashboardCard(
      onTap: onOpenPlayer,
      child: _ResumeCardContent(
        icon: Icons.graphic_eq_rounded,
        label: 'Continue listening',
        title: current.title,
        subtitle: current.subtitle,
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.activity});

  final QuranActivityDay? activity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int ayahsRead = activity?.ayahsRead ?? 0;
    const int dailyGoal = 20;
    final double progress = (ayahsRead / dailyGoal).clamp(0.0, 1.0);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(
            icon: Icons.local_florist_outlined,
            label: 'Daily goal',
          ),
          const SizedBox(height: 12),
          Text(
            '$ayahsRead / $dailyGoal ayahs',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ayahsRead == 0
                ? 'Reading activity tracking is ready for today.'
                : 'May Allah bless your consistency.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingPlanCard extends StatelessWidget {
  const _ReadingPlanCard({required this.plan});

  final ReadingPlanEntry? plan;

  @override
  Widget build(BuildContext context) {
    final ReadingPlanEntry? activePlan = plan;
    if (activePlan == null) {
      return const _DashboardCard(
        child: _EmptyCardContent(
          icon: Icons.route_outlined,
          title: 'Reading plan',
          message: 'Plans for 7, 30, 60 days and Ramadan are scaffolded.',
        ),
      );
    }

    final int total = (activePlan.targetGlobalAyah - activePlan.startGlobalAyah)
        .abs()
        .clamp(1, quran.totalVerseCount)
        .toInt();
    final int done =
        (activePlan.lastCompletedGlobalAyah - activePlan.startGlobalAyah)
            .clamp(0, total)
            .toInt();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(
            icon: Icons.route_outlined,
            label: 'Reading plan',
          ),
          const SizedBox(height: 12),
          Text(
            activePlan.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text('$done / $total ayahs completed'),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.actions});

  final HomeDashboardPage actions;

  @override
  Widget build(BuildContext context) {
    final List<_QuickAction> items = <_QuickAction>[
      _QuickAction(Icons.menu_book_outlined, 'Quran', actions.onOpenQuran),
      _QuickAction(
        Icons.access_time_outlined,
        'Prayer',
        actions.onOpenPrayerTimes,
      ),
      _QuickAction(Icons.explore_outlined, 'Qibla', actions.onOpenQibla),
      _QuickAction(Icons.auto_stories_outlined, 'Duas', actions.onOpenDuas),
      _QuickAction(
        Icons.download_outlined,
        'Downloads',
        actions.onOpenDownloads,
      ),
      _QuickAction(Icons.search_rounded, 'Search', actions.onOpenSearch),
    ];

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(icon: Icons.apps_rounded, label: 'Quick actions'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 720
                  ? 6
                  : constraints.maxWidth >= 460
                  ? 3
                  : 2;
              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: columns >= 4 ? 1.05 : 1.35,
                ),
                itemBuilder: (context, index) {
                  final _QuickAction item = items[index];
                  return _QuickActionTile(item: item);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard({required this.ayah});

  final _DailyAyah ayah;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return _DashboardCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ReadPage(chapter: ayah.surah, startVerse: ayah.verse),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionLabel(
            icon: Icons.wb_sunny_outlined,
            label: '${quran.getSurahName(ayah.surah)} ${ayah.verse}',
          ),
          const SizedBox(height: 14),
          Text(
            ayah.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Hafs',
              fontSize: 28,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ayah.translation,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsPreviewCard extends StatelessWidget {
  const _StatsPreviewCard({required this.stats, required this.activity});

  final QuranStatsSnapshot? stats;
  final QuranActivityDay? activity;

  @override
  Widget build(BuildContext context) {
    final QuranStatsSnapshot snapshot =
        stats ?? QuranStatsSnapshot(id: 'summary', updatedAt: DateTime.now());
    final int today = activity?.ayahsRead ?? 0;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(
            icon: Icons.insights_outlined,
            label: 'Quran stats',
          ),
          const SizedBox(height: 14),
          _MetricRow(label: 'Today', value: '$today ayahs'),
          _MetricRow(
            label: 'Total read',
            value: '${snapshot.totalAyahsRead} ayahs',
          ),
          _MetricRow(label: 'Streak', value: '${snapshot.currentStreak} days'),
          _MetricRow(
            label: 'Estimated letters read',
            value: '${snapshot.estimatedLettersRead}',
          ),
          const SizedBox(height: 8),
          Text(
            'Reward is with Allah.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarksPreviewCard extends StatelessWidget {
  const _BookmarksPreviewCard({required this.bookmarks});

  final List<QuranBookmarkEntry> bookmarks;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const _DashboardCard(
        child: _EmptyCardContent(
          icon: Icons.bookmark_border_rounded,
          title: 'Bookmarks and notes',
          message: 'Favourites and private ayah notes will appear here.',
        ),
      );
    }

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel(
            icon: Icons.bookmark_border_rounded,
            label: 'Bookmarks and notes',
          ),
          const SizedBox(height: 10),
          for (final QuranBookmarkEntry bookmark in bookmarks)
            _BookmarkPreviewTile(bookmark: bookmark),
        ],
      ),
    );
  }
}

class _BookmarkPreviewTile extends StatelessWidget {
  const _BookmarkPreviewTile({required this.bookmark});

  final QuranBookmarkEntry bookmark;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: colors.primaryContainer,
        child: Text(
          bookmark.verse.toString(),
          style: TextStyle(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text('${quran.getSurahName(bookmark.surah)} ${bookmark.verse}'),
      subtitle: Text(
        bookmark.note.trim().isEmpty ? bookmark.folder : bookmark.note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ReadPage(chapter: bookmark.surah, startVerse: bookmark.verse),
        ),
      ),
    );
  }
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({required this.wide, required this.children});

  final bool wide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _ResumeCardContent extends StatelessWidget {
  const _ResumeCardContent({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(icon: icon, label: label),
        const SizedBox(height: 14),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyCardContent extends StatelessWidget {
  const _EmptyCardContent({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _IconTile(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  actionLabel!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withAlpha(190),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Icon(icon, color: colors.onPrimaryContainer),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withAlpha(150),
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(color: colors.outlineVariant.withAlpha(130)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CompactPrayerTimes extends StatelessWidget {
  const _CompactPrayerTimes({required this.day, required this.use24HourFormat});

  final PrayerDay day;
  final bool use24HourFormat;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: day.entries
          .map((PrayerTimeEntry entry) {
            return _InfoPill(
              icon: entry.kind == PrayerTimeKind.sunrise
                  ? Icons.wb_sunny_outlined
                  : Icons.nights_stay_outlined,
              label:
                  '${entry.kind.label} ${_formatTime(entry.time, use24HourFormat)}',
            );
          })
          .toList(growable: false),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final _QuickAction item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: colors.outlineVariant.withAlpha(110)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(item.icon, color: colors.primary),
              const SizedBox(height: 7),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AyahRef {
  const _AyahRef({required this.surah, required this.verse});

  final int surah;
  final int verse;
}

_AyahRef _ayahRefFromGlobalIndex(int globalAyah) {
  int remaining = globalAyah.clamp(1, quran.totalVerseCount).toInt();
  for (int surah = 1; surah <= 114; surah++) {
    final int verseCount = quran.getVerseCount(surah);
    if (remaining <= verseCount) {
      return _AyahRef(surah: surah, verse: remaining);
    }
    remaining -= verseCount;
  }
  return const _AyahRef(surah: 114, verse: 6);
}

int _translationIndex() {
  final dynamic saved = SettingsDB().get('translation', defaultValue: 0);
  if (saved is int && saved >= 0 && saved < quran.Translation.values.length) {
    return saved;
  }
  return 0;
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _greetingFor(DateTime now) {
  if (now.hour < 12) return 'Assalamu alaikum';
  if (now.hour < 17) return 'Peaceful afternoon';
  return 'Peaceful evening';
}

String _formatDashboardDate(DateTime now) {
  const List<String> weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}

String _formatTime(DateTime time, bool use24HourFormat) {
  if (use24HourFormat) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
}

String _formatCountdown(Duration duration) {
  final Duration normalized = duration.isNegative ? Duration.zero : duration;
  final int hours = normalized.inHours;
  final int minutes = normalized.inMinutes.remainder(60);
  if (hours <= 0) return '$minutes min';
  return '${hours}h ${minutes}m';
}
