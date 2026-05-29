import 'package:equran/backend/library.dart' show SettingsDB;
import 'package:equran/utils/reciter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuranAudioStreamResolver {
  static const String _everyAyahBase = 'https://everyayah.com/data';

  /// Generates individual ayah strings for the reading pages (EveryAyah Model)
  /// Outputs format pattern: https://everyayah.com/data/Alafasy_128kbps/018010.mp3
  static String buildAyahUrl({
    required ReciterProfile reciter,
    required int surah,
    required int ayah,
  }) {
    final String paddedSurah = surah.toString().padLeft(3, '0');
    final String paddedAyah = ayah.toString().padLeft(3, '0');
    return '$_everyAyahBase/${reciter.everyAyahFolder}/$paddedSurah$paddedAyah.mp3';
  }

  /// Generates standalone full chapter strings for the player page
  /// Updated to use EveryAyah full chapter downloads
  static String buildFullSurahUrl({
    required ReciterProfile reciter,
    required int surah,
  }) {
    return '${reciter.fallbackSurahUrl}/$surah.mp3';
  }
}

class QuranAudioService {
  AppReciter get selectedReciter {
    final Object? savedValue = SettingsDB().get(
      'reciter',
      defaultValue: 'alafasy',
    );
    final String savedCode = savedValue?.toString() ?? 'alafasy';
    final String normalizedCode = AppReciter.normalizeCode(savedCode);
    if (normalizedCode != savedCode) {
      SettingsDB().put('reciter', normalizedCode);
    }
    return AppReciter.fromCode(normalizedCode);
  }

  Future<String> getSurahUrl(int surah) async {
    final reciter = selectedReciter;
    final profile = QuranAudioCatalog.findById(reciter.code);
    return QuranAudioStreamResolver.buildFullSurahUrl(
      reciter: profile,
      surah: surah,
    );
  }

  Future<String> getAyahUrl(int surah, int ayah) async {
    final reciter = selectedReciter;
    final profile = QuranAudioCatalog.findById(reciter.code);
    return QuranAudioStreamResolver.buildAyahUrl(
      reciter: profile,
      surah: surah,
      ayah: ayah,
    );
  }
}

class PlayerAudioService {
  static const String _baseUrl = 'https://quranapi.pages.dev/api';
  static final Map<String, Future<Map<String, dynamic>>> _responseCache =
      <String, Future<Map<String, dynamic>>>{};

  PlayerReciter get selectedReciter {
    final Object? savedValue = SettingsDB().get(
      'player_reciter',
      defaultValue: '1',
    );
    final String savedCode = savedValue?.toString() ?? '1';
    return PlayerReciter.fromCode(savedCode);
  }

  Future<String> getSurahUrl(int surah) async {
    final reciter = selectedReciter;
    final Map<String, dynamic> response = await _getJson(
      '$_baseUrl/$surah.json',
    );
    return _extractAudioUrl(response, reciter);
  }

  Future<Map<String, dynamic>> _getJson(String url) {
    return _responseCache.putIfAbsent(url, () async {
      try {
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          throw Exception('Audio API request failed: ${response.statusCode}');
        }

        final Object? decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected audio API response format.');
        }
        return decoded;
      } catch (_) {
        _responseCache.remove(url);
        rethrow;
      }
    });
  }

  String _extractAudioUrl(
    Map<String, dynamic> response,
    PlayerReciter reciter,
  ) {
    final dynamic audio = response['audio'];
    if (audio is! Map) {
      throw Exception('Audio data missing from API response.');
    }

    final dynamic reciterEntry = audio[reciter.code];
    if (reciterEntry is! Map) {
      throw Exception('Selected reciter is unavailable for this item.');
    }

    final dynamic originalUrl = reciterEntry['originalUrl'];
    if (originalUrl is String && originalUrl.isNotEmpty) {
      return originalUrl;
    }

    final dynamic fallbackUrl = reciterEntry['url'];
    if (fallbackUrl is String && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }

    throw Exception('No audio URL available for the selected reciter.');
  }
}
