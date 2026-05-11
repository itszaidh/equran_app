import 'package:equran/backend/library.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  _DhikrPreset _selectedPreset = _DhikrPreset.presets.first;
  int _count = 0;

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
      body: ListView(
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _TasbihHero(
                    preset: _selectedPreset,
                    count: _count,
                    target: _selectedPreset.target,
                  ),
                  const SizedBox(height: 18),
                  _CounterCard(
                    count: _count,
                    onIncrement: _increment,
                    onReset: _reset,
                    onSave: _saveSession,
                  ),
                  const SizedBox(height: 18),
                  _PresetSelector(
                    selected: _selectedPreset,
                    onSelected: _selectPreset,
                  ),
                  const SizedBox(height: 22),
                  _RecentDhikrSessions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _increment() {
    setState(() {
      _count += 1;
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _selectPreset(_DhikrPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _count = 0;
    });
  }

  Future<void> _saveSession() async {
    if (_count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count some dhikr first')),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DhikrSessionEntry session = DhikrSessionEntry(
      id: 'dhikr:${now.microsecondsSinceEpoch}',
      label: _selectedPreset.label,
      targetCount: _selectedPreset.target,
      count: _count,
      startedAt: now,
      completedAt: _count >= _selectedPreset.target ? now : null,
    );
    await DhikrSessionsDB().put(session.id, session);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dhikr session saved')),
    );
  }
}

class _TasbihHero extends StatelessWidget {
  const _TasbihHero({
    required this.preset,
    required this.count,
    required this.target,
  });

  final _DhikrPreset preset;
  final int count;
  final int target;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final double progress = target <= 0
        ? 0
        : (count / target).clamp(0.0, 1.0).toDouble();

    return EquranGradientCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              EquranIconBadge(
                icon: Icons.auto_awesome_outlined,
                backgroundColor: colors.onPrimary.withAlpha(26),
                foregroundColor: colors.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  preset.label,
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
            '$count / $target',
            style: theme.textTheme.displayMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(EquranRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              color: colors.onPrimary,
              backgroundColor: colors.onPrimary.withAlpha(40),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress >= 1
                ? 'Target complete. Save the session when you are ready.'
                : 'A calm counter for daily remembrance.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.count,
    required this.onIncrement,
    required this.onReset,
    required this.onSave,
  });

  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        children: <Widget>[
          Text(
            '$count',
            style: theme.textTheme.displayLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 168,
            height: 168,
            child: FilledButton(
              onPressed: onIncrement,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                textStyle: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Count'),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.selected,
    required this.onSelected,
  });

  final _DhikrPreset selected;
  final ValueChanged<_DhikrPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Presets',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final _DhikrPreset preset in _DhikrPreset.presets)
                ChoiceChip(
                  selected: selected == preset,
                  label: Text('${preset.label} ${preset.target}'),
                  onSelected: (_) => onSelected(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentDhikrSessions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: DhikrSessionsDB().listener,
      builder: (BuildContext context, Box<dynamic> box, Widget? child) {
        final List<DhikrSessionEntry> sessions =
            box.values.whereType<DhikrSessionEntry>().toList(growable: false)
              ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final List<DhikrSessionEntry> latest =
            sessions.take(3).toList(growable: false);
        if (latest.isEmpty) {
          return const SizedBox.shrink();
        }

        final EquranColors colors = context.equranColors;
        return EquranSurfaceCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Recent sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              for (final DhikrSessionEntry session in latest)
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
                    '${session.count} of ${session.targetCount} counted',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DhikrPreset {
  const _DhikrPreset(this.label, this.target);

  final String label;
  final int target;

  static const List<_DhikrPreset> presets = <_DhikrPreset>[
    _DhikrPreset('SubhanAllah', 33),
    _DhikrPreset('Alhamdulillah', 33),
    _DhikrPreset('Allahu Akbar', 34),
    _DhikrPreset('Astaghfirullah', 100),
  ];
}
