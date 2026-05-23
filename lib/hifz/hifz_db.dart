import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/hifz_entry.dart';
import 'models/hifz_review_log.dart';

class HifzDB {
  static const String entriesBoxName = 'hifzEntries';
  static const String logsBoxName = 'hifzLogs';

  static Future<void> init() async {
    await Hive.openBox<HifzEntry>(entriesBoxName);
    await Hive.openBox<HifzReviewLog>(logsBoxName);
  }

  static Box<HifzEntry> get _entries => Hive.box<HifzEntry>(entriesBoxName);

  static Box<HifzReviewLog> get _logs => Hive.box<HifzReviewLog>(logsBoxName);

  // Save or update a single entry
  static Future<void> saveEntry(HifzEntry entry) async {
    await _entries.put(entry.key, entry);
  }

  // Get a single entry, null if not exists
  static HifzEntry? getEntry(int surah, int ayah) {
    return _entries.get('$surah:$ayah');
  }

  // Get all entries
  static List<HifzEntry> getAllEntries() {
    return _entries.values.toList();
  }

  // Get all due entries sorted by dueDate ascending
  static List<HifzEntry> getDueEntries() {
    final now = DateTime.now().add(const Duration(hours: 1));
    return _entries.values.where((e) => e.dueDate.isBefore(now)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get entries with status 'new' not yet due
  static List<HifzEntry> getNewEntries() {
    return _entries.values.where((e) => e.status == 'new').toList()
      ..sort((a, b) {
        if (a.surah != b.surah) return a.surah.compareTo(b.surah);
        return a.ayah.compareTo(b.ayah);
      });
  }

  // Add a range of ayahs as new entries
  // Does not overwrite existing entries
  static Future<void> addAyahRange({
    required int surah,
    required int startAyah,
    required int endAyah,
  }) async {
    for (int ayah = startAyah; ayah <= endAyah; ayah++) {
      final key = '$surah:$ayah';
      if (_entries.containsKey(key)) continue;
      final entry = HifzEntry()
        ..surah = surah
        ..ayah = ayah
        ..status = 'new'
        ..interval = 0
        ..easeFactor = 2.5
        ..repetitions = 0
        ..dueDate = DateTime.now()
        ..lastReviewed = null
        ..lapses = 0
        ..track = 'sabaq';
      await _entries.put(key, entry);
    }
  }

  // Count entries by status
  static Map<String, int> getStatusCounts() {
    final counts = <String, int>{
      'new': 0,
      'learning': 0,
      'review': 0,
      'mastered': 0,
    };
    for (final e in _entries.values) {
      counts[e.status] = (counts[e.status] ?? 0) + 1;
    }
    return counts;
  }

  // Count mastered ayahs per surah
  // Returns Map<surahNumber, masteredCount>
  static Map<int, int> getMasteredPerSurah() {
    final result = <int, int>{};
    for (final e in _entries.values.where((e) => e.status == 'mastered')) {
      result[e.surah] = (result[e.surah] ?? 0) + 1;
    }
    return result;
  }

  // Get all entries for a specific surah
  static List<HifzEntry> getEntriesForSurah(int surah) {
    return _entries.values.where((e) => e.surah == surah).toList()
      ..sort((a, b) => a.ayah.compareTo(b.ayah));
  }

  // Save review log
  static Future<void> saveLog(HifzReviewLog log) async {
    await _logs.add(log);
  }

  // Get logs for a date range
  static List<HifzReviewLog> getLogsForRange(DateTime from, DateTime to) {
    return _logs.values
        .where((l) => l.reviewedAt.isAfter(from) && l.reviewedAt.isBefore(to))
        .toList();
  }

  // Get retention rate (0.0 to 1.0)
  // = (good + easy) / total ratings, all time
  static double getRetentionRate() {
    final logs = _logs.values.toList();
    if (logs.isEmpty) return 0.0;
    final positive = logs
        .where((l) => l.rating == 'good' || l.rating == 'easy')
        .length;
    return positive / logs.length;
  }

  // Get total review count for today
  static int getTodayReviewCount() {
    final today = DateTime.now();
    return _logs.values.where((l) {
      return l.reviewedAt.year == today.year &&
          l.reviewedAt.month == today.month &&
          l.reviewedAt.day == today.day;
    }).length;
  }

  // Check if any hifz activity on a given date
  // Used for Statistics heatmap integration
  static bool hasActivityOnDate(DateTime date) {
    return _logs.values.any(
      (l) =>
          l.reviewedAt.year == date.year &&
          l.reviewedAt.month == date.month &&
          l.reviewedAt.day == date.day,
    );
  }

  // Delete a single entry
  static Future<void> deleteEntry(int surah, int ayah) async {
    await _entries.delete('$surah:$ayah');
  }

  // Listenable for ValueListenableBuilder
  static ValueListenable<Box<HifzEntry>> get entriesListenable =>
      _entries.listenable();
}
