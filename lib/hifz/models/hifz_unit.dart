import 'package:hive/hive.dart';
import 'package:quran/quran.dart' as quran;
import '../hifz_surah_data.dart';

part 'hifz_unit.g.dart';

enum HifzUnitType { surah, juz }

@HiveType(typeId: 4)
class HifzUnit extends HiveObject {
  @HiveField(0)
  late String id; // e.g. "surah_18" or "juz_30"

  @HiveField(1)
  late String unitType; // 'surah' or 'juz'

  @HiveField(2)
  late int unitNumber; // Surah number (1-114) or Juz number (1-30)

  @HiveField(3)
  late int frontierSurah; // Surah of next unseen ayah

  @HiveField(4)
  late int frontierAyah; // Ayah number of next unseen ayah

  @HiveField(5)
  late DateTime startedAt;

  @HiveField(6)
  DateTime? completedAt; // Set when frontier reaches end of unit

  @HiveField(7)
  late bool isComplete;

  HifzUnitType get type =>
      unitType == 'surah' ? HifzUnitType.surah : HifzUnitType.juz;

  // Total ayahs in this unit
  int get totalAyahs {
    if (type == HifzUnitType.surah) {
      return HifzSurahData.ayahCount(unitNumber);
    } else {
      return quran
          .getSurahAndVersesFromJuz(unitNumber)
          .values
          .fold(0, (sum, range) => sum + (range[1] - range[0] + 1));
    }
  }

  // How many ayahs have been introduced
  // (frontier position - start position)
  int get introducedAyahs {
    if (type == HifzUnitType.surah) {
      return frontierAyah - 1;
    } else {
      final juzData = quran.getSurahAndVersesFromJuz(unitNumber);
      final List<(int, int)> all = [];
      for (final entry in juzData.entries) {
        final surah = entry.key;
        final range = entry.value;
        for (int a = range[0]; a <= range[1]; a++) {
          all.add((surah, a));
        }
      }
      final idx = all.indexWhere(
        (e) => e.$1 == frontierSurah && e.$2 == frontierAyah,
      );
      return idx < 0 ? 0 : idx;
    }
  }

  double get progressFraction =>
      totalAyahs == 0 ? 0.0 : introducedAyahs / totalAyahs;

  // Display name
  String get displayName {
    if (type == HifzUnitType.surah) {
      return HifzSurahData.name(unitNumber);
    } else {
      return 'Juz $unitNumber';
    }
  }
}
