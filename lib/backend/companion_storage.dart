import 'package:equran/backend/base_db.dart';

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
  await QuranActivityDB().initBox();
  await ReadingPlansDB().initBox();
  await ResumeStateDB().initBox();
  await RecentSearchesDB().initBox();
  await DhikrSessionsDB().initBox();
  await QuranStatsDB().initBox();
  await DownloadMetadataDB().initBox();
}
