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

  Future<List<QuranTextSearchResult>> search(String query, {int limit = 80}) {
    final String normalizedQuery = query.trim();
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

  List<QuranTextSearchResult> _searchSync(String query, {required int limit}) {
    final quran.Translation translation = _selectedTranslation();
    final List<String> words = _splitWords(query);
    final Map<String, _SearchHit> hits = <String, _SearchHit>{};

    void addHit(int? surah, int? verse, {required bool translationMatch}) {
      if (surah == null || verse == null) return;
      if (surah < 1 || surah > 114) return;
      if (verse < 1 || verse > quran.getVerseCount(surah)) return;
      final String id = '$surah:$verse';
      hits[id] = _SearchHit(
        surah: surah,
        verse: verse,
        translationMatch:
            (hits[id]?.translationMatch ?? false) || translationMatch,
      );
    }

    if (words.isNotEmpty) {
      try {
        _collectPackageResults(
          quran.searchWords(words),
          (surah, verse) => addHit(surah, verse, translationMatch: false),
        );
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
        _collectPackageResults(
          quran.searchWordsInTranslation(words, translation: translation),
          (surah, verse) => addHit(surah, verse, translationMatch: true),
        );
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
    }

    if (_containsArabic(query)) {
      final String normalizedNeedle = _normalizeArabic(query);
      if (normalizedNeedle.length >= 2) {
        for (int surah = 1; surah <= 114 && hits.length < limit; surah++) {
          final int verseCount = quran.getVerseCount(surah);
          for (
            int verse = 1;
            verse <= verseCount && hits.length < limit;
            verse++
          ) {
            final String text = quranVerseText(surah, verse);
            if (_normalizeArabic(text).contains(normalizedNeedle)) {
              addHit(surah, verse, translationMatch: false);
            }
          }
        }
      }
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
            translationPreview: quran.cleanTranslationText(
              quran.getVerseTranslation(
                hit.surah,
                hit.verse,
                translation: translation,
              ),
            ),
            translationMatch: hit.translationMatch,
          );
        })
        .toList(growable: false);
  }

  void _collectPackageResults(
    Map<dynamic, dynamic> response,
    void Function(int? surah, int? verse) add,
  ) {
    final dynamic rawResults = response['result'];
    if (rawResults is! Iterable) return;

    for (final dynamic rawResult in rawResults) {
      if (rawResult is! Map) continue;
      add(_readInt(rawResult['surah']), _readInt(rawResult['verse']));
    }
  }

  List<String> _splitWords(String query) {
    return query
        .split(RegExp(r'\s+'))
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);
  }

  quran.Translation _selectedTranslation() {
    final dynamic saved = SettingsDB().get('translation', defaultValue: 0);
    if (saved is int && saved >= 0 && saved < quran.Translation.values.length) {
      return quran.Translation.values[saved];
    }
    return quran.Translation.enSaheeh;
  }

  bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  String _normalizeArabic(String value) {
    return value
        .replaceAll(
          RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
          '',
        )
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim();
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
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
