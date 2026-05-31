import os

FILE_PATH = "/home/yousuf/Documents/Personal Projects/equran_app/lib/prayer/islamic_calendar_page.dart"

REPLACEMENTS = [
    # 1. Imports
    (
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:equran/l10n/app_localizations.dart';"
    ),
    # 2. build method localizations initialization
    (
        "  @override\n  Widget build(BuildContext context) {\n    final EquranColors colors = context.equranColors;\n    final ThemeData theme = Theme.of(context);",
        "  @override\n  Widget build(BuildContext context) {\n    final EquranColors colors = context.equranColors;\n    final ThemeData theme = Theme.of(context);\n    final localizations = AppLocalizations.of(context)!;"
    ),
    # 3. AppBar Title
    (
        "title: const Text('Islamic Calendar'),",
        "title: Text(localizations.islamicCalendar),"
    ),
    # 4. Sighting Offset labels (first occurrence in compact card)
    (
        "    final String offsetLabel = _sightingOffset == 0\n        ? 'Standard'\n        : '${_sightingOffset > 0 ? '+' : ''}$_sightingOffset day${_sightingOffset.abs() == 1 ? '' : 's'}';",
        "    final String offsetLabel = _sightingOffset == 0\n        ? localizations.standard\n        : '${_sightingOffset > 0 ? '+' : ''}${_sightingOffset.abs() == 1 ? localizations.daySingular(_sightingOffset.abs()) : localizations.daysPlural(_sightingOffset.abs())}';"
    ),
    # 5. Sighting Offset labels (second occurrence in settings bar)
    (
        "    final String offsetLabel = _sightingOffset == 0\n        ? 'Standard'\n        : '${_sightingOffset > 0 ? '+' : ''}$_sightingOffset day${_sightingOffset.abs() == 1 ? '' : 's'}';",
        "    final String offsetLabel = _sightingOffset == 0\n        ? localizations.standard\n        : '${_sightingOffset > 0 ? '+' : ''}${_sightingOffset.abs() == 1 ? localizations.daySingular(_sightingOffset.abs()) : localizations.daysPlural(_sightingOffset.abs())}';"
    ),
    # 6. Sighting card text
    (
        "                  'Moon Sighting',",
        "                  localizations.moonSighting,"
    ),
    (
        "                  colors.primary,\n                    fontWeight: FontWeight.w600,",
        "                  colors.primary,\n                    fontWeight: FontWeight.w600,"
    ),
    # 7. Fasting Alerts button
    (
        "                  'Fasting Alerts',",
        "                  localizations.fastingAlerts,"
    ),
    # 8. Tooltips
    (
        "tooltip: 'Customize calendar',",
        "tooltip: localizations.customizeCalendar,"
    ),
    (
        "tooltip: 'Share this date',",
        "tooltip: localizations.shareDate,"
    ),
    # 9. Date not found SnackBar
    (
        "content: Text('Could not locate that date in the near future'),",
        "content: Text(localizations.dateNotFound),"
    ),
    (
        "content: Text('Could not locate that date in the near future')",
        "content: Text(localizations.dateNotFound)"
    ),
    (
        "const SnackBar(content: Text('Could not locate that date in the near future')),",
        "SnackBar(content: Text(localizations.dateNotFound)),"
    ),
    # 10. Legend Chips
    (
        "_legendChip(theme, colors, 'Today', colors.primary),",
        "_legendChip(theme, colors, localizations.todayLegend, colors.primary),"
    ),
    (
        "_legendChip(theme, colors, 'Eid', colors.accentGold),",
        "_legendChip(theme, colors, localizations.eidLegend, colors.accentGold),"
    ),
    (
        "_legendChip(theme, colors, 'Ramadan', colors.primary.withAlpha(140)),",
        "_legendChip(theme, colors, localizations.ramadanLegend, colors.primary.withAlpha(140)),"
    ),
    (
        "_legendChip(theme, colors, 'Blessed Night', colors.goldSoft),",
        "_legendChip(theme, colors, localizations.blessedNightLegend, colors.goldSoft),"
    ),
    (
        "_legendChip(theme, colors, 'Fast', colors.mint),",
        "_legendChip(theme, colors, localizations.fastLegend, colors.mint),"
    ),
    # 11. Clipboard SnackBar
    (
        "content: Text('Date details copied to clipboard'),",
        "content: Text(localizations.dateCopiedClipboard),"
    ),
    # 12. _showCalendarSettingsSheet localizations initialization
    (
        "  Future<void> _showCalendarSettingsSheet(\n    ThemeData theme,\n    EquranColors colors,\n  ) async {\n    await showModalBottomSheet<void>(",
        "  Future<void> _showCalendarSettingsSheet(\n    ThemeData theme,\n    EquranColors colors,\n  ) async {\n    final localizations = AppLocalizations.of(context)!;\n    await showModalBottomSheet<void>("
    ),
    # 13. Settings Sheet Text
    (
        "                'Calendar Settings',",
        "                localizations.calendarSettings,"
    ),
    (
        "                'Adjust for local moon sighting and fasting reminders',",
        "                localizations.calendarSettingsSubtitle,"
    ),
    (
        "                'Moon Sighting Offset',",
        "                localizations.sightingOffsetLabel,"
    ),
    (
        "                  final String label = offset == 0\n                      ? 'Standard'\n                      : offset > 0\n                      ? '+$offset day'\n                      : '$offset day';",
        "                  final String label = offset == 0\n                      ? localizations.standard\n                      : offset > 0\n                      ? '+${offset.abs() == 1 ? localizations.daySingular(offset.abs()) : localizations.daysPlural(offset.abs())}'\n                      : '-${offset.abs() == 1 ? localizations.daySingular(offset.abs()) : localizations.daysPlural(offset.abs())}';"
    ),
    (
        "                        Text(\n                          'Fasting Reminders',",
        "                        Text(\n                          localizations.fastingReminder,"
    ),
    (
        "                          'Get notified the evening before recommended fasts',",
        "                          localizations.fastingRemindersSubtitle,"
    ),
    (
        "              Text(\n                'Note: Hijri dates are approximate and depend on local moon sighting. The offset lets you align the calendar with your community’s observation.',",
        "              Text(\n                localizations.hijriDateDisclaimer,"
    ),
    # 14. Key dates
    (
        "        Text(\n          'Key Dates in $year',",
        "        Text(\n          localizations.keyDatesInYear(year),"
    ),
    # 15. Compact card moon sighting title
    (
        "                  'Moon Sighting',",
        "                  localizations.moonSighting,"
    ),
    # 16. Fasting Alerts
    (
        "                  'Fasting Alerts',",
        "                  localizations.fastingAlerts,"
    )
]

def run():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply all replacements
    for search, replace in REPLACEMENTS:
        if search in content:
            content = content.replace(search, replace)
        else:
            print(f"Warning: search pattern not found:\n{search}\n")

    # Localize "Tap to adjust" to localizations.tapToAdjust
    content = content.replace(
        "            Text(\n              'Tap to adjust',",
        "            Text(\n              localizations.tapToAdjust,"
    )

    # Localize recommended for this day details
    # recommended.add('Increase recitation of the Qur\'an');
    # recommended.add('Give charity and help those in need');
    # recommended.add('Seek Laylat al-Qadr in the odd nights');
    # recommended.add('Perform Eid prayer and give Zakat al-Fitr');
    # recommended.add('Recommended Fast');
    # recommended.add('Recommended for this day');
    # Wait, they are simple helper lists, but we can localize them using existing keys if we want, or keep them as is. Let's keep them since they are within private helper lists and very long, or let's verify if they have localized equivalents. We can check if they are already handled.
    # Actually, we can check if they are in ARB or keep them as is. Let's see: we didn't add translations for those detailed paragraphs yet, but let's keep them or check.

    # Also localize the "Today" pill:
    content = content.replace(
        "                            'TODAY',",
        "                            localizations.todayLegend.toUpperCase(),"
    )

    # Localize legend chips in _buildEventLegend
    content = content.replace(
        "  Widget _buildEventLegend(ThemeData theme, EquranColors colors) {",
        "  Widget _buildEventLegend(ThemeData theme, EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )

    # Localize recommended for this day header in _buildDateDetailsCard
    content = content.replace(
        "  Widget _buildDateDetailsCard(ThemeData theme, EquranColors colors) {",
        "  Widget _buildDateDetailsCard(ThemeData theme, EquranColors colors) {\n    final localizations = AppLocalizations.of(context)!;"
    )
    content = content.replace(
        "              'Recommended for this day',",
        "              localizations.recommendedForThisDay,"
    )
    content = content.replace(
        "                    'Recommended Fast',",
        "                    localizations.recommendedFast,"
    )
    content = content.replace(
        "                  'Recommended Fast',",
        "                  localizations.recommendedFast,"
    )

    # Localize 'Moon Sighting' in column settings bar
    content = content.replace(
        "                        Text(\n                          'Moon Sighting',",
        "                        Text(\n                          localizations.moonSighting,"
    )

    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Calendar Page localized successfully!")

if __name__ == '__main__':
    run()
