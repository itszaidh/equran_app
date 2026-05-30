import 'dart:convert';
import 'dart:io';

import 'package:quran/quran.dart' as quran;

void main() {
  final dir = Directory('assets/data/quran/text/qpc-v4');

  int qpcV4Page = 1;
  int diffCount = 0;

  for (int i = 1; i <= 114; i++) {
    final file = File('${dir.path}/$i.json');
    if (!file.existsSync()) continue;

    final data = jsonDecode(file.readAsStringSync());
    final ayahs = data['ayahs'] as List;

    int? previousLastRune;

    for (final ayah in ayahs) {
      final text = ayah['text'] as String;
      final currentNum = ayah['ayah'] as int;

      final puaOnly = text.replaceAll(RegExp(r'\s+'), '');
      if (puaOnly.isEmpty) continue;

      final firstRune = puaOnly.runes.first;

      if (previousLastRune != null) {
        if (firstRune <= previousLastRune) {
          // New page
          qpcV4Page++;
        }
      } else if (i == 1 && currentNum == 1) {
        // First page
      } else if (firstRune == 0xfc41 && i != 1) {
        // Wait, if it's the very first ayah of the surah, and it's 0xFC41, it might be a new page.
        // But previousLastRune is null because it's a new file.
        // We can't rely on this across surahs easily unless we remember the last rune of the previous surah.
      }

      previousLastRune = puaOnly.runes.last;
    }
  }
}
