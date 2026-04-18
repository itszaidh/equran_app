import 'dart:io';
import 'dart:math';

import 'package:equran/backend/quran_stream_url.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;

class AudioDownloadEntry {
  const AudioDownloadEntry({
    required this.file,
    required this.type,
    required this.reciterCode,
    required this.surah,
    required this.sizeBytes,
    this.ayah,
  });

  final File file;
  final AudioDownloadType type;
  final String reciterCode;
  final int surah;
  final int? ayah;
  final int sizeBytes;

  String get title => type == AudioDownloadType.surah
      ? quran.getSurahName(surah)
      : '${quran.getSurahName(surah)} • Ayah $ayah';

  String get subtitle => type == AudioDownloadType.surah
      ? 'Surah ${surah.toString().padLeft(3, '0')}'
      : 'Surah $surah, Ayah $ayah';
}

enum AudioDownloadType { surah, ayah }

class AudioDownloadsSummary {
  const AudioDownloadsSummary({
    required this.surahDownloads,
    required this.ayahDownloads,
  });

  final List<AudioDownloadEntry> surahDownloads;
  final List<AudioDownloadEntry> ayahDownloads;

  List<AudioDownloadEntry> get allDownloads => <AudioDownloadEntry>[
    ...surahDownloads,
    ...ayahDownloads,
  ];

  int get totalSizeBytes =>
      allDownloads.fold<int>(0, (total, entry) => total + entry.sizeBytes);
}

class AudioDownloadService {
  static const String _surahDirectoryName = 'surah_audio';
  static const String _ayahDirectoryName = 'ayah_audio';

  Future<Directory> _audioDirectory(String directoryName) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${baseDir.path}/$directoryName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> surahDirectory() => _audioDirectory(_surahDirectoryName);

  Future<Directory> ayahDirectory() => _audioDirectory(_ayahDirectoryName);

  String _reciterCode() => QuranAudioService().selectedReciter.code;

  String surahFileName(int surah) {
    return '${_reciterCode()}_${surah.toString().padLeft(3, '0')}.mp3';
  }

  String ayahFileName(int surah, int ayah) {
    return '${_reciterCode()}_${surah.toString().padLeft(3, '0')}_${ayah.toString().padLeft(3, '0')}.mp3';
  }

  Future<File> surahFile(int surah) async {
    final Directory dir = await surahDirectory();
    return File('${dir.path}/${surahFileName(surah)}');
  }

  Future<File> ayahFile(int surah, int ayah) async {
    final Directory dir = await ayahDirectory();
    return File('${dir.path}/${ayahFileName(surah, ayah)}');
  }

  Future<bool> hasSurah(int surah) async {
    final File file = await surahFile(surah);
    return file.existsSync();
  }

  Future<bool> hasAyah(int surah, int ayah) async {
    final File file = await ayahFile(surah, ayah);
    return file.existsSync();
  }

  Future<File> downloadSurah(int surah) async {
    final String url = await QuranAudioService().getSurahUrl(surah);
    final File file = await surahFile(surah);
    await _downloadToFile(url, file);
    return file;
  }

  Future<File> downloadAyah(int surah, int ayah) async {
    final String url = await QuranAudioService().getAyahUrl(surah, ayah);
    final File file = await ayahFile(surah, ayah);
    await _downloadToFile(url, file);
    return file;
  }

  Future<void> _downloadToFile(String url, File file) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }
    await file.writeAsBytes(response.bodyBytes, flush: true);
  }

  Future<void> deleteSurah(int surah) async {
    final File file = await surahFile(surah);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteAyah(int surah, int ayah) async {
    final File file = await ayahFile(surah, ayah);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteEntry(AudioDownloadEntry entry) async {
    if (entry.file.existsSync()) {
      await entry.file.delete();
    }
  }

  Future<void> clearAll() async {
    final AudioDownloadsSummary downloadsSummary = await summary();
    for (final AudioDownloadEntry entry in downloadsSummary.allDownloads) {
      await deleteEntry(entry);
    }
  }

  Future<AudioDownloadsSummary> summary() async {
    final List<AudioDownloadEntry> surahs = await _scanSurahs();
    final List<AudioDownloadEntry> ayahs = await _scanAyahs();
    surahs.sort(_compareEntries);
    ayahs.sort(_compareEntries);
    return AudioDownloadsSummary(surahDownloads: surahs, ayahDownloads: ayahs);
  }

  int _compareEntries(AudioDownloadEntry a, AudioDownloadEntry b) {
    final int surahCompare = a.surah.compareTo(b.surah);
    if (surahCompare != 0) return surahCompare;
    return (a.ayah ?? 0).compareTo(b.ayah ?? 0);
  }

  Future<List<AudioDownloadEntry>> _scanSurahs() async {
    final Directory dir = await surahDirectory();
    final RegExp pattern = RegExp(r'^(.+)_(\d{3})\.mp3$');
    final List<AudioDownloadEntry> entries = <AudioDownloadEntry>[];

    for (final FileSystemEntity entity in dir.listSync()) {
      if (entity is! File) continue;
      final RegExpMatch? match = pattern.firstMatch(_basename(entity.path));
      if (match == null) continue;
      final int? surah = int.tryParse(match.group(2)!);
      if (surah == null || surah < 1 || surah > 114) continue;
      entries.add(
        AudioDownloadEntry(
          file: entity,
          type: AudioDownloadType.surah,
          reciterCode: match.group(1)!,
          surah: surah,
          sizeBytes: entity.lengthSync(),
        ),
      );
    }
    return entries;
  }

  Future<List<AudioDownloadEntry>> _scanAyahs() async {
    final Directory dir = await ayahDirectory();
    final RegExp pattern = RegExp(r'^(.+)_(\d{3})_(\d{3})\.mp3$');
    final List<AudioDownloadEntry> entries = <AudioDownloadEntry>[];

    for (final FileSystemEntity entity in dir.listSync()) {
      if (entity is! File) continue;
      final RegExpMatch? match = pattern.firstMatch(_basename(entity.path));
      if (match == null) continue;
      final int? surah = int.tryParse(match.group(2)!);
      final int? ayah = int.tryParse(match.group(3)!);
      if (surah == null || ayah == null) continue;
      if (surah < 1 || surah > 114 || ayah < 1) continue;
      entries.add(
        AudioDownloadEntry(
          file: entity,
          type: AudioDownloadType.ayah,
          reciterCode: match.group(1)!,
          surah: surah,
          ayah: ayah,
          sizeBytes: entity.lengthSync(),
        ),
      );
    }
    return entries;
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    final int unitIndex = min(
      units.length - 1,
      (log(bytes) / log(1024)).floor(),
    );
    final double value = bytes / pow(1024, unitIndex);
    final String formatted = unitIndex == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 10 ? 1 : 2);
    return '$formatted ${units[unitIndex]}';
  }

  String _basename(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}
