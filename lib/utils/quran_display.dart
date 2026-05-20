import 'package:equran/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:quran/quran.dart' as quran;

bool isArabicLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

bool isArabicLocalizations(AppLocalizations localizations) =>
    localizations.localeName == 'ar';

String localizedSurahName(AppLocalizations localizations, int surah) {
  return isArabicLocalizations(localizations)
      ? quran.getSurahNameArabic(surah)
      : quran.getSurahName(surah);
}

String localizedSurahNameFromValues(
  AppLocalizations localizations, {
  required String arabicName,
  required String transliteration,
}) {
  return isArabicLocalizations(localizations) ? arabicName : transliteration;
}

String localizedSurahAyahLabel(
  AppLocalizations localizations,
  int surah,
  int ayah,
) {
  return localizations.surahLabel(
    localizedSurahName(localizations, surah),
    ayah,
  );
}

String localizedAyahReference(AppLocalizations localizations, int ayah) {
  return localizations.ayahNumber(ayah);
}

String localizedJuzLabel(AppLocalizations localizations, int juz) {
  return localizations.juzNumber(juz);
}
