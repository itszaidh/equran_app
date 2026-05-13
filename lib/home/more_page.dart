import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:equran/widgets/last_read_cards.dart'
    show equranResumeQuranAsset;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String _appDownloadUrl =
    'https://f-droid.org/en/packages/com.app.equran/';
const String _issueReportUrl = 'https://github.com/ya27hw/equran_app/issues';
const String _contactEmail = 'equran@elbaesy.com';

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.onOpenPlayer,
    required this.onOpenQibla,
    required this.onOpenDownloads,
    required this.onOpenSearch,
    required this.onOpenReadingPlans,
    required this.onOpenTasbih,
    required this.onOpenAsmaUlHusna,
    required this.onOpenSettings,
    required this.onOpenStats,
    required this.onToggleTheme,
  });

  final VoidCallback onOpenPlayer;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenDownloads;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenReadingPlans;
  final VoidCallback onOpenTasbih;
  final VoidCallback onOpenAsmaUlHusna;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenStats;
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
                        icon: Icons.diamond_outlined,
                        title: 'Asma ul Husna',
                        subtitle: 'The 99 Beautiful Names',
                        onTap: onOpenAsmaUlHusna,
                      ),
                      _MoreAction(
                        icon: Icons.insights_outlined,
                        title: 'Quran Stats',
                        subtitle: 'Streaks, goals, and weekly reading',
                        onTap: onOpenStats,
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
                  const SizedBox(height: 18),
                  _MoreSupportSection(
                    onAbout: () => _showAboutApp(context),
                    onShare: () => _shareApp(context),
                    onFeedback: () => _openFeedbackContactPage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutApp(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showAboutDialog(
      context: context,
      applicationName: 'eQuran',
      applicationVersion: 'Version ${packageInfo.version}',
      applicationIcon: Icon(
        Icons.menu_book_rounded,
        color: colorScheme.primary,
        size: 40,
      ),
      children: const <Widget>[
        SizedBox(height: 16),
        Text(
          'eQuran is a modern Quran companion designed for focused reading, listening, and daily reflection.',
        ),
      ],
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'eQuran',
          subject: 'Download eQuran',
          text: 'Download eQuran on F-Droid: $_appDownloadUrl',
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Unable to open the share sheet.');
    }
  }

  void _openFeedbackContactPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _FeedbackContactPage(),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          const Positioned.fill(child: _MoreHeroArtwork()),
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

class _MoreHeroArtwork extends StatelessWidget {
  const _MoreHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 340;
        final double artworkEdgePadding = _artworkEdgePadding(
          constraints.maxWidth,
        );
        final double artWidth = compact ? 120 : 144;

        return IgnorePointer(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: artworkEdgePadding),
              child: Opacity(
                opacity: 0.18,
                child: SizedBox(
                  width: artWidth,
                  child: Image.asset(
                    equranResumeQuranAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _artworkEdgePadding(double width) {
    if (width < 340) return 2;
    if (width < 430) return 6;
    if (width < 560) return 12;
    return 18;
  }
}

class _MoreShortcutsGrid extends StatelessWidget {
  const _MoreShortcutsGrid({required this.items});

  final List<_MoreAction> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 670 ? 2 : 1;
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

class _MoreSupportSection extends StatelessWidget {
  const _MoreSupportSection({
    required this.onAbout,
    required this.onShare,
    required this.onFeedback,
  });

  final VoidCallback onAbout;
  final VoidCallback onShare;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) {
    return EquranSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MoreSupportTile(
            icon: Icons.info_outline_rounded,
            title: 'About this app',
            onTap: onAbout,
          ),
          const Divider(height: 1),
          _MoreSupportTile(
            icon: Icons.share_outlined,
            title: 'Share app',
            onTap: onShare,
          ),
          const Divider(height: 1),
          _MoreSupportTile(
            icon: Icons.feedback_outlined,
            title: 'Feedback / Contact',
            onTap: onFeedback,
          ),
        ],
      ),
    );
  }
}

class _MoreSupportTile extends StatelessWidget {
  const _MoreSupportTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: colors.primary),
      title: Text(title),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
      onTap: onTap,
    );
  }
}

class _FeedbackContactPage extends StatelessWidget {
  const _FeedbackContactPage();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback / Contact'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
        actionsIconTheme: IconThemeData(color: colors.textSecondary),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Report issues'),
            subtitle: const Text('Open the GitHub issue tracker.'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () async {
              final Uri uri = Uri.parse(_issueReportUrl);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
                  context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to open issue tracker.'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email support'),
            subtitle: Text(_contactEmail),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'mailto',
                path: _contactEmail,
                queryParameters: <String, String>{'subject': 'eQuran feedback'},
              );
              if (!await launchUrl(uri) && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to open email client.')),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'We appreciate your feedback and suggestions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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
