import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import 'juz_data.dart';
import 'page_data.dart';
import 'sajdah_verses.dart';
import 'surah_data.dart';

const int totalPagesCount = 604;
const int totalMakkiSurahs = 89;
const int totalMadaniSurahs = 25;
const int totalJuzCount = 30;
const int totalSurahCount = 114;
const int totalVerseCount = 6236;
const String basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
const String sajdah = 'سَجْدَةٌ';

const String _quranTextAssetBase = 'assets/data/quran/text';
const String _translationAssetBase = 'assets/data/quran/translations';
const String missingTranslationPrefix = '__missing_translation__';

final Map<int, Map<int, String>> _quranTextCache = <int, Map<int, String>>{};
final Map<Translation, Map<int, Map<int, String>>> _translationCache =
    <Translation, Map<int, Map<int, String>>>{};
final Set<Translation> _missingTranslations = <Translation>{};

Future<void> initializeQuran({
  bool preloadText = true,
  Iterable<Translation> preloadTranslations = const <Translation>[
    Translation.enSaheeh,
  ],
}) async {
  if (preloadText) {
    await Future.wait(<Future<void>>[
      for (int surah = 1; surah <= totalSurahCount; surah++)
        ensureSurahTextLoaded(surah),
    ]);
  }
  for (final Translation translation in preloadTranslations) {
    await Future.wait(<Future<void>>[
      for (int surah = 1; surah <= totalSurahCount; surah++)
        ensureTranslationSurahLoaded(translation, surah),
    ]);
  }
}

Future<void> ensureSurahTextLoaded(int surahNumber) async {
  final int surah = _validSurahNumber(surahNumber);
  if (_quranTextCache.containsKey(surah)) return;
  _quranTextCache[surah] = await _loadAssetSurah(
    '$_quranTextAssetBase/$surah.json',
    surah,
  );
}

Future<void> ensureTranslationSurahLoaded(
  Translation translation,
  int surahNumber,
) async {
  final int surah = _validSurahNumber(surahNumber);
  final Map<int, Map<int, String>> translationMap = _translationCache
      .putIfAbsent(translation, () => <int, Map<int, String>>{});
  if (translationMap.containsKey(surah) ||
      _missingTranslations.contains(translation)) {
    return;
  }

  try {
    translationMap[surah] = await _loadAssetSurah(
      '$_translationAssetBase/${translation.resourceId}/$surah.json',
      surah,
    );
  } on FlutterError {
    _missingTranslations.add(translation);
  }
}

void registerTranslationSurah({
  required Translation translation,
  required int surah,
  required Map<int, String> verses,
}) {
  final int normalizedSurah = _validSurahNumber(surah);
  final Map<int, Map<int, String>> cache = _translationCache.putIfAbsent(
    translation,
    () => <int, Map<int, String>>{},
  );
  cache[normalizedSurah] = Map<int, String>.unmodifiable(verses);
  _missingTranslations.remove(translation);
}

void clearRegisteredTranslation(Translation translation) {
  if (translation == Translation.enSaheeh) return;
  _translationCache.remove(translation);
  _missingTranslations.add(translation);
}

bool isTranslationLoaded(Translation translation) {
  if (_missingTranslations.contains(translation)) return false;
  final Map<int, Map<int, String>>? loaded = _translationCache[translation];
  return loaded != null && loaded.length == totalSurahCount;
}

String missingTranslationMessage(Translation translation) {
  return 'Download ${translation.label} in Settings to view this translation.';
}

bool isMissingTranslationText(String text) {
  return text.startsWith(missingTranslationPrefix);
}

String cleanTranslationText(String text) {
  return isMissingTranslationText(text)
      ? text.substring(missingTranslationPrefix.length)
      : text;
}

List getPageData(int pageNumber) {
  if (pageNumber < 1 || pageNumber > totalPagesCount) {
    throw 'Invalid page number. Page number must be between 1 and 604';
  }
  return pageData[pageNumber - 1];
}

int getSurahCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > totalPagesCount) {
    throw 'Invalid page number. Page number must be between 1 and 604';
  }
  return pageData[pageNumber - 1].length;
}

int getVerseCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > totalPagesCount) {
    throw 'Invalid page number. Page number must be between 1 and 604';
  }
  int totalVerseCount = 0;
  for (int i = 0; i < pageData[pageNumber - 1].length; i++) {
    totalVerseCount += int.parse(
      pageData[pageNumber - 1][i]!['end'].toString(),
    );
  }
  return totalVerseCount;
}

int getJuzNumber(int surahNumber, int verseNumber) {
  for (final Map<String, dynamic> item in juz) {
    if (item['verses'].keys.contains(surahNumber)) {
      if (verseNumber >= item['verses'][surahNumber][0] &&
          verseNumber <= item['verses'][surahNumber][1]) {
        return int.parse(item['id'].toString());
      }
    }
  }
  return -1;
}

Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber) {
  if (juzNumber < 1 || juzNumber > totalJuzCount) {
    throw 'Invalid juz number. Juz number must be between 1 and 30';
  }
  return juz[juzNumber - 1]['verses'] as Map<int, List<int>>;
}

String getSurahName(int surahNumber) {
  return _surahValue(surahNumber, 'name');
}

String getSurahNameEnglish(int surahNumber) {
  return _surahValue(surahNumber, 'english');
}

String getSurahNameTurkish(int surahNumber) {
  return _surahValue(surahNumber, 'turkish');
}

String getSurahNameFrench(int surahNumber) {
  return _surahValue(surahNumber, 'french');
}

String getSurahNameArabic(int surahNumber) {
  return _surahValue(surahNumber, 'arabic');
}

String getSurahNameRussian(int surahNumber) {
  return _surahValue(surahNumber, 'russian');
}

int getPageNumber(int surahNumber, int verseNumber) {
  _validSurahNumber(surahNumber);
  for (int pageIndex = 0; pageIndex < pageData.length; pageIndex++) {
    for (
      int surahIndexInPage = 0;
      surahIndexInPage < pageData[pageIndex].length;
      surahIndexInPage++
    ) {
      final dynamic item = pageData[pageIndex][surahIndexInPage];
      if (item['surah'] == surahNumber &&
          item['start'] <= verseNumber &&
          item['end'] >= verseNumber) {
        return pageIndex + 1;
      }
    }
  }
  throw 'Invalid verse number.';
}

String getPlaceOfRevelation(int surahNumber) {
  return _surahValue(surahNumber, 'place');
}

int getVerseCount(int surahNumber) {
  return int.parse(_surahValue(surahNumber, 'aya'));
}

String getVerse(
  int surahNumber,
  int verseNumber, {
  bool verseEndSymbol = false,
}) {
  final String? verse = _loadedSurahText(surahNumber)[verseNumber];
  if (verse == null) {
    throw 'No verse found with given surahNumber and verseNumber.\n\n';
  }
  return verse + (verseEndSymbol ? getVerseEndSymbol(verseNumber) : '');
}

String getJuzURL(int juzNumber) => 'https://quran.com/juz/$juzNumber';
String getSurahURL(int surahNumber) => 'https://quran.com/$surahNumber';
String getVerseURL(int surahNumber, int verseNumber) =>
    'https://quran.com/$surahNumber/$verseNumber';

String getVerseEndSymbol(int verseNumber, {bool arabicNumeral = true}) {
  if (!arabicNumeral) return '\u06dd${verseNumber.toString()}';
  const Map<String, String> arabicNumbers = <String, String>{
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
  return '\u06dd${verseNumber.toString().split('').map((String digit) {
    return arabicNumbers[digit] ?? digit;
  }).join()}';
}

List<int> getSurahPages(int surahNumber) {
  _validSurahNumber(surahNumber);
  final List<int> pages = <int>[];
  for (int currentPage = 1; currentPage <= totalPagesCount; currentPage++) {
    final List page = getPageData(currentPage);
    for (int j = 0; j < page.length; j++) {
      if (page[j]['surah'] == surahNumber) {
        pages.add(currentPage);
        break;
      }
    }
  }
  return pages;
}

enum SurahSeperator {
  none,
  surahName,
  surahNameArabic,
  surahNameEnglish,
  surahNameTurkish,
  surahNameFrench,
  surahNameRussian,
}

List<String> getVersesTextByPage(
  int pageNumber, {
  bool verseEndSymbol = false,
  SurahSeperator surahSeperator = SurahSeperator.none,
  String customSurahSeperator = '',
}) {
  if (pageNumber > totalPagesCount || pageNumber <= 0) {
    throw 'Invalid pageNumber';
  }

  final List<String> verses = <String>[];
  final List page = getPageData(pageNumber);
  for (final dynamic data in page) {
    if (customSurahSeperator != '') {
      verses.add(customSurahSeperator);
    } else if (surahSeperator == SurahSeperator.surahName) {
      verses.add(getSurahName(data['surah'] as int));
    } else if (surahSeperator == SurahSeperator.surahNameArabic) {
      verses.add(getSurahNameArabic(data['surah'] as int));
    } else if (surahSeperator == SurahSeperator.surahNameEnglish) {
      verses.add(getSurahNameEnglish(data['surah'] as int));
    } else if (surahSeperator == SurahSeperator.surahNameTurkish) {
      verses.add(getSurahNameTurkish(data['surah'] as int));
    } else if (surahSeperator == SurahSeperator.surahNameFrench) {
      verses.add(getSurahNameFrench(data['surah'] as int));
    } else if (surahSeperator == SurahSeperator.surahNameRussian) {
      verses.add(getSurahNameRussian(data['surah'] as int));
    }
    for (int j = data['start'] as int; j <= (data['end'] as int); j++) {
      verses.add(
        getVerse(data['surah'] as int, j, verseEndSymbol: verseEndSymbol),
      );
    }
  }
  return verses;
}

enum Reciter {
  arAlafasy('ar.alafasy', 'Alafasy'),
  arHusary('ar.husary', 'Husary'),
  arAhmedAjamy('ar.ahmedajamy', 'Ahmed al-Ajamy'),
  arHudhaify('ar.hudhaify', 'Hudhaify'),
  arMaherMuaiqly('ar.mahermuaiqly', 'Maher Al Muaiqly'),
  arMuhammadAyyoub('ar.muhammadayyoub', 'Muhammad Ayyoub'),
  arMuhammadJibreel('ar.muhammadjibreel', 'Muhammad Jibreel'),
  arMinshawi('ar.minshawi', 'Minshawi'),
  arShaatree('ar.shaatree', 'Abu Bakr Ash-Shaatree');

  const Reciter(this.code, this.englishName);

  final String code;
  final String englishName;
}

String getAudioURLBySurah(
  int surahNumber, {
  Reciter reciter = Reciter.arAlafasy,
  int bitrate = 128,
}) {
  return 'https://cdn.islamic.network/quran/audio-surah/$bitrate/${reciter.code}/$surahNumber.mp3';
}

String getAudioURLByVerse(
  int surahNumber,
  int verseNumber, {
  Reciter reciter = Reciter.arAlafasy,
  int bitrate = 128,
}) {
  int verseNum = 0;
  for (int i = 1; i < surahNumber; i++) {
    verseNum += getVerseCount(i);
  }
  verseNum += verseNumber;
  return 'https://cdn.islamic.network/quran/audio/$bitrate/${reciter.code}/$verseNum.mp3';
}

bool isSajdahVerse(int surahNumber, int verseNumber) {
  return sajdahVerses[surahNumber] == verseNumber;
}

String getAudioURLByVerseNumber(
  int verseNumber, {
  Reciter reciter = Reciter.arAlafasy,
  int bitrate = 128,
}) {
  return 'https://cdn.islamic.network/quran/audio/$bitrate/${reciter.code}/$verseNumber.mp3';
}

enum Translation {
  enSaheeh('en_saheeh', 'English (Saheeh)', true),
  enClearQuran('en_clear_quran', 'English (Clear Quran)', false),
  trSaheeh('tr_saheeh', 'Turkish (Saheeh)', false),
  mlAbdulHameed('ml_abdul_hameed', 'Malayalam (Abdul Hameed)', false),
  faHusseinDari('fa_hussein_dari', 'Persian (Hussein Dari)', false),
  frHamidullah('fr_hamidullah', 'French (Hamidullah)', false),
  itPiccardo('it_piccardo', 'Italian (Piccardo)', false),
  nlSiregar('nl_siregar', 'Dutch (Siregar)', false),
  portuguese('portuguese', 'Portuguese', false),
  ruKuliev('ru_kuliev', 'Russian (Kuliev)', false),
  urdu('urdu', 'Urdu', false),
  bengali('bengali', 'Bengali', false),
  chinese('chinese', 'Chinese', false),
  indonesian('indonesian', 'Indonesian', false),
  spanish('spanish', 'Spanish', false),
  swedish('swedish', 'Swedish', false);

  const Translation(this.resourceId, this.label, this.isBundled);

  final String resourceId;
  final String label;
  final bool isBundled;
}

String getVerseTranslation(
  int surahNumber,
  int verseNumber, {
  bool verseEndSymbol = false,
  Translation translation = Translation.enSaheeh,
}) {
  final Map<int, String>? surahTranslation =
      _translationCache[translation]?[surahNumber] ??
      _loadTranslationSyncFromFile(translation, surahNumber);
  final String? verse = surahTranslation?[verseNumber];
  if (verse == null) {
    return '$missingTranslationPrefix${missingTranslationMessage(translation)}';
  }
  return verse +
      (verseEndSymbol
          ? getVerseEndSymbol(verseNumber, arabicNumeral: false)
          : '');
}

Map searchWordsInTranslation(
  List<String> words, {
  Translation translation = Translation.enSaheeh,
}) {
  final List<Map<String, int>> result = <Map<String, int>>[];
  for (int surah = 1; surah <= totalSurahCount; surah++) {
    final Map<int, String>? verses =
        _translationCache[translation]?[surah] ??
        _loadTranslationSyncFromFile(translation, surah);
    if (verses == null) continue;
    verses.forEach((int verse, String content) {
      final bool exists = words.any((String word) {
        return content.toLowerCase().contains(word.toLowerCase());
      });
      if (exists) result.add(<String, int>{'surah': surah, 'verse': verse});
    });
  }
  return <String, Object>{'occurences': result.length, 'result': result};
}

Map searchWords(List<String> words) {
  final List<Map<String, int>> result = <Map<String, int>>[];
  for (int surah = 1; surah <= totalSurahCount; surah++) {
    final Map<int, String> verses = _loadedSurahText(surah);
    verses.forEach((int verse, String content) {
      final bool exists = words.any((String word) {
        return content.toLowerCase().contains(word.toLowerCase());
      });
      if (exists) result.add(<String, int>{'surah': surah, 'verse': verse});
    });
  }
  return <String, Object>{'occurences': result.length, 'result': result};
}

class RandomVerse {
  RandomVerse() {
    final Random random = Random();
    surahNumber = random.nextInt(totalSurahCount) + 1;
    verseNumber = random.nextInt(getVerseCount(surahNumber)) + 1;
    verse = getVerse(surahNumber, verseNumber);
    translation = getVerseTranslation(surahNumber, verseNumber);
  }

  late int surahNumber;
  late int verseNumber;
  late String verse;
  late String translation;
}

Future<Map<int, String>> _loadAssetSurah(String assetPath, int surah) async {
  final String raw = await rootBundle.loadString(assetPath);
  return _parseSurahJson(raw, surah);
}

Map<int, String> _loadedSurahText(int surahNumber) {
  final int surah = _validSurahNumber(surahNumber);
  return _quranTextCache[surah] ?? _loadTextSyncFromFile(surah);
}

Map<int, String> _loadTextSyncFromFile(int surah) {
  final Map<int, String>? cached = _quranTextCache[surah];
  if (cached != null) return cached;
  final File file = File('$_quranTextAssetBase/$surah.json');
  if (!file.existsSync()) {
    throw 'Quran text is not loaded. Call initializeQuran() before reading verses.';
  }
  final Map<int, String> parsed = _parseSurahJson(
    file.readAsStringSync(),
    surah,
  );
  _quranTextCache[surah] = parsed;
  return parsed;
}

Map<int, String>? _loadTranslationSyncFromFile(
  Translation translation,
  int surah,
) {
  if (_missingTranslations.contains(translation)) return null;
  final Map<int, Map<int, String>> translationMap = _translationCache
      .putIfAbsent(translation, () => <int, Map<int, String>>{});
  final Map<int, String>? cached = translationMap[surah];
  if (cached != null) return cached;
  final File file = File(
    '$_translationAssetBase/${translation.resourceId}/$surah.json',
  );
  if (!file.existsSync()) {
    if (!translation.isBundled) _missingTranslations.add(translation);
    return null;
  }
  final Map<int, String> parsed = _parseSurahJson(
    file.readAsStringSync(),
    surah,
  );
  translationMap[surah] = parsed;
  return parsed;
}

Map<int, String> _parseSurahJson(String raw, int expectedSurah) {
  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map || decoded['ayahs'] is! List) {
    throw const FormatException('Unexpected Quran JSON shape.');
  }

  final Map<int, String> mapped = <int, String>{};
  for (final Object? entry in decoded['ayahs'] as List) {
    if (entry is! Map) continue;
    final int? surah = _readInt(entry['surah']);
    final int? ayah = _readInt(entry['ayah']);
    final Object? text = entry['text'];
    if (surah != expectedSurah || ayah == null || text is! String) continue;
    mapped[ayah] = text;
  }
  return Map<int, String>.unmodifiable(mapped);
}

int _validSurahNumber(int surahNumber) {
  if (surahNumber > totalSurahCount || surahNumber <= 0) {
    throw 'No Surah found with given surahNumber';
  }
  return surahNumber;
}

String _surahValue(int surahNumber, String key) {
  _validSurahNumber(surahNumber);
  return surah[surahNumber - 1][key].toString();
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
