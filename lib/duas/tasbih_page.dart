import 'dart:async';
import 'dart:math' as math;

import 'package:equran/backend/library.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

const String _tasbihDesignAsset = 'assets/images/app_assets/design.png';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  static const String _selectedPresetKey = 'tasbih.selectedPreset';
  static const String _currentCountKey = 'tasbih.currentCount';
  static const String _hapticsKey = 'tasbih.hapticsEnabled';

  int _selectedPresetIndex = 0;
  int _count = 0;
  bool _hapticsEnabled = true;
  DateTime _sessionStartedAt = DateTime.now();
  DateTime? _postPrayerSequenceStartedAt;
  final List<int> _postPrayerSequenceCounts = <int>[0, 0, 0];
  int _liveUnsavedCountToday = 0;
  int _liveUnsavedRoundsToday = 0;
  String? _completionMessage;

  _DhikrPreset get _selectedPreset =>
      _DhikrPreset.presets[_selectedPresetIndex];

  @override
  void initState() {
    super.initState();
    final dynamic savedIndex = SettingsDB().get(
      _selectedPresetKey,
      defaultValue: 0,
    );
    final dynamic savedCount = SettingsDB().get(
      _currentCountKey,
      defaultValue: 0,
    );
    _selectedPresetIndex = savedIndex is int
        ? savedIndex.clamp(0, _DhikrPreset.presets.length - 1).toInt()
        : 0;
    _count = savedCount is int ? savedCount.clamp(0, 100000).toInt() : 0;
    _hapticsEnabled = SettingsDB().get(_hapticsKey, defaultValue: true) == true;
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Tasbih'),
        centerTitle: true,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: DhikrSessionsDB().listener,
        builder: (context, box, child) {
          final List<DhikrSessionEntry> sessions =
              box.values.whereType<DhikrSessionEntry>().toList(growable: false)
                ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
          final _TasbihStats stats = _TasbihStats.fromSessions(
            sessions,
            currentCount: _count,
            currentStartedAt: _sessionStartedAt,
            liveUnsavedCount: _liveUnsavedCountToday,
            liveUnsavedRounds: _liveUnsavedRoundsToday,
          );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              EquranSpacing.pagePadding,
              10,
              EquranSpacing.pagePadding,
              32,
            ),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _TasbihStatsCard(stats: stats),
                      const SizedBox(height: 10),
                      _PresetSelector(
                        selectedIndex: _selectedPresetIndex,
                        onSelected: _selectPreset,
                      ),
                      const SizedBox(height: 10),
                      _CircularCounter(
                        preset: _selectedPreset,
                        count: _count,
                        completionMessage: _completionMessage,
                        onTap: _increment,
                      ),
                      const SizedBox(height: 10),
                      _CounterActions(
                        hapticsEnabled: _hapticsEnabled,
                        onReset: _reset,
                        onHapticsChanged: _setHapticsEnabled,
                      ),
                      const SizedBox(height: 14),
                      _RecentDhikrSessions(sessions: sessions.take(5).toList()),
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

  Future<void> _increment() async {
    final _DhikrPreset preset = _selectedPreset;
    final int nextCount = _count + 1;
    if (_hapticsEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() {
      _count = nextCount;
    });
    _persistCurrentState();

    if (nextCount >= preset.target) {
      await _completePreset(preset, nextCount);
    }
  }

  Future<void> _completePreset(_DhikrPreset preset, int completedCount) async {
    if (_hapticsEnabled) {
      unawaited(HapticFeedback.heavyImpact());
    }
    final bool groupedCompletion = await _recordCompletedPreset(
      preset,
      completedCount,
    );
    if (!mounted) return;

    final int nextIndex = _nextPresetIndex(_selectedPresetIndex);
    setState(() {
      _completionMessage = groupedCompletion
          ? 'Post-prayer dhikr complete'
          : '${preset.label} complete';
      _selectedPresetIndex = nextIndex;
      _count = 0;
      _sessionStartedAt = DateTime.now();
    });
    _persistCurrentState();

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() {
          _completionMessage = null;
        });
      }),
    );
  }

  int _nextPresetIndex(int currentIndex) {
    if (currentIndex >= 0 && currentIndex < 2) return currentIndex + 1;
    if (currentIndex == 2) return 0;
    return currentIndex;
  }

  void _reset() {
    setState(() {
      _count = 0;
      _sessionStartedAt = DateTime.now();
      _resetPostPrayerSequence();
      _liveUnsavedCountToday = 0;
      _liveUnsavedRoundsToday = 0;
      _completionMessage = null;
    });
    _persistCurrentState();
  }

  void _selectPreset(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _count = 0;
      _sessionStartedAt = DateTime.now();
      if (index < 0 || index > 2) {
        _resetPostPrayerSequence();
      }
      _completionMessage = null;
    });
    _persistCurrentState();
  }

  Future<void> _setHapticsEnabled(bool enabled) async {
    setState(() {
      _hapticsEnabled = enabled;
    });
    await SettingsDB().put(_hapticsKey, enabled);
  }

  Future<void> _saveSession({required bool manual, int? completedCount}) async {
    final int count = completedCount ?? _count;
    if (count <= 0) {
      if (!manual || !mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Count some dhikr first')));
      return;
    }

    final DateTime now = DateTime.now();
    final _DhikrPreset preset = _selectedPreset;
    final bool completed = count >= preset.target;
    final DhikrSessionEntry session = DhikrSessionEntry(
      id: 'dhikr:${now.microsecondsSinceEpoch}',
      label: preset.label,
      targetCount: preset.target,
      count: count,
      startedAt: _sessionStartedAt,
      completedAt: completed ? now : null,
    );
    await DhikrSessionsDB().put(session.id, session);
    if (!manual || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dhikr session saved')));
  }

  Future<bool> _recordCompletedPreset(
    _DhikrPreset preset,
    int completedCount,
  ) async {
    final int sequenceIndex = _selectedPresetIndex;
    if (sequenceIndex < 0 || sequenceIndex > 2) {
      await _saveSession(manual: false, completedCount: completedCount);
      return false;
    }

    _postPrayerSequenceStartedAt ??= _sessionStartedAt;
    _postPrayerSequenceCounts[sequenceIndex] = completedCount
        .clamp(0, preset.target)
        .toInt();

    final bool sequenceComplete =
        _postPrayerSequenceCounts[0] >= 33 &&
        _postPrayerSequenceCounts[1] >= 33 &&
        _postPrayerSequenceCounts[2] >= 34;
    if (!sequenceComplete) {
      setState(() {
        _liveUnsavedCountToday += completedCount;
        _liveUnsavedRoundsToday += 1;
      });
      return false;
    }

    final DateTime now = DateTime.now();
    final DhikrSessionEntry session = DhikrSessionEntry(
      id: 'dhikr:post-prayer:${now.microsecondsSinceEpoch}',
      label: 'Post-prayer dhikr',
      targetCount: 100,
      count: 100,
      startedAt: _postPrayerSequenceStartedAt ?? _sessionStartedAt,
      completedAt: now,
    );
    await DhikrSessionsDB().put(session.id, session);
    _resetPostPrayerSequence();
    setState(() {
      _liveUnsavedCountToday = 0;
      _liveUnsavedRoundsToday = 0;
    });
    if (_hapticsEnabled) {
      unawaited(HapticFeedback.heavyImpact());
    }
    return true;
  }

  void _resetPostPrayerSequence() {
    _postPrayerSequenceStartedAt = null;
    for (int i = 0; i < _postPrayerSequenceCounts.length; i++) {
      _postPrayerSequenceCounts[i] = 0;
    }
  }

  void _persistCurrentState() {
    unawaited(SettingsDB().put(_selectedPresetKey, _selectedPresetIndex));
    unawaited(SettingsDB().put(_currentCountKey, _count));
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    final _DhikrPreset selectedPreset = _DhikrPreset.presets[selectedIndex];

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      backgroundColor: colors.surfaceSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              EquranIconBadge(
                icon: Icons.auto_awesome_rounded,
                size: 30,
                backgroundColor: colors.mint,
                foregroundColor: colors.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      selectedPreset.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${selectedPreset.target} counts • 33 -> 33 -> 34',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _DhikrPreset.presets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                return _PresetPill(
                  preset: _DhikrPreset.presets[index],
                  selected: index == selectedIndex,
                  sequenceStep: index < 3 ? index + 1 : null,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({
    required this.preset,
    required this.selected,
    required this.onTap,
    this.sequenceStep,
  });

  final _DhikrPreset preset;
  final bool selected;
  final VoidCallback onTap;
  final int? sequenceStep;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    final Color foreground = selected ? colors.onPrimary : colors.textPrimary;
    final BorderRadius radius = BorderRadius.circular(EquranRadii.pill);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          decoration: BoxDecoration(
            gradient: selected ? colors.heroGradient : null,
            color: selected ? null : colors.surface.withAlpha(178),
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? colors.primarySoft.withAlpha(170)
                  : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.onPrimary.withAlpha(34)
                      : colors.mint,
                  shape: BoxShape.circle,
                ),
                child: sequenceStep == null
                    ? Icon(
                        preset.label == 'Custom'
                            ? Icons.tune_rounded
                            : Icons.spa_rounded,
                        color: selected ? colors.onPrimary : colors.primary,
                        size: 16,
                      )
                    : Text(
                        '$sequenceStep',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected ? colors.onPrimary : colors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(width: 7),
              Text(
                '${preset.compactLabel} ${preset.target}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularCounter extends StatelessWidget {
  const _CircularCounter({
    required this.preset,
    required this.count,
    required this.completionMessage,
    required this.onTap,
  });

  final _DhikrPreset preset;
  final int count;
  final String? completionMessage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);
    final double progress = preset.target <= 0
        ? 0
        : (count / preset.target).clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double ringSize = math.min(198, constraints.maxWidth - 42);
        return EquranSurfaceCard(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          backgroundColor: colors.surfaceSoft,
          borderColor: colors.primary.withAlpha(44),
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(_tasbihDesignAsset, fit: BoxFit.cover),
                    ),
                  ),
                  CustomPaint(
                    painter: _CounterRingPainter(
                      progress: progress,
                      trackColor: colors.border,
                      progressColor: colors.primarySoft,
                      glowColor: colors.primary,
                    ),
                    child: SizedBox.square(
                      dimension: ringSize.clamp(152, 198).toDouble(),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '$count',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: colors.textPrimary,
                                fontSize: 54,
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '/ ${preset.target}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                preset.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                completionMessage ??
                    (preset.sequenceHint.isEmpty
                        ? 'Tap anywhere on this card'
                        : preset.sequenceHint),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: completionMessage == null
                      ? colors.textSecondary
                      : colors.primarySoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CounterActions extends StatelessWidget {
  const _CounterActions({
    required this.hapticsEnabled,
    required this.onReset,
    required this.onHapticsChanged,
  });

  final bool hapticsEnabled;
  final VoidCallback onReset;
  final ValueChanged<bool> onHapticsChanged;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(11, 6, 10, 6),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
          ),
          const Spacer(),
          Icon(Icons.vibration_rounded, color: colors.textMuted, size: 20),
          const SizedBox(width: 6),
          Text(
            'Haptics',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Switch(value: hapticsEnabled, onChanged: onHapticsChanged),
        ],
      ),
    );
  }
}

class _TasbihStatsCard extends StatelessWidget {
  const _TasbihStatsCard({required this.stats});

  final _TasbihStats stats;

  @override
  Widget build(BuildContext context) {
    return EquranGradientCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -26,
            top: -34,
            bottom: -34,
            width: 160,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(_tasbihDesignAsset, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatsValue(
                    label: 'Today',
                    value: '${stats.totalToday}',
                  ),
                ),
                Expanded(
                  child: _StatsValue(
                    label: 'Rounds',
                    value: '${stats.roundsToday}',
                  ),
                ),
                Expanded(
                  child: _StatsValue(
                    label: 'Streak',
                    value: '${stats.streak}d',
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

class _StatsValue extends StatelessWidget {
  const _StatsValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Column(
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onPrimaryMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RecentDhikrSessions extends StatelessWidget {
  const _RecentDhikrSessions({required this.sessions});

  final List<DhikrSessionEntry> sessions;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recent sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Saved dhikr sessions will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            for (final DhikrSessionEntry session in sessions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: EquranIconBadge(
                  icon: session.completedAt == null
                      ? Icons.radio_button_checked_rounded
                      : Icons.check_rounded,
                  size: 36,
                ),
                title: Text(session.label),
                subtitle: Text(
                  session.label == 'Post-prayer dhikr'
                      ? 'SubhanAllah 33 • Alhamdulillah 33 • Allahu Akbar 34\n${_sessionTimeLabel(session)}'
                      : '${session.count} of ${session.targetCount} counted • ${_sessionTimeLabel(session)}',
                ),
                trailing: Text(
                  session.completedAt == null ? 'Saved' : 'Done',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: session.completedAt == null
                        ? colors.textMuted
                        : colors.primarySoft,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CounterRingPainter extends CustomPainter {
  const _CounterRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 12;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final Paint glow = Paint()
      ..color = glowColor.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: <Color>[progressColor, glowColor, progressColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    if (progress <= 0) return;
    final double sweep = (math.pi * 2) * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CounterRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        trackColor != oldDelegate.trackColor ||
        progressColor != oldDelegate.progressColor ||
        glowColor != oldDelegate.glowColor;
  }
}

class _TasbihStats {
  const _TasbihStats({
    required this.totalToday,
    required this.roundsToday,
    required this.streak,
  });

  final int totalToday;
  final int roundsToday;
  final int streak;

  static _TasbihStats fromSessions(
    List<DhikrSessionEntry> sessions, {
    required int currentCount,
    required DateTime currentStartedAt,
    required int liveUnsavedCount,
    required int liveUnsavedRounds,
  }) {
    final String today = _dateKey(DateTime.now());
    int totalToday = liveUnsavedCount;
    int roundsToday = liveUnsavedRounds;
    final Set<String> completedDates = <String>{};

    for (final DhikrSessionEntry session in sessions) {
      if (_dateKey(session.startedAt) == today) {
        totalToday += session.count;
      }
      final DateTime? completedAt = session.completedAt;
      if (completedAt != null) {
        completedDates.add(_dateKey(completedAt));
        if (_dateKey(completedAt) == today) {
          roundsToday += session.label == 'Post-prayer dhikr' ? 3 : 1;
        }
      }
    }
    if (_dateKey(currentStartedAt) == today) {
      totalToday += currentCount;
    }

    int streak = 0;
    DateTime cursor = DateTime.now();
    while (completedDates.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return _TasbihStats(
      totalToday: totalToday,
      roundsToday: roundsToday,
      streak: streak,
    );
  }
}

class _DhikrPreset {
  const _DhikrPreset({
    required this.label,
    required this.target,
    this.shortLabel,
    this.sequenceHint = '',
  });

  final String label;
  final int target;
  final String? shortLabel;
  final String sequenceHint;

  String get compactLabel => shortLabel ?? label;

  static const List<_DhikrPreset> presets = <_DhikrPreset>[
    _DhikrPreset(
      label: 'SubhanAllah',
      shortLabel: 'Subhan',
      target: 33,
      sequenceHint: 'Auto-advances to Alhamdulillah',
    ),
    _DhikrPreset(
      label: 'Alhamdulillah',
      shortLabel: 'Hamd',
      target: 33,
      sequenceHint: 'Auto-advances to Allahu Akbar',
    ),
    _DhikrPreset(
      label: 'Allahu Akbar',
      shortLabel: 'Akbar',
      target: 34,
      sequenceHint: 'Completes the post-prayer sequence',
    ),
    _DhikrPreset(label: 'Astaghfirullah', shortLabel: 'Istighfar', target: 100),
    _DhikrPreset(label: 'Custom', target: 100),
  ];
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _sessionTimeLabel(DhikrSessionEntry session) {
  final DateTime time = session.completedAt ?? session.startedAt;
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String period = time.hour >= 12 ? 'PM' : 'AM';
  return '${time.month}/${time.day} $hour:${time.minute.toString().padLeft(2, '0')} $period';
}
