import 'package:hive/hive.dart';
import '../hifz_surah_data.dart';
import '../hifz_juz_data.dart';

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
      return HifzJuzData.ayahsInJuz(unitNumber).length;
    }
  }

  // How many ayahs have been introduced
  // (frontier position - start position)
  int get introducedAyahs {
    if (type == HifzUnitType.surah) {
      return frontierAyah - 1;
    } else {
      final all = HifzJuzData.ayahsInJuz(unitNumber);
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
      return HifzJuzData.juzName(unitNumber);
    }
  }
}
