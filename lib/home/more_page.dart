import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.onOpenPlayer,
    required this.onOpenQibla,
    required this.onOpenDownloads,
    required this.onOpenSearch,
    required this.onOpenReadingPlans,
    required this.onOpenTasbih,
    required this.onOpenSettings,
    required this.onToggleTheme,
  });

  final VoidCallback onOpenPlayer;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenDownloads;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenReadingPlans;
  final VoidCallback onOpenTasbih;
  final VoidCallback onOpenSettings;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return ColoredBox(
      color: colors.background,
      child: ListView(
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
                  _MoreHero(onOpenReadingPlans: onOpenReadingPlans),
                  const SizedBox(height: 18),
                  _MoreShortcutsGrid(
                    items: <_MoreAction>[
                      _MoreAction(
                        icon: Icons.library_music_outlined,
                        title: 'Player',
                        subtitle: 'Recitations and audio controls',
                        onTap: onOpenPlayer,
                      ),
                      _MoreAction(
                        icon: Icons.explore_outlined,
                        title: 'Qibla',
                        subtitle: 'Compass and direction',
                        onTap: onOpenQibla,
                      ),
                      _MoreAction(
                        icon: Icons.download_outlined,
                        title: 'Downloads',
                        subtitle: 'Offline audio and cleanup',
                        onTap: onOpenDownloads,
                      ),
                      _MoreAction(
                        icon: Icons.travel_explore_rounded,
                        title: 'Quran Search',
                        subtitle: 'Search Arabic and translation',
                        onTap: onOpenSearch,
                      ),
                      _MoreAction(
                        icon: Icons.route_outlined,
                        title: 'Reading Routine',
                        subtitle: 'Plans, goals, and progress',
                        onTap: onOpenReadingPlans,
                      ),
                      _MoreAction(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Tasbih',
                        subtitle: 'Calm dhikr counter',
                        onTap: onOpenTasbih,
                      ),
                      _MoreAction(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Fonts, reciter, app behavior',
                        onTap: onOpenSettings,
                      ),
                      _MoreAction(
                        icon: Icons.brightness_6_outlined,
                        title: 'Theme',
                        subtitle: 'Switch light or night mode',
                        onTap: onToggleTheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreHero extends StatelessWidget {
  const _MoreHero({required this.onOpenReadingPlans});

  final VoidCallback onOpenReadingPlans;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return EquranGradientCard(
      onTap: onOpenReadingPlans,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -18,
            bottom: -22,
            width: 170,
            height: 120,
            child: EquranOpenBookMark(opacity: 0.24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your Islamic Companion',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 420,
                child: Text(
                  'Qibla, downloads, settings, plans, and tools gathered in one quiet place.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Open routine',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onPrimary,
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreShortcutsGrid extends StatelessWidget {
  const _MoreShortcutsGrid({required this.items});

  final List<_MoreAction> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 720 ? 2 : 1;
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 4.6 : 3.8,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _MoreActionTile(action: items[index]);
          },
        );
      },
    );
  }
}

class _MoreActionTile extends StatelessWidget {
  const _MoreActionTile({required this.action});

  final _MoreAction action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return EquranSurfaceCard(
      onTap: action.onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: <Widget>[
          EquranIconBadge(icon: action.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  action.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
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

class _MoreAction {
  const _MoreAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
