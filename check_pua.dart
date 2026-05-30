import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/data/quran/text/qpc-v4');
  for (int i = 1; i <= 114; i++) {
    final file = File('${dir.path}/$i.json');
    if (!file.existsSync()) continue;

    final data = jsonDecode(file.readAsStringSync());
    final ayahs = data['ayahs'] as List;

    String? previousText;
    int? previousLastRune;

    for (final ayah in ayahs) {
      final text = ayah['text'] as String;
      final currentNum = ayah['ayah'] as int;

      // Remove spaces/newlines to get only the PUA characters
      final puaOnly = text.replaceAll(RegExp(r'\s+'), '');
      if (puaOnly.isEmpty) continue;

      final firstRune = puaOnly.runes.first;

      if (previousLastRune != null) {
        // The first rune of this ayah should be strictly greater than the last rune of the previous ayah
        // unless it's a new page (which we can roughly check if the rune drops back to ﱁ (0xFC41) etc.)
        // But since we just want to find anomalies like 80:41:
        if (firstRune <= previousLastRune) {
          // It could be a new page. If it is a new page, it usually starts near 0xFC41 or 0x0600
          // Let's just print when the sequence drops.
          print(
            'Surah $i Ayah $currentNum: sequence drop from 0x${previousLastRune.toRadixString(16)} to 0x${firstRune.toRadixString(16)}',
          );
        }
      }

      previousLastRune = puaOnly.runes.last;
    }
  }
}
