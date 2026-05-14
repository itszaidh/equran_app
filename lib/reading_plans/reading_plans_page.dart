import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/reading_plans/routine_progress.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

const String _routineDesignAsset = 'assets/media/images/app/design.webp';

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
    final bool done = plan != null && routineProgressSummary(plan!).isTodayDone;
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
    final RoutineProgressSummary progress = routineProgressSummary(plan);
    final _AyahRef start = _ayahRefFromGlobalIndex(
      progress.todayStartGlobalAyah,
    );
    final _AyahRef end = _ayahRefFromGlobalIndex(progress.todayEndGlobalAyah);
    final bool done = progress.isTodayDone;
    final double dailyFraction = progress.todayFraction;
    final int percentComplete = (dailyFraction * 100).round();

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
                      progress.isRoutineDone
                          ? 'Routine complete'
                          : done
                          ? 'Today completed'
                          : 'Today\'s reading',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      progress.isRoutineDone
                          ? 'All ${progress.totalAyahs} ayahs completed'
                          : 'Today\'s portion: ${progress.todayPortionAyahs} ayahs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (!progress.isRoutineDone &&
                        progress.catchUpAyahs > 0) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        'Includes ${progress.catchUpAyahs} catch-up ayahs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else if (!progress.isRoutineDone) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        '${_refLabel(start)} to ${_refLabel(end)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
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
                ? 'Today\'s portion complete'
                : '$percentComplete% complete • ${progress.todayRemainingAyahs} ayahs remaining today',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: progress.isRoutineDone
                ? null
                : () => _openContinue(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(progress.isRoutineDone ? 'Routine complete' : 'Resume'),
          ),
        ],
      ),
    );
  }

  void _openContinue(BuildContext context) {
    final RoutineProgressSummary progress = routineProgressSummary(plan);
    final int resumeGlobalAyah = progress.nextUnreadGlobalAyah;
    final _AyahRef resume = _ayahRefFromGlobalIndex(resumeGlobalAyah);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ReadPage(
            chapter: resume.surah,
            startVerse: resume.verse,
            mode: ReadPageMode.routine,
            routineId: plan.id,
          );
        },
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

class _AyahRef {
  const _AyahRef({required this.surah, required this.verse});

  final int surah;
  final int verse;
}

_PlanProgress _planProgress(ReadingPlanEntry plan) {
  final RoutineProgressSummary progress = routineProgressSummary(plan);
  return _PlanProgress(
    completedAyahs: progress.completedAyahs,
    totalAyahs: progress.totalAyahs,
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
