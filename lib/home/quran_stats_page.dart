import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

const int _totalSurahs = 114;
const int _surahGridColumns = 6;
const int _surahCellAnimationMs = 300;
const int _surahCellStaggerMs = 8;
const int _surahGridAnimationMs =
    _surahCellAnimationMs + ((_totalSurahs - 1) * _surahCellStaggerMs);

final Map<String, int> _letterCountCache = <String, int>{};

enum StatRange {
  week('Week'),
  month('Month'),
  year('Year'),
  allTime('All time');

  const StatRange(this.label);

  final String label;
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late final StatisticsRepository _repository;
  late final ValueNotifier<StatRange> _rangeNotifier;
  late final ValueNotifier<int> _refreshNotifier;
  late final ScrollController _scrollController;
  late final AnimationController _surahGridController;
  late final ValueListenable<Box<dynamic>> _quranListener;
  late final ValueListenable<Box<dynamic>> _dhikrListener;
  late final ValueListenable<Box<dynamic>> _duasListener;
  late final ValueListenable<Box<dynamic>> _favouritesListener;
  late final ValueListenable<Box<dynamic>> _settingsListener;
  final GlobalKey _surahProgressKey = GlobalKey();
  bool _surahGridExpanded = false;

  @override
  void initState() {
    super.initState();
    _repository = StatisticsRepository();
    _rangeNotifier = ValueNotifier<StatRange>(StatRange.week);
    _refreshNotifier = ValueNotifier<int>(0);
    _scrollController = ScrollController();
    _surahGridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _surahGridAnimationMs),
    )..forward();
    _quranListener = QuranActivityDB().listener;
    _dhikrListener = DhikrSessionsDB().listener;
    _duasListener = DuaInteractionsDB().listener;
    _favouritesListener = DuaFavouritesDB().listener;
    _settingsListener = SettingsDB().listener;
    for (final ValueListenable<Box<dynamic>> listener
        in <ValueListenable<Box<dynamic>>>[
          _quranListener,
          _dhikrListener,
          _duasListener,
          _favouritesListener,
          _settingsListener,
        ]) {
      listener.addListener(_handleDataChanged);
    }
  }

  @override
  void dispose() {
    for (final ValueListenable<Box<dynamic>> listener
        in <ValueListenable<Box<dynamic>>>[
          _quranListener,
          _dhikrListener,
          _duasListener,
          _favouritesListener,
          _settingsListener,
        ]) {
      listener.removeListener(_handleDataChanged);
    }
    _surahGridExpanded = false;
    _scrollController.dispose();
    _surahGridController.dispose();
    _rangeNotifier.dispose();
    _refreshNotifier.dispose();
    super.dispose();
  }

  void _handleDataChanged() {
    _repository.clearCache();
    _refreshNotifier.value++;
  }

  void _openSurah(int surah) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReadPage(chapter: surah, startVerse: 1),
      ),
    );
  }

  void _toggleSurahGridExpanded() {
    final bool nextExpanded = !_surahGridExpanded;
    final double? targetOffset = nextExpanded
        ? null
        : _surahProgressScrollOffset();
    setState(() {
      _surahGridExpanded = nextExpanded;
    });
    if (nextExpanded || targetOffset == null || !_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  double? _surahProgressScrollOffset() {
    final BuildContext? sectionContext = _surahProgressKey.currentContext;
    final RenderObject? sectionObject = sectionContext?.findRenderObject();
    final RenderObject? pageObject = context.findRenderObject();
    if (sectionObject is! RenderBox || pageObject is! RenderBox) return null;

    final double sectionTop = sectionObject.localToGlobal(Offset.zero).dy;
    final double pageTop = pageObject.localToGlobal(Offset.zero).dy;
    final double target = _scrollController.offset + sectionTop - pageTop - 36;
    final ScrollPosition position = _scrollController.position;
    return target.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        top: true,
        bottom: true,
        child: ValueListenableBuilder<int>(
          valueListenable: _refreshNotifier,
          builder: (context, refreshToken, _) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                _PageContentSliver(
                  topPadding: 16,
                  child: _DataSection<OverviewStats>(
                    refreshToken: refreshToken,
                    load: () => _repository.overview(),
                    placeholderHeight: 170,
                    builder: (context, data) => _OverviewHeaderCard(data: data),
                  ),
                ),
                _PageContentSliver(
                  child: _DataSection<StreakStats>(
                    refreshToken: refreshToken,
                    load: () => _repository.streaks(),
                    placeholderHeight: 64,
                    builder: (context, data) => data.highest <= 0
                        ? const SizedBox.shrink()
                        : _StreakBanner(streak: data.highest),
                  ),
                ),
                _PageContentSliver(
                  child: _RangeToggle(rangeListenable: _rangeNotifier),
                ),
                const _StickySectionHeader(label: 'Quran'),
                _PageContentSliver(
                  child: _RangeAwareSection<QuranStatsData>(
                    refreshToken: refreshToken,
                    rangeListenable: _rangeNotifier,
                    load: _repository.quranStats,
                    placeholderHeight: 680,
                    builder: (context, data) => _QuranSection(
                      data: data,
                      surahProgressKey: _surahProgressKey,
                      surahGridExpanded: _surahGridExpanded,
                      animationController: _surahGridController,
                      onOpenSurah: _openSurah,
                      onToggleSurahGrid: _toggleSurahGridExpanded,
                    ),
                  ),
                ),
                const _StickySectionHeader(label: 'Tasbih'),
                _PageContentSliver(
                  child: _RangeAwareSection<TasbihStatsData>(
                    refreshToken: refreshToken,
                    rangeListenable: _rangeNotifier,
                    load: _repository.tasbih,
                    placeholderHeight: 260,
                    builder: (context, data) => _TasbihSection(data: data),
                  ),
                ),
                const _StickySectionHeader(label: 'Duas'),
                _PageContentSliver(
                  child: _RangeAwareSection<DuasStatsData>(
                    refreshToken: refreshToken,
                    rangeListenable: _rangeNotifier,
                    load: _repository.duas,
                    placeholderHeight: 220,
                    builder: (context, data) => _DuasSection(data: data),
                  ),
                ),
                const _StickySectionHeader(label: 'Activity History'),
                _PageContentSliver(
                  child: _RangeAwareSection<HeatmapData>(
                    refreshToken: refreshToken,
                    rangeListenable: _rangeNotifier,
                    load: _repository.heatmap,
                    placeholderHeight: 150,
                    builder: (context, data) =>
                        _YearlyHeatmapSection(data: data),
                  ),
                ),
                const _StickySectionHeader(label: 'Streaks'),
                _PageContentSliver(
                  bottomPadding: 32,
                  child: _DataSection<StreakStats>(
                    refreshToken: refreshToken,
                    load: () => _repository.streaks(),
                    placeholderHeight: 150,
                    builder: (context, data) =>
                        _WorshipStreakSection(data: data),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StatisticsRepository {
  final Map<StatRange, Future<OverviewStats>> _overviewCache =
      <StatRange, Future<OverviewStats>>{};
  final Map<StatRange, Future<QuranStatsData>> _quranCache =
      <StatRange, Future<QuranStatsData>>{};
  final Map<StatRange, Future<TasbihStatsData>> _tasbihCache =
      <StatRange, Future<TasbihStatsData>>{};
  final Map<StatRange, Future<DuasStatsData>> _duasCache =
      <StatRange, Future<DuasStatsData>>{};
  final Map<StatRange, Future<HeatmapData>> _heatmapCache =
      <StatRange, Future<HeatmapData>>{};
  final Map<StatRange, Future<StreakStats>> _streakCache =
      <StatRange, Future<StreakStats>>{};

  void clearCache() {
    _overviewCache.clear();
    _quranCache.clear();
    _tasbihCache.clear();
    _duasCache.clear();
    _heatmapCache.clear();
    _streakCache.clear();
  }

  Future<OverviewStats> overview() {
    return _overviewCache.putIfAbsent(StatRange.allTime, () async {
      final DateTime now = DateTime.now();
      final String todayKey = _dateKey(now);
      final Map<String, QuranActivityDay> quranDays = _quranDaysByDate();
      final List<DhikrSessionEntry> sessions = _dhikrSessions();
      final List<DuaInteractionEntry> duaViews = _duaInteractions();
      final int quranAyahs = _dayAyahCount(quranDays[todayKey]);
      final int tasbihCount = sessions
          .where((entry) => _dateKey(_dhikrDate(entry)) == todayKey)
          .fold<int>(0, (sum, entry) => sum + entry.count);
      final int duasViewed = duaViews
          .where((entry) => entry.dateKey == todayKey)
          .fold<int>(0, (sum, entry) => sum + entry.count);
      final int dailyGoal = _dailyGoal();
      final double progress =
          ((quranAyahs / dailyGoal).clamp(0.0, 1.0) +
              (tasbihCount / 100).clamp(0.0, 1.0) +
              (duasViewed > 0 ? 1.0 : 0.0)) /
          3;
      final StreakStats streakStats = _buildStreaks(
        quranDays.values.toList(growable: false),
        sessions,
        duaViews,
        now,
      );
      return OverviewStats(
        quranAyahs: quranAyahs,
        tasbihCount: tasbihCount,
        duasViewed: duasViewed,
        progress: progress,
        motivation: _worshipMotivation(progress),
        highestStreak: streakStats.highest,
      );
    });
  }

  Future<QuranStatsData> quranStats(StatRange range) {
    return _quranCache.putIfAbsent(range, () async {
      final DateTime now = DateTime.now();
      final List<QuranActivityDay> activityDays = _quranDays();
      final Map<String, QuranActivityDay> byDate = <String, QuranActivityDay>{
        for (final QuranActivityDay day in activityDays) day.dateKey: day,
      };
      final int totalAyahs = activityDays.fold<int>(
        0,
        (sum, day) => sum + _dayAyahCount(day),
      );
      final int totalLetters = _estimatedLettersRead(activityDays);
      final Map<int, int> surahCounts = _surahCounts(activityDays);
      final MapEntry<int, int>? mostRead = surahCounts.entries.isEmpty
          ? null
          : surahCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final int? mostActiveWeekday = _mostActiveWeekday(
        activityDays
            .map(
              (day) => ActivityDayCount(
                date: _activityDayDate(day),
                count: _dayAyahCount(day),
              ),
            )
            .toList(growable: false),
      );
      final Map<int, Set<int>> ayahsBySurah = _readAyahsBySurah(activityDays);
      final Map<int, int> surahVisitCounts = _surahVisitCounts(activityDays);
      return QuranStatsData(
        buckets: _quranBuckets(range, byDate, now),
        totalAyahs: totalAyahs,
        totalLetters: totalLetters,
        activeDays: activityDays.where(_hasReadingActivity).length,
        mostActiveDayName: mostActiveWeekday == null
            ? 'No day yet'
            : _weekdayName(mostActiveWeekday),
        mostReadSurahName: mostRead == null
            ? 'No surah yet'
            : quran.getSurahName(mostRead.key),
        mostReadSurahAyahs: mostRead?.value ?? 0,
        insights: _buildInsights(
          activityDays: activityDays,
          activityByDate: byDate,
          now: now,
          surahVisitCounts: surahVisitCounts,
        ),
        completedSurahs: _completedSurahs(ayahsBySurah),
        khatmCompletionDates: _khatmCompletionDates(activityDays),
      );
    });
  }

  Future<TasbihStatsData> tasbih(StatRange range) {
    return _tasbihCache.putIfAbsent(range, () async {
      final DateTime now = DateTime.now();
      final List<DhikrSessionEntry> sessions = _dhikrSessions()
          .where((entry) => _inRange(_dhikrDate(entry), range, now))
          .toList(growable: false);
      final int total = sessions.fold<int>(
        0,
        (sum, entry) => sum + entry.count,
      );
      final Set<String> activeDays = sessions
          .where((entry) => entry.count > 0)
          .map((entry) => _dateKey(_dhikrDate(entry)))
          .toSet();
      final Map<String, int> labelCounts = <String, int>{};
      for (final DhikrSessionEntry session in sessions) {
        final String label = session.label.trim().isEmpty
            ? 'Dhikr'
            : session.label.trim();
        labelCounts[label] = (labelCounts[label] ?? 0) + session.count;
      }
      final MapEntry<String, int>? mostRecited = labelCounts.entries.isEmpty
          ? null
          : labelCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      return TasbihStatsData(
        hasData: sessions.isNotEmpty,
        totalDhikr: total,
        dailyAverage: activeDays.isEmpty ? 0 : total / activeDays.length,
        activeDays: activeDays.length,
        mostRecitedName: mostRecited?.key ?? 'No dhikr yet',
        mostRecitedCount: mostRecited?.value ?? 0,
      );
    });
  }

  Future<DuasStatsData> duas(StatRange range) {
    return _duasCache.putIfAbsent(range, () async {
      final DateTime now = DateTime.now();
      final List<DuaInteractionEntry> interactions = _duaInteractions()
          .where((entry) => _inRange(entry.date, range, now))
          .toList(growable: false);
      final int viewed = interactions.fold<int>(
        0,
        (sum, entry) => sum + entry.count,
      );
      final Map<String, _DuaCategoryCount> categoryCounts =
          <String, _DuaCategoryCount>{};
      for (final DuaInteractionEntry interaction in interactions) {
        final _DuaCategoryCount existing =
            categoryCounts[interaction.categoryId] ??
            _DuaCategoryCount(title: interaction.categoryTitle, count: 0);
        categoryCounts[interaction.categoryId] = _DuaCategoryCount(
          title: existing.title,
          count: existing.count + interaction.count,
        );
      }
      final _DuaCategoryCount? mostViewed = categoryCounts.values.isEmpty
          ? null
          : categoryCounts.values.reduce((a, b) => a.count >= b.count ? a : b);
      final int favourites = DuaFavouritesDB().length;
      return DuasStatsData(
        hasData: viewed > 0 || favourites > 0,
        viewedCount: viewed,
        favouriteCount: favourites,
        mostViewedCategory: mostViewed?.title ?? 'No category yet',
        mostViewedCategoryCount: mostViewed?.count ?? 0,
      );
    });
  }

  Future<HeatmapData> heatmap(StatRange range) {
    return _heatmapCache.putIfAbsent(range, () async {
      final DateTime now = DateTime.now();
      final DateTime currentWeekStart = _weekStart(now);
      final DateTime firstWeekStart = currentWeekStart.subtract(
        const Duration(days: 52 * 7),
      );
      final Map<String, QuranActivityDay> quranDays = _quranDaysByDate();
      final Map<String, int> tasbihByDate = _tasbihCountsByDate(
        _dhikrSessions(),
      );
      final Map<String, int> duasByDate = _duaCountsByDate(_duaInteractions());
      final List<HeatmapWeek> weeks = <HeatmapWeek>[];
      for (int week = 0; week < 53; week++) {
        final DateTime weekStart = firstWeekStart.add(Duration(days: week * 7));
        weeks.add(
          HeatmapWeek(
            start: weekStart,
            days: <HeatmapDay>[
              for (int offset = 0; offset < 7; offset++)
                _heatmapDay(
                  weekStart.add(Duration(days: offset)),
                  quranDays,
                  tasbihByDate,
                  duasByDate,
                ),
            ],
          ),
        );
      }
      return HeatmapData(weeks: weeks);
    });
  }

  Future<StreakStats> streaks() {
    return _streakCache.putIfAbsent(StatRange.allTime, () async {
      return _buildStreaks(
        _quranDays(),
        _dhikrSessions(),
        _duaInteractions(),
        DateTime.now(),
      );
    });
  }

  List<QuranActivityDay> _quranDays() {
    return QuranActivityDB().box.values.whereType<QuranActivityDay>().toList(
      growable: false,
    );
  }

  Map<String, QuranActivityDay> _quranDaysByDate() {
    return <String, QuranActivityDay>{
      for (final QuranActivityDay day in _quranDays()) day.dateKey: day,
    };
  }

  List<DhikrSessionEntry> _dhikrSessions() {
    return DhikrSessionsDB().box.values.whereType<DhikrSessionEntry>().toList(
      growable: false,
    );
  }

  List<DuaInteractionEntry> _duaInteractions() {
    return DuaInteractionsDB().box.values
        .map(DuaInteractionEntry.fromStored)
        .whereType<DuaInteractionEntry>()
        .toList(growable: false);
  }
}

class _PageContentSliver extends StatelessWidget {
  const _PageContentSliver({
    required this.child,
    this.topPadding = 0,
    this.bottomPadding = 24,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        EquranSpacing.pagePadding,
        topPadding,
        EquranSpacing.pagePadding,
        bottomPadding,
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StickySectionHeader extends StatelessWidget {
  const _StickySectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SectionHeaderDelegate(label: label),
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SectionHeaderDelegate({required this.label});

  final String label;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final EquranColors colors = context.equranColors;
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: EquranSpacing.pagePadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _SectionLabel(label),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return label != oldDelegate.label;
  }
}

class _DataSection<T> extends StatefulWidget {
  const _DataSection({
    required this.refreshToken,
    required this.load,
    required this.builder,
    required this.placeholderHeight,
  });

  final int refreshToken;
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final double placeholderHeight;

  @override
  State<_DataSection<T>> createState() => _DataSectionState<T>();
}

class _DataSectionState<T> extends State<_DataSection<T>> {
  T? _data;
  Future<T>? _pending;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _DataSection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.load != widget.load) {
      _load();
    }
  }

  void _load() {
    final Future<T> pending = widget.load();
    _pending = pending;
    setState(() => _loading = true);
    pending.then(
      (T value) {
        if (!mounted || _pending != pending) return;
        setState(() {
          _data = value;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted || _pending != pending) return;
        setState(() => _loading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final T? data = _data;
    if (data == null) {
      return _ShimmerPlaceholder(height: widget.placeholderHeight);
    }
    return _LoadingOverlay(
      loading: _loading,
      child: widget.builder(context, data),
    );
  }
}

class _RangeAwareSection<T> extends StatefulWidget {
  const _RangeAwareSection({
    required this.refreshToken,
    required this.rangeListenable,
    required this.load,
    required this.builder,
    required this.placeholderHeight,
  });

  final int refreshToken;
  final ValueNotifier<StatRange> rangeListenable;
  final Future<T> Function(StatRange range) load;
  final Widget Function(BuildContext context, T data) builder;
  final double placeholderHeight;

  @override
  State<_RangeAwareSection<T>> createState() => _RangeAwareSectionState<T>();
}

class _RangeAwareSectionState<T> extends State<_RangeAwareSection<T>> {
  T? _data;
  Future<T>? _pending;
  late StatRange _range;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _range = widget.rangeListenable.value;
    widget.rangeListenable.addListener(_handleRangeChanged);
    _load(_range);
  }

  @override
  void didUpdateWidget(covariant _RangeAwareSection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rangeListenable != widget.rangeListenable) {
      oldWidget.rangeListenable.removeListener(_handleRangeChanged);
      widget.rangeListenable.addListener(_handleRangeChanged);
      _range = widget.rangeListenable.value;
      _load(_range);
      return;
    }
    if (oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.load != widget.load) {
      _load(_range);
    }
  }

  @override
  void dispose() {
    widget.rangeListenable.removeListener(_handleRangeChanged);
    super.dispose();
  }

  void _handleRangeChanged() {
    _range = widget.rangeListenable.value;
    _load(_range);
  }

  void _load(StatRange range) {
    final Future<T> pending = widget.load(range);
    _pending = pending;
    setState(() => _loading = true);
    pending.then(
      (T value) {
        if (!mounted || _pending != pending) return;
        setState(() {
          _data = value;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted || _pending != pending) return;
        setState(() => _loading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final T? data = _data;
    if (data == null) {
      return _ShimmerPlaceholder(height: widget.placeholderHeight);
    }
    return _LoadingOverlay(
      loading: _loading,
      child: widget.builder(context, data),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.loading, required this.child});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;
    final EquranColors colors = context.equranColors;
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: colors.background.withAlpha(128),
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewHeaderCard extends StatelessWidget {
  const _OverviewHeaderCard({required this.data});

  final OverviewStats data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.xl);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colors.primaryGradientStart,
              colors.primaryGradientEnd,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -40,
              right: -32,
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: colors.onPrimary,
                  opacity: 0.05,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(EquranSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "Today's Worship",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _OverviewPill(label: 'Quran: ${data.quranAyahs} ayahs'),
                      _OverviewPill(label: 'Tasbih: ${data.tasbihCount} dhikr'),
                      _OverviewPill(label: 'Duas: ${data.duasViewed} duas'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _AnimatedWorshipProgress(progress: data.progress),
                  const SizedBox(height: 8),
                  Text(
                    data.motivation,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryMuted,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  const _OverviewPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.onPrimary.withAlpha(38),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AnimatedWorshipProgress extends StatelessWidget {
  const _AnimatedWorshipProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: 6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.onPrimary.withAlpha(51),
            borderRadius: radius,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(widthFactor: value, child: child),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.onPrimary,
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.rangeListenable});

  final ValueNotifier<StatRange> rangeListenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StatRange>(
      valueListenable: rangeListenable,
      builder: (context, selected, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: <Widget>[
              for (final StatRange range in StatRange.values) ...<Widget>[
                if (range != StatRange.values.first) const SizedBox(width: 8),
                _RangePill(
                  range: range,
                  selected: range == selected,
                  onTap: () => rangeListenable.value = range,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.range,
    required this.selected,
    required this.onTap,
  });

  final StatRange range;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return Material(
      color: selected ? colors.primary : colors.surfaceAlt,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            range.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuranSection extends StatelessWidget {
  const _QuranSection({
    required this.data,
    required this.surahProgressKey,
    required this.surahGridExpanded,
    required this.animationController,
    required this.onOpenSurah,
    required this.onToggleSurahGrid,
  });

  final QuranStatsData data;
  final GlobalKey surahProgressKey;
  final bool surahGridExpanded;
  final AnimationController animationController;
  final ValueChanged<int> onOpenSurah;
  final VoidCallback onToggleSurahGrid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ActivityCard(buckets: data.buckets),
        const SizedBox(height: 20),
        _LifetimeTotalsGrid(data: data),
        const SizedBox(height: 20),
        _InsightsRow(insights: data.insights),
        const SizedBox(height: 20),
        _SurahProgressSection(
          sectionKey: surahProgressKey,
          completedSurahs: data.completedSurahs,
          expanded: surahGridExpanded,
          animationController: animationController,
          onOpenSurah: onOpenSurah,
          onToggleExpanded: onToggleSurahGrid,
        ),
        const SizedBox(height: 20),
        _KhatmTrackerSection(completionDates: data.khatmCompletionDates),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.buckets});

  final List<ActivityBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    final int maxAyahs = buckets.fold<int>(
      1,
      (max, bucket) => math.max(max, bucket.count),
    );
    final Color activeBarFill = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SectionLabel('Quran activity'),
            const SizedBox(height: 16),
            SizedBox(
              height: 188,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (final ActivityBucket bucket in buckets)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                message:
                                    '${bucket.detailLabel}\n${bucket.count} ayahs',
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: bucket.count <= 0
                                      ? SizedBox(
                                          height: 6,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: colors.surfaceAlt,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadii.pill,
                                                  ),
                                            ),
                                            child: const SizedBox.expand(),
                                          ),
                                        )
                                      : FractionallySizedBox(
                                          heightFactor:
                                              (bucket.count / maxAyahs)
                                                  .clamp(0.08, 1.0)
                                                  .toDouble(),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: activeBarFill,
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: <Color>[
                                                  colors.primaryGradientStart,
                                                  colors.primaryGradientEnd,
                                                ],
                                              ),
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(
                                                      AppRadii.pill,
                                                    ),
                                                  ),
                                            ),
                                            child: const SizedBox.expand(),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bucket.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifetimeTotalsGrid extends StatelessWidget {
  const _LifetimeTotalsGrid({required this.data});

  final QuranStatsData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = constraints.maxWidth >= 720 ? 12 : 10;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    icon: Icons.done_all_rounded,
                    value: '${data.totalAyahs}',
                    label: 'Total ayahs',
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: _StatCard(
                    icon: Icons.text_fields_rounded,
                    value: _compactNumber(data.totalLetters),
                    label: 'Total letters',
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today_rounded,
                    value: '${data.activeDays}',
                    label: 'Active days',
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available_rounded,
                    value: data.mostActiveDayName,
                    label: 'Most active day',
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            _FeatureCard(
              title: data.mostReadSurahName,
              subtitle: '${data.mostReadSurahAyahs} ayahs read',
              icon: Icons.menu_book_rounded,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StatIcon(icon: icon),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MostRecitedStatCard extends StatelessWidget {
  const _MostRecitedStatCard({
    required this.icon,
    required this.name,
    required this.count,
  });

  final IconData icon;
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StatIcon(icon: icon),
            const SizedBox(height: 14),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count recitations',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _StatIcon(icon: icon),
          ],
        ),
      ),
    );
  }
}

class _InsightsRow extends StatelessWidget {
  const _InsightsRow({required this.insights});

  final List<InsightData> insights;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: <Widget>[
              for (int index = 0; index < insights.length; index++) ...<Widget>[
                if (index > 0) const SizedBox(width: 10),
                _InsightChip(insight: insights[index]),
              ],
            ],
          ),
        ),
        if (insights.length > 1)
          PositionedDirectional(
            top: 0,
            end: 0,
            bottom: 0,
            width: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: <Color>[
                      colors.background.withAlpha(0),
                      colors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.insight});

  final InsightData insight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.mint,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(insight.icon, color: colors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              insight.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahProgressSection extends StatelessWidget {
  const _SurahProgressSection({
    required this.sectionKey,
    required this.completedSurahs,
    required this.expanded,
    required this.animationController,
    required this.onOpenSurah,
    required this.onToggleExpanded,
  });

  final GlobalKey sectionKey;
  final Set<int> completedSurahs;
  final bool expanded;
  final AnimationController animationController;
  final ValueChanged<int> onOpenSurah;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('Surah Progress'),
        const SizedBox(height: 12),
        Text(
          '${completedSurahs.length} / $_totalSurahs Surahs complete',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const double gap = 4;
            final double cellSize =
                (constraints.maxWidth - (gap * (_surahGridColumns - 1))) /
                _surahGridColumns;
            final int rows = (_totalSurahs / _surahGridColumns).ceil();
            final double fullHeight = (cellSize * rows) + (gap * (rows - 1));
            final double collapsedHeight = (cellSize + gap) * 4;
            final double gridHeight = expanded ? fullHeight : collapsedHeight;

            return AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: gridHeight,
                child: Stack(
                  clipBehavior: expanded ? Clip.none : Clip.hardEdge,
                  children: <Widget>[
                    SizedBox(
                      height: fullHeight,
                      child: AnimatedBuilder(
                        animation: animationController,
                        builder: (context, _) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _totalSurahs,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _surahGridColumns,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: gap,
                                  crossAxisSpacing: gap,
                                ),
                            itemBuilder: (context, index) {
                              final int surah = index + 1;
                              final bool complete = completedSurahs.contains(
                                surah,
                              );
                              final double progress = _surahCellProgress(
                                animationController.value,
                                index,
                              );
                              return _SurahProgressCell(
                                surah: surah,
                                complete: complete,
                                animationProgress: progress,
                                onTap: complete
                                    ? () => onOpenSurah(surah)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: collapsedHeight * 0.3,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: expanded ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  colors.background.withAlpha(0),
                                  colors.background,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: _SurahGridToggleButton(
            expanded: expanded,
            onPressed: onToggleExpanded,
          ),
        ),
      ],
    );
  }

  double _surahCellProgress(double controllerValue, int index) {
    final double elapsedMs =
        (controllerValue * _surahGridAnimationMs) -
        (index * _surahCellStaggerMs);
    final double linear = (elapsedMs / _surahCellAnimationMs).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(linear);
  }
}

class _SurahGridToggleButton extends StatelessWidget {
  const _SurahGridToggleButton({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return Material(
      color: colors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  expanded ? 'Show less' : 'Show all $_totalSurahs surahs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
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

class _SurahProgressCell extends StatelessWidget {
  const _SurahProgressCell({
    required this.surah,
    required this.complete,
    required this.animationProgress,
    required this.onTap,
  });

  final int surah;
  final bool complete;
  final double animationProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.small);
    final Color background = complete ? colors.primary : colors.surfaceAlt;
    final Color foreground = complete ? colors.onPrimary : colors.textMuted;
    final Widget label = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$surah',
          style: theme.textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Opacity(
      opacity: animationProgress,
      child: Transform.scale(
        scale: 0.8 + (0.2 * animationProgress),
        child: onTap == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: radius,
                ),
                child: label,
              )
            : Material(
                color: background,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: label,
                ),
              ),
      ),
    );
  }
}

class _KhatmTrackerSection extends StatelessWidget {
  const _KhatmTrackerSection({required this.completionDates});

  final List<DateTime> completionDates;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('Quran Completions'),
        const SizedBox(height: 12),
        Text(
          '${completionDates.length}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Full completions',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        if (completionDates.isEmpty)
          Text(
            'Complete all $_totalSurahs Surahs to record your first Khatm',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <Widget>[
                for (
                  int index = 0;
                  index < completionDates.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(width: 10),
                  _KhatmDateChip(
                    number: index + 1,
                    date: completionDates[index],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _KhatmDateChip extends StatelessWidget {
  const _KhatmDateChip({required this.number, required this.date});

  final int number;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          'Khatm $number · ${_dateChipLabel(date)}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TasbihSection extends StatelessWidget {
  const _TasbihSection({required this.data});

  final TasbihStatsData data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasData) {
      return const _EmptyStatsSection(
        icon: Icons.radio_button_checked_rounded,
        message: 'Start your first Tasbih session',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final double gap = constraints.maxWidth >= 720 ? 12 : 10;
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _StatCard(
                        icon: Icons.tag_rounded,
                        value: '${data.totalDhikr}',
                        label: 'Total dhikr',
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.show_chart_rounded,
                        value: _averageLabel(data.dailyAverage),
                        label: 'Daily average',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MostRecitedStatCard(
                        icon: Icons.favorite_rounded,
                        name: data.mostRecitedName,
                        count: data.mostRecitedCount,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_month_rounded,
                        value: '${data.activeDays}',
                        label: 'Active days',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                _FeatureCard(
                  title: data.mostRecitedName,
                  subtitle: '${data.mostRecitedCount} recitations',
                  icon: Icons.spa_rounded,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DuasSection extends StatelessWidget {
  const _DuasSection({required this.data});

  final DuasStatsData data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasData) {
      return const _EmptyStatsSection(
        icon: Icons.auto_stories_rounded,
        message: 'Open a dua to begin your Duas history',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                icon: Icons.visibility_rounded,
                value: '${data.viewedCount}',
                label: 'Duas viewed',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.favorite_rounded,
                value: '${data.favouriteCount}',
                label: 'Favourite duas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          title: data.mostViewedCategory,
          subtitle: '${data.mostViewedCategoryCount} views',
          icon: Icons.category_rounded,
        ),
      ],
    );
  }
}

class _EmptyStatsSection extends StatelessWidget {
  const _EmptyStatsSection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: <Widget>[
                _StatIcon(icon: icon),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _YearlyHeatmapSection extends StatelessWidget {
  const _YearlyHeatmapSection({required this.data});

  final HeatmapData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[_ActivityHeatmap(data: data)],
    );
  }
}

class _ActivityHeatmap extends StatefulWidget {
  const _ActivityHeatmap({required this.data});

  final HeatmapData data;

  @override
  State<_ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<_ActivityHeatmap> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    const double cellSize = 10;
    const double gap = 2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(height: 18),
                for (int row = 0; row < 7; row++)
                  SizedBox(
                    height: cellSize + gap,
                    width: 18,
                    child: row == 0 || row == 2 || row == 4
                        ? Text(
                            row == 0
                                ? 'M'
                                : row == 2
                                ? 'W'
                                : 'F',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < widget.data.weeks.length;
                          index++
                        )
                          SizedBox(
                            width: cellSize + gap,
                            height: 18,
                            child: _monthMarker(index)
                                ? Text(
                                    _shortMonthLabel(
                                      widget.data.weeks[index].start,
                                    ),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                    for (int row = 0; row < 7; row++)
                      Row(
                        children: <Widget>[
                          for (final HeatmapWeek week in widget.data.weeks)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: gap,
                                bottom: gap,
                              ),
                              child: _HeatmapCell(day: week.days[row]),
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
    );
  }

  bool _monthMarker(int index) {
    if (index == 0) return true;
    return widget.data.weeks[index].start.month !=
        widget.data.weeks[index - 1].start.month;
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.day});

  final HeatmapDay day;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final Color color = switch (day.total) {
      <= 0 => colors.surfaceAlt,
      <= 10 => colors.primary.withAlpha(64),
      <= 30 => colors.primary.withAlpha(140),
      <= 60 => colors.primary.withAlpha(204),
      _ => colors.primary,
    };
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message:
          '${_dateChipLabel(day.date)}\nQuran: ${day.quran} ayahs\nTasbih: ${day.tasbih} dhikr\nDuas: ${day.duas} duas',
      child: SizedBox.square(
        dimension: 10,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
        ),
      ),
    );
  }
}

class _WorshipStreakSection extends StatelessWidget {
  const _WorshipStreakSection({required this.data});

  final StreakStats data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StreakDetailCard(
                icon: Icons.menu_book_rounded,
                value: data.quran,
                label: 'Quran streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakDetailCard(
                icon: Icons.spa_rounded,
                value: data.tasbih,
                label: 'Tasbih streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakDetailCard(
                icon: Icons.local_fire_department_rounded,
                value: data.overall,
                label: 'Overall streak',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakDetailCard extends StatelessWidget {
  const _StreakDetailCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StatIcon(icon: icon),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.goldSoft,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.accentGold),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.local_fire_department_rounded,
              color: colors.accentGold,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$streak day worship streak',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: colors.mint, shape: BoxShape.circle),
      child: Icon(icon, color: colors.primary, size: 18),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder({required this.height});

  final double height;

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double value = _controller.value;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: <double>[
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
              colors: <Color>[
                colors.surfaceAlt,
                colors.surface,
                colors.surfaceAlt,
              ],
            ).createShader(bounds);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.large),
            ),
            child: SizedBox(height: widget.height),
          ),
        );
      },
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  IslamicPatternPainter({required this.color, this.opacity = 0.06});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round())
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
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return color != oldDelegate.color || opacity != oldDelegate.opacity;
  }
}

class OverviewStats {
  const OverviewStats({
    required this.quranAyahs,
    required this.tasbihCount,
    required this.duasViewed,
    required this.progress,
    required this.motivation,
    required this.highestStreak,
  });

  final int quranAyahs;
  final int tasbihCount;
  final int duasViewed;
  final double progress;
  final String motivation;
  final int highestStreak;
}

class QuranStatsData {
  const QuranStatsData({
    required this.buckets,
    required this.totalAyahs,
    required this.totalLetters,
    required this.activeDays,
    required this.mostActiveDayName,
    required this.mostReadSurahName,
    required this.mostReadSurahAyahs,
    required this.insights,
    required this.completedSurahs,
    required this.khatmCompletionDates,
  });

  final List<ActivityBucket> buckets;
  final int totalAyahs;
  final int totalLetters;
  final int activeDays;
  final String mostActiveDayName;
  final String mostReadSurahName;
  final int mostReadSurahAyahs;
  final List<InsightData> insights;
  final Set<int> completedSurahs;
  final List<DateTime> khatmCompletionDates;
}

class TasbihStatsData {
  const TasbihStatsData({
    required this.hasData,
    required this.totalDhikr,
    required this.dailyAverage,
    required this.activeDays,
    required this.mostRecitedName,
    required this.mostRecitedCount,
  });

  final bool hasData;
  final int totalDhikr;
  final double dailyAverage;
  final int activeDays;
  final String mostRecitedName;
  final int mostRecitedCount;
}

class DuasStatsData {
  const DuasStatsData({
    required this.hasData,
    required this.viewedCount,
    required this.favouriteCount,
    required this.mostViewedCategory,
    required this.mostViewedCategoryCount,
  });

  final bool hasData;
  final int viewedCount;
  final int favouriteCount;
  final String mostViewedCategory;
  final int mostViewedCategoryCount;
}

class StreakStats {
  const StreakStats({
    required this.quran,
    required this.tasbih,
    required this.overall,
  });

  final int quran;
  final int tasbih;
  final int overall;

  int get highest => math.max(quran, math.max(tasbih, overall));
}

class HeatmapData {
  const HeatmapData({required this.weeks});

  final List<HeatmapWeek> weeks;
}

class HeatmapWeek {
  const HeatmapWeek({required this.start, required this.days});

  final DateTime start;
  final List<HeatmapDay> days;
}

class HeatmapDay {
  const HeatmapDay({
    required this.date,
    required this.quran,
    required this.tasbih,
    required this.duas,
  });

  final DateTime date;
  final int quran;
  final int tasbih;
  final int duas;

  int get total => quran + tasbih + duas;
}

class ActivityBucket {
  const ActivityBucket({
    required this.label,
    required this.detailLabel,
    required this.count,
    required this.isCurrent,
  });

  final String label;
  final String detailLabel;
  final int count;
  final bool isCurrent;
}

class InsightData {
  const InsightData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class ActivityDayCount {
  const ActivityDayCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class DuaInteractionEntry {
  const DuaInteractionEntry({
    required this.dateKey,
    required this.categoryId,
    required this.categoryTitle,
    required this.count,
    required this.updatedAt,
  });

  final String dateKey;
  final String categoryId;
  final String categoryTitle;
  final int count;
  final DateTime updatedAt;

  DateTime get date => DateTime.parse(dateKey);

  static DuaInteractionEntry? fromStored(Object? value) {
    if (value is! Map) return null;
    final String? dateKey = _stringOrNull(value['dateKey']);
    final String? categoryId = _stringOrNull(value['categoryId']);
    final String? categoryTitle = _stringOrNull(value['categoryTitle']);
    final int count = _intValue(value['count']);
    final DateTime? updatedAt = _dateTimeOrNull(value['updatedAt']);
    if (dateKey == null ||
        DateTime.tryParse(dateKey) == null ||
        categoryId == null ||
        categoryTitle == null) {
      return null;
    }
    return DuaInteractionEntry(
      dateKey: dateKey,
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      count: count,
      updatedAt: updatedAt ?? DateTime.parse(dateKey),
    );
  }
}

class _ReadAyahRef {
  const _ReadAyahRef({required this.surah, required this.verse});

  final int surah;
  final int verse;

  String get key => '$surah:$verse';
}

class _DuaCategoryCount {
  const _DuaCategoryCount({required this.title, required this.count});

  final String title;
  final int count;
}

HeatmapDay _heatmapDay(
  DateTime date,
  Map<String, QuranActivityDay> quranDays,
  Map<String, int> tasbihByDate,
  Map<String, int> duasByDate,
) {
  final String key = _dateKey(date);
  return HeatmapDay(
    date: DateTime(date.year, date.month, date.day),
    quran: _dayAyahCount(quranDays[key]),
    tasbih: tasbihByDate[key] ?? 0,
    duas: duasByDate[key] ?? 0,
  );
}

Map<String, int> _tasbihCountsByDate(List<DhikrSessionEntry> sessions) {
  final Map<String, int> counts = <String, int>{};
  for (final DhikrSessionEntry session in sessions) {
    final String key = _dateKey(_dhikrDate(session));
    counts[key] = (counts[key] ?? 0) + session.count;
  }
  return counts;
}

Map<String, int> _duaCountsByDate(List<DuaInteractionEntry> interactions) {
  final Map<String, int> counts = <String, int>{};
  for (final DuaInteractionEntry interaction in interactions) {
    counts[interaction.dateKey] =
        (counts[interaction.dateKey] ?? 0) + interaction.count;
  }
  return counts;
}

StreakStats _buildStreaks(
  List<QuranActivityDay> quranDays,
  List<DhikrSessionEntry> sessions,
  List<DuaInteractionEntry> duaViews,
  DateTime now,
) {
  final Set<String> quranActiveDays = quranDays
      .where(_hasReadingActivity)
      .map((day) => day.dateKey)
      .toSet();
  final Set<String> tasbihActiveDays = sessions
      .where((entry) => entry.count > 0)
      .map((entry) => _dateKey(_dhikrDate(entry)))
      .toSet();
  final Set<String> duaActiveDays = duaViews
      .where((entry) => entry.count > 0)
      .map((entry) => entry.dateKey)
      .toSet();
  return StreakStats(
    quran: _currentStreak(quranActiveDays, now),
    tasbih: _currentStreak(tasbihActiveDays, now),
    overall: _currentStreak(<String>{
      ...quranActiveDays,
      ...tasbihActiveDays,
      ...duaActiveDays,
    }, now),
  );
}

int _currentStreak(Set<String> activeDays, DateTime now) {
  int streak = 0;
  DateTime cursor = DateTime(now.year, now.month, now.day);
  while (activeDays.contains(_dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

List<ActivityBucket> _quranBuckets(
  StatRange range,
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  return switch (range) {
    StatRange.week => _quranWeekBuckets(byDate, now),
    StatRange.month => _quranMonthBuckets(byDate, now),
    StatRange.year => _quranYearBuckets(byDate, now),
    StatRange.allTime => _quranAllTimeBuckets(byDate, now),
  };
}

List<ActivityBucket> _quranWeekBuckets(
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return <ActivityBucket>[
    for (int offset = 6; offset >= 0; offset--)
      _bucketForDates(
        label: labels[now.subtract(Duration(days: offset)).weekday - 1],
        detailLabel: _monthDayLabel(now.subtract(Duration(days: offset))),
        dates: <DateTime>[now.subtract(Duration(days: offset))],
        current: offset == 0,
        byDate: byDate,
      ),
  ];
}

List<ActivityBucket> _quranMonthBuckets(
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  final DateTime currentWeekStart = _weekStart(now);
  return <ActivityBucket>[
    for (int offset = 3; offset >= 0; offset--)
      _bucketForDates(
        label: 'W${4 - offset}',
        detailLabel: _dateRangeLabel(
          currentWeekStart.subtract(Duration(days: offset * 7)),
          currentWeekStart
              .subtract(Duration(days: offset * 7))
              .add(const Duration(days: 6)),
        ),
        dates: <DateTime>[
          for (int day = 0; day < 7; day++)
            currentWeekStart
                .subtract(Duration(days: offset * 7))
                .add(Duration(days: day)),
        ],
        current: offset == 0,
        byDate: byDate,
      ),
  ];
}

List<ActivityBucket> _quranYearBuckets(
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  return <ActivityBucket>[
    for (int offset = 11; offset >= 0; offset--)
      _bucketForMonth(DateTime(now.year, now.month - offset), byDate, now),
  ];
}

List<ActivityBucket> _quranAllTimeBuckets(
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  final Iterable<DateTime> dates = byDate.values.map(_activityDayDate);
  final int firstYear = dates.isEmpty
      ? now.year
      : dates.map((date) => date.year).reduce(math.min);
  return <ActivityBucket>[
    for (int year = firstYear; year <= now.year; year++)
      _bucketForDates(
        label: '$year',
        detailLabel: '$year',
        dates: <DateTime>[
          for (
            DateTime date = DateTime(year);
            date.year == year;
            date = date.add(const Duration(days: 1))
          )
            date,
        ],
        current: year == now.year,
        byDate: byDate,
      ),
  ];
}

ActivityBucket _bucketForMonth(
  DateTime month,
  Map<String, QuranActivityDay> byDate,
  DateTime now,
) {
  final DateTime start = DateTime(month.year, month.month);
  final DateTime end = DateTime(month.year, month.month + 1, 0);
  final bool current = month.year == now.year && month.month == now.month;
  return _bucketForDates(
    label: _shortMonthLabel(month),
    detailLabel: _monthLabel(month),
    dates: <DateTime>[
      for (int day = 0; day < end.day; day++) start.add(Duration(days: day)),
    ],
    current: current,
    byDate: byDate,
  );
}

ActivityBucket _bucketForDates({
  required String label,
  required String detailLabel,
  required List<DateTime> dates,
  required bool current,
  required Map<String, QuranActivityDay> byDate,
}) {
  int count = 0;
  for (final DateTime date in dates) {
    count += _dayAyahCount(byDate[_dateKey(date)]);
  }
  return ActivityBucket(
    label: label,
    detailLabel: detailLabel,
    count: count,
    isCurrent: current,
  );
}

bool _inRange(DateTime date, StatRange range, DateTime now) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  return switch (range) {
    StatRange.week =>
      !day.isBefore(today.subtract(const Duration(days: 6))) &&
          !day.isAfter(today),
    StatRange.month =>
      !day.isBefore(today.subtract(const Duration(days: 29))) &&
          !day.isAfter(today),
    StatRange.year => day.year == today.year,
    StatRange.allTime => true,
  };
}

int _dailyGoal() {
  final dynamic saved = SettingsDB().get('dailyQuranGoalAyahs');
  if (saved is int) return saved.clamp(1, 1000).toInt();
  if (saved is String) {
    return (int.tryParse(saved) ?? 20).clamp(1, 1000).toInt();
  }
  return 20;
}

String _worshipMotivation(double progress) {
  if (progress >= 1) return 'Mashallah! Daily worship complete';
  if (progress >= 0.5) return 'Great progress, keep going';
  if (progress > 0) return 'Every deed counts, keep going';
  return 'Start your worship for today';
}

int _dayAyahCount(QuranActivityDay? day) {
  if (day == null) return 0;
  return math.max(day.ayahsRead, day.readAyahKeys.length);
}

bool _hasReadingActivity(QuranActivityDay day) {
  return _dayAyahCount(day) > 0 || day.pagesRead > 0 || day.readingSeconds > 0;
}

DateTime _dhikrDate(DhikrSessionEntry entry) {
  return entry.completedAt ?? entry.startedAt;
}

int _estimatedLettersRead(List<QuranActivityDay> activityDays) {
  int total = 0;
  for (final QuranActivityDay day in activityDays) {
    for (final String key in day.readAyahKeys) {
      final _ReadAyahRef? ref = _parseReadAyahKey(key);
      if (ref == null) continue;
      total += _letterCountCache.putIfAbsent(
        ref.key,
        () => quranVerseArabicLetterCount(ref.surah, ref.verse),
      );
    }
  }
  return total;
}

Map<int, int> _surahCounts(List<QuranActivityDay> activityDays) {
  final Map<int, int> counts = <int, int>{};
  for (final QuranActivityDay day in activityDays) {
    for (final String key in day.readAyahKeys) {
      final _ReadAyahRef? ref = _parseReadAyahKey(key);
      if (ref == null) continue;
      counts[ref.surah] = (counts[ref.surah] ?? 0) + 1;
    }
  }
  return counts;
}

Map<int, int> _surahVisitCounts(List<QuranActivityDay> activityDays) {
  final Map<int, int> counts = <int, int>{};
  for (final QuranActivityDay day in activityDays) {
    for (final int surah in _surahsForDay(day)) {
      counts[surah] = (counts[surah] ?? 0) + 1;
    }
  }
  return counts;
}

Set<int> _surahsForDay(QuranActivityDay day) {
  final Set<int> surahs = <int>{};
  for (final String key in day.readAyahKeys) {
    final _ReadAyahRef? ref = _parseReadAyahKey(key);
    if (ref == null) continue;
    surahs.add(ref.surah);
  }
  return surahs;
}

Map<int, Set<int>> _readAyahsBySurah(List<QuranActivityDay> activityDays) {
  final Map<int, Set<int>> ayahsBySurah = <int, Set<int>>{};
  for (final QuranActivityDay day in activityDays) {
    for (final String key in day.readAyahKeys) {
      final _ReadAyahRef? ref = _parseReadAyahKey(key);
      if (ref == null) continue;
      ayahsBySurah.putIfAbsent(ref.surah, () => <int>{}).add(ref.verse);
    }
  }
  return ayahsBySurah;
}

Set<int> _completedSurahs(Map<int, Set<int>> ayahsBySurah) {
  final Set<int> completed = <int>{};
  for (int surah = 1; surah <= _totalSurahs; surah++) {
    final int readAyahCount = ayahsBySurah[surah]?.length ?? 0;
    if (readAyahCount >= quran.getVerseCount(surah)) {
      completed.add(surah);
    }
  }
  return completed;
}

List<DateTime> _khatmCompletionDates(List<QuranActivityDay> activityDays) {
  final List<QuranActivityDay> sortedDays = activityDays.toList(growable: false)
    ..sort((a, b) => _activityDayDate(a).compareTo(_activityDayDate(b)));
  final Map<int, Set<int>> cycleAyahsBySurah = <int, Set<int>>{};
  final List<DateTime> completions = <DateTime>[];
  for (final QuranActivityDay day in sortedDays) {
    for (final String key in day.readAyahKeys) {
      final _ReadAyahRef? ref = _parseReadAyahKey(key);
      if (ref == null) continue;
      cycleAyahsBySurah.putIfAbsent(ref.surah, () => <int>{}).add(ref.verse);
    }
    if (_completedSurahs(cycleAyahsBySurah).length >= _totalSurahs) {
      completions.add(_activityDayDate(day));
      cycleAyahsBySurah.clear();
    }
  }
  return completions;
}

_ReadAyahRef? _parseReadAyahKey(String key) {
  final List<String> parts = key.split(':');
  if (parts.length != 2) return null;
  final int? surah = int.tryParse(parts.first);
  final int? verse = int.tryParse(parts.last);
  if (surah == null || verse == null) return null;
  if (surah < 1 || surah > _totalSurahs) return null;
  if (verse < 1 || verse > quran.getVerseCount(surah)) return null;
  return _ReadAyahRef(surah: surah, verse: verse);
}

List<InsightData> _buildInsights({
  required List<QuranActivityDay> activityDays,
  required Map<String, QuranActivityDay> activityByDate,
  required DateTime now,
  required Map<int, int> surahVisitCounts,
}) {
  final List<InsightData> insights = <InsightData>[];
  final int? activeDay = _mostActiveWeekday(
    activityDays
        .map(
          (day) => ActivityDayCount(
            date: _activityDayDate(day),
            count: _dayAyahCount(day),
          ),
        )
        .toList(growable: false),
  );
  if (activeDay != null) {
    insights.add(
      InsightData(
        icon: Icons.calendar_month_rounded,
        label: 'You read most on ${_weekdayPlural(activeDay)}',
      ),
    );
  }
  final InsightData? trend = _readingTrendInsight(activityByDate, now);
  if (trend != null) insights.add(trend);
  final InsightData? favourite = _favouriteSurahInsight(surahVisitCounts);
  if (favourite != null) insights.add(favourite);
  if (insights.isEmpty) {
    return const <InsightData>[
      InsightData(
        icon: Icons.auto_awesome_rounded,
        label: 'Start reading to unlock insights',
      ),
    ];
  }
  return insights.take(3).toList(growable: false);
}

int? _mostActiveWeekday(List<ActivityDayCount> days) {
  final List<int> counts = List<int>.filled(8, 0);
  for (final ActivityDayCount day in days) {
    if (day.count <= 0) continue;
    counts[day.date.weekday] += day.count;
  }
  int bestWeekday = 0;
  int bestCount = 0;
  for (int weekday = 1; weekday < counts.length; weekday++) {
    if (counts[weekday] > bestCount) {
      bestWeekday = weekday;
      bestCount = counts[weekday];
    }
  }
  return bestWeekday == 0 ? null : bestWeekday;
}

InsightData? _readingTrendInsight(
  Map<String, QuranActivityDay> activityByDate,
  DateTime now,
) {
  final DateTime currentWeekStart = _weekStart(now);
  final int daysElapsed = now.difference(currentWeekStart).inDays + 1;
  final DateTime previousWeekStart = currentWeekStart.subtract(
    const Duration(days: 7),
  );
  final int currentWeekAyahs = _ayahsForRange(
    activityByDate,
    currentWeekStart,
    daysElapsed,
  );
  final int previousWeekAyahs = _ayahsForRange(
    activityByDate,
    previousWeekStart,
    daysElapsed,
  );
  if (previousWeekAyahs <= 0 || currentWeekAyahs == previousWeekAyahs) {
    return null;
  }
  final bool up = currentWeekAyahs > previousWeekAyahs;
  final int percent = math.max(
    1,
    (((currentWeekAyahs - previousWeekAyahs).abs() / previousWeekAyahs) * 100)
        .round(),
  );
  return InsightData(
    icon: up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
    label: 'Reading ${up ? 'up' : 'down'} $percent% from last week',
  );
}

int _ayahsForRange(
  Map<String, QuranActivityDay> activityByDate,
  DateTime start,
  int dayCount,
) {
  int total = 0;
  for (int offset = 0; offset < dayCount; offset++) {
    total += _dayAyahCount(
      activityByDate[_dateKey(start.add(Duration(days: offset)))],
    );
  }
  return total;
}

InsightData? _favouriteSurahInsight(Map<int, int> surahVisitCounts) {
  if (surahVisitCounts.isEmpty) return null;
  final MapEntry<int, int> favourite = surahVisitCounts.entries.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );
  return InsightData(
    icon: Icons.favorite_rounded,
    label: 'You visit ${quran.getSurahName(favourite.key)} most often',
  );
}

DateTime _activityDayDate(QuranActivityDay day) {
  final DateTime? parsed = DateTime.tryParse(day.dateKey);
  if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
  return DateTime(day.updatedAt.year, day.updatedAt.month, day.updatedAt.day);
}

DateTime _weekStart(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _compactNumber(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 10000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
}

String _averageLabel(double value) {
  if (value == 0) return '0';
  return value.toStringAsFixed(value >= 10 ? 0 : 1);
}

String _monthLabel(DateTime date) {
  return '${_shortMonthLabel(date)} ${date.year}';
}

String _monthDayLabel(DateTime date) {
  return '${_shortMonthLabel(date)} ${date.day}';
}

String _dateRangeLabel(DateTime start, DateTime end) {
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return _monthDayLabel(start);
  }
  return '${_monthDayLabel(start)} - ${_monthDayLabel(end)}';
}

String _dateChipLabel(DateTime date) {
  return '${_shortMonthLabel(date)} ${date.day}, ${date.year}';
}

String _weekdayName(int weekday) {
  const List<String> weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return weekdays[(weekday - 1).clamp(0, weekdays.length - 1)];
}

String _weekdayPlural(int weekday) {
  const List<String> weekdays = <String>[
    'Mondays',
    'Tuesdays',
    'Wednesdays',
    'Thursdays',
    'Fridays',
    'Saturdays',
    'Sundays',
  ];
  return weekdays[(weekday - 1).clamp(0, weekdays.length - 1)];
}

String _shortMonthLabel(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[date.month - 1];
}

String? _stringOrNull(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num || value is bool) return value.toString();
  return null;
}

int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _dateTimeOrNull(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
