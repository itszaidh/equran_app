import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:equran/backend/library.dart'
    show BookmarkDB, FavouritesDB, SettingsDB;
import 'package:equran/utils/library.dart';
import 'package:equran/widgets/library.dart'
    show FontSlider, PlayBackSlider, SettingsSwitch;
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' show Translation;
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return "${info.version}+${info.buildNumber}";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: <Widget>[
          _buildSettingsGroup(
            context: context,
            title: "General",
            subtitle: "App behavior and history",
            icon: Icons.tune_rounded,
            initiallyExpanded: true,
            children: const <Widget>[
              SettingsSwitch(
                title: "Vibration",
                subtitle: "Enable haptic feedback when navigating.",
                settingsKey: "vibration",
              ),
              SettingsSwitch(
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
              const SettingsSwitch(
                title: "Card View",
                subtitle: "Displays each verse separately, or all in one page.",
                settingsKey: "viewMode",
              ),
              const SettingsSwitch(
                title: "Enable Translation",
                subtitle: "Enables translation for each verse.",
                settingsKey: "enableTranslation",
              ),
              _buildTranslationTile(context),
              const FontSlider(),
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
            subtitle: "Clear saved local data",
            icon: Icons.storage_rounded,
            children: <Widget>[
              _buildClearReadingHistoryTile(context),
              _buildClearFavouritesTile(context),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: "About",
            subtitle: "App version",
            icon: Icons.info_outline_rounded,
            children: <Widget>[
              _buildVersionTile(context),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
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
      onTap: () {
        List<Translation> items = Translation.values;
        int selected = SettingsDB().get("translation", defaultValue: 0);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, dialogSetState) {
                return AlertDialog(
                  title: const Text("Select Language"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: items.asMap().entries.map((entry) {
                        int index = entry.key;
                        return RadioListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(entry.value.name),
                          value: index,
                          groupValue: selected,
                          onChanged: (int? value) {
                            SettingsDB().put("translation", value);
                            if (mounted) {
                              setState(() {});
                            }
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReciterTile(BuildContext context) {
    return ListTile(
      title: const Text("Reciter"),
      subtitle: Text(_selectedReciterName()),
      onTap: () {
        final List<AppReciter> items = AppReciter.values.toList()
          ..sort(
            (a, b) => a.englishName.toLowerCase().compareTo(
              b.englishName.toLowerCase(),
            ),
          );
        final selected = SettingsDB().get("reciter", defaultValue: "1");
        final selectedReciter = AppReciter.fromCode(selected);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, dialogSetState) {
                return AlertDialog(
                  title: const Text("Select Reciter"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: items.asMap().entries.map((entry) {
                        return RadioListTile<AppReciter>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(entry.value.englishName),
                          value: entry.value,
                          groupValue: selectedReciter,
                          onChanged: (value) {
                            if (value == null) return;
                            SettingsDB().put("reciter", value.code);
                            if (mounted) {
                              setState(() {});
                            }
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildThemeColorTile(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Choose a Color'),
              icon: const Icon(Icons.format_paint_rounded),
              content: Wrap(
                runSpacing: 10,
                spacing: 10,
                children: List.generate(Colors.primaries.length, (index) {
                  final color = Colors.primaries[index];
                  return InkWell(
                    onTap: () {
                      SettingsDB().put("color", index);
                      if (mounted) {
                        setState(() {});
                      }

                      AdaptiveTheme.of(context).setTheme(
                        light: ThemeData(colorSchemeSeed: color),
                        dark: ThemeData(
                          colorSchemeSeed: color,
                          brightness: Brightness.dark,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 18,
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
      title: const Text("Color scheme"),
      subtitle: Text(_selectedThemeName()),
    );
  }

  Widget _buildClearReadingHistoryTile(BuildContext context) {
    return ListTile(
      title: const Text("Clear reading history"),
      subtitle: const Text("Removes all your reading history."),
      onTap: () => _showClearDataDialog(
        context: context,
        title: "Clear reading history",
        message: "WARNING: Are you sure you want to clear your reading history?",
        onConfirm: () async => BookmarkDB().clear(),
      ),
    );
  }

  Widget _buildClearFavouritesTile(BuildContext context) {
    return ListTile(
      title: const Text("Clear Favourites"),
      subtitle: const Text("Removes all verses you have liked."),
      onTap: () => _showClearDataDialog(
        context: context,
        title: "Clear Favourites",
        message: "WARNING: Are you sure you want to clear favourites?",
        onConfirm: () async => FavouritesDB().clear(),
      ),
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return FutureBuilder(
      future: getVersion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text("Loading..."));
        }
        return ListTile(
          title: Text("Version: ${snapshot.data}"),
        );
      },
    );
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
              Navigator.of(context).pop();
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

  Widget _buildThemeModeTile(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AdaptiveThemeMode themeMode = AdaptiveTheme.of(context).mode;
    final bool isDark = themeMode.isSystem
        ? theme.brightness == Brightness.dark
        : themeMode.isDark;

    return SwitchListTile(
      secondary: Icon(
        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      ),
      title: const Text("Dark mode"),
      subtitle: Text(isDark ? "Using dark theme." : "Using light theme."),
      value: isDark,
      onChanged: (value) async {
        final AdaptiveThemeMode newMode =
            value ? AdaptiveThemeMode.dark : AdaptiveThemeMode.light;
        await SettingsDB().put(
          "themeMode",
          value ? "dark" : "light",
        );
        if (context.mounted) {
          AdaptiveTheme.of(context).setThemeMode(newMode);
        }
      },
    );
  }

  String _selectedThemeName() {
    final dynamic savedColor = SettingsDB().get("color");
    if (savedColor is int &&
        savedColor >= 0 &&
        savedColor < _themeColorNames.length) {
      return _themeColorNames[savedColor];
    }
    return "Cyan";
  }

  String _selectedTranslationName() {
    final dynamic savedTranslation =
        SettingsDB().get("translation", defaultValue: 0);
    if (savedTranslation is int &&
        savedTranslation >= 0 &&
        savedTranslation < Translation.values.length) {
      return Translation.values[savedTranslation].name;
    }
    return Translation.values.first.name;
  }

  String _selectedReciterName() {
    final dynamic savedReciter = SettingsDB().get("reciter", defaultValue: "1");
    return AppReciter.fromCode(savedReciter?.toString()).englishName;
  }
}

const List<String> _themeColorNames = <String>[
  "Red",
  "Pink",
  "Purple",
  "Deep purple",
  "Indigo",
  "Blue",
  "Light blue",
  "Cyan",
  "Teal",
  "Green",
  "Light green",
  "Lime",
  "Yellow",
  "Amber",
  "Orange",
  "Deep orange",
  "Brown",
  "Blue grey",
];
