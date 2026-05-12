import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class QuranStatsPage extends StatelessWidget {
  const QuranStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return ColoredBox(
      color: colors.background,
      child: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: QuranActivityDB().listener,
        builder: (context, activityBox, _) {
          return ValueListenableBuilder<Box<dynamic>>(
            valueListenable: QuranStatsDB().listener,
            builder: (context, statsBox, _) {
              final _QuranStatsViewData data =
                  _QuranStatsViewData.fromStorage();
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  EquranSpacing.pagePadding,
                  16,
                  EquranSpacing.pagePadding,
                  32,
                ),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _StatsHero(data: data),
                          const SizedBox(height: 12),
                          _WeeklyActivityCard(days: data.weekDays),
                          const SizedBox(height: 12),
                          _StatsGrid(data: data),
                          const SizedBox(height: 12),
                          _RewardNoteCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsHero extends StatelessWidget {
  const _StatsHero({required this.data});

  final _QuranStatsViewData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return EquranGradientCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Quran Stats',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${data.ayahsToday} / ${data.dailyGoal} ayahs today',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(EquranRadii.pill),
                  child: LinearProgressIndicator(
                    value: data.dailyGoalProgress,
                    minHeight: 7,
                    color: colors.onPrimary,
                    backgroundColor: colors.onPrimary.withAlpha(38),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          EquranIconBadge(
            icon: Icons.insights_rounded,
            size: 48,
            backgroundColor: colors.onPrimary.withAlpha(28),
            foregroundColor: colors.onPrimary,
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final _QuranStatsViewData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 720 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns == 3 ? 1.85 : 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            _StatTile('This week', '${data.ayahsThisWeek}', Icons.view_week),
            _StatTile('Total ayahs', '${data.totalAyahsRead}', Icons.done_all),
            _StatTile(
              'Current streak',
              '${data.currentStreak}d',
              Icons.local_fire_department,
            ),
            _StatTile(
              'Longest streak',
              '${data.longestStreak}d',
              Icons.timeline,
            ),
            _StatTile(
              'Estimated letters read',
              _compactNumber(data.estimatedLettersRead),
              Icons.text_fields,
            ),
            _StatTile(
              'Listening time',
              _durationLabel(data.listeningSeconds),
              Icons.headphones,
            ),
            _StatTile(
              'Routine today',
              '${data.routinePercent}%',
              Icons.route_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      backgroundColor: colors.surfaceSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(icon, color: colors.primary, size: 22),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({required this.days});

  final List<_WeekDayStat> days;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final int maxAyahs = days.fold<int>(
      1,
      (max, day) => math.max(max, day.ayahs),
    );
    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Weekly activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final _WeekDayStat day in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: (day.ayahs / maxAyahs)
                                    .clamp(0.06, 1.0)
                                    .toDouble(),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: colors.heroGradient,
                                    borderRadius: BorderRadius.circular(
                                      EquranRadii.pill,
                                    ),
                                  ),
                                  child: const SizedBox(width: 18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            day.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w800,
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
    );
  }
}

class _RewardNoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: <Widget>[
          Icon(Icons.volunteer_activism_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Estimated letters read counts Arabic letters only. Reward is with Allah.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranStatsViewData {
  const _QuranStatsViewData({
    required this.ayahsToday,
    required this.ayahsThisWeek,
    required this.totalAyahsRead,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyGoal,
    required this.estimatedLettersRead,
    required this.listeningSeconds,
    required this.routinePercent,
    required this.weekDays,
  });

  final int ayahsToday;
  final int ayahsThisWeek;
  final int totalAyahsRead;
  final int currentStreak;
  final int longestStreak;
  final int dailyGoal;
  final int estimatedLettersRead;
  final int listeningSeconds;
  final int routinePercent;
  final List<_WeekDayStat> weekDays;

  double get dailyGoalProgress =>
      dailyGoal <= 0 ? 0 : (ayahsToday / dailyGoal).clamp(0.0, 1.0).toDouble();

  static _QuranStatsViewData fromStorage() {
    final DateTime now = DateTime.now();
    final String todayKey = _dateKey(now);
    final List<QuranActivityDay> activityDays = QuranActivityDB().box.values
        .whereType<QuranActivityDay>()
        .toList(growable: false);
    final dynamic summaryValue = QuranStatsDB().get('summary');
    final QuranStatsSnapshot snapshot = summaryValue is QuranStatsSnapshot
        ? summaryValue
        : QuranStatsSnapshot(id: 'summary', updatedAt: now);
    final Map<String, QuranActivityDay> byDate = <String, QuranActivityDay>{
      for (final QuranActivityDay day in activityDays) day.dateKey: day,
    };
    final List<_WeekDayStat> weekDays = <_WeekDayStat>[
      for (int offset = 6; offset >= 0; offset--)
        _WeekDayStat.fromDate(
          now.subtract(Duration(days: offset)),
          byDate[_dateKey(now.subtract(Duration(days: offset)))]?.ayahsRead ??
              0,
        ),
    ];
    final int ayahsThisWeek = weekDays.fold<int>(
      0,
      (sum, day) => sum + day.ayahs,
    );
    return _QuranStatsViewData(
      ayahsToday: byDate[todayKey]?.ayahsRead ?? 0,
      ayahsThisWeek: ayahsThisWeek,
      totalAyahsRead: snapshot.totalAyahsRead,
      currentStreak: snapshot.currentStreak,
      longestStreak: _longestReadingStreak(activityDays),
      dailyGoal: _dailyGoal(),
      estimatedLettersRead: snapshot.estimatedLettersRead,
      listeningSeconds: snapshot.listeningSeconds,
      routinePercent: _routinePercent(todayKey),
      weekDays: weekDays,
    );
  }
}

class _WeekDayStat {
  const _WeekDayStat({required this.label, required this.ayahs});

  final String label;
  final int ayahs;

  factory _WeekDayStat.fromDate(DateTime date, int ayahs) {
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return _WeekDayStat(label: labels[date.weekday - 1], ayahs: ayahs);
  }
}

int _dailyGoal() {
  final dynamic saved = SettingsDB().get('dailyQuranGoalAyahs');
  if (saved is int) return saved.clamp(1, 1000).toInt();
  if (saved is String) {
    return (int.tryParse(saved) ?? 20).clamp(1, 1000).toInt();
  }
  return 20;
}

int _routinePercent(String todayKey) {
  ReadingPlanEntry? activePlan;
  for (final ReadingPlanEntry plan
      in ReadingPlansDB().box.values.whereType<ReadingPlanEntry>()) {
    if (!plan.active) continue;
    activePlan = plan;
    break;
  }
  if (activePlan == null) return 0;
  final _RoutineRange range = _routineTodayRange(activePlan);
  final RoutineDayProgressEntry? progress = RoutineDayProgressDB().progressFor(
    activePlan.id,
    todayKey,
  );
  final int completed = (progress?.completedAyahCount ?? 0)
      .clamp(0, range.totalAyahs)
      .toInt();
  return ((completed / range.totalAyahs) * 100).round().clamp(0, 100).toInt();
}

_RoutineRange _routineTodayRange(ReadingPlanEntry plan) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime start = DateTime(
    plan.startedAt.year,
    plan.startedAt.month,
    plan.startedAt.day,
  );
  final int totalAyahs = math.max(
    1,
    plan.targetGlobalAyah - plan.startGlobalAyah + 1,
  );
  final int totalDays = math.max(1, plan.finishBy.difference(start).inDays + 1);
  final int elapsedDays = today
      .difference(start)
      .inDays
      .clamp(0, totalDays - 1)
      .toInt();
  final int perDay = (totalAyahs / totalDays).ceil();
  final int startAyah = math.min(
    plan.targetGlobalAyah,
    plan.startGlobalAyah + (elapsedDays * perDay),
  );
  final int endAyah = math.min(plan.targetGlobalAyah, startAyah + perDay - 1);
  return _RoutineRange(startGlobalAyah: startAyah, endGlobalAyah: endAyah);
}

class _RoutineRange {
  const _RoutineRange({
    required this.startGlobalAyah,
    required this.endGlobalAyah,
  });

  final int startGlobalAyah;
  final int endGlobalAyah;

  int get totalAyahs => math.max(1, endGlobalAyah - startGlobalAyah + 1);
}

int _longestReadingStreak(List<QuranActivityDay> days) {
  final Set<String> activeDays = days
      .where((day) => day.ayahsRead > 0 || day.readAyahKeys.isNotEmpty)
      .map((day) => day.dateKey)
      .toSet();
  if (activeDays.isEmpty) return 0;
  final List<String> sorted = activeDays.toList()..sort();
  int longest = 0;
  int current = 0;
  DateTime? previous;
  for (final String key in sorted) {
    final DateTime date = DateTime.parse(key);
    if (previous == null || date.difference(previous).inDays == 1) {
      current++;
    } else {
      current = 1;
    }
    longest = math.max(longest, current);
    previous = date;
  }
  return longest;
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

String _durationLabel(int seconds) {
  if (seconds <= 0) return '0m';
  final Duration duration = Duration(seconds: seconds);
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  if (hours <= 0) return '${math.max(1, minutes)}m';
  return '${hours}h ${minutes}m';
}
