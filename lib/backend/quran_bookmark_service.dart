import 'package:equran/backend/companion_storage.dart';
import 'package:equran/backend/companion_storage_models.dart';
import 'package:equran/backend/favourites_db.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:quran/quran.dart' as quran;

class QuranBookmarkService {
  const QuranBookmarkService();

  bool isFavourite(int surah, int verse) {
    final String key = favouriteAyahKey(surah, verse);
    final dynamic entry = QuranBookmarksDB().get(key);
    if (entry is QuranBookmarkEntry && entry.isFavourite) return true;
    return FavouritesDB().contains(key);
  }

  Future<void> saveFavourite(int surah, int verse, {String note = ''}) async {
    final String key = favouriteAyahKey(surah, verse);
    final String trimmedNote = note.trim();
    final String legacyNote = FavouritesDB()
        .get(key, defaultValue: '')
        .toString()
        .trim();
    final String noteToStore = trimmedNote.isEmpty ? legacyNote : trimmedNote;
    final DateTime now = DateTime.now();

    await FavouritesDB().put(key, noteToStore);

    final dynamic existing = QuranBookmarksDB().get(key);
    if (existing is QuranBookmarkEntry) {
      final String existingNote = existing.note.trim();
      await QuranBookmarksDB().put(
        key,
        existing.copyWith(
          isFavourite: true,
          note: noteToStore.isEmpty && existingNote.isNotEmpty
              ? existingNote
              : noteToStore,
          legacyKey: key,
          updatedAt: now,
        ),
      );
      return;
    }

    await QuranBookmarksDB().put(
      key,
      QuranBookmarkEntry(
        id: key,
        surah: surah,
        verse: verse,
        note: noteToStore,
        legacyKey: key,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> removeFavourite(int surah, int verse) async {
    final String key = favouriteAyahKey(surah, verse);
    await FavouritesDB().delete(key);

    final dynamic existing = QuranBookmarksDB().get(key);
    if (existing is! QuranBookmarkEntry) return;
    if (existing.note.trim().isEmpty &&
        existing.tags.isEmpty &&
        existing.folder == 'Default') {
      await QuranBookmarksDB().delete(key);
      return;
    }

    await QuranBookmarksDB().put(
      key,
      existing.copyWith(isFavourite: false, updatedAt: DateTime.now()),
    );
  }

  List<QuranBookmarkEntry> bookmarkEntriesWithLegacyFallback() {
    final Map<String, QuranBookmarkEntry> entries =
        <String, QuranBookmarkEntry>{};
    for (final QuranBookmarkEntry entry
        in QuranBookmarksDB().box.values.whereType<QuranBookmarkEntry>()) {
      entries[entry.id] = entry;
    }

    final DateTime fallbackTime = DateTime.fromMillisecondsSinceEpoch(0);
    for (final dynamic rawKey in FavouritesDB().getKeys()) {
      final _ParsedAyahKey? parsed = _ParsedAyahKey.parse(rawKey);
      if (parsed == null) continue;
      final String key = favouriteAyahKey(parsed.surah, parsed.verse);
      entries.putIfAbsent(
        key,
        () => QuranBookmarkEntry(
          id: key,
          surah: parsed.surah,
          verse: parsed.verse,
          note: FavouritesDB().get(rawKey, defaultValue: '').toString(),
          legacyKey: rawKey.toString(),
          createdAt: fallbackTime,
          updatedAt: fallbackTime,
        ),
      );
    }

    final List<QuranBookmarkEntry> sorted = entries.values.toList();
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}

class _ParsedAyahKey {
  const _ParsedAyahKey({required this.surah, required this.verse});

  final int surah;
  final int verse;

  static _ParsedAyahKey? parse(dynamic rawKey) {
    final List<String> parts = rawKey.toString().split('-');
    if (parts.length != 2) return null;
    final int? surah = int.tryParse(parts[0]);
    final int? verse = int.tryParse(parts[1]);
    if (surah == null || verse == null) return null;
    if (surah < 1 || surah > 114 || verse < 1) return null;
    if (verse > quran.getVerseCount(surah)) return null;
    return _ParsedAyahKey(surah: surah, verse: verse);
  }
}
