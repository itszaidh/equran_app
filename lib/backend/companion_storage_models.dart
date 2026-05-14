import 'package:hive/hive.dart';

const int companionStorageSchemaVersion = 1;

void registerCompanionStorageAdapters() {
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(SchemaMigrationRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(QuranBookmarkEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(QuranActivityDayAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(ReadingPlanEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(ResumeStateEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(RecentSearchEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(DhikrSessionEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(17)) {
    Hive.registerAdapter(QuranStatsSnapshotAdapter());
  }
  if (!Hive.isAdapterRegistered(18)) {
    Hive.registerAdapter(DownloadMetadataEntryAdapter());
  }
}

class SchemaMigrationRecord {
  const SchemaMigrationRecord({
    required this.key,
    required this.version,
    required this.migratedAt,
    required this.success,
    this.message = '',
  });

  final String key;
  final int version;
  final DateTime migratedAt;
  final bool success;
  final String message;
}

class QuranBookmarkEntry {
  const QuranBookmarkEntry({
    required this.id,
    required this.surah,
    required this.verse,
    required this.createdAt,
    required this.updatedAt,
    this.isFavourite = true,
    this.note = '',
    this.folder = 'Default',
    this.tags = const <String>[],
    this.legacyKey = '',
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final int surah;
  final int verse;
  final bool isFavourite;
  final String note;
  final String folder;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String legacyKey;
  final int schemaVersion;

  bool get hasNote => note.trim().isNotEmpty;

  QuranBookmarkEntry copyWith({
    bool? isFavourite,
    String? note,
    String? folder,
    List<String>? tags,
    DateTime? updatedAt,
    String? legacyKey,
  }) {
    return QuranBookmarkEntry(
      id: id,
      surah: surah,
      verse: verse,
      isFavourite: isFavourite ?? this.isFavourite,
      note: note ?? this.note,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      legacyKey: legacyKey ?? this.legacyKey,
      schemaVersion: schemaVersion,
    );
  }
}

class QuranActivityDay {
  const QuranActivityDay({
    required this.dateKey,
    required this.updatedAt,
    this.ayahsRead = 0,
    this.pagesRead = 0,
    this.listeningSeconds = 0,
    this.readingSeconds = 0,
    this.readAyahKeys = const <String>[],
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String dateKey;
  final int ayahsRead;
  final int pagesRead;
  final int listeningSeconds;
  final int readingSeconds;
  final List<String> readAyahKeys;
  final DateTime updatedAt;
  final int schemaVersion;
}

class ReadingPlanEntry {
  const ReadingPlanEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.startedAt,
    required this.finishBy,
    required this.startGlobalAyah,
    required this.targetGlobalAyah,
    required this.lastCompletedGlobalAyah,
    this.active = true,
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final String type;
  final String title;
  final DateTime startedAt;
  final DateTime finishBy;
  final int startGlobalAyah;
  final int targetGlobalAyah;
  final int lastCompletedGlobalAyah;
  final bool active;
  final int schemaVersion;
}

class RoutineDayProgressEntry {
  const RoutineDayProgressEntry({
    required this.routineId,
    required this.dateKey,
    required this.currentSurah,
    required this.currentAyah,
    required this.completedAyahCount,
    required this.lastOpenedSurah,
    required this.lastOpenedAyah,
    required this.updatedAt,
    this.completedGlobalAyahs = const <int>[],
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String routineId;
  final String dateKey;
  final int currentSurah;
  final int currentAyah;
  final int completedAyahCount;
  final int lastOpenedSurah;
  final int lastOpenedAyah;
  final DateTime updatedAt;
  final List<int> completedGlobalAyahs;
  final int schemaVersion;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'routineId': routineId,
    'dateKey': dateKey,
    'currentSurah': currentSurah,
    'currentAyah': currentAyah,
    'completedAyahCount': completedAyahCount,
    'lastOpenedSurah': lastOpenedSurah,
    'lastOpenedAyah': lastOpenedAyah,
    'updatedAt': updatedAt,
    'completedGlobalAyahs': completedGlobalAyahs,
    'schemaVersion': schemaVersion,
  };

  static RoutineDayProgressEntry? fromStored(dynamic value) {
    if (value is RoutineDayProgressEntry) return value;
    if (value is! Map) return null;
    final dynamic updatedAt = value['updatedAt'];
    final List<int> completedGlobalAyahs =
        (value['completedGlobalAyahs'] as List?)?.whereType<int>().toList() ??
        const <int>[];
    return RoutineDayProgressEntry(
      routineId: value['routineId'] as String? ?? '',
      dateKey: value['dateKey'] as String? ?? '',
      currentSurah: value['currentSurah'] as int? ?? 1,
      currentAyah: value['currentAyah'] as int? ?? 1,
      completedAyahCount: value['completedAyahCount'] as int? ?? 0,
      lastOpenedSurah: value['lastOpenedSurah'] as int? ?? 1,
      lastOpenedAyah: value['lastOpenedAyah'] as int? ?? 1,
      updatedAt: updatedAt is DateTime
          ? updatedAt
          : DateTime.fromMillisecondsSinceEpoch(0),
      completedGlobalAyahs: completedGlobalAyahs,
      schemaVersion:
          value['schemaVersion'] as int? ?? companionStorageSchemaVersion,
    );
  }
}

class ResumeStateEntry {
  const ResumeStateEntry({
    required this.id,
    required this.kind,
    required this.updatedAt,
    this.surah,
    this.ayah,
    this.juz,
    this.positionMillis,
    this.title = '',
    this.subtitle = '',
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final String kind;
  final int? surah;
  final int? ayah;
  final int? juz;
  final int? positionMillis;
  final String title;
  final String subtitle;
  final DateTime updatedAt;
  final int schemaVersion;
}

class RecentSearchEntry {
  const RecentSearchEntry({
    required this.id,
    required this.query,
    required this.mode,
    required this.searchedAt,
    this.resultCount = 0,
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final String query;
  final String mode;
  final DateTime searchedAt;
  final int resultCount;
  final int schemaVersion;
}

class DhikrSessionEntry {
  const DhikrSessionEntry({
    required this.id,
    required this.label,
    required this.startedAt,
    this.targetCount = 0,
    this.count = 0,
    this.completedAt,
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final String label;
  final int targetCount;
  final int count;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int schemaVersion;
}

class QuranStatsSnapshot {
  const QuranStatsSnapshot({
    required this.id,
    required this.updatedAt,
    this.totalAyahsRead = 0,
    this.estimatedLettersRead = 0,
    this.listeningSeconds = 0,
    this.totalReadingSeconds = 0,
    this.currentStreak = 0,
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final int totalAyahsRead;
  final int estimatedLettersRead;
  final int listeningSeconds;
  final int totalReadingSeconds;
  final int currentStreak;
  final DateTime updatedAt;
  final int schemaVersion;
}

class DownloadMetadataEntry {
  const DownloadMetadataEntry({
    required this.id,
    required this.reciterCode,
    required this.type,
    required this.path,
    required this.updatedAt,
    this.surah,
    this.ayah,
    this.sizeBytes = 0,
    this.status = 'available',
    this.schemaVersion = companionStorageSchemaVersion,
  });

  final String id;
  final String reciterCode;
  final String type;
  final int? surah;
  final int? ayah;
  final String path;
  final int sizeBytes;
  final String status;
  final DateTime updatedAt;
  final int schemaVersion;
}

class SchemaMigrationRecordAdapter extends TypeAdapter<SchemaMigrationRecord> {
  @override
  final int typeId = 10;

  @override
  SchemaMigrationRecord read(BinaryReader reader) {
    final fields = _readFields(reader);
    return SchemaMigrationRecord(
      key: fields[0] as String? ?? '',
      version: fields[1] as int? ?? 0,
      migratedAt:
          fields[2] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      success: fields[3] as bool? ?? false,
      message: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, SchemaMigrationRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.migratedAt)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.message);
  }
}

class QuranBookmarkEntryAdapter extends TypeAdapter<QuranBookmarkEntry> {
  @override
  final int typeId = 11;

  @override
  QuranBookmarkEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    return QuranBookmarkEntry(
      id: fields[0] as String? ?? '',
      surah: fields[1] as int? ?? 1,
      verse: fields[2] as int? ?? 1,
      isFavourite: fields[3] as bool? ?? true,
      note: fields[4] as String? ?? '',
      folder: fields[5] as String? ?? 'Default',
      tags: _stringList(fields[6]),
      createdAt:
          fields[7] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          fields[8] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      legacyKey: fields[9] as String? ?? '',
      schemaVersion: fields[10] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, QuranBookmarkEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surah)
      ..writeByte(2)
      ..write(obj.verse)
      ..writeByte(3)
      ..write(obj.isFavourite)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.folder)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.legacyKey)
      ..writeByte(10)
      ..write(obj.schemaVersion);
  }
}

class QuranActivityDayAdapter extends TypeAdapter<QuranActivityDay> {
  @override
  final int typeId = 12;

  @override
  QuranActivityDay read(BinaryReader reader) {
    final fields = _readFields(reader);
    return QuranActivityDay(
      dateKey: fields[0] as String? ?? '',
      ayahsRead: fields[1] as int? ?? 0,
      pagesRead: fields[2] as int? ?? 0,
      listeningSeconds: fields[3] as int? ?? 0,
      readAyahKeys: _stringList(fields[4]),
      updatedAt:
          fields[5] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: fields[6] as int? ?? 1,
      readingSeconds: fields[7] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, QuranActivityDay obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.ayahsRead)
      ..writeByte(2)
      ..write(obj.pagesRead)
      ..writeByte(3)
      ..write(obj.listeningSeconds)
      ..writeByte(4)
      ..write(obj.readAyahKeys)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.schemaVersion)
      ..writeByte(7)
      ..write(obj.readingSeconds);
  }
}

class ReadingPlanEntryAdapter extends TypeAdapter<ReadingPlanEntry> {
  @override
  final int typeId = 13;

  @override
  ReadingPlanEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(0);
    return ReadingPlanEntry(
      id: fields[0] as String? ?? '',
      type: fields[1] as String? ?? 'custom',
      title: fields[2] as String? ?? '',
      startedAt: fields[3] as DateTime? ?? now,
      finishBy: fields[4] as DateTime? ?? now,
      startGlobalAyah: fields[5] as int? ?? 1,
      targetGlobalAyah: fields[6] as int? ?? 6236,
      lastCompletedGlobalAyah: fields[7] as int? ?? 0,
      active: fields[8] as bool? ?? true,
      schemaVersion: fields[9] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingPlanEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.finishBy)
      ..writeByte(5)
      ..write(obj.startGlobalAyah)
      ..writeByte(6)
      ..write(obj.targetGlobalAyah)
      ..writeByte(7)
      ..write(obj.lastCompletedGlobalAyah)
      ..writeByte(8)
      ..write(obj.active)
      ..writeByte(9)
      ..write(obj.schemaVersion);
  }
}

class ResumeStateEntryAdapter extends TypeAdapter<ResumeStateEntry> {
  @override
  final int typeId = 14;

  @override
  ResumeStateEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    return ResumeStateEntry(
      id: fields[0] as String? ?? '',
      kind: fields[1] as String? ?? '',
      surah: fields[2] as int?,
      ayah: fields[3] as int?,
      juz: fields[4] as int?,
      positionMillis: fields[5] as int?,
      title: fields[6] as String? ?? '',
      subtitle: fields[7] as String? ?? '',
      updatedAt:
          fields[8] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: fields[9] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeStateEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.surah)
      ..writeByte(3)
      ..write(obj.ayah)
      ..writeByte(4)
      ..write(obj.juz)
      ..writeByte(5)
      ..write(obj.positionMillis)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.subtitle)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.schemaVersion);
  }
}

class RecentSearchEntryAdapter extends TypeAdapter<RecentSearchEntry> {
  @override
  final int typeId = 15;

  @override
  RecentSearchEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    return RecentSearchEntry(
      id: fields[0] as String? ?? '',
      query: fields[1] as String? ?? '',
      mode: fields[2] as String? ?? 'surah',
      searchedAt:
          fields[3] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      resultCount: fields[4] as int? ?? 0,
      schemaVersion: fields[5] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, RecentSearchEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.query)
      ..writeByte(2)
      ..write(obj.mode)
      ..writeByte(3)
      ..write(obj.searchedAt)
      ..writeByte(4)
      ..write(obj.resultCount)
      ..writeByte(5)
      ..write(obj.schemaVersion);
  }
}

class DhikrSessionEntryAdapter extends TypeAdapter<DhikrSessionEntry> {
  @override
  final int typeId = 16;

  @override
  DhikrSessionEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    return DhikrSessionEntry(
      id: fields[0] as String? ?? '',
      label: fields[1] as String? ?? '',
      targetCount: fields[2] as int? ?? 0,
      count: fields[3] as int? ?? 0,
      startedAt:
          fields[4] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: fields[5] as DateTime?,
      schemaVersion: fields[6] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, DhikrSessionEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.targetCount)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.startedAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.schemaVersion);
  }
}

class QuranStatsSnapshotAdapter extends TypeAdapter<QuranStatsSnapshot> {
  @override
  final int typeId = 17;

  @override
  QuranStatsSnapshot read(BinaryReader reader) {
    final fields = _readFields(reader);
    return QuranStatsSnapshot(
      id: fields[0] as String? ?? 'summary',
      totalAyahsRead: fields[1] as int? ?? 0,
      estimatedLettersRead: fields[2] as int? ?? 0,
      listeningSeconds: fields[3] as int? ?? 0,
      currentStreak: fields[4] as int? ?? 0,
      updatedAt:
          fields[5] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: fields[6] as int? ?? 1,
      totalReadingSeconds: fields[7] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, QuranStatsSnapshot obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalAyahsRead)
      ..writeByte(2)
      ..write(obj.estimatedLettersRead)
      ..writeByte(3)
      ..write(obj.listeningSeconds)
      ..writeByte(4)
      ..write(obj.currentStreak)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.schemaVersion)
      ..writeByte(7)
      ..write(obj.totalReadingSeconds);
  }
}

class DownloadMetadataEntryAdapter extends TypeAdapter<DownloadMetadataEntry> {
  @override
  final int typeId = 18;

  @override
  DownloadMetadataEntry read(BinaryReader reader) {
    final fields = _readFields(reader);
    return DownloadMetadataEntry(
      id: fields[0] as String? ?? '',
      reciterCode: fields[1] as String? ?? '',
      type: fields[2] as String? ?? '',
      surah: fields[3] as int?,
      ayah: fields[4] as int?,
      path: fields[5] as String? ?? '',
      sizeBytes: fields[6] as int? ?? 0,
      status: fields[7] as String? ?? 'available',
      updatedAt:
          fields[8] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: fields[9] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadMetadataEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reciterCode)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.surah)
      ..writeByte(4)
      ..write(obj.ayah)
      ..writeByte(5)
      ..write(obj.path)
      ..writeByte(6)
      ..write(obj.sizeBytes)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.schemaVersion);
  }
}

Map<int, dynamic> _readFields(BinaryReader reader) {
  final int numOfFields = reader.readByte();
  return <int, dynamic>{
    for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
  };
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((dynamic item) => item.toString()).toList();
  }
  return const <String>[];
}
