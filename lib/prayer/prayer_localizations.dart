import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/l10n/app_localizations.dart';

String localizedPrayerName(
  AppLocalizations localizations,
  PrayerTimeKind kind,
) {
  return switch (kind) {
    PrayerTimeKind.fajr => localizations.prayerNameFajr,
    PrayerTimeKind.sunrise => localizations.prayerNameSunrise,
    PrayerTimeKind.dhuhr => localizations.prayerNameDhuhr,
    PrayerTimeKind.asr => localizations.prayerNameAsr,
    PrayerTimeKind.maghrib => localizations.prayerNameMaghrib,
    PrayerTimeKind.isha => localizations.prayerNameIsha,
  };
}
