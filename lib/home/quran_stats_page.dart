import 'dart:async';
import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

class QuranStatsPage extends StatefulWidget {
  const QuranStatsPage({super.key});

  @override
  State<QuranStatsPage> createState() => _QuranStatsPageState();
}

class _QuranStatsPageState extends State<QuranStatsPage> {
  _StatsRange _range = _StatsRange.week;
  DateTime _heatmapMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _editingGoal = false;
  late final TextEditingController _goalController;
  late final FocusNode _goalFocusNode;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: _dailyGoal().toString());
    _goalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _goalFocusNode.dispose();
    super.dispose();
  }

  void _startGoalEdit(int goal) {
    setState(() {
      _editingGoal = true;
      _goalController.text = goal.toString();
      _goalController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _goalController.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _goalFocusNode.requestFocus();
    });
  }

  Future<void> _saveGoal() async {
    final int nextGoal = (int.tryParse(_goalController.text.trim()) ?? 20)
        .clamp(1, 1000)
        .toInt();
    await SettingsDB().put('dailyQuranGoalAyahs', nextGoal);
    if (!mounted) return;
    setState(() {
      _editingGoal = false;
      _goalController.text = nextGoal.toString();
    });
    _goalFocusNode.unfocus();
  }

  void _moveHeatmapMonth(int delta) {
    setState(() {
      _heatmapMonth = DateTime(_heatmapMonth.year, _heatmapMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: ValueListenableBuilder<Box<dynamic>>(
          valueListenable: QuranActivityDB().listener,
          builder: (context, activityBox, _) {
            return ValueListenableBuilder<Box<dynamic>>(
              valueListenable: QuranStatsDB().listener,
              builder: (context, statsBox, _) {
                return ValueListenableBuilder<Box<dynamic>>(
                  valueListenable: SettingsDB().listener,
                  builder: (context, settingsBox, _) {
                    final _QuranStatsViewData data =
                        _QuranStatsViewData.fromStorage();
                    final List<_ActivityBucket> buckets = data.bucketsFor(
                      _range,
                    );

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            EquranSpacing.pagePadding,
                            16,
                            EquranSpacing.pagePadding,
                            32,
                          ),
                          sliver: SliverList.list(
                            children: <Widget>[
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 860,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      _StatsHeaderCard(
                                        data: data,
                                        editingGoal: _editingGoal,
                                        goalController: _goalController,
                                        goalFocusNode: _goalFocusNode,
                                        onEditGoal: () =>
                                            _startGoalEdit(data.dailyGoal),
                                        onSaveGoal: _saveGoal,
                                      ),
                                      const SizedBox(height: 20),
                                      _ActivityCard(
                                        buckets: buckets,
                                        range: _range,
                                        onRangeChanged: (range) {
                                          setState(() => _range = range);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _StatsGrid(data: data),
                                      const SizedBox(height: 20),
                                      _StreakHeatmapCard(
                                        data: data,
                                        month: _heatmapMonth,
                                        onPreviousMonth: () =>
                                            _moveHeatmapMonth(-1),
                                        onNextMonth: () => _moveHeatmapMonth(1),
                                      ),
                                      const SizedBox(height: 20),
                                      _EstimatedLettersNote(data: data),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatsHeaderCard extends StatelessWidget {
  const _StatsHeaderCard({
    required this.data,
    required this.editingGoal,
    required this.goalController,
    required this.goalFocusNode,
    required this.onEditGoal,
    required this.onSaveGoal,
  });

  final _QuranStatsViewData data;
  final bool editingGoal;
  final TextEditingController goalController;
  final FocusNode goalFocusNode;
  final VoidCallback onEditGoal;
  final VoidCallback onSaveGoal;

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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Quran Stats',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _HeaderIconButton(onPressed: onEditGoal),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: editingGoal
                    ? _GoalEditor(
                        key: const ValueKey<String>('goal-editor'),
                        controller: goalController,
                        focusNode: goalFocusNode,
                        onSave: onSaveGoal,
                      )
                    : GestureDetector(
                        key: const ValueKey<String>('goal-progress'),
                        behavior: HitTestBehavior.opaque,
                        onTap: onEditGoal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${data.ayahsToday} / ${data.dailyGoal} ayahs today',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onPrimaryMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(data.dailyGoalProgress * 100).round()}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onPrimaryMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            _AnimatedProgressBar(
                              progress: data.dailyGoalProgress,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return Material(
      color: colors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: SizedBox.square(
          dimension: 42,
          child: Icon(Icons.edit_rounded, color: colors.primary),
        ),
      ),
    );
  }
}

class _GoalEditor extends StatelessWidget {
  const _GoalEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSave,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return Row(
      children: <Widget>[
        Text(
          'Daily goal',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onPrimaryMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.onPrimary.withAlpha(26),
              borderRadius: radius,
              border: Border.all(color: colors.onPrimary.withAlpha(51)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: EditableText(
                controller: controller,
                focusNode: focusNode,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: colors.onPrimary,
                backgroundCursorColor: colors.onPrimaryMuted,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSave(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Save daily goal',
          onPressed: onSave,
          color: colors.onPrimary,
          icon: const Icon(Icons.done_rounded),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.onPrimary.withAlpha(51),
            borderRadius: radius,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0).toDouble(),
                  child: child,
                ),
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

class _ActivityCard extends StatefulWidget {
  const _ActivityCard({
    required this.buckets,
    required this.range,
    required this.onRangeChanged,
  });

  final List<_ActivityBucket> buckets;
  final _StatsRange range;
  final ValueChanged<_StatsRange> onRangeChanged;

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _ActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.range != widget.range ||
        oldWidget.buckets.length != widget.buckets.length) {
      _selectedIndex = null;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    final int maxAyahs = widget.buckets.fold<int>(
      1,
      (max, bucket) => math.max(max, bucket.ayahs),
    );
    final _ActivityBucket? selected = _selectedIndex == null
        ? null
        : widget.buckets[_selectedIndex!];

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
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
              Row(
                children: <Widget>[
                  const Expanded(child: _SectionLabel('Weekly activity')),
                  _RangeToggle(
                    selected: widget.range,
                    onChanged: widget.onRangeChanged,
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected == null
                    ? const SizedBox(height: 16)
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppRadii.medium,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                selected.detailLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selected.ayahs} ayahs',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: 188,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          bottom: 34,
                          child: CustomPaint(
                            painter: _ChartGridPainter(color: colors.divider),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              for (
                                int index = 0;
                                index < widget.buckets.length;
                                index++
                              )
                                Expanded(
                                  child: _ActivityBar(
                                    bucket: widget.buckets[index],
                                    maxAyahs: maxAyahs,
                                    animationValue: _animation.value,
                                    selected: _selectedIndex == index,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = _selectedIndex == index
                                            ? null
                                            : index;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.selected, required this.onChanged});

  final _StatsRange selected;
  final ValueChanged<_StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final _StatsRange range in _StatsRange.values)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: _RangePill(
              range: range,
              selected: range == selected,
              onTap: () => onChanged(range),
            ),
          ),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.range,
    required this.selected,
    required this.onTap,
  });

  final _StatsRange range;
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.bucket,
    required this.maxAyahs,
    required this.animationValue,
    required this.selected,
    required this.onTap,
  });

  final _ActivityBucket bucket;
  final int maxAyahs;
  final double animationValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final double heightFactor = bucket.ayahs <= 0
        ? 0
        : (bucket.ayahs / maxAyahs).clamp(0.08, 1.0).toDouble();
    final Color barColor = bucket.ayahs <= 0
        ? colors.surfaceAlt
        : bucket.isCurrent
        ? colors.primaryStrong
        : colors.primary;
    final double barWidth = bucket.isCurrent ? 22 : 16;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: selected ? barWidth + 4 : barWidth,
                  child: FractionallySizedBox(
                    heightFactor: math.max(0.03, heightFactor * animationValue),
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadii.pill),
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              bucket.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartGridPainter extends CustomPainter {
  const _ChartGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartGridPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final _QuranStatsViewData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = constraints.maxWidth >= 720 ? 12 : 10;
        final int columns = constraints.maxWidth >= 720 ? 3 : 2;
        final double tileWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            _StatCard(
              width: tileWidth,
              icon: Icons.bar_chart_rounded,
              value: '${data.ayahsThisWeek}',
              label: 'This week',
            ),
            _StatCard(
              width: tileWidth,
              icon: Icons.done_all_rounded,
              value: '${data.totalAyahsRead}',
              label: 'Total ayahs',
            ),
            _StatCard(
              width: tileWidth,
              icon: Icons.local_fire_department_rounded,
              value: '${data.currentStreak}d',
              label: 'Current streak',
            ),
            _StatCard(
              width: tileWidth,
              icon: Icons.trending_up_rounded,
              value: '${data.longestStreak}d',
              label: 'Longest streak',
            ),
            _MostReadSurahCard(data: data),
            _StatCard(
              width: tileWidth,
              icon: Icons.insights_rounded,
              value: data.dailyAverageLabel,
              label: 'Daily average',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius,
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
      ),
    );
  }
}

class _MostReadSurahCard extends StatelessWidget {
  const _MostReadSurahCard({required this.data});

  final _QuranStatsViewData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius,
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const _StatIcon(icon: Icons.menu_book_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Most read Surah',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.mostReadSurahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${data.mostReadSurahAyahs} ayahs read',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

class _StreakHeatmapCard extends StatelessWidget {
  const _StreakHeatmapCard({
    required this.data,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final _QuranStatsViewData data;
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    final List<List<DateTime?>> weeks = _monthWeeks(month);

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
            Row(
              children: <Widget>[
                const Expanded(child: _SectionLabel('Reading consistency')),
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: onPreviousMonth,
                  color: colors.textSecondary,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  _monthLabel(month),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: onNextMonth,
                  color: colors.textSecondary,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Column(
                children: <Widget>[
                  for (final List<DateTime?> week in weeks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final DateTime? day in week)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _HeatmapCell(
                                day: day,
                                ayahs: day == null
                                    ? 0
                                    : data.ayahsForDate(_dateKey(day)),
                              ),
                            ),
                        ],
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

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.day, required this.ayahs});

  final DateTime? day;
  final int ayahs;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final Color color;
    if (day == null) {
      color = colors.background.withAlpha(0);
    } else if (ayahs <= 0) {
      color = colors.surfaceAlt;
    } else if (ayahs <= 10) {
      color = colors.primarySoft.withAlpha(102);
    } else if (ayahs <= 30) {
      color = colors.primarySoft;
    } else {
      color = colors.primary;
    }
    return SizedBox.square(
      dimension: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
      ),
    );
  }
}

class _EstimatedLettersNote extends StatelessWidget {
  const _EstimatedLettersNote({required this.data});

  final _QuranStatsViewData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.large);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const _StatIcon(icon: Icons.text_fields_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_compactNumber(data.estimatedLettersRead)} estimated Arabic letters read. Reward is with Allah.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
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

class _QuranStatsViewData {
  const _QuranStatsViewData({
    required this.ayahsToday,
    required this.ayahsThisWeek,
    required this.totalAyahsRead,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyGoal,
    required this.estimatedLettersRead,
    required this.mostReadSurahName,
    required this.mostReadSurahAyahs,
    required this.dailyAverageLabel,
    required this.activityByDate,
    required this.now,
  });

  final int ayahsToday;
  final int ayahsThisWeek;
  final int totalAyahsRead;
  final int currentStreak;
  final int longestStreak;
  final int dailyGoal;
  final int estimatedLettersRead;
  final String mostReadSurahName;
  final int mostReadSurahAyahs;
  final String dailyAverageLabel;
  final Map<String, QuranActivityDay> activityByDate;
  final DateTime now;

  double get dailyGoalProgress =>
      dailyGoal <= 0 ? 0 : (ayahsToday / dailyGoal).clamp(0.0, 1.0).toDouble();

  int ayahsForDate(String dateKey) => activityByDate[dateKey]?.ayahsRead ?? 0;

  List<_ActivityBucket> bucketsFor(_StatsRange range) {
    return switch (range) {
      _StatsRange.week => _weekBuckets(),
      _StatsRange.month => _monthBuckets(),
      _StatsRange.year => _yearBuckets(),
    };
  }

  List<_ActivityBucket> _weekBuckets() {
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return <_ActivityBucket>[
      for (int offset = 6; offset >= 0; offset--)
        _bucketForDates(
          label: labels[now.subtract(Duration(days: offset)).weekday - 1],
          detailLabel: _monthDayLabel(now.subtract(Duration(days: offset))),
          dates: <DateTime>[now.subtract(Duration(days: offset))],
          current: offset == 0,
        ),
    ];
  }

  List<_ActivityBucket> _monthBuckets() {
    final DateTime currentWeekStart = _weekStart(now);
    return <_ActivityBucket>[
      for (int offset = 5; offset >= 0; offset--)
        _bucketForDates(
          label: 'W${6 - offset}',
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
        ),
    ];
  }

  List<_ActivityBucket> _yearBuckets() {
    return <_ActivityBucket>[
      for (int offset = 11; offset >= 0; offset--)
        _bucketForMonth(DateTime(now.year, now.month - offset)),
    ];
  }

  _ActivityBucket _bucketForDates({
    required String label,
    required String detailLabel,
    required List<DateTime> dates,
    required bool current,
  }) {
    int ayahs = 0;
    for (final DateTime date in dates) {
      final QuranActivityDay? day = activityByDate[_dateKey(date)];
      if (day == null) continue;
      ayahs += day.ayahsRead;
    }
    return _ActivityBucket(
      label: label,
      detailLabel: detailLabel,
      ayahs: ayahs,
      isCurrent: current,
    );
  }

  _ActivityBucket _bucketForMonth(DateTime month) {
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
    );
  }

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
    final int ayahsThisWeek = List<int>.generate(7, (int offset) {
      return byDate[_dateKey(now.subtract(Duration(days: offset)))]
              ?.ayahsRead ??
          0;
    }).fold<int>(0, (sum, count) => sum + count);
    final Map<int, int> surahCounts = _surahCounts(activityDays);
    final MapEntry<int, int>? mostRead = surahCounts.entries.isEmpty
        ? null
        : surahCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final int activeDays = activityDays
        .where((day) => day.ayahsRead > 0 || day.readAyahKeys.isNotEmpty)
        .length;
    final double dailyAverage = activeDays <= 0
        ? 0
        : snapshot.totalAyahsRead / activeDays;

    return _QuranStatsViewData(
      ayahsToday: byDate[todayKey]?.ayahsRead ?? 0,
      ayahsThisWeek: ayahsThisWeek,
      totalAyahsRead: snapshot.totalAyahsRead,
      currentStreak: snapshot.currentStreak,
      longestStreak: _longestReadingStreak(activityDays),
      dailyGoal: _dailyGoal(),
      estimatedLettersRead: snapshot.estimatedLettersRead,
      mostReadSurahName: mostRead == null
          ? 'No surah yet'
          : quran.getSurahName(mostRead.key),
      mostReadSurahAyahs: mostRead?.value ?? 0,
      dailyAverageLabel: dailyAverage == 0
          ? '0'
          : dailyAverage.toStringAsFixed(dailyAverage >= 10 ? 0 : 1),
      activityByDate: byDate,
      now: now,
    );
  }
}

class _ActivityBucket {
  const _ActivityBucket({
    required this.label,
    required this.detailLabel,
    required this.ayahs,
    required this.isCurrent,
  });

  final String label;
  final String detailLabel;
  final int ayahs;
  final bool isCurrent;
}

enum _StatsRange {
  week('Week'),
  month('Month'),
  year('Year');

  const _StatsRange(this.label);

  final String label;
}

int _dailyGoal() {
  final dynamic saved = SettingsDB().get('dailyQuranGoalAyahs');
  if (saved is int) return saved.clamp(1, 1000).toInt();
  if (saved is String) {
    return (int.tryParse(saved) ?? 20).clamp(1, 1000).toInt();
  }
  return 20;
}

Map<int, int> _surahCounts(List<QuranActivityDay> activityDays) {
  final Map<int, int> counts = <int, int>{};
  for (final QuranActivityDay day in activityDays) {
    for (final String key in day.readAyahKeys) {
      final int? surah = int.tryParse(key.split(':').first);
      if (surah == null || surah < 1 || surah > 114) continue;
      counts[surah] = (counts[surah] ?? 0) + 1;
    }
  }
  return counts;
}

DateTime _weekStart(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

List<List<DateTime?>> _monthWeeks(DateTime month) {
  final DateTime first = DateTime(month.year, month.month);
  final DateTime last = DateTime(month.year, month.month + 1, 0);
  final int leadingBlanks = first.weekday - 1;
  final int totalCells = leadingBlanks + last.day;
  final int rows = (totalCells / 7).ceil();
  return <List<DateTime?>>[
    for (int row = 0; row < rows; row++)
      <DateTime?>[
        for (int column = 0; column < 7; column++)
          _monthCellDate(first, row, column, leadingBlanks, last.day),
      ],
  ];
}

DateTime? _monthCellDate(
  DateTime first,
  int row,
  int column,
  int leadingBlanks,
  int daysInMonth,
) {
  final int index = row * 7 + column;
  final int dayNumber = index - leadingBlanks + 1;
  if (dayNumber < 1 || dayNumber > daysInMonth) return null;
  return DateTime(first.year, first.month, dayNumber);
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
