import 'dart:io';

import 'package:equran/backend/resource_models.dart';
import 'package:equran/backend/settings_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ResourceInstallStore {
  ResourceInstallStore._();

  static final ResourceInstallStore instance = ResourceInstallStore._();

  static const String _installedResourcesKey = 'downloadableResources.v1';
  static const String _selectedTafsirResourcesKey =
      'selectedTafsirResourceIds.v1';

  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Map<String, InstalledResource> installedResources() {
    final Object? raw = SettingsDB().get(
      _installedResourcesKey,
      defaultValue: <String, Object?>{},
    );
    if (raw is! Map) return <String, InstalledResource>{};

    final Map<String, InstalledResource> installed =
        <String, InstalledResource>{};
    raw.forEach((dynamic key, dynamic value) {
      if (value is! Map) return;
      try {
        final InstalledResource resource = InstalledResource.fromJson(
          value.map(
            (dynamic itemKey, dynamic itemValue) =>
                MapEntry<String, Object?>(itemKey.toString(), itemValue),
          ),
        );
        if (resource.id.isEmpty || resource.rawType.isEmpty) return;
        installed[key.toString()] = resource;
      } catch (_) {
        // Ignore stale or malformed metadata and keep the app usable.
      }
    });
    return installed;
  }

  InstalledResource? installedFor(DownloadableResource resource) {
    return installedResources()[metadataKey(resource.rawType, resource.id)];
  }

  bool isInstalled(DownloadableResource resource) {
    final InstalledResource? installed = installedFor(resource);
    return installed != null &&
        installed.status == 'installed' &&
        Directory(installed.localPath).existsSync();
  }

  ResourceInstallState installStateFor(DownloadableResource resource) {
    final InstalledResource? installed = installedFor(resource);
    if (installed == null || !Directory(installed.localPath).existsSync()) {
      return ResourceInstallState.notDownloaded;
    }
    if (installed.version != resource.version) {
      return ResourceInstallState.updateAvailable;
    }
    return ResourceInstallState.installed;
  }

  Future<void> markInstalled({
    required DownloadableResource resource,
    required Directory directory,
    required String? sha256,
    required int? sizeBytes,
  }) async {
    final Map<String, InstalledResource> installed = installedResources();
    installed[metadataKey(resource.rawType, resource.id)] = InstalledResource(
      id: resource.id,
      rawType: resource.rawType,
      version: resource.version,
      installedAt: DateTime.now().toUtc(),
      localPath: directory.path,
      sha256: sha256,
      sizeBytes: sizeBytes ?? resource.sizeBytes,
      status: 'installed',
    );
    await _saveInstalledResources(installed);
  }

  Future<void> uninstall(DownloadableResource resource) async {
    final InstalledResource? installed = installedFor(resource);
    if (installed != null) {
      final Directory directory = Directory(installed.localPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }

    final Map<String, InstalledResource> installedResourcesMap =
        installedResources();
    installedResourcesMap.remove(metadataKey(resource.rawType, resource.id));
    await _saveInstalledResources(installedResourcesMap);
  }

  Future<Directory> installDirectory(DownloadableResource resource) async {
    final Directory root = await resourcesRootDirectory();
    final String typeDirectory = resource.type == ResourceType.translation
        ? 'translations'
        : _safePathSegment(resource.rawType);
    return Directory(
      '${root.path}${Platform.pathSeparator}$typeDirectory${Platform.pathSeparator}${_safePathSegment(resource.id)}',
    );
  }

  Future<Directory> resourcesRootDirectory() async {
    final Directory support = await getApplicationSupportDirectory();
    final Directory root = Directory(
      '${support.path}${Platform.pathSeparator}resources',
    );
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  List<String> selectedTafsirResourceIds(ResourceManifest manifest) {
    final List<String> manifestIds = manifest
        .resourcesOfType(ResourceType.tafsir)
        .map((DownloadableResource resource) => resource.id)
        .toList(growable: false);
    final Object? raw = SettingsDB().get(
      _selectedTafsirResourcesKey,
      defaultValue: manifestIds.isEmpty ? <String>[] : <String>[manifestIds[0]],
    );
    final List<String> selected = raw is List
        ? raw.map((Object? value) => value.toString()).toList(growable: false)
        : const <String>[];
    final List<String> filtered = selected
        .where((String id) => manifestIds.contains(id))
        .toList(growable: false);
    if (filtered.isNotEmpty || manifestIds.isEmpty) return filtered;
    return <String>[manifestIds[0]];
  }

  Future<void> saveSelectedTafsirResourceIds(List<String> resourceIds) async {
    final List<String> normalized = resourceIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    await SettingsDB().put(_selectedTafsirResourcesKey, normalized);
    _notifyChanged();
  }

  Future<void> _saveInstalledResources(
    Map<String, InstalledResource> installed,
  ) async {
    await SettingsDB().put(
      _installedResourcesKey,
      installed.map(
        (String key, InstalledResource resource) =>
            MapEntry<String, Object?>(key, resource.toJson()),
      ),
    );
    _notifyChanged();
  }

  void _notifyChanged() {
    changes.value = changes.value + 1;
  }

  static String metadataKey(String rawType, String id) {
    return '${rawType.trim().toLowerCase()}/${id.trim()}';
  }

  static String _safePathSegment(String value) {
    final String sanitized = value.trim().replaceAll(
      RegExp(r'[^A-Za-z0-9._-]+'),
      '_',
    );
    return sanitized.isEmpty ? 'resource' : sanitized;
  }
}
