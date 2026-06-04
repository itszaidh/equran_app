import 'package:equran/backend/settings_db.dart';
import 'package:equran/l10n/app_localizations.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DuaTypographySettingsCard extends StatelessWidget {
  const DuaTypographySettingsCard({super.key});

  static const Map<String, String> _supportedLanguages = <String, String>{
    'en': 'English',
    'de': 'Deutsch',
    'bn': 'বাংলা',
    'id': 'Bahasa Indonesia',
    'tr': 'Türkçe',
    'ur': 'اردو',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final bool isLight = theme.brightness == Brightness.light;

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: SettingsDB().listener,
      builder: (BuildContext context, Box<dynamic> settingsBox, Widget? child) {
        final bool showTranslation = settingsBox.get('duaShowTranslation', defaultValue: true) as bool;
        final bool showTransliteration = settingsBox.get('duaShowTransliteration', defaultValue: true) as bool;
        final String defaultLang = Localizations.localeOf(context).languageCode;
        final String translationLang = settingsBox.get('duaTranslationLanguage', defaultValue: defaultLang) as String;

        return Card(
          elevation: isLight ? 1.5 : 0,
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: BorderSide(
              color: isLight
                  ? colors.primary.withAlpha(20)
                  : colors.outlineVariant.withAlpha(70),
              width: 1.1,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.medium),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.alphaBlend(
                    colors.primary.withAlpha(isLight ? 4 : 8),
                    theme.cardTheme.color ?? colors.surfaceContainerLow,
                  ),
                  Color.alphaBlend(
                    colors.tertiary.withAlpha(isLight ? 3 : 6),
                    theme.cardTheme.color ?? colors.surfaceContainerLow,
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isNarrow = constraints.maxWidth < 460;

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildToggleChip(
                                context: context,
                                label: localizations.translation,
                                isSelected: showTranslation,
                                icon: Icons.translate_rounded,
                                onSelected: (bool val) =>
                                    SettingsDB().put('duaShowTranslation', val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildToggleChip(
                                context: context,
                                label: localizations.transliterationOption,
                                isSelected: showTransliteration,
                                icon: Icons.spellcheck_rounded,
                                onSelected: (bool val) =>
                                    SettingsDB().put('duaShowTransliteration', val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildLanguageDropdown(context, translationLang, isFullWidth: true),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildToggleChip(
                            context: context,
                            label: localizations.translation,
                            isSelected: showTranslation,
                            icon: Icons.translate_rounded,
                            onSelected: (bool val) =>
                                SettingsDB().put('duaShowTranslation', val),
                          ),
                          const SizedBox(width: 8),
                          _buildToggleChip(
                            context: context,
                            label: localizations.transliterationOption,
                            isSelected: showTransliteration,
                            icon: Icons.spellcheck_rounded,
                            onSelected: (bool val) =>
                                SettingsDB().put('duaShowTransliteration', val),
                          ),
                        ],
                      ),
                      _buildLanguageDropdown(context, translationLang, isFullWidth: false),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required IconData icon,
    required ValueChanged<bool> onSelected,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withAlpha(isLight ? 20 : 34)
                : colors.surfaceContainerHighest.withAlpha(isLight ? 80 : 40),
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(
              color: isSelected
                  ? colors.primary.withAlpha(190)
                  : colors.outlineVariant.withAlpha(80),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: isSelected ? colors.primary : colors.onSurfaceVariant.withAlpha(180),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? colors.primary : colors.onSurface.withAlpha(200),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    String currentLang, {
    required bool isFullWidth,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    final Widget dropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withAlpha(isLight ? 80 : 40),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(
          color: colors.outlineVariant.withAlpha(80),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _supportedLanguages.containsKey(currentLang) ? currentLang : 'en',
          icon: Icon(
            Icons.language_rounded,
            size: 15,
            color: colors.primary,
          ),
          isDense: true,
          alignment: Alignment.centerLeft,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          dropdownColor: colors.surfaceContainerLow,
          onChanged: (String? value) {
            if (value != null) {
              SettingsDB().put('duaTranslationLanguage', value);
            }
          },
          items: _supportedLanguages.entries.map((MapEntry<String, String> entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 4),
                  Text(
                    entry.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface.withAlpha(200),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: dropdown,
      );
    }

    return dropdown;
  }
}
