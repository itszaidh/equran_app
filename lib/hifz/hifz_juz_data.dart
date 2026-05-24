import 'hifz_surah_data.dart';

class HifzJuzData {
  // Each entry: [startSurah, startAyah, endSurah, endAyah]
  static const List<List<int>> juzBoundaries = [
    [1, 1, 2, 141], // Juz 1
    [2, 142, 2, 252], // Juz 2
    [2, 253, 3, 92], // Juz 3
    [3, 93, 4, 23], // Juz 4
    [4, 24, 4, 147], // Juz 5
    [4, 148, 5, 81], // Juz 6
    [5, 82, 6, 110], // Juz 7
    [6, 111, 7, 87], // Juz 8
    [7, 88, 8, 40], // Juz 9
    [8, 41, 9, 92], // Juz 10
    [9, 93, 11, 5], // Juz 11
    [11, 6, 12, 52], // Juz 12
    [12, 53, 14, 52], // Juz 13
    [14, 53, 16, 128], // Juz 14
    [17, 1, 18, 74], // Juz 15
    [18, 75, 20, 135], // Juz 16
    [21, 1, 22, 78], // Juz 17
    [23, 1, 25, 20], // Juz 18
    [25, 21, 27, 55], // Juz 19
    [27, 56, 29, 45], // Juz 20
    [29, 46, 33, 30], // Juz 21
    [33, 31, 36, 27], // Juz 22
    [36, 28, 39, 31], // Juz 23
    [39, 32, 41, 46], // Juz 24
    [41, 47, 45, 37], // Juz 25
    [46, 1, 51, 30], // Juz 26
    [51, 31, 57, 29], // Juz 27
    [58, 1, 66, 12], // Juz 28
    [67, 1, 77, 50], // Juz 29
    [78, 1, 114, 6], // Juz 30
  ];

  // Returns list of (surah, ayah) tuples
  // for all ayahs in a given juz (1-indexed)
  static List<(int, int)> ayahsInJuz(int juz) {
    assert(juz >= 1 && juz <= 30);
    final b = juzBoundaries[juz - 1];
    final startSurah = b[0];
    final startAyah = b[1];
    final endSurah = b[2];
    final endAyah = b[3];

    final result = <(int, int)>[];
    for (int s = startSurah; s <= endSurah; s++) {
      final aStart = s == startSurah ? startAyah : 1;
      final aEnd = s == endSurah ? endAyah : HifzSurahData.ayahCount(s);
      for (int a = aStart; a <= aEnd; a++) {
        result.add((s, a));
      }
    }
    return result;
  }

  // Returns which juz a given surah:ayah belongs to
  static int juzForAyah(int surah, int ayah) {
    for (int i = 0; i < juzBoundaries.length; i++) {
      final b = juzBoundaries[i];
      final startSurah = b[0];
      final startAyah = b[1];
      final endSurah = b[2];
      final endAyah = b[3];

      final afterStart =
          surah > startSurah || (surah == startSurah && ayah >= startAyah);
      final beforeEnd =
          surah < endSurah || (surah == endSurah && ayah <= endAyah);

      if (afterStart && beforeEnd) return i + 1;
    }
    return 1; // fallback
  }

  static String juzName(int juz) => 'Juz $juz';
}
