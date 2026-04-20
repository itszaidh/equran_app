import 'package:equran/backend/library.dart' show SettingsDB;
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class FontSlider extends StatefulWidget {
  const FontSlider({super.key});

  @override
  State<FontSlider> createState() => _FontSliderState();
}

class _FontSliderState extends State<FontSlider> {
  @override
  Widget build(BuildContext context) {
    double fontSize = SettingsDB().get("fontSize", defaultValue: 38.0);
    double fontSizeTranslation = SettingsDB().get(
      "fontSizeTranslation",
      defaultValue: 20.0,
    );
    final bool enableTranslation = SettingsDB().get(
      "enableTranslation",
      defaultValue: true,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Center(child: Text("Font Size")),
              subtitle: Slider(
                value: fontSize,
                min: 25.0,
                max: 65.0,
                label: (fontSize / 2).round().toString(),
                onChanged: (double value) {
                  setState(() {
                    fontSize = value;
                    SettingsDB().put("fontSize", value);
                  });
                },
              ),
            ),
            if (enableTranslation)
              ListTile(
                title: const Center(child: Text("Translation Font Size")),
                subtitle: Slider(
                  value: fontSizeTranslation,
                  min: 10.0,
                  max: 30.0,
                  label: (fontSizeTranslation / 2).round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      fontSizeTranslation = value;
                      SettingsDB().put("fontSizeTranslation", value);
                    });
                  },
                ),
              ),
            _FontPreview(
              fontSize: fontSize,
              fontSizeTranslation: fontSizeTranslation,
              showTranslation: enableTranslation,
            ),
          ],
        ),
      ),
    );
  }
}

class _FontPreview extends StatelessWidget {
  const _FontPreview({
    required this.fontSize,
    required this.fontSizeTranslation,
    required this.showTranslation,
  });

  final double fontSize;
  final double fontSizeTranslation;
  final bool showTranslation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Preview',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                quran.getVerse(1, 1),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Hafs',
                  height: 1.65,
                  fontSize: fontSize,
                ),
              ),
              if (showTranslation) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  quran.getVerseTranslation(1, 1),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: fontSizeTranslation,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
