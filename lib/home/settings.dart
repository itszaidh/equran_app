import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:equran/backend/library.dart'
    show
        BookmarkDB,
        FavouritesDB,
        QuranActivityDB,
        QuranBookmarkFoldersDB,
        QuranBookmarksDB,
        QuranStatsDB,
        ResumeStateDB,
        RoutineDayProgressDB,
        SettingsDB;
import 'package:equran/backend/backup_service.dart';
import 'package:equran/prayer/prayer_times_settings_page.dart';
import 'package:equran/utils/app_theme.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/library.dart';
import 'package:equran/widgets/library.dart'
    show
        AppSelectionDialog,
        AppSelectionOption,
        FontSlider,
        PlayBackSlider,
        SettingsSwitch;
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' show Translation;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final bool cardViewEnabled = SettingsDB().get(
      "viewMode",
      defaultValue: true,
    );
    final bool translationEnabled = SettingsDB().get(
      "enableTranslation",
      defaultValue: true,
    );
    final bool showTranslationControls = cardViewEnabled && translationEnabled;

    return Material(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: <Widget>[
          _buildSettingsGroup(
            context: context,
            title: "General",
            subtitle: "App behavior and history",
            icon: Icons.tune_rounded,
            initiallyExpanded: true,
            children: <Widget>[
              const SettingsSwitch(
                title: "Vibration",
                subtitle: "Enable haptic feedback when navigating.",
                settingsKey: "vibration",
              ),
              const SettingsSwitch(
                title: "Show reading history",
                settingsKey: "showLastRead",
                subtitle: "Shows you up to 7 last read Surahs.",
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "Reading",
            subtitle: "Quran display and translation",
            icon: Icons.menu_book_rounded,
            initiallyExpanded: true,
            children: <Widget>[
              SettingsSwitch(
                title: "Card View",
                subtitle: "Displays each verse separately, or all in one page.",
                settingsKey: "viewMode",
                onChanged: (_) => setState(() {}),
              ),
              if (cardViewEnabled)
                SettingsSwitch(
                  title: "Display Translation",
                  subtitle: "Display translation for each verse in card view.",
                  settingsKey: "enableTranslation",
                  onChanged: (_) => setState(() {}),
                  defaultValue: true,
                ),
              if (cardViewEnabled) _buildTransliterationToggle(),
              _buildDailyQuranGoalTile(context),
              _buildTranslationTile(context),
              FontSlider(showTranslationControls: showTranslationControls),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "Audio",
            subtitle: "Reciter and playback",
            icon: Icons.graphic_eq_rounded,
            children: <Widget>[
              _buildReciterTile(context),
              const PlayBackSlider(),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "Prayer Times",
            subtitle: "Location and calculation settings",
            icon: Icons.access_time_outlined,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: const Text('Prayer Times settings'),
                subtitle: const Text(
                  'Manage location, method, Asr, time format, and offsets.',
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const PrayerTimesSettingsPage(),
                  ),
                ),
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "Appearance",
            subtitle: "Theme, color, and display mode",
            icon: Icons.palette_outlined,
            children: <Widget>[
              _buildThemeModeTile(context),
              _buildThemeColorTile(context),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "Data",
            subtitle: "Backup, restore, or clear saved local data",
            icon: Icons.storage_rounded,
            children: <Widget>[
              _buildBackupDataTile(context),
              _buildRestoreDataTile(context),
              _buildClearReadingHistoryTile(context),
              _buildClearFavouritesTile(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(AppRadii.medium);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationTile(BuildContext context) {
    return ListTile(
      title: const Text("Translation"),
      subtitle: Text(_selectedTranslationName()),
      onTap: () async {
        final int selected = SettingsDB().get("translation", defaultValue: 0);
        final int? value = await _showSelectionDialog<int>(
          context: context,
          title: "Translation Language",
          icon: Icons.translate_rounded,
          selectedValue: selected,
          options:
              Translation.values
                  .asMap()
                  .entries
                  .map(
                    (entry) => AppSelectionOption<int>(
                      value: entry.key,
                      title: translationDisplayName(entry.value),
                    ),
                  )
                  .toList()
                ..sort((a, b) => a.title.compareTo(b.title)),
        );
        if (value == null) return;
        SettingsDB().put("translation", value);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<T?> _showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required IconData icon,
    required T selectedValue,
    required List<AppSelectionOption<T>> options,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppSelectionDialog<T>(
        title: title,
        icon: icon,
        selectedValue: selectedValue,
        options: options,
      ),
    );
  }

  Widget _buildTransliterationToggle() {
    return const SettingsSwitch(
      title: "Display Transliteration",
      subtitle: "Show transliteration for each verse in card view.",
      settingsKey: "showTransliteration",
      defaultValue: false,
    );
  }

  Widget _buildReciterTile(BuildContext context) {
    return ListTile(
      title: const Text("Reciter"),
      subtitle: Text(_selectedReciterName()),
      onTap: () async {
        final List<AppReciter> items = AppReciter.values.toList()
          ..sort(
            (a, b) => a.englishName.toLowerCase().compareTo(
              b.englishName.toLowerCase(),
            ),
          );
        final selected = SettingsDB().get("reciter", defaultValue: "1");
        final selectedReciter = AppReciter.fromCode(selected);
        final AppReciter? value = await _showSelectionDialog<AppReciter>(
          context: context,
          title: "Reciter",
          icon: Icons.record_voice_over_rounded,
          selectedValue: selectedReciter,
          options: items
              .map(
                (reciter) => AppSelectionOption<AppReciter>(
                  value: reciter,
                  title: reciter.englishName,
                ),
              )
              .toList(),
        );
        if (value == null) return;
        SettingsDB().put("reciter", value.code);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildThemeColorTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        final String? selectedScheme = await _showThemeSchemeDialog(context);
        if (selectedScheme == null) return;
        await SettingsDB().put("themeScheme", selectedScheme);
        if (mounted) {
          setState(() {});
        }

        final MaterialColor color = _savedMaterialColor();
        if (context.mounted) {
          AdaptiveTheme.of(context).setTheme(
            light: AppTheme.buildLightTheme(color, schemeId: selectedScheme),
            dark: AppTheme.buildDarkTheme(color, schemeId: selectedScheme),
          );
        }
      },
      title: const Text("Color scheme"),
      subtitle: Text(_selectedThemeName()),
    );
  }

  Future<String?> _showThemeSchemeDialog(BuildContext context) {
    final String selectedScheme = _selectedThemeScheme();

    return showDialog<String>(
      context: context,
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final ColorScheme colorScheme = theme.colorScheme;
        final BorderRadius radius = BorderRadius.circular(AppRadii.large);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          backgroundColor: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: ClipRRect(
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: MediaQuery.sizeOf(context).height - 64,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.format_paint_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Color Scheme',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: Scrollbar(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _themeSchemeOptions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final _ThemeSchemeOption option =
                                _themeSchemeOptions[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.medium,
                                ),
                                side: BorderSide(
                                  color: option.id == selectedScheme
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              tileColor: option.id == selectedScheme
                                  ? colorScheme.primaryContainer.withAlpha(90)
                                  : colorScheme.surfaceContainerLow,
                              leading: _ThemeSchemeSwatch(option: option),
                              title: Text(option.title),
                              subtitle: Text(option.subtitle),
                              trailing: option.id == selectedScheme
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: colorScheme.primary,
                                    )
                                  : null,
                              onTap: () => Navigator.of(context).pop(option.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyQuranGoalTile(BuildContext context) {
    final int goal = _dailyQuranGoalAyahs();
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: const Text("Daily Quran goal"),
      subtitle: Text("$goal ayahs per day"),
      onTap: () async {
        final int? value = await _showDailyGoalDialog(context, goal);
        if (value == null) return;
        await SettingsDB().put("dailyQuranGoalAyahs", value);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<int?> _showDailyGoalDialog(BuildContext context, int initialGoal) {
    final TextEditingController controller = TextEditingController(
      text: initialGoal.toString(),
    );
    String? errorText;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Daily Quran goal'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Ayahs per day',
                  hintText: '20',
                  errorText: errorText,
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() {
                      errorText = null;
                    });
                  }
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final int? value = int.tryParse(controller.text.trim());
                    if (value == null || value < 1 || value > 1000) {
                      setDialogState(() {
                        errorText = 'Enter a goal from 1 to 1000 ayahs';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildClearReadingHistoryTile(BuildContext context) {
    return ListTile(
      title: const Text("Clear reading history"),
      subtitle: const Text(
        "Removes last read, resume positions, and Quran reading progress.",
      ),
      onTap: () => _showClearDataDialog(
        context: context,
        title: "Clear reading history",
        message:
            "WARNING: This will clear last read, resume positions, Quran stats, and routine day progress.",
        onConfirm: _clearReadingHistory,
      ),
    );
  }

  Widget _buildBackupDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.backup_outlined),
      title: const Text("Backup data"),
      subtitle: const Text(
        "Exports favourites, reading history, reciter, text sizes, and all settings.",
      ),
      onTap: () async {
        try {
          final String? outputPath = await BackupService.exportBackupFile();
          if (!context.mounted) return;
          _showMessage(
            context,
            outputPath == null
                ? 'Backup file ready to share.'
                : 'Backup saved to $outputPath',
          );
        } on AppBackupException catch (error) {
          if (error.message != 'Backup cancelled.') {
            _showMessage(context, error.message);
          }
        } catch (_) {
          _showMessage(context, 'Unable to create the backup file.');
        }
      },
    );
  }

  Widget _buildRestoreDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.restore_page_outlined),
      title: const Text("Restore data"),
      subtitle: const Text(
        "Restores favourites, reading history, reciter, text sizes, and saved settings from a backup file.",
      ),
      onTap: () async {
        final bool shouldRestore = await _showRestoreConfirmation(context);
        if (!shouldRestore || !context.mounted) return;

        try {
          final BackupRestoreResult result =
              await BackupService.restoreFromPickedFile();
          if (!context.mounted) return;
          await _applyRestoredTheme(context);
          if (!context.mounted) return;
          setState(() {});
          _showMessage(
            context,
            'Restored ${result.favouritesCount} favourites, ${result.readingHistoryCount} history entries, and ${result.settingsCount} settings.',
          );
        } on AppBackupException catch (error) {
          if (error.message != 'Restore cancelled.' && context.mounted) {
            _showMessage(context, error.message);
          }
        } catch (_) {
          if (context.mounted) {
            _showMessage(context, 'Unable to restore the selected backup.');
          }
        }
      },
    );
  }

  Widget _buildClearFavouritesTile(BuildContext context) {
    return ListTile(
      title: const Text("Clear Favourites"),
      subtitle: const Text(
        "Removes saved ayahs, folders, notes, tags, and favourites.",
      ),
      onTap: () => _showClearDataDialog(
        context: context,
        title: "Clear Favourites",
        message:
            "WARNING: This will clear every saved ayah, folder, note, tag, and favourite.",
        onConfirm: _clearSavedAyahLibrary,
      ),
    );
  }

  Future<void> _clearReadingHistory() async {
    await BookmarkDB().clear();
    await ResumeStateDB().clear();
    await QuranActivityDB().clear();
    await QuranStatsDB().clear();
    await RoutineDayProgressDB().clear();
  }

  Future<void> _clearSavedAyahLibrary() async {
    await FavouritesDB().clear();
    await QuranBookmarksDB().clear();
    await QuranBookmarkFoldersDB().clear();
  }

  void _showClearDataDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        icon: const Icon(Icons.warning_amber_rounded),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "NO",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "YES",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyRestoredTheme(BuildContext context) async {
    final MaterialColor color = _savedMaterialColor();
    final String themeScheme = _selectedThemeScheme();
    final dynamic themeModeValue = SettingsDB().get("themeMode");
    final AdaptiveThemeMode themeMode = switch (themeModeValue) {
      "light" => AdaptiveThemeMode.light,
      "dark" => AdaptiveThemeMode.dark,
      "auto" => AdaptiveThemeMode.system,
      _ => AdaptiveThemeMode.system,
    };

    AdaptiveTheme.of(context).setTheme(
      light: AppTheme.buildLightTheme(color, schemeId: themeScheme),
      dark: AppTheme.buildDarkTheme(color, schemeId: themeScheme),
    );
    AdaptiveTheme.of(context).setThemeMode(themeMode);
  }

  Future<bool> _showRestoreConfirmation(BuildContext context) async {
    final bool? shouldRestore = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Restore backup"),
        icon: const Icon(Icons.restore_page_outlined),
        content: const Text(
          "This will replace your current favourites, reading history, and saved settings with the contents of the backup file.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Restore"),
          ),
        ],
      ),
    );

    return shouldRestore == true;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildThemeModeTile(BuildContext context) {
    final AdaptiveThemeMode themeMode = AdaptiveTheme.of(context).mode;

    return ListTile(
      leading: Icon(_themeModeIcon(themeMode)),
      title: const Text("Theme mode"),
      subtitle: Text(_themeModeLabel(themeMode)),
      onTap: () => _showThemeModeDialog(context),
    );
  }

  Future<void> _showThemeModeDialog(BuildContext context) async {
    final AdaptiveThemeMode currentMode = AdaptiveTheme.of(context).mode;
    final AdaptiveThemeMode? selectedMode =
        await _showSelectionDialog<AdaptiveThemeMode>(
          context: context,
          title: "Theme Mode",
          icon: Icons.palette_outlined,
          selectedValue: currentMode,
          options: const <AppSelectionOption<AdaptiveThemeMode>>[
            AppSelectionOption<AdaptiveThemeMode>(
              value: AdaptiveThemeMode.dark,
              title: "Dark",
              subtitle: "Always use night mode.",
              leading: Icon(Icons.dark_mode_rounded),
            ),
            AppSelectionOption<AdaptiveThemeMode>(
              value: AdaptiveThemeMode.light,
              title: "Light",
              subtitle: "Always use light mode.",
              leading: Icon(Icons.light_mode_rounded),
            ),
            AppSelectionOption<AdaptiveThemeMode>(
              value: AdaptiveThemeMode.system,
              title: "Auto",
              subtitle: "Follow the system theme.",
              leading: Icon(Icons.brightness_auto_rounded),
            ),
          ],
        );

    if (selectedMode == null) return;
    await SettingsDB().put("themeMode", _themeModeSettingValue(selectedMode));
    if (context.mounted) {
      AdaptiveTheme.of(context).setThemeMode(selectedMode);
      setState(() {});
    }
  }

  IconData _themeModeIcon(AdaptiveThemeMode themeMode) {
    if (themeMode.isDark) return Icons.dark_mode_rounded;
    if (themeMode.isSystem) return Icons.brightness_auto_rounded;
    return Icons.light_mode_rounded;
  }

  String _themeModeLabel(AdaptiveThemeMode themeMode) {
    if (themeMode.isDark) return "Dark";
    if (themeMode.isSystem) return "Auto";
    return "Light";
  }

  String _themeModeSettingValue(AdaptiveThemeMode themeMode) {
    if (themeMode.isDark) return "dark";
    if (themeMode.isSystem) return "auto";
    return "light";
  }

  String _selectedThemeName() {
    return _themeSchemeOptions
        .firstWhere(
          (option) => option.id == _selectedThemeScheme(),
          orElse: () => _themeSchemeOptions.first,
        )
        .title;
  }

  String _selectedThemeScheme() {
    final dynamic savedScheme = SettingsDB().get("themeScheme");
    return switch (savedScheme) {
      AppTheme.fancyBlueScheme => AppTheme.fancyBlueScheme,
      AppTheme.fancyPurpleScheme => AppTheme.fancyPurpleScheme,
      AppTheme.sepiaScheme => AppTheme.sepiaScheme,
      AppTheme.blackScheme => AppTheme.blackScheme,
      AppTheme.redScheme => AppTheme.redScheme,
      _ => AppTheme.defaultScheme,
    };
  }

  MaterialColor _savedMaterialColor() {
    final dynamic savedColorIndex = SettingsDB().get("color");
    final int colorIndex =
        savedColorIndex is int &&
            savedColorIndex >= 0 &&
            savedColorIndex < Colors.primaries.length
        ? savedColorIndex
        : 7;
    return Colors.primaries[colorIndex];
  }

  int _dailyQuranGoalAyahs() {
    final dynamic saved = SettingsDB().get("dailyQuranGoalAyahs");
    if (saved is int) return saved.clamp(1, 1000).toInt();
    if (saved is String) {
      return (int.tryParse(saved) ?? 20).clamp(1, 1000).toInt();
    }
    return 20;
  }

  String _selectedTranslationName() {
    final dynamic savedTranslation = SettingsDB().get(
      "translation",
      defaultValue: 0,
    );
    if (savedTranslation is int &&
        savedTranslation >= 0 &&
        savedTranslation < Translation.values.length) {
      return translationDisplayName(Translation.values[savedTranslation]);
    }
    return translationDisplayName(Translation.values.first);
  }

  String _selectedReciterName() {
    final dynamic savedReciter = SettingsDB().get("reciter", defaultValue: "1");
    return AppReciter.fromCode(savedReciter?.toString()).englishName;
  }
}

class _ThemeSchemeOption {
  const _ThemeSchemeOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<Color> colors;
}

class _ThemeSchemeSwatch extends StatelessWidget {
  const _ThemeSchemeSwatch({required this.option});

  final _ThemeSchemeOption option;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: option.colors),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

const List<_ThemeSchemeOption> _themeSchemeOptions = <_ThemeSchemeOption>[
  _ThemeSchemeOption(
    id: AppTheme.defaultScheme,
    title: 'Emerald Green',
    subtitle: 'The original calm eQuran palette.',
    colors: <Color>[Color(0xFF07110E), Color(0xFF1E7A61)],
  ),
  _ThemeSchemeOption(
    id: AppTheme.fancyBlueScheme,
    title: 'Sapphire Blue',
    subtitle: 'Deep navy with sapphire and muted cyan accents.',
    colors: <Color>[Color(0xFF06101C), Color(0xFF3B8DD6)],
  ),
  _ThemeSchemeOption(
    id: AppTheme.fancyPurpleScheme,
    title: 'Royal Purple',
    subtitle: 'Midnight purple with royal violet highlights.',
    colors: <Color>[Color(0xFF100A19), Color(0xFF9368D0)],
  ),
  _ThemeSchemeOption(
    id: AppTheme.sepiaScheme,
    title: 'Sepia',
    subtitle: 'Warm parchment, brown, and soft gold tones.',
    colors: <Color>[Color(0xFF130E09), Color(0xFFC08A4C)],
  ),
  _ThemeSchemeOption(
    id: AppTheme.blackScheme,
    title: 'Black',
    subtitle: 'AMOLED black with restrained teal accents.',
    colors: <Color>[Color(0xFF000000), Color(0xFF18A28D)],
  ),
  _ThemeSchemeOption(
    id: AppTheme.redScheme,
    title: 'Ruby Red',
    subtitle: 'Deep maroon surfaces with elegant ruby highlights.',
    colors: <Color>[Color(0xFF12070A), Color(0xFFC8475D)],
  ),
];
