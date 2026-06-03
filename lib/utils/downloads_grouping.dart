import 'package:equran/backend/audio_downloads.dart';
import 'package:equran/utils/reciter.dart';
import 'package:quran/quran.dart' as quran;

class ReciterDownloadsGroup {
  const ReciterDownloadsGroup({
    required this.reciterCode,
    required this.entries,
  });

  final String reciterCode;
  final List<AudioDownloadEntry> entries;

  List<AudioDownloadEntry> get surahs => entries
      .where(
        (entry) =>
            entry.type == AudioDownloadType.surah ||
            entry.type == AudioDownloadType.ayahSurah,
      )
      .toList(growable: false);

  List<AudioDownloadEntry> get ayahs => entries
      .where((entry) => entry.type == AudioDownloadType.ayah)
      .toList(growable: false);

  int get ayahCount {
    int count = ayahs.fold<int>(0, (total, entry) => total + entry.ayahCount);

    // Include ayahs covered by the surah downloads (full files or complete ayah packs)
    for (final entry in surahs) {
      count += quran.getVerseCount(entry.surah);
    }

    return count;
  }

  int get sizeBytes =>
      entries.fold<int>(0, (total, entry) => total + entry.sizeBytes);
}

List<ReciterDownloadsGroup> groupDownloadsByReciter(
  AudioDownloadsSummary summary,
) {
  final Map<String, List<AudioDownloadEntry>> grouped =
      <String, List<AudioDownloadEntry>>{};
  for (final AudioDownloadEntry entry in summary.allDownloads) {
    grouped
        .putIfAbsent(entry.reciterCode, () => <AudioDownloadEntry>[])
        .add(entry);
  }

  final List<ReciterDownloadsGroup> groups = grouped.entries
      .map(
        (entry) =>
            ReciterDownloadsGroup(reciterCode: entry.key, entries: entry.value),
      )
      .toList();
  groups.sort(
    (a, b) => reciterDisplayName(
      a.reciterCode,
    ).compareTo(reciterDisplayName(b.reciterCode)),
  );
  return groups;
}

String reciterDisplayName(String reciterCode) {
  final String normalizedCode = AppReciter.normalizeCode(reciterCode);
  final bool isKnownReciter = AppReciter.values.any(
    (reciter) => reciter.code == normalizedCode,
  );
  if (!isKnownReciter) return 'Reciter $reciterCode';
  return AppReciter.fromCode(normalizedCode).englishName;
}

/// Represents all downloads for a single surah (across any number of reciters).
/// Used when the user switches to "Group by Surah" mode.
class SurahDownloadsGroup {
  const SurahDownloadsGroup({required this.surah, required this.entries});

  final int surah;
  final List<AudioDownloadEntry> entries;

  int get sizeBytes =>
      entries.fold<int>(0, (total, entry) => total + entry.sizeBytes);

  /// Groups the entries for this surah by reciter code.
  /// Useful for rendering "which reciters have this surah".
  Map<String, List<AudioDownloadEntry>> get entriesByReciter {
    final Map<String, List<AudioDownloadEntry>> map = {};
    for (final entry in entries) {
      map
          .putIfAbsent(entry.reciterCode, () => <AudioDownloadEntry>[])
          .add(entry);
    }
    return map;
  }
}

/// Inverts the data so we can render "grouped by surah" instead of "grouped by reciter".
List<SurahDownloadsGroup> groupDownloadsBySurah(
  List<AudioDownloadEntry> allEntries,
) {
  final Map<int, List<AudioDownloadEntry>> grouped =
      <int, List<AudioDownloadEntry>>{};

  for (final AudioDownloadEntry entry in allEntries) {
    grouped.putIfAbsent(entry.surah, () => <AudioDownloadEntry>[]).add(entry);
  }

  final List<SurahDownloadsGroup> groups = grouped.entries
      .map((e) => SurahDownloadsGroup(surah: e.key, entries: e.value))
      .toList();

  groups.sort((a, b) => a.surah.compareTo(b.surah));
  return groups;
}
