import 'dart:convert';
import 'dart:io';

import 'package:equran/backend/resource_install_store.dart';
import 'package:equran/backend/resource_models.dart';
import 'package:equran/backend/resource_repository.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
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

  final Map<String, SurahTiming?> _cache = <String, SurahTiming?>{};

  static Future<bool> hasTimingSupportForReciter(String code) async {
    return ResourceRepository.instance
        .timingResourceForReciter(code)
        .then((DownloadableResource? resource) => resource != null);
  }

  static Future<bool> hasInstalledTimingForReciter(String code) async {
    final DownloadableResource? resource = await ResourceRepository.instance
        .timingResourceForReciter(code);
    if (resource == null) return false;
    return ResourceInstallStore.instance.isInstalled(resource);
  }

  static Future<DownloadableResource?> timingResourceForReciter(String code) {
    return ResourceRepository.instance.timingResourceForReciter(code);
  }

  Future<SurahTiming?> loadSurahTiming({
    required String reciterCode,
    required int surahNumber,
  }) async {
    final String normalizedCode = reciterCode.trim();
    final int normalizedSurah = surahNumber.clamp(1, 114).toInt();
    final DownloadableResource? resource = await ResourceRepository.instance
        .timingResourceForReciter(normalizedCode);
    final InstalledResource? installed = resource == null
        ? null
        : ResourceInstallStore.instance.installedFor(resource);
    final String cacheKey =
        '$normalizedCode-$normalizedSurah-${installed?.version ?? 'missing'}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    if (resource == null || installed == null) {
      _cache[cacheKey] = null;
      return null;
    }

    final String? rawTiming = await _loadTimingFile(
      installed: installed,
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

  Future<String?> _loadTimingFile({
    required InstalledResource installed,
    required int surahNumber,
  }) async {
    final String paddedSurah = surahNumber.toString().padLeft(3, '0');
    final String separator = Platform.pathSeparator;
    final List<String> candidateDirectories = <String>[
      installed.localPath,
      '${installed.localPath}$separator${installed.id}',
    ];
    final List<String> candidateFiles = <String>[
      '$paddedSurah.txt',
      '$surahNumber.txt',
      '$paddedSurah.json',
      '$surahNumber.json',
    ];
    final List<String> candidatePaths = <String>[
      for (final String directory in candidateDirectories)
        for (final String fileName in candidateFiles)
          '$directory$separator$fileName',
    ];

    for (final String path in candidatePaths) {
      try {
        final File file = File(path);
        if (await file.exists()) return await file.readAsString();
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Unable to load timing file "$path": $error');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        'No timing file found for ${installed.id}/$surahNumber in '
        '${installed.localPath}.',
      );
    }
    return null;
  }

  void clearCache() {
    _cache.clear();
  }

  static Future<ResourceInstallState> timingInstallStateForReciter(
    String code,
  ) async {
    final DownloadableResource? resource = await ResourceRepository.instance
        .timingResourceForReciter(code);
    if (resource == null) return ResourceInstallState.notDownloaded;
    return ResourceInstallStore.instance.installStateFor(resource);
  }

  static Future<InstalledResource?> installedTimingForReciter(
    String code,
  ) async {
    final DownloadableResource? resource = await ResourceRepository.instance
        .timingResourceForReciter(code);
    if (resource == null) return null;
    return ResourceInstallStore.instance.installedFor(resource);
  }

  static void debugLogTimingError(String message, Object error) {
    if (kDebugMode) {
      debugPrint('$message: $error');
    }
  }

  static Future<String?> readTimingFileForInstalledResource({
    required InstalledResource installed,
    required int surahNumber,
  }) async {
    try {
      return await SurahTimingRepository()._loadTimingFile(
        installed: installed,
        surahNumber: surahNumber,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to read timing file: $error');
      }
      return null;
    }
  }

  static SurahTiming? parseTimingFile({
    required String reciterCode,
    required int surahNumber,
    required String rawTiming,
  }) {
    final int ayahCount = quran.getVerseCount(surahNumber);
    final List<Duration> markers = <Duration>[];
    int malformedRows = 0;
    final String trimmedTiming = rawTiming.trimLeft();

    if (trimmedTiming.startsWith('[') || trimmedTiming.startsWith('{')) {
      try {
        malformedRows = _appendJsonTimingMarkers(
          jsonDecode(rawTiming),
          markers,
        );
      } catch (_) {
        malformedRows++;
      }
    } else {
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

    final int leadingMarkerCount = (markers.length - ayahCount)
        .clamp(0, markers.length - 1)
        .toInt();
    final List<AyahTiming> ayahs = _looksLikeStartMarkers(markers)
        ? _timingsFromStartMarkers(markers, ayahCount, leadingMarkerCount)
        : _timingsFromBoundaryMarkers(markers, ayahCount, leadingMarkerCount);

    if (ayahs.isEmpty) return null;

    if (kDebugMode && malformedRows > 0) {
      debugPrint(
        'Timing file $reciterCode/$surahNumber ignored $malformedRows '
        'malformed rows.',
      );
    }

    // Most packaged timing files are ayah boundary/end markers. Some reciters
    // include a leading basmala/preamble segment, so extra leading markers are
    // folded into ayah 1 instead of shifting the displayed ayah forward.
    return SurahTiming(
      reciterCode: reciterCode,
      surahNumber: surahNumber,
      ayahs: List<AyahTiming>.unmodifiable(ayahs),
    );
  }

  static bool _looksLikeStartMarkers(List<Duration> markers) {
    return markers.isNotEmpty &&
        markers.first <= const Duration(milliseconds: 1200);
  }

  static List<AyahTiming> _timingsFromBoundaryMarkers(
    List<Duration> markers,
    int ayahCount,
    int leadingMarkerCount,
  ) {
    final List<AyahTiming> ayahs = <AyahTiming>[];
    for (int index = 0; index < ayahCount; index++) {
      final int endIndex = (index + leadingMarkerCount)
          .clamp(0, markers.length - 1)
          .toInt();
      final int startIndex = (endIndex - 1)
          .clamp(0, markers.length - 1)
          .toInt();
      final Duration start = index == 0 ? Duration.zero : markers[startIndex];
      final Duration end = markers[endIndex];
      if (end <= start) continue;
      ayahs.add(AyahTiming(ayahNumber: index + 1, start: start, end: end));
    }
    return ayahs;
  }

  static List<AyahTiming> _timingsFromStartMarkers(
    List<Duration> markers,
    int ayahCount,
    int leadingMarkerCount,
  ) {
    final List<AyahTiming> ayahs = <AyahTiming>[];
    for (int index = 0; index < ayahCount; index++) {
      final int startIndex = index == 0
          ? 0
          : (index + leadingMarkerCount).clamp(0, markers.length - 1).toInt();
      final int endIndex = index + leadingMarkerCount + 1;
      final Duration start = markers[startIndex];
      final Duration end = endIndex < markers.length
          ? markers[endIndex]
          : const Duration(days: 1);
      if (end <= start) continue;
      ayahs.add(AyahTiming(ayahNumber: index + 1, start: start, end: end));
    }
    return ayahs;
  }

  static int _appendJsonTimingMarkers(Object? value, List<Duration> markers) {
    int malformedRows = 0;
    if (value is List<Object?>) {
      for (final Object? entry in value) {
        final int? milliseconds = _millisecondsFromJsonEntry(entry);
        if (milliseconds == null || milliseconds < 0) {
          malformedRows++;
          continue;
        }
        markers.add(Duration(milliseconds: milliseconds));
      }
      return malformedRows;
    }

    if (value is Map<String, Object?>) {
      for (final String key in <String>[
        'markers',
        'timings',
        'ayahs',
        'verses',
      ]) {
        final Object? nestedValue = value[key];
        if (nestedValue is List<Object?>) {
          return _appendJsonTimingMarkers(nestedValue, markers);
        }
      }
    }

    return 1;
  }

  static int? _millisecondsFromJsonEntry(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    if (value is Map<String, Object?>) {
      for (final String key in <String>[
        'start',
        'startMs',
        'start_ms',
        'timestamp',
        'time',
        'milliseconds',
        'ms',
      ]) {
        final int? milliseconds = _millisecondsFromJsonEntry(value[key]);
        if (milliseconds != null) return milliseconds;
      }
    }
    return null;
  }
}
