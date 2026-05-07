import 'package:flutter/foundation.dart'
    show FlutterError, debugPrint, kDebugMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:quran/quran.dart' as quran;

class AyahTiming {
  const AyahTiming({
    required this.ayahNumber,
    required this.start,
    required this.end,
  });

  final int ayahNumber;
  final Duration start;
  final Duration end;

  bool contains(Duration position) {
    return position >= start && position < end;
  }
}

class SurahTiming {
  const SurahTiming({
    required this.reciterCode,
    required this.surahNumber,
    required this.ayahs,
  });

  final String reciterCode;
  final int surahNumber;
  final List<AyahTiming> ayahs;

  AyahTiming? timingForPosition(Duration position) {
    if (ayahs.isEmpty) return null;
    if (position < ayahs.first.start) return null;

    int low = 0;
    int high = ayahs.length - 1;
    while (low <= high) {
      final int mid = low + ((high - low) >> 1);
      final AyahTiming candidate = ayahs[mid];
      if (candidate.contains(position)) return candidate;
      if (position < candidate.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return null;
  }
}

class SurahTimingRepository {
  SurahTimingRepository();

  static const Set<String> supportedReciterCodes = <String>{'2', '3', '4'};

  final Map<String, SurahTiming?> _cache = <String, SurahTiming?>{};

  static bool hasTimingSupportForReciter(String code) {
    return supportedReciterCodes.contains(code);
  }

  Future<SurahTiming?> loadSurahTiming({
    required String reciterCode,
    required int surahNumber,
  }) async {
    final String normalizedCode = reciterCode.trim();
    final int normalizedSurah = surahNumber.clamp(1, 114).toInt();
    final String cacheKey = '$normalizedCode-$normalizedSurah';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    if (!hasTimingSupportForReciter(normalizedCode)) {
      _cache[cacheKey] = null;
      return null;
    }

    final String? rawTiming = await _loadTimingAsset(
      reciterCode: normalizedCode,
      surahNumber: normalizedSurah,
    );
    if (rawTiming == null) {
      _cache[cacheKey] = null;
      return null;
    }

    final SurahTiming? timing = parseTimingFile(
      reciterCode: normalizedCode,
      surahNumber: normalizedSurah,
      rawTiming: rawTiming,
    );
    _cache[cacheKey] = timing;
    return timing;
  }

  Future<String?> _loadTimingAsset({
    required String reciterCode,
    required int surahNumber,
  }) async {
    final String paddedSurah = surahNumber.toString().padLeft(3, '0');
    final List<String> candidatePaths = <String>[
      'assets/timings/$reciterCode/$paddedSurah.txt',
      'assets/timings/$reciterCode/$surahNumber.txt',
    ];

    for (final String path in candidatePaths) {
      try {
        return await rootBundle.loadString(path);
      } on FlutterError catch (_) {
        // Missing timing files are expected for unsupported or incomplete sets.
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Unable to load timing asset "$path": $error');
        }
      }
    }
    return null;
  }

  static SurahTiming? parseTimingFile({
    required String reciterCode,
    required int surahNumber,
    required String rawTiming,
  }) {
    final int ayahCount = quran.getVerseCount(surahNumber);
    final List<Duration> markers = <Duration>[];
    int malformedRows = 0;

    for (final String rawLine in rawTiming.split(RegExp(r'\r?\n'))) {
      final String line = rawLine.trim();
      if (line.isEmpty) continue;
      final int? milliseconds = int.tryParse(line);
      if (milliseconds == null || milliseconds < 0) {
        malformedRows++;
        continue;
      }
      markers.add(Duration(milliseconds: milliseconds));
    }

    if (markers.length < ayahCount) {
      if (kDebugMode) {
        debugPrint(
          'Timing file $reciterCode/$surahNumber has ${markers.length} '
          'valid rows for $ayahCount ayahs. Ignoring it.',
        );
      }
      return null;
    }

    markers.sort();

    final List<AyahTiming> ayahs = <AyahTiming>[];
    for (int index = 0; index < ayahCount; index++) {
      final Duration start = markers[index];
      final Duration end = index + 1 < markers.length
          ? markers[index + 1]
          : const Duration(days: 1);
      if (end <= start) continue;
      ayahs.add(AyahTiming(ayahNumber: index + 1, start: start, end: end));
    }

    if (ayahs.isEmpty) return null;

    if (kDebugMode && malformedRows > 0) {
      debugPrint(
        'Timing file $reciterCode/$surahNumber ignored $malformedRows '
        'malformed rows.',
      );
    }

    // VerseByVerseQuran timing files are millisecond start markers. Some files
    // include an extra final marker for the end of the last ayah; files without
    // that final marker keep the last ayah active until playback completes.
    return SurahTiming(
      reciterCode: reciterCode,
      surahNumber: surahNumber,
      ayahs: List<AyahTiming>.unmodifiable(ayahs),
    );
  }
}
