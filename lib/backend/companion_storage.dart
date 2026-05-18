import 'package:equran/backend/base_db.dart';
import 'package:equran/backend/companion_storage_models.dart';

class SchemaMigrationsDB extends BaseDB {
  SchemaMigrationsDB._privateConstructor() : super('schema_migrations');

  static final SchemaMigrationsDB _instance =
      SchemaMigrationsDB._privateConstructor();

  factory SchemaMigrationsDB() => _instance;
}

class QuranBookmarksDB extends BaseDB {
  QuranBookmarksDB._privateConstructor() : super('quran_bookmarks');

  static final QuranBookmarksDB _instance =
      QuranBookmarksDB._privateConstructor();

  factory QuranBookmarksDB() => _instance;
}

class QuranBookmarkFoldersDB extends BaseDB {
  QuranBookmarkFoldersDB._privateConstructor()
    : super('quran_bookmark_folders');

  static final QuranBookmarkFoldersDB _instance =
      QuranBookmarkFoldersDB._privateConstructor();

  factory QuranBookmarkFoldersDB() => _instance;
}

class QuranActivityDB extends BaseDB {
  QuranActivityDB._privateConstructor() : super('quran_activity');

  static final QuranActivityDB _instance =
      QuranActivityDB._privateConstructor();

  factory QuranActivityDB() => _instance;
}

class ReadingPlansDB extends BaseDB {
  ReadingPlansDB._privateConstructor() : super('reading_plans');

  static final ReadingPlansDB _instance = ReadingPlansDB._privateConstructor();

  factory ReadingPlansDB() => _instance;
}

class RoutineDayProgressDB extends BaseDB {
  RoutineDayProgressDB._privateConstructor() : super('routine_day_progress');

  static final RoutineDayProgressDB _instance =
      RoutineDayProgressDB._privateConstructor();

  factory RoutineDayProgressDB() => _instance;

  String progressKey(String routineId, String dateKey) =>
      '$routineId::$dateKey';

  RoutineDayProgressEntry? progressFor(String routineId, String dateKey) {
    final dynamic value = get(progressKey(routineId, dateKey));
    return RoutineDayProgressEntry.fromStored(value);
  }

  List<RoutineDayProgressEntry> progressEntriesForRoutine(String routineId) {
    return box.values
        .map(RoutineDayProgressEntry.fromStored)
        .whereType<RoutineDayProgressEntry>()
        .where((RoutineDayProgressEntry entry) => entry.routineId == routineId)
        .toList(growable: false);
  }

  Future<void> saveProgress(RoutineDayProgressEntry progress) async {
    await put(
      progressKey(progress.routineId, progress.dateKey),
      progress.toMap(),
    );
    await put('active_routine_progress', progress.toMap());
  }

  Future<void> deleteProgressForRoutine(String routineId) async {
    final List<dynamic> keys = getKeys()
        .where((dynamic key) => key is String && key.startsWith('$routineId::'))
        .toList(growable: false);
    for (final dynamic key in keys) {
      await delete(key);
    }
    final RoutineDayProgressEntry? active = RoutineDayProgressEntry.fromStored(
      get('active_routine_progress'),
    );
    if (active?.routineId == routineId) {
      await delete('active_routine_progress');
    }
  }
}

class ResumeStateDB extends BaseDB {
  ResumeStateDB._privateConstructor() : super('resume_state');

  static final ResumeStateDB _instance = ResumeStateDB._privateConstructor();

  factory ResumeStateDB() => _instance;
}

class RecentSearchesDB extends BaseDB {
  RecentSearchesDB._privateConstructor() : super('recent_searches');

  static final RecentSearchesDB _instance =
      RecentSearchesDB._privateConstructor();

  factory RecentSearchesDB() => _instance;
}

class DhikrSessionsDB extends BaseDB {
  DhikrSessionsDB._privateConstructor() : super('dhikr_sessions');

  static final DhikrSessionsDB _instance =
      DhikrSessionsDB._privateConstructor();

  factory DhikrSessionsDB() => _instance;
}

class DuaInteractionsDB extends BaseDB {
  DuaInteractionsDB._privateConstructor() : super('dua_interactions');

  static final DuaInteractionsDB _instance =
      DuaInteractionsDB._privateConstructor();

  factory DuaInteractionsDB() => _instance;

  Future<void> recordCategoryView({
    required String categoryId,
    required String categoryTitle,
    required int duaCount,
    DateTime? viewedAt,
  }) async {
    final DateTime now = viewedAt ?? DateTime.now();
    final String dateKey = _dateKey(now);
    final String key = 'category:$dateKey:$categoryId';
    final Object? existing = get(key);
    final int existingCount = existing is Map
        ? _intValue(existing['count'])
        : 0;
    await put(key, <String, Object?>{
      'id': key,
      'dateKey': dateKey,
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'count': existingCount + duaCount.clamp(0, 10000).toInt(),
      'updatedAt': now.toIso8601String(),
    });
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }
}

class SalahLogDB extends BaseDB {
  SalahLogDB._privateConstructor() : super('salah_log');

  static final SalahLogDB _instance = SalahLogDB._privateConstructor();

  factory SalahLogDB() => _instance;

  Future<SalahLogEntry?> getEntry(String date) async {
    return SalahLogEntry.fromStored(get(date));
  }

  Future<void> saveEntry(SalahLogEntry entry) async {
    await put(entry.date, entry.toMap());
  }

  Future<List<SalahLogEntry>> getRange(DateTime from, DateTime to) async {
    final DateTime start = DateTime(from.year, from.month, from.day);
    final DateTime end = DateTime(to.year, to.month, to.day);
    final List<SalahLogEntry> entries = <SalahLogEntry>[];
    for (
      DateTime cursor = start;
      !cursor.isAfter(end);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      final SalahLogEntry? entry = await getEntry(_dateKey(cursor));
      if (entry != null) entries.add(entry);
    }
    return entries;
  }

  Future<Map<String, int>> getStatusCounts(DateTime from, DateTime to) async {
    final Map<String, int> counts = <String, int>{};
    const List<String> prayers = <String>[
      'fajr',
      'dhuhr',
      'asr',
      'maghrib',
      'isha',
    ];
    const List<String> statuses = <String>['onTime', 'late', 'notPrayed'];
    for (final String prayer in prayers) {
      for (final String status in statuses) {
        counts['${prayer}_$status'] = 0;
      }
    }
    for (final SalahLogEntry entry in await getRange(from, to)) {
      final Map<String, String> values = <String, String>{
        'fajr': entry.fajr,
        'dhuhr': entry.dhuhr,
        'asr': entry.asr,
        'maghrib': entry.maghrib,
        'isha': entry.isha,
      };
      for (final MapEntry<String, String> value in values.entries) {
        if (!statuses.contains(value.value)) continue;
        final String key = '${value.key}_${value.value}';
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class QuranStatsDB extends BaseDB {
  QuranStatsDB._privateConstructor() : super('quran_stats');

  static final QuranStatsDB _instance = QuranStatsDB._privateConstructor();

  factory QuranStatsDB() => _instance;
}

class DownloadMetadataDB extends BaseDB {
  DownloadMetadataDB._privateConstructor() : super('download_metadata');

  static final DownloadMetadataDB _instance =
      DownloadMetadataDB._privateConstructor();

  factory DownloadMetadataDB() => _instance;
}

Future<void> initCompanionStorageBoxes() async {
  await SchemaMigrationsDB().initBox();
  await QuranBookmarksDB().initBox();
  await QuranBookmarkFoldersDB().initBox();
  await QuranActivityDB().initBox();
  await ReadingPlansDB().initBox();
  await RoutineDayProgressDB().initBox();
  await ResumeStateDB().initBox();
  await RecentSearchesDB().initBox();
  await DhikrSessionsDB().initBox();
  await DuaInteractionsDB().initBox();
  await SalahLogDB().initBox();
  await QuranStatsDB().initBox();
  await DownloadMetadataDB().initBox();
}
