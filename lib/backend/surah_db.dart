import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:equran/backend/base_db.dart';
import 'package:equran/backend/settings_db.dart';

class SurahDB extends BaseDB {
  SurahDB._privateConstructor() : super("surahs");

  static final SurahDB _instance = SurahDB._privateConstructor();

  factory SurahDB() {
    return _instance;
  }

  /// Dynamically resolves the correct text asset path depending on font choices
  Future<List<String>> loadSurahVerses(int surahNumber) async {
    final String activeStyle = SettingsDB().quranScriptStyle;
    final String assetTarget =
        'assets/data/quran/text/$activeStyle/$surahNumber.json';

    try {
      final String jsonString = await rootBundle.loadString(assetTarget);
      final Map<String, dynamic> decoded =
          json.decode(jsonString) as Map<String, dynamic>;
      if (decoded.containsKey('ayahs')) {
        final List<dynamic> decodedList = decoded['ayahs'] as List<dynamic>;
        return decodedList.map((entry) => entry['text'].toString()).toList();
      }
      final List<dynamic> decodedList =
          json.decode(jsonString) as List<dynamic>;
      return decodedList.map((verse) => verse.toString()).toList();
    } catch (e) {
      // Robust structural fallback safety check to avoid application crashes on upgrade cycles
      final String fallbackTarget =
          'assets/data/quran/text/uthmani/$surahNumber.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackTarget);
        final Map<String, dynamic> decoded =
            json.decode(jsonString) as Map<String, dynamic>;
        if (decoded.containsKey('ayahs')) {
          final List<dynamic> decodedList = decoded['ayahs'] as List<dynamic>;
          return decodedList.map((entry) => entry['text'].toString()).toList();
        }
        final List<dynamic> decodedList =
            json.decode(jsonString) as List<dynamic>;
        return decodedList.map((verse) => verse.toString()).toList();
      } catch (_) {
        return <String>[];
      }
    }
  }
}

class QuranTextAssetRepository {
  final Box _settingsBox;
  const QuranTextAssetRepository(this._settingsBox);

  /// Dynamically resolves the correct text asset path depending on font choices
  Future<List<String>> loadSurahVerses(int surahNumber) async {
    final String activeStyle =
        _settingsBox.get('quran_script_style', defaultValue: 'uthmani')
            as String;
    final String assetTarget =
        'assets/data/quran/text/$activeStyle/$surahNumber.json';

    try {
      final String jsonString = await rootBundle.loadString(assetTarget);
      final Map<String, dynamic> decoded =
          json.decode(jsonString) as Map<String, dynamic>;
      if (decoded.containsKey('ayahs')) {
        final List<dynamic> decodedList = decoded['ayahs'] as List<dynamic>;
        return decodedList.map((entry) => entry['text'].toString()).toList();
      }
      final List<dynamic> decodedList =
          json.decode(jsonString) as List<dynamic>;
      return decodedList.map((verse) => verse.toString()).toList();
    } catch (e) {
      // Robust structural fallback safety check to avoid application crashes on upgrade cycles
      final String fallbackTarget =
          'assets/data/quran/text/uthmani/$surahNumber.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackTarget);
        final Map<String, dynamic> decoded =
            json.decode(jsonString) as Map<String, dynamic>;
        if (decoded.containsKey('ayahs')) {
          final List<dynamic> decodedList = decoded['ayahs'] as List<dynamic>;
          return decodedList.map((entry) => entry['text'].toString()).toList();
        }
        final List<dynamic> decodedList =
            json.decode(jsonString) as List<dynamic>;
        return decodedList.map((verse) => verse.toString()).toList();
      } catch (_) {
        return <String>[];
      }
    }
  }
}
