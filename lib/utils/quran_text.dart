import 'package:quran/quran.dart' as quran;

const String quranBasmalaText = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ';

String favouriteAyahKey(int chapter, int verse) {
  return '$chapter-${verse.toString().padLeft(3, '0')}';
}

String arabicVerseNumber(int verse) {
  const Map<String, String> arabicDigits = <String, String>{
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  return verse
      .toString()
      .split('')
      .map((digit) => arabicDigits[digit] ?? digit)
      .join();
}

String quranVerseText(
  int chapter,
  int verse, {
  bool includeVerseNumber = false,
}) {
  String verseText = quran.getVerse(chapter, verse);
  if (verse == 1 && chapter != 1) {
    verseText = verseText.replaceAll(quranBasmalaText, '');
  }

  if (!includeVerseNumber) return verseText;
  return '$verseText ${arabicVerseNumber(verse)}';
}

String inlineQuranVerseSegment(int chapter, int verse) {
  return '\u2067${quranVerseText(chapter, verse, includeVerseNumber: true)}\u2069  ';
}

double shareArabicFontSizeForText(String verseText) {
  final int ayahLength = verseText.runes.length;
  return switch (ayahLength) {
    <= 80 => 86,
    <= 140 => 74,
    <= 220 => 62,
    <= 360 => 52,
    <= 520 => 42,
    <= 760 => 34,
    <= 980 => 30,
    _ => 26,
  };
}

double shareTranslationFontSizeForText(String verseText) {
  final int ayahLength = verseText.runes.length;
  return switch (ayahLength) {
    <= 140 => 26,
    <= 360 => 23,
    <= 760 => 18,
    <= 980 => 16,
    _ => 15,
  };
}
