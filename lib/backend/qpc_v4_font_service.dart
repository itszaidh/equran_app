import 'dart:async';
import 'dart:io';

import 'package:equran/backend/qcf_cpal_patcher.dart';
import 'package:equran/backend/resource_install_store.dart';
import 'package:equran/backend/resource_models.dart';
import 'package:flutter/services.dart';

class QpcV4FontService {
  QpcV4FontService._privateConstructor();
  static final QpcV4FontService instance =
      QpcV4FontService._privateConstructor();

  static const String tajweedFontsResourceId = 'qpc_v4_tajweed_fonts';
  static const DownloadableResource tajweedFontsResource = DownloadableResource(
    id: tajweedFontsResourceId,
    rawType: 'quran_fonts',
    name: 'QPC V4 Tajweed fonts',
    version: '1.0.0',
    url:
        'https://github.com/ya27hw/equran-assets/releases/download/1.0.0/tajweed.zip',
    metadata: <String, Object?>{'requiredPages': 604},
  );

  final Set<int> _loadedPages = <int>{};
  final Set<int> _loadingPages = <int>{};
  Map<int, File>? _fontFileIndex;
  String? _fontFileIndexRoot;

  /// Preloads a list of pages.
  Future<void> preloadFontsForPages(List<int> pages) async {
    for (final int page in pages) {
      unawaited(ensureFontLoadedForPage(page));
    }
  }

  /// Dynamically loads a font for a specific page if not already loaded.
  /// Returns true only when the page font is installed and loaded.
  Future<bool> ensureFontLoadedForPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return false;

    if (_loadedPages.contains(pageNumber)) {
      return await fontFileForPage(pageNumber) != null;
    }

    // Avoid duplicate download/load requests for the same page
    if (_loadingPages.contains(pageNumber)) {
      while (_loadingPages.contains(pageNumber)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return _loadedPages.contains(pageNumber);
    }

    _loadingPages.add(pageNumber);

    try {
      final File? fontFile = await fontFileForPage(pageNumber);
      if (fontFile == null) return false;
      final Uint8List bytes = await fontFile.readAsBytes();

      // Register light variant (original bytes)
      final FontLoader lightLoader = FontLoader(
        'QPCV4_Page_${pageNumber}_light',
      );
      lightLoader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));

      // Register dark variant (patched bytes)
      // Clone the bytes before patching to avoid mutating the light variant's buffer
      final Uint8List darkBytes = Uint8List.fromList(bytes);
      final Uint8List patchedBytes = QcfCpalPatcher.patchForDarkMode(darkBytes);

      final FontLoader darkLoader = FontLoader('QPCV4_Page_${pageNumber}_dark');
      darkLoader.addFont(
        Future<ByteData>.value(ByteData.sublistView(patchedBytes)),
      );

      // Wait for both to load
      await Future.wait<void>(<Future<void>>[
        lightLoader.load(),
        darkLoader.load(),
      ]);

      _loadedPages.add(pageNumber);
      return true;
    } catch (e) {
      // Graceful fallback if loading fails (e.g. offline).
      return false;
    } finally {
      _loadingPages.remove(pageNumber);
    }
  }

  Future<bool> hasAllPageFonts() async {
    final Map<int, File> index = await _installedFontFileIndex();
    for (int page = 1; page <= 604; page++) {
      if (!index.containsKey(page)) return false;
    }
    return true;
  }

  Future<File?> fontFileForPage(int pageNumber) async {
    final Map<int, File> index = await _installedFontFileIndex();
    return index[pageNumber];
  }

  void clearCache() {
    _loadingPages.clear();
    _fontFileIndex = null;
    _fontFileIndexRoot = null;
  }

  Future<Map<int, File>> _installedFontFileIndex() async {
    final InstalledResource? installed = ResourceInstallStore.instance
        .installedFor(tajweedFontsResource);
    if (installed == null || installed.status != 'installed') {
      _fontFileIndex = const <int, File>{};
      _fontFileIndexRoot = null;
      return _fontFileIndex!;
    }

    final Directory directory = Directory(installed.localPath);
    if (!await directory.exists()) {
      _fontFileIndex = const <int, File>{};
      _fontFileIndexRoot = null;
      return _fontFileIndex!;
    }

    if (_fontFileIndexRoot == directory.path && _fontFileIndex != null) {
      return _fontFileIndex!;
    }

    final Map<int, File> index = <int, File>{};
    await for (final FileSystemEntity entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final String name = entity.uri.pathSegments
          .where((String segment) => segment.isNotEmpty)
          .last;
      final int? page = _qpcV4FontPageNumber(name);
      if (page != null) {
        index.putIfAbsent(page, () => entity);
      }
    }

    _fontFileIndex = Map<int, File>.unmodifiable(index);
    _fontFileIndexRoot = directory.path;
    return _fontFileIndex!;
  }

  static int? _qpcV4FontPageNumber(String fileName) {
    final RegExpMatch? match = RegExp(
      r'^(?:p|page)?0*([1-9][0-9]{0,2})\.ttf$',
      caseSensitive: false,
    ).firstMatch(fileName.trim());
    if (match == null) return null;
    final int? page = int.tryParse(match.group(1)!);
    if (page == null || page < 1 || page > 604) return null;
    return page;
  }
}
