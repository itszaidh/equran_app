import 'dart:async';
import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/home/read.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;

const int _totalSurahs = 114;
const int _surahGridColumns = 10;
const int _surahCellAnimationMs = 300;
const int _surahCellStaggerMs = 8;
const int _surahGridAnimationMs =
    _surahCellAnimationMs + ((_totalSurahs - 1) * _surahCellStaggerMs);

final Map<String, int> _letterCountCache = <String, int>{};

class QuranStatsPage extends StatefulWidget {
  const QuranStatsPage({super.key});

  @override
  State<QuranStatsPage> createState() => _QuranStatsPageState();
}

class _QuranStatsPageState extends State<QuranStatsPage>
    with SingleTickerProviderStateMixin {
  _StatsRange _range = _StatsRange.week;
  DateTime _heatmapMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _editingGoal = false;
  late final TextEditingController _goalController;
  late final FocusNode _goalFocusNode;
  late final AnimationController _surahGridController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: _dailyGoal().toString());
    _goalFocusNode = FocusNode();
    _surahGridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _surahGridAnimationMs),
    )..forward();
  }

  @override
  void dispose() {
    _surahGridController.dispose();
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

  void _openSurah(int surah) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReadPage(chapter: surah, startVerse: 1),
      ),
    );
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
              valueListenable: SettingsDB().listener,
              builder: (context, settingsBox, _) {
                final _QuranStatsViewData data =
                    _QuranStatsViewData.fromStorage();
                final List<_ActivityBucket> buckets = data.bucketsFor(_range);

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
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  if (data.currentStreak > 0) ...<Widget>[
                                    const SizedBox(height: 14),
                                    _StreakBanner(streak: data.currentStreak),
                                  ],
                                  const SizedBox(height: 20),
                                  _ActivityCard(
                                    buckets: buckets,
                                    range: _range,
                                    onRangeChanged: (range) {
                                      setState(() => _range = range);
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _StatsGrid(data: data),
                                  const SizedBox(height: 24),
                                  _InsightsSection(insights: data.insights),
                                  const SizedBox(height: 24),
                                  _SurahProgressSection(
                                    completedSurahs: data.completedSurahs,
                                    animationController: _surahGridController,
                                    onOpenSurah: _openSurah,
                                  ),
                                  const SizedBox(height: 24),
                                  _KhatmTrackerSection(
                                    completionDates: data.khatmCompletionDates,
                                  ),
                                  const SizedBox(height: 24),
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
    final String motivation = _dailyGoalMotivation(data.dailyGoalProgress);
    final int displayedToday = data.ayahsTodayForGoal;

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
              top: -36,
              right: -28,
              width: 178,
              height: 178,
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: colors.onPrimary,
                  opacity: 0.10,
                ),
              ),
            ),
            Padding(
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
                                        '$displayedToday / ${data.dailyGoal} ayahs today',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colors.onPrimaryMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${(data.dailyGoalProgress * 100).round()}%',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                                const SizedBox(height: 8),
                                Text(
                                  motivation,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.onPrimaryMuted,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
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

  String _dailyGoalMotivation(double progress) {
    if (progress >= 1) return 'Mashallah! Daily goal complete';
    if (progress >= 0.5) return 'Great progress, keep going';
    if (progress > 0) return 'Every ayah counts, keep reading';
    return 'Start your reading for today';
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StreakBanner extends StatefulWidget {
  const _StreakBanner({required this.streak});

  final int streak;

  @override
  State<_StreakBanner> createState() => _StreakBannerState();
}

class _StreakBannerState extends State<_StreakBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
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

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.goldSoft,
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(color: colors.accentGold.withAlpha(102)),
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
                    '${widget.streak} day streak — keep it going!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w600,
                    ),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.pill);
    return Material(
      color: colors.onPrimary.withAlpha(38),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: SizedBox.square(
          dimension: 42,
          child: Icon(Icons.edit_rounded, color: colors.onPrimary),
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
          child: _AnimatedFractionallySizedBox(
            widthFactor: progress,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
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

class _AnimatedFractionallySizedBox extends StatelessWidget {
  const _AnimatedFractionallySizedBox({
    required this.widthFactor,
    required this.duration,
    required this.curve,
    required this.child,
  });

  final double widthFactor;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widthFactor.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(widthFactor: value, child: child),
        );
      },
      child: child,
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
                  const Expanded(child: _SectionLabel('activity')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('Lifetime totals'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final double gap = constraints.maxWidth >= 720 ? 12 : 10;
            final double tileWidth = (constraints.maxWidth - gap) / 2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _StatCard(
                        width: tileWidth,
                        icon: Icons.done_all_rounded,
                        value: '${data.totalAyahsRead}',
                        label: 'Total ayahs',
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _StatCard(
                        width: tileWidth,
                        icon: Icons.text_fields_rounded,
                        value: _compactNumber(data.estimatedLettersRead),
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
                        width: tileWidth,
                        icon: Icons.calendar_today_rounded,
                        value: '${data.totalActiveDays}',
                        label: 'Active days',
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: _StatCard(
                        width: tileWidth,
                        icon: Icons.event_available_rounded,
                        value: data.mostActiveDayName,
                        label: 'Most active day',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                _MostReadSurahCard(data: data),
              ],
            );
          },
        ),
      ],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
              const SizedBox(width: 14),
              const _StatIcon(icon: Icons.menu_book_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.insights});

  final List<_InsightData> insights;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('Your Insights'),
        const SizedBox(height: 12),
        Stack(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < insights.length;
                    index++
                  ) ...<Widget>[
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
        ),
      ],
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.insight});

  final _InsightData insight;

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
    required this.completedSurahs,
    required this.animationController,
    required this.onOpenSurah,
  });

  final Set<int> completedSurahs;
  final AnimationController animationController;
  final ValueChanged<int> onOpenSurah;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('Surah Progress'),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _totalSurahs,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _surahGridColumns,
                childAspectRatio: 1,
                mainAxisSpacing: EquranSpacing.xs,
                crossAxisSpacing: EquranSpacing.xs,
              ),
              itemBuilder: (context, index) {
                final int surah = index + 1;
                final bool complete = completedSurahs.contains(surah);
                final double progress = _surahCellProgress(
                  animationController.value,
                  index,
                );

                return _SurahProgressCell(
                  surah: surah,
                  complete: complete,
                  animationProgress: progress,
                  onTap: complete ? () => onOpenSurah(surah) : null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          '${completedSurahs.length} of $_totalSurahs Surahs complete',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
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
    final Widget content = DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: label,
    );

    return Opacity(
      opacity: animationProgress,
      child: Transform.scale(
        scale: 0.8 + (0.2 * animationProgress),
        child: onTap == null
            ? content
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
    required this.totalAyahsRead,
    required this.currentStreak,
    required this.dailyGoal,
    required this.estimatedLettersRead,
    required this.totalActiveDays,
    required this.mostActiveDayName,
    required this.mostReadSurahName,
    required this.mostReadSurahAyahs,
    required this.completedSurahs,
    required this.khatmCompletionDates,
    required this.insights,
    required this.activityByDate,
    required this.now,
  });

  final int ayahsToday;
  final int totalAyahsRead;
  final int currentStreak;
  final int dailyGoal;
  final int estimatedLettersRead;
  final int totalActiveDays;
  final String mostActiveDayName;
  final String mostReadSurahName;
  final int mostReadSurahAyahs;
  final Set<int> completedSurahs;
  final List<DateTime> khatmCompletionDates;
  final List<_InsightData> insights;
  final Map<String, QuranActivityDay> activityByDate;
  final DateTime now;

  double get dailyGoalProgress =>
      dailyGoal <= 0 ? 0 : (ayahsToday / dailyGoal).clamp(0.0, 1.0).toDouble();

  int get ayahsTodayForGoal => ayahsToday.clamp(0, dailyGoal).toInt();

  int ayahsForDate(String dateKey) => _dayAyahCount(activityByDate[dateKey]);

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
      ayahs += _dayAyahCount(day);
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
    final Map<String, QuranActivityDay> byDate = <String, QuranActivityDay>{
      for (final QuranActivityDay day in activityDays) day.dateKey: day,
    };
    final int totalAyahsRead = activityDays.fold<int>(
      0,
      (sum, day) => sum + _dayAyahCount(day),
    );
    final int estimatedLettersRead = _estimatedLettersRead(activityDays);
    final Map<int, int> surahCounts = _surahCounts(activityDays);
    final MapEntry<int, int>? mostRead = surahCounts.entries.isEmpty
        ? null
        : surahCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final int activeDays = activityDays.where(_hasReadingActivity).length;
    final int? mostActiveWeekday = _mostActiveWeekday(activityDays);
    final Map<int, Set<int>> readAyahsBySurah = _readAyahsBySurah(activityDays);
    final Set<int> completedSurahs = _completedSurahs(readAyahsBySurah);
    final Map<int, int> surahVisitCounts = _surahVisitCounts(activityDays);
    final List<DateTime> khatmCompletionDates = _khatmCompletionDates(
      activityDays,
    );

    return _QuranStatsViewData(
      ayahsToday: _dayAyahCount(byDate[todayKey]),
      totalAyahsRead: totalAyahsRead,
      currentStreak: _currentReadingStreak(activityDays, now),
      dailyGoal: _dailyGoal(),
      estimatedLettersRead: estimatedLettersRead,
      totalActiveDays: activeDays,
      mostActiveDayName: mostActiveWeekday == null
          ? 'No day yet'
          : _weekdayName(mostActiveWeekday),
      mostReadSurahName: mostRead == null
          ? 'No surah yet'
          : quran.getSurahName(mostRead.key),
      mostReadSurahAyahs: mostRead?.value ?? 0,
      completedSurahs: completedSurahs,
      khatmCompletionDates: khatmCompletionDates,
      insights: _buildInsights(
        activityDays: activityDays,
        activityByDate: byDate,
        now: now,
        surahVisitCounts: surahVisitCounts,
      ),
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

class _InsightData {
  const _InsightData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ReadAyahRef {
  const _ReadAyahRef({required this.surah, required this.verse});

  final int surah;
  final int verse;

  String get key => '$surah:$verse';
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

int _dayAyahCount(QuranActivityDay? day) {
  if (day == null) return 0;
  return math.max(day.ayahsRead, day.readAyahKeys.length);
}

bool _hasReadingActivity(QuranActivityDay day) {
  return _dayAyahCount(day) > 0 || day.pagesRead > 0 || day.readingSeconds > 0;
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
  final List<QuranActivityDay> sortedDays = _sortedActivityDays(activityDays);
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

List<QuranActivityDay> _sortedActivityDays(List<QuranActivityDay> days) {
  return days.toList(growable: false)
    ..sort((a, b) => _activityDayDate(a).compareTo(_activityDayDate(b)));
}

DateTime _activityDayDate(QuranActivityDay day) {
  final DateTime? parsed = DateTime.tryParse(day.dateKey);
  if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
  return DateTime(day.updatedAt.year, day.updatedAt.month, day.updatedAt.day);
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

List<_InsightData> _buildInsights({
  required List<QuranActivityDay> activityDays,
  required Map<String, QuranActivityDay> activityByDate,
  required DateTime now,
  required Map<int, int> surahVisitCounts,
}) {
  final List<_InsightData> insights = <_InsightData>[];
  final _InsightData? activeDay = _mostActiveDayInsight(activityDays);
  if (activeDay != null) insights.add(activeDay);

  final _InsightData? trend = _readingTrendInsight(activityByDate, now);
  if (trend != null) insights.add(trend);

  final _InsightData? favourite = _favouriteSurahInsight(surahVisitCounts);
  if (favourite != null) insights.add(favourite);

  if (insights.isEmpty) {
    return const <_InsightData>[
      _InsightData(
        icon: Icons.auto_awesome_rounded,
        label: 'Start reading to unlock insights',
      ),
    ];
  }

  return insights.take(3).toList(growable: false);
}

_InsightData? _mostActiveDayInsight(List<QuranActivityDay> activityDays) {
  final int? bestWeekday = _mostActiveWeekday(activityDays);
  if (bestWeekday == null) return null;

  return _InsightData(
    icon: Icons.calendar_month_rounded,
    label: 'You read most on ${_weekdayPlural(bestWeekday)}',
  );
}

int? _mostActiveWeekday(List<QuranActivityDay> activityDays) {
  final List<int> ayahsByWeekday = List<int>.filled(8, 0);
  for (final QuranActivityDay day in activityDays) {
    final int ayahs = _dayAyahCount(day);
    if (ayahs <= 0) continue;
    ayahsByWeekday[_activityDayDate(day).weekday] += ayahs;
  }

  int bestWeekday = 0;
  int bestCount = 0;
  for (int weekday = 1; weekday < ayahsByWeekday.length; weekday++) {
    if (ayahsByWeekday[weekday] > bestCount) {
      bestWeekday = weekday;
      bestCount = ayahsByWeekday[weekday];
    }
  }
  return bestWeekday == 0 ? null : bestWeekday;
}

_InsightData? _readingTrendInsight(
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
  return _InsightData(
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

_InsightData? _favouriteSurahInsight(Map<int, int> surahVisitCounts) {
  if (surahVisitCounts.isEmpty) return null;
  final MapEntry<int, int> favourite = surahVisitCounts.entries.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );
  return _InsightData(
    icon: Icons.favorite_rounded,
    label: 'You visit ${quran.getSurahName(favourite.key)} most often',
  );
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

int _currentReadingStreak(List<QuranActivityDay> days, DateTime now) {
  final Set<String> activeDays = days
      .where(_hasReadingActivity)
      .map((day) => day.dateKey)
      .toSet();
  int streak = 0;
  DateTime cursor = DateTime(now.year, now.month, now.day);
  while (activeDays.contains(_dateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
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
