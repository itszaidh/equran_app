import 'package:equran/backend/resource_models.dart';
import 'package:equran/backend/settings_db.dart';
import 'package:http/http.dart' as http;

class ResourceRepository {
  ResourceRepository._();

  static final ResourceRepository instance = ResourceRepository._();

  static const String _manifestCacheKey = 'downloadableResourceManifest.v1';
  static const String _manifestFetchedAtKey =
      'downloadableResourceManifestFetchedAt.v1';
  static const String _assetLatestDownloadBase =
      'https://github.com/ya27hw/equran-assets/releases/latest/download';
  static const List<String> _remoteManifestUrls = <String>[
    '$_assetLatestDownloadBase/resource_manifest.json',
    '$_assetLatestDownloadBase/manifest.json',
  ];

  ResourceManifest? _cachedManifest;

  Future<ResourceManifest> loadManifest({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedManifest != null) return _cachedManifest!;

    if (forceRefresh || _cachedManifest == null) {
      final ResourceManifest? remoteManifest = await _loadRemoteManifest();
      if (remoteManifest != null) {
        _cachedManifest = remoteManifest;
        return remoteManifest;
      }
    }

    final ResourceManifest? storedManifest = _loadCachedManifest();
    if (storedManifest != null) {
      _cachedManifest = storedManifest;
      return storedManifest;
    }

    final ResourceManifest fallback = ResourceManifest.fromJson(
      _fallbackManifest,
    );
    _cachedManifest = fallback;
    return fallback;
  }

  Future<ResourceManifest> refreshManifest() {
    return loadManifest(forceRefresh: true);
  }

  Future<DownloadableResource?> resourceById(String id) async {
    return (await loadManifest()).resourceById(id);
  }

  Future<DownloadableResource?> timingResourceForReciter(
    String reciterCode,
  ) async {
    final String normalized = reciterCode.trim();
    if (normalized.isEmpty) return null;
    final ResourceManifest manifest = await loadManifest();
    for (final DownloadableResource resource in manifest.resourcesOfType(
      ResourceType.timings,
    )) {
      if (resource.reciterCode == normalized || resource.id == normalized) {
        return resource;
      }
    }
    return null;
  }

  ResourceManifest? _loadCachedManifest() {
    final Object? raw = SettingsDB().get(_manifestCacheKey);
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      return ResourceManifest.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<ResourceManifest?> _loadRemoteManifest() async {
    for (final String manifestUrl in _remoteManifestUrls) {
      try {
        final http.Response response = await http
            .get(Uri.parse(manifestUrl))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode != 200 || response.body.trim().isEmpty) {
          continue;
        }

        final ResourceManifest manifest = ResourceManifest.fromJsonString(
          response.body,
        );
        if (manifest.resources.isEmpty) continue;

        await SettingsDB().put(_manifestCacheKey, manifest.toJsonString());
        await SettingsDB().put(
          _manifestFetchedAtKey,
          DateTime.now().toUtc().toIso8601String(),
        );
        return manifest;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static final Map<String, Object?> _fallbackManifest = <String, Object?>{
    'version': 1,
    'resources': <Map<String, Object?>>[
      <String, Object?>{
        'id': 'en_al_jalalayn',
        'type': 'tafsir',
        'name': 'Al-Jalalayn',
        'language': 'en',
        'version': '1.0.0',
        'url': '$_assetLatestDownloadBase/en_al_jalalayn.zip',
        'sizeBytes': 857088,
      },
      <String, Object?>{
        'id': 'en_al_mukhtasar',
        'type': 'tafsir',
        'name': 'Al-Mukhtasar',
        'language': 'en',
        'version': '1.0.0',
        'url': '$_assetLatestDownloadBase/en_al_mukhtasar.zip',
      },
      <String, Object?>{
        'id': '2',
        'type': 'timings',
        'name': 'Abu Bakr Al Shatri timings',
        'reciterCode': '2',
        'version': '1.0.0',
        'url': '$_assetLatestDownloadBase/2.zip',
        'sizeBytes': 35778,
      },
      <String, Object?>{
        'id': '3',
        'type': 'timings',
        'name': 'Nasser Al Qatami timings',
        'reciterCode': '3',
        'version': '1.0.0',
        'url': '$_assetLatestDownloadBase/3.zip',
        'sizeBytes': 36122,
      },
      <String, Object?>{
        'id': '4',
        'type': 'timings',
        'name': 'Yasser Al Dosari timings',
        'reciterCode': '4',
        'version': '1.0.0',
        'url': '$_assetLatestDownloadBase/4.zip',
        'sizeBytes': 35905,
      },
    ],
  };
}

String prettyBytes(int? bytes) {
  if (bytes == null || bytes <= 0) return 'Size unknown';
  const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
  double value = bytes.toDouble();
  int unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final String formatted = unitIndex == 0 || value >= 10
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$formatted ${units[unitIndex]}';
}

String resourceDetailsLabel(DownloadableResource resource) {
  final List<String> parts = <String>[
    if (resource.language != null) resource.language!.toUpperCase(),
    if (resource.reciterCode != null) 'Reciter ${resource.reciterCode}',
    'v${resource.version}',
    prettyBytes(resource.sizeBytes),
  ];
  return parts.join(' • ');
}
