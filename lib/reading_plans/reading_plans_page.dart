import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

const String _routineDesignAsset = 'assets/images/app_assets/design.png';

class ReadingPlansPage extends StatelessWidget {
  const ReadingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Reading Routine'),
        centerTitle: true,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
        actionsIconTheme: IconThemeData(color: colors.textSecondary),
      ),
      body: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: ReadingPlansDB().listener,
        builder: (BuildContext context, Box<dynamic> box, Widget? child) {
          final List<ReadingPlanEntry> plans =
              box.values.whereType<ReadingPlanEntry>().toList(growable: false)
                ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
          final ReadingPlanEntry? activePlan = _activePlan(plans);

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
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _RoutineHero(plan: activePlan),
                      const SizedBox(height: 18),
                      _ActivitySummary(plan: activePlan),
                      const SizedBox(height: 14),
                      if (activePlan == null)
                        _EmptyRoutineCard(onCreate: _createThirtyDayPlan)
                      else
                        _TodayTaskCard(plan: activePlan),
                      const SizedBox(height: 14),
                      _RoutineHistorySection(
                        plans: plans,
                        activePlan: activePlan,
                      ),
                      const SizedBox(height: 22),
                      _PlanPresetGrid(
                        onCreatePlan: (BuildContext context, _PlanPreset plan) {
                          _createPresetPlan(context, plan);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createThirtyDayPlan(BuildContext context) {
    _createPresetPlan(context, _PlanPreset.thirtyDays);
  }

  static Future<void> _createPresetPlan(
    BuildContext context,
    _PlanPreset preset,
  ) async {
    final DateTime now = DateTime.now();
    final List<ReadingPlanEntry> existingPlans = ReadingPlansDB().box.values
        .whereType<ReadingPlanEntry>()
        .toList(growable: false);
    for (final ReadingPlanEntry plan in existingPlans) {
      if (!plan.active) continue;
      await ReadingPlansDB().put(
        plan.id,
        ReadingPlanEntry(
          id: plan.id,
          type: plan.type,
          title: plan.title,
          startedAt: plan.startedAt,
          finishBy: plan.finishBy,
          startGlobalAyah: plan.startGlobalAyah,
          targetGlobalAyah: plan.targetGlobalAyah,
          lastCompletedGlobalAyah: plan.lastCompletedGlobalAyah,
          active: false,
          schemaVersion: plan.schemaVersion,
        ),
      );
    }

    final ReadingPlanEntry newPlan = ReadingPlanEntry(
      id: 'plan:${preset.type}:${now.microsecondsSinceEpoch}',
      type: preset.type,
      title: preset.title,
      startedAt: DateTime(now.year, now.month, now.day),
      finishBy: DateTime(now.year, now.month, now.day + preset.days - 1),
      startGlobalAyah: 1,
      targetGlobalAyah: quran.totalVerseCount,
      lastCompletedGlobalAyah: 0,
    );
    await ReadingPlansDB().put(newPlan.id, newPlan);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${preset.title} started')));
  }
}

ReadingPlanEntry? _activePlan(List<ReadingPlanEntry> plans) {
  for (final ReadingPlanEntry plan in plans) {
    if (plan.active) return plan;
  }
  return null;
}

class _RoutineHero extends StatelessWidget {
  const _RoutineHero({required this.plan});

  final ReadingPlanEntry? plan;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final _PlanProgress? progress = plan == null ? null : _planProgress(plan!);

    return EquranGradientCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -12,
            bottom: -16,
            width: 150,
            height: 120,
            child: Opacity(
              opacity: 0.20,
              child: Image.asset(_routineDesignAsset, fit: BoxFit.cover),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  EquranIconBadge(
                    icon: Icons.calendar_month_rounded,
                    backgroundColor: colors.onPrimary.withAlpha(26),
                    foregroundColor: colors.onPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan?.title ?? 'Build a Quran routine',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                plan == null
                    ? 'Choose a gentle plan and let today have a clear portion.'
                    : '${progress!.completedAyahs} of ${progress.totalAyahs} ayahs completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimaryMuted,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(EquranRadii.pill),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress?.fraction ?? 0,
                  color: colors.onPrimary,
                  backgroundColor: colors.onPrimary.withAlpha(40),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                plan == null
                    ? '7-day, 30-day, and 60-day plans are ready.'
                    : 'Finish target: ${_shortDate(plan!.finishBy)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimaryMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.plan});

  final ReadingPlanEntry? plan;

  @override
  Widget build(BuildContext context) {
    final bool done = plan != null && _todayRange(plan!).isDone;
    final List<_SummaryPillData> items = <_SummaryPillData>[
      _SummaryPillData('All', plan == null ? 0 : 1),
      _SummaryPillData('Done', done ? 1 : 0),
      _SummaryPillData('Ongoing', plan != null && !done ? 1 : 0),
      const _SummaryPillData('Skipped', 0),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _SummaryPill(item: item)).toList(),
    );
  }
}

class _SummaryPillData {
  const _SummaryPillData(this.label, this.count);

  final String label;
  final int count;
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.item});

  final _SummaryPillData item;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: item.count > 0 ? colors.mint : colors.surface,
        borderRadius: BorderRadius.circular(EquranRadii.pill),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        '${item.label} ${item.count}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: item.count > 0 ? colors.primary : colors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyRoutineCard extends StatelessWidget {
  const _EmptyRoutineCard({required this.onCreate});

  final void Function(BuildContext context) onCreate;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No active routine',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start with a balanced 30-day plan, or choose a faster or gentler routine below.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => onCreate(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Start 30-day plan'),
          ),
        ],
      ),
    );
  }
}

class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({required this.plan});

  final ReadingPlanEntry plan;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final _TodayRange range = _todayRange(plan);
    final _AyahRef start = _ayahRefFromGlobalIndex(range.startGlobalAyah);
    final _AyahRef end = _ayahRefFromGlobalIndex(range.endGlobalAyah);
    final RoutineDayProgressEntry? savedProgress = RoutineDayProgressDB()
        .progressFor(plan.id, _dateKey(DateTime.now()));
    final int legacyCompleted =
        (plan.lastCompletedGlobalAyah - range.startGlobalAyah + 1)
            .clamp(0, range.totalAyahs)
            .toInt();
    final int completedToday = math
        .max(
          savedProgress?.completedAyahCount ?? legacyCompleted,
          range.isDone ? range.totalAyahs : 0,
        )
        .clamp(0, range.totalAyahs)
        .toInt();
    final bool done = completedToday >= range.totalAyahs;
    final double dailyFraction = range.totalAyahs <= 0
        ? 0
        : (completedToday / range.totalAyahs).clamp(0.0, 1.0).toDouble();
    final int percentComplete = (dailyFraction * 100).round();
    final int percentLeft = 100 - percentComplete;

    return EquranSurfaceCard(
      backgroundColor: done ? null : colors.surface,
      borderColor: done ? colors.primary.withAlpha(90) : colors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              EquranIconBadge(
                icon: done ? Icons.check_rounded : Icons.menu_book_outlined,
                backgroundColor: done ? colors.primary : colors.mint,
                foregroundColor: done ? colors.onPrimary : colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      done ? 'Today completed' : 'Today\'s reading',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${range.totalAyahs} ayahs - ${_refLabel(start)} to ${_refLabel(end)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(EquranRadii.pill),
            child: LinearProgressIndicator(
              value: dailyFraction,
              minHeight: 8,
              color: colors.primary,
              backgroundColor: colors.mint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            done
                ? '100% complete'
                : '$percentComplete% complete • $percentLeft% left today',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openContinue(context, range),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: done ? null : () => _markDone(context, range),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openContinue(BuildContext context, _TodayRange range) {
    int resumeGlobalAyah = range.startGlobalAyah;
    final RoutineDayProgressEntry? savedProgress = RoutineDayProgressDB()
        .progressFor(plan.id, _dateKey(DateTime.now()));
    if (savedProgress != null) {
      final int savedGlobalAyah = _globalAyahIndex(
        savedProgress.lastOpenedSurah,
        savedProgress.lastOpenedAyah,
      );
      if (savedGlobalAyah >= range.startGlobalAyah &&
          savedGlobalAyah <= plan.targetGlobalAyah) {
        resumeGlobalAyah = savedGlobalAyah;
      }
    } else if (plan.lastCompletedGlobalAyah >= range.startGlobalAyah) {
      resumeGlobalAyah = math.min(
        plan.lastCompletedGlobalAyah + 1,
        plan.targetGlobalAyah,
      );
    }
    final _AyahRef resume = _ayahRefFromGlobalIndex(resumeGlobalAyah);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ReadPage(
            chapter: resume.surah,
            startVerse: resume.verse,
            routineId: plan.id,
          );
        },
      ),
    );
  }

  Future<void> _markDone(BuildContext context, _TodayRange range) async {
    final bool confirmed = await _confirmRoutineAction(
      context: context,
      title: 'Mark today complete?',
      message: 'Mark today\'s reading as complete?',
      confirmLabel: 'Mark Done',
    );
    if (!confirmed) return;

    final ReadingPlanEntry updated = ReadingPlanEntry(
      id: plan.id,
      type: plan.type,
      title: plan.title,
      startedAt: plan.startedAt,
      finishBy: plan.finishBy,
      startGlobalAyah: plan.startGlobalAyah,
      targetGlobalAyah: plan.targetGlobalAyah,
      lastCompletedGlobalAyah: math.max(
        plan.lastCompletedGlobalAyah,
        range.endGlobalAyah,
      ),
      active: plan.active,
      schemaVersion: plan.schemaVersion,
    );
    await ReadingPlansDB().put(updated.id, updated);
    final _AyahRef endRef = _ayahRefFromGlobalIndex(range.endGlobalAyah);
    await RoutineDayProgressDB().saveProgress(
      RoutineDayProgressEntry(
        routineId: plan.id,
        dateKey: _dateKey(DateTime.now()),
        currentSurah: endRef.surah,
        currentAyah: endRef.verse,
        completedAyahCount: range.totalAyahs,
        lastOpenedSurah: endRef.surah,
        lastOpenedAyah: endRef.verse,
        updatedAt: DateTime.now(),
        completedGlobalAyahs: <int>[
          for (
            int ayah = range.startGlobalAyah;
            ayah <= range.endGlobalAyah;
            ayah++
          )
            ayah,
        ],
      ),
    );
    await _recordManualGoalCompletion(range);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Today\'s reading marked complete')),
    );
  }

  Future<void> _recordManualGoalCompletion(_TodayRange range) async {
    final DateTime now = DateTime.now();
    final String todayKey = _dateKey(now);
    final dynamic existingActivity = QuranActivityDB().get(todayKey);
    final QuranActivityDay activity = existingActivity is QuranActivityDay
        ? existingActivity
        : QuranActivityDay(dateKey: todayKey, updatedAt: now);
    final Set<String> readKeys = activity.readAyahKeys.toSet();
    int added = 0;
    int addedLetters = 0;

    for (
      int global = range.startGlobalAyah;
      global <= range.endGlobalAyah;
      global++
    ) {
      final _AyahRef ref = _ayahRefFromGlobalIndex(global);
      final String key = '${ref.surah}:${ref.verse}';
      if (readKeys.add(key)) {
        added++;
        addedLetters += _estimatedArabicLetters(ref);
      }
    }
    if (added == 0) return;

    await QuranActivityDB().put(
      todayKey,
      QuranActivityDay(
        dateKey: todayKey,
        ayahsRead: activity.ayahsRead + added,
        pagesRead: activity.pagesRead,
        listeningSeconds: activity.listeningSeconds,
        readAyahKeys: readKeys.toList()..sort(),
        updatedAt: now,
        schemaVersion: activity.schemaVersion,
      ),
    );

    final dynamic existingStats = QuranStatsDB().get('summary');
    final QuranStatsSnapshot stats = existingStats is QuranStatsSnapshot
        ? existingStats
        : QuranStatsSnapshot(id: 'summary', updatedAt: now);
    await QuranStatsDB().put(
      'summary',
      QuranStatsSnapshot(
        id: 'summary',
        totalAyahsRead: stats.totalAyahsRead + added,
        estimatedLettersRead: stats.estimatedLettersRead + addedLetters,
        listeningSeconds: stats.listeningSeconds,
        currentStreak: _readingStreakIncluding(todayKey),
        updatedAt: now,
        schemaVersion: stats.schemaVersion,
      ),
    );
  }
}

class _RoutineHistorySection extends StatelessWidget {
  const _RoutineHistorySection({required this.plans, required this.activePlan});

  final List<ReadingPlanEntry> plans;
  final ReadingPlanEntry? activePlan;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final List<ReadingPlanEntry> pastPlans = plans
        .where((ReadingPlanEntry plan) => !plan.active)
        .toList(growable: false);

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Routine history',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (activePlan != null)
            _RoutineHistoryTile(
              plan: activePlan!,
              label: 'Current routine',
              onDelete: () => _deleteRoutine(context, activePlan!),
            )
          else
            Text(
              'No current routine.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          if (pastPlans.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Past routines',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: <Widget>[
                for (final ReadingPlanEntry plan in pastPlans)
                  _RoutineHistoryTile(
                    plan: plan,
                    label: 'Past routine',
                    onDelete: () => _deleteRoutine(context, plan),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RoutineHistoryTile extends StatelessWidget {
  const _RoutineHistoryTile({
    required this.plan,
    required this.label,
    required this.onDelete,
  });

  final ReadingPlanEntry plan;
  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final _PlanProgress progress = _planProgress(plan);
    final EquranColors colors = context.equranColors;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: EquranIconBadge(
        icon: plan.active ? Icons.route_outlined : Icons.history_rounded,
        size: 38,
      ),
      title: Text(plan.title),
      subtitle: Text(
        '$label • ${progress.completedAyahs}/${progress.totalAyahs} ayahs • ${_shortDate(plan.startedAt)}',
      ),
      trailing: IconButton(
        tooltip: 'Delete routine',
        onPressed: onDelete,
        color: colors.textMuted,
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }
}

Future<void> _deleteRoutine(BuildContext context, ReadingPlanEntry plan) async {
  final bool confirmed = await _confirmRoutineAction(
    context: context,
    title: plan.active ? 'Delete current routine?' : 'Delete routine?',
    message: 'This removes "${plan.title}" from your routine history.',
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!confirmed) return;
  await ReadingPlansDB().delete(plan.id);
  await RoutineDayProgressDB().deleteProgressForRoutine(plan.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Routine deleted')));
}

Future<bool> _confirmRoutineAction({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

class _PlanPresetGrid extends StatelessWidget {
  const _PlanPresetGrid({required this.onCreatePlan});

  final void Function(BuildContext context, _PlanPreset plan) onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final List<_PlanPreset> presets = <_PlanPreset>[
      _PlanPreset.sevenDays,
      _PlanPreset.thirtyDays,
      _PlanPreset.sixtyDays,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose a plan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool twoColumn = constraints.maxWidth >= 620;
            return GridView.builder(
              itemCount: presets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: twoColumn ? 2 : 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: twoColumn ? 3.2 : 3.8,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _PlanPresetCard(
                  preset: presets[index],
                  onTap: () => onCreatePlan(context, presets[index]),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PlanPresetCard extends StatelessWidget {
  const _PlanPresetCard({required this.preset, required this.onTap});

  final _PlanPreset preset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return EquranSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: <Widget>[
          EquranIconBadge(icon: preset.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  preset.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  preset.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textMuted),
        ],
      ),
    );
  }
}

class _PlanPreset {
  const _PlanPreset({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.days,
    required this.icon,
  });

  final String type;
  final String title;
  final String subtitle;
  final int days;
  final IconData icon;

  static const _PlanPreset sevenDays = _PlanPreset(
    type: 'complete_7_days',
    title: 'Complete Quran in 7 days',
    subtitle: 'A focused weekly routine',
    days: 7,
    icon: Icons.bolt_outlined,
  );

  static const _PlanPreset thirtyDays = _PlanPreset(
    type: 'complete_30_days',
    title: 'Complete Quran in 30 days',
    subtitle: 'Balanced daily portions',
    days: 30,
    icon: Icons.calendar_month_outlined,
  );

  static const _PlanPreset sixtyDays = _PlanPreset(
    type: 'complete_60_days',
    title: 'Complete Quran in 60 days',
    subtitle: 'Gentle long-form reading',
    days: 60,
    icon: Icons.auto_stories_outlined,
  );
}

class _PlanProgress {
  const _PlanProgress({required this.completedAyahs, required this.totalAyahs});

  final int completedAyahs;
  final int totalAyahs;

  double get fraction {
    if (totalAyahs <= 0) return 0;
    return (completedAyahs / totalAyahs).clamp(0.0, 1.0).toDouble();
  }
}

class _TodayRange {
  const _TodayRange({
    required this.startGlobalAyah,
    required this.endGlobalAyah,
    required this.isDone,
  });

  final int startGlobalAyah;
  final int endGlobalAyah;
  final bool isDone;

  int get totalAyahs => math.max(1, endGlobalAyah - startGlobalAyah + 1);
}

class _AyahRef {
  const _AyahRef({required this.surah, required this.verse});

  final int surah;
  final int verse;
}

_PlanProgress _planProgress(ReadingPlanEntry plan) {
  final int total = math.max(
    1,
    plan.targetGlobalAyah - plan.startGlobalAyah + 1,
  );
  final int completed = math
      .max(0, plan.lastCompletedGlobalAyah - plan.startGlobalAyah + 1)
      .clamp(0, total)
      .toInt();
  return _PlanProgress(completedAyahs: completed, totalAyahs: total);
}

_TodayRange _todayRange(ReadingPlanEntry plan) {
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
  return _TodayRange(
    startGlobalAyah: startAyah,
    endGlobalAyah: endAyah,
    isDone: plan.lastCompletedGlobalAyah >= endAyah,
  );
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

int _globalAyahIndex(int surah, int verse) {
  int index = verse.clamp(1, quran.getVerseCount(surah)).toInt();
  for (int currentSurah = 1; currentSurah < surah; currentSurah++) {
    index += quran.getVerseCount(currentSurah);
  }
  return index.clamp(1, quran.totalVerseCount).toInt();
}

String _refLabel(_AyahRef ref) {
  return '${quran.getSurahName(ref.surah)} ${ref.verse}';
}

String _shortDate(DateTime date) {
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
  return '${months[(date.month - 1).clamp(0, 11).toInt()]} ${date.day}, ${date.year}';
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

int _estimatedArabicLetters(_AyahRef ref) {
  return quranVerseArabicLetterCount(ref.surah, ref.verse);
}

int _readingStreakIncluding(String todayKey) {
  final Set<String> activeDays = QuranActivityDB().box.values
      .whereType<QuranActivityDay>()
      .where((day) => day.ayahsRead > 0 || day.readAyahKeys.isNotEmpty)
      .map((day) => day.dateKey)
      .toSet();
  activeDays.add(todayKey);

  DateTime cursor = DateTime.now();
  int streak = 0;
  while (activeDays.contains(_dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
