# v3 Size Optimization Notes

## Quran data

- Replaced the hosted `quran` dependency with a local path package at
  `third_party/quran_lite`.
- Kept the small API surface the app already uses: surah names, ayah counts,
  page data, juz data, Quran text lookup, translation enum compatibility,
  verse search, and global counts.
- Moved Arabic Quran text into per-surah JSON assets under
  `assets/data/quran/text/`.
- Moved the bundled first-run English Saheeh translation into per-surah JSON
  assets under `assets/data/quran/translations/en_saheeh/`.
- Removed the large Dart translation constants from the app build. Extra
  translations are represented as downloadable `translation` resources.

## Downloadable translations

- Extended `ResourceType` with `translation`.
- Translation ZIP validation now expects the same per-surah JSON shape as
  tafsir:
  `{ "ayahs": [{ "surah": 1, "ayah": 1, "text": "..." }] }`.
- Installed translations are stored under
  `appSupport/resources/translations/<translation-id>/`.
- Settings now lists translation resources beside tafsir and timing packs.
- Selecting a missing translation prompts for download instead of silently
  showing empty text.

## Timezone

- Kept the `timezone` package because `flutter_local_notifications` still
  schedules exact zoned notifications with `TZDateTime`.
- Replaced `timezone/data/latest_all.dart` with
  `timezone/data/latest_10y.dart`.
- Device timezone still comes from `flutter_timezone`; saved location timezone
  is used when available.

## Size observations

- Hosted `quran` package source previously contributed about `28 MB` of Dart
  library data, mostly translations.
- Local `third_party/quran_lite` is about `104 KB`; bundled Quran JSON assets
  are about `3.4 MB`.
- Timezone database source import changed from about `1.9 MB` to `284 KB`.
- Current arm64 release APK from `--analyze-size`: `31.2 MB`.
- Current split APKs: armv7 `28.9 MB`, arm64 `31.0 MB`, x86_64 `32.5 MB`.

## Preserved behavior

Quran reading, search, default translation display, transliteration, tafsir
downloads, timing downloads, audio/player sync, prayer times, reminders,
qibla, bookmarks/favourites/notes, routines, stats, tasbih, settings/themes,
share image, and existing navigation are preserved.
