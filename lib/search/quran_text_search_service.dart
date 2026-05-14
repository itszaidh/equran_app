import 'dart:async';

import 'package:equran/backend/library.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;

class QuranTextSearchResult {
  const QuranTextSearchResult({
    required this.surah,
    required this.verse,
    required this.arabicPreview,
    required this.translationPreview,
    required this.translationMatch,
  });

  final int surah;
  final int verse;
  final String arabicPreview;
  final String translationPreview;
  final bool translationMatch;

  String get id => '$surah:$verse';
}

class QuranTextSearchService {
  const QuranTextSearchService();

  static List<_SearchEntry>? _arabicIndex;
  static final Map<quran.Translation, List<_SearchEntry>> _translationIndexes =
      <quran.Translation, List<_SearchEntry>>{};

  Future<List<QuranTextSearchResult>> search(String query, {int limit = 80}) {
    final String trimmedQuery = query.trim();
    final String normalizedQuery = _normalizeSearchText(trimmedQuery);
    if (normalizedQuery.length < 2) {
      return Future<List<QuranTextSearchResult>>.value(
        const <QuranTextSearchResult>[],
      );
    }

    return Future<List<QuranTextSearchResult>>.microtask(() {
      return _searchSync(normalizedQuery, limit: limit);
    });
  }

  Future<void> storeRecentQuery(String query, int resultCount) async {
    final String trimmed = query.trim();
    if (trimmed.length < 2) return;

    final String id = 'quran_text:${trimmed.toLowerCase()}';
    await RecentSearchesDB().put(
      id,
      RecentSearchEntry(
        id: id,
        query: trimmed,
        mode: 'quran_text',
        searchedAt: DateTime.now(),
        resultCount: resultCount,
      ),
    );

    final List<RecentSearchEntry> entries = recentQuranTextSearches();
    for (final RecentSearchEntry entry in entries.skip(8)) {
      unawaited(RecentSearchesDB().delete(entry.id));
    }
  }

  List<RecentSearchEntry> recentQuranTextSearches() {
    final List<RecentSearchEntry> entries = RecentSearchesDB().box.values
        .whereType<RecentSearchEntry>()
        .where((RecentSearchEntry entry) => entry.mode == 'quran_text')
        .toList();
    entries.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return entries;
  }

  List<QuranTextSearchResult> _searchSync(
    String normalizedQuery, {
    required int limit,
  }) {
    final quran.Translation translation = _selectedTranslation();
    final Map<String, _SearchHit> hits = <String, _SearchHit>{};

    void addHit(_SearchEntry entry, {required bool translationMatch}) {
      final String id = entry.id;
      hits[id] = _SearchHit(
        surah: entry.surah,
        verse: entry.verse,
        translationMatch:
            (hits[id]?.translationMatch ?? false) || translationMatch,
      );
    }

    try {
      for (final _SearchEntry entry in _arabicEntries()) {
        if (entry.normalizedArabic.contains(normalizedQuery)) {
          addHit(entry, translationMatch: false);
          if (hits.length >= limit) break;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Quran Arabic search failed: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'quran_text_search_service',
          context: ErrorDescription('while searching Arabic Quran text'),
        ),
      );
    }

    try {
      for (final _SearchEntry entry in _translationEntries(translation)) {
        if (entry.normalizedTranslation.contains(normalizedQuery)) {
          addHit(entry, translationMatch: true);
          if (hits.length >= limit) break;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Quran translation search failed: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'quran_text_search_service',
          context: ErrorDescription('while searching Quran translation'),
        ),
      );
    }

    final List<_SearchHit> orderedHits = hits.values.toList()
      ..sort((a, b) {
        final int surahCompare = a.surah.compareTo(b.surah);
        if (surahCompare != 0) return surahCompare;
        return a.verse.compareTo(b.verse);
      });

    return orderedHits
        .take(limit)
        .map((_SearchHit hit) {
          return QuranTextSearchResult(
            surah: hit.surah,
            verse: hit.verse,
            arabicPreview: quranVerseText(hit.surah, hit.verse),
            translationPreview: _translationText(
              hit.surah,
              hit.verse,
              translation,
            ),
            translationMatch: hit.translationMatch,
          );
        })
        .toList(growable: false);
  }

  quran.Translation _selectedTranslation() {
    final dynamic saved = SettingsDB().get('translation', defaultValue: 0);
    if (saved is int && saved >= 0 && saved < quran.Translation.values.length) {
      return quran.Translation.values[saved];
    }
    return quran.Translation.enSaheeh;
  }

  List<_SearchEntry> _arabicEntries() {
    return _arabicIndex ??= _buildIndex();
  }

  List<_SearchEntry> _translationEntries(quran.Translation translation) {
    return _translationIndexes[translation] ??= _buildIndex(
      translation: translation,
    );
  }

  List<_SearchEntry> _buildIndex({quran.Translation? translation}) {
    final List<_SearchEntry> entries = <_SearchEntry>[];
    for (int surah = 1; surah <= quran.totalSurahCount; surah++) {
      final int verseCount = quran.getVerseCount(surah);
      for (int verse = 1; verse <= verseCount; verse++) {
        final String arabic = quranVerseText(surah, verse);
        final String translationText = translation == null
            ? ''
            : _translationText(surah, verse, translation);
        entries.add(
          _SearchEntry(
            surah: surah,
            verse: verse,
            normalizedArabic: _normalizeSearchText(arabic),
            normalizedTranslation: _normalizeSearchText(translationText),
          ),
        );
      }
    }
    return List<_SearchEntry>.unmodifiable(entries);
  }

  String _translationText(int surah, int verse, quran.Translation translation) {
    try {
      return quran.cleanTranslationText(
        quran.getVerseTranslation(surah, verse, translation: translation),
      );
    } catch (_) {
      return '';
    }
  }

  String _normalizeSearchText(String value) {
    final String withoutArabicMarks = _normalizeArabic(value);
    return withoutArabicMarks
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _normalizeArabic(String value) {
    return value
        .replaceAll(
          RegExp(r'[\u0610-\u061A\u0640\u064B-\u065F\u0670\u06D6-\u06ED]'),
          '',
        )
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim();
  }
}

class _SearchHit {
  const _SearchHit({
    required this.surah,
    required this.verse,
    required this.translationMatch,
  });

  final int surah;
  final int verse;
  final bool translationMatch;
}

class _SearchEntry {
  const _SearchEntry({
    required this.surah,
    required this.verse,
    required this.normalizedArabic,
    required this.normalizedTranslation,
  });

  final int surah;
  final int verse;
  final String normalizedArabic;
  final String normalizedTranslation;

  String get id => '$surah:$verse';
}
