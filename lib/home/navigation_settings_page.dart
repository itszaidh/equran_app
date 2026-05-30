import 'package:equran/backend/library.dart' show SettingsDB;
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:equran/l10n/app_localizations.dart';

class NavigationSettingsPage extends StatefulWidget {
  const NavigationSettingsPage({super.key});

  @override
  State<NavigationSettingsPage> createState() => _NavigationSettingsPageState();
}

class _NavigationSettingsPageState extends State<NavigationSettingsPage> {
  final List<String> _allModules = const ['home', 'quran', 'prayer', 'duas', 'more'];

  List<String> _activeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    final dynamic saved = SettingsDB().get("navigation_slots");
    if (saved is List) {
      _activeSlots = List<String>.from(saved);
    } else {
      _activeSlots = ['home', 'quran', 'prayer', 'more'];
    }
  }

  Future<void> _saveSlots() async {
    await SettingsDB().put("navigation_slots", _activeSlots);
    if (mounted) setState(() {});
  }

  String _getModuleLabel(String key, AppLocalizations localizations) {
    return switch (key) {
      'stats' => localizations.statistics,
      'home' => localizations.home,
      'quran' => localizations.quran,
      'prayer' => localizations.prayer,
      'duas' => localizations.duas,
      'more' => localizations.more,
      _ => key.toUpperCase(),
    };
  }

  IconData _getModuleIcon(String key) {
    return switch (key) {
      'stats' => Icons.bar_chart_rounded,
      'home' => Icons.home_rounded,
      'quran' => Icons.menu_book_rounded,
      'prayer' => Icons.schedule_rounded,
      'duas' => Icons.auto_stories_rounded,
      'more' => Icons.grid_view_rounded,
      _ => Icons.star_rounded,
    };
  }

  void _swapOrReplaceSlot(int index, String newModule) {
    final int existingIndex = _activeSlots.indexOf(newModule);
    setState(() {
      if (existingIndex != -1) {
        // Swap positions
        final String temp = _activeSlots[index];
        _activeSlots[index] = newModule;
        _activeSlots[existingIndex] = temp;
      } else {
        // Replace
        _activeSlots[index] = newModule;
      }
    });
    _saveSlots();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    // The single inactive module
    final String inactiveModule = _allModules.firstWhere(
      (m) => !_activeSlots.contains(m),
      orElse: () => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Bar Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: <Widget>[
          // Header Card
          Card(
            color: colors.primary.withAlpha(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.large),
              side: BorderSide(color: colors.primary.withAlpha(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info_outline_rounded, color: colors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Drag the cards below to rearrange tabs, or tap "Swap" to customize modules. Statistics is locked as the default main tab.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Locked Card
          Text(
            'LOCKED TABS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: colors.surfaceSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
              side: BorderSide(color: colors.border),
            ),
            child: ListTile(
              leading: Icon(_getModuleIcon('stats'), color: colors.textMuted),
              title: Text(
                _getModuleLabel('stats', localizations),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
              ),
              subtitle: const Text('Slot 1 (Fixed)'),
              trailing: Icon(Icons.lock_rounded, color: colors.textMuted, size: 18),
            ),
          ),
          const SizedBox(height: 24),

          // Customizable List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOMIZABLE TABS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              if (inactiveModule.isNotEmpty)
                Text(
                  'Inactive: ${_getModuleLabel(inactiveModule, localizations)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeSlots.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final String item = _activeSlots.removeAt(oldIndex);
                  _activeSlots.insert(newIndex, item);
                });
                _saveSlots();
              },
              itemBuilder: (context, index) {
                final String moduleKey = _activeSlots[index];
                return Card(
                  key: ValueKey<String>(moduleKey),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    side: BorderSide(color: colors.border),
                  ),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.drag_handle_rounded, color: colors.textMuted),
                        const SizedBox(width: 8),
                        Icon(_getModuleIcon(moduleKey), color: colors.primary),
                      ],
                    ),
                    title: Text(
                      _getModuleLabel(moduleKey, localizations),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text('Slot ${index + 2}'),
                    trailing: TextButton.icon(
                      onPressed: inactiveModule.isEmpty
                          ? null
                          : () => _swapOrReplaceSlot(index, inactiveModule),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: Text(
                        'Swap',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
