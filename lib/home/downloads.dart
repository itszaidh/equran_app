import 'package:equran/backend/library.dart'
    show
        AudioDownloadEntry,
        AudioDownloadService,
        AudioDownloadsSummary,
        DownloadMetadataService;
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/downloads_grouping.dart';
import 'package:equran/utils/quran_display.dart';
import 'package:flutter/material.dart';
import 'package:equran/l10n/app_localizations.dart';

class _SurahAyahDownloadsGroup {
  const _SurahAyahDownloadsGroup({required this.surah, required this.entries});

  final int surah;
  final List<AudioDownloadEntry> entries;

  int get ayahCount =>
      entries.fold<int>(0, (total, entry) => total + entry.ayahCount);

  int get sizeBytes =>
      entries.fold<int>(0, (total, entry) => total + entry.sizeBytes);
}

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  late Future<AudioDownloadsSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  void _refresh() {
    setState(() {
      _summaryFuture = _loadSummary();
    });
  }

  Future<AudioDownloadsSummary> _loadSummary() async {
    final AudioDownloadsSummary summary = await AudioDownloadService()
        .summary();
    await const DownloadMetadataService().syncFromSummary(summary);
    return summary;
  }

  Future<void> _deleteEntry(AudioDownloadEntry entry) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(AppLocalizations.of(context)!.deleteDownloadQuestion),
        content: Text(
          AppLocalizations.of(context)!.removeDownloadFromOffline(entry.title),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AudioDownloadService().deleteEntry(entry);
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.deletedDownload(entry.title),
          ),
        ),
      );
    }
  }

  Future<void> _clearAll(AudioDownloadsSummary summary) async {
    if (summary.allDownloads.isEmpty) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(AppLocalizations.of(context)!.deleteAllDownloadsQuestion),
        content: Text(
          AppLocalizations.of(context)!.deleteAllDownloadsBody(
            summary.allDownloads.length,
            AudioDownloadService.formatBytes(summary.totalSizeBytes),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.deleteAll),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AudioDownloadService().clearAll();
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.deletedAllDownloadedAudio,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder<AudioDownloadsSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final AudioDownloadsSummary summary = snapshot.data!;
        final List<ReciterDownloadsGroup> reciterGroups =
            groupDownloadsByReciter(summary);
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              _buildSummaryCard(theme, summary),
              const SizedBox(height: 16),
              _buildCleanupPreviewCard(theme, summary),
              const SizedBox(height: 16),
              if (reciterGroups.isEmpty)
                _buildEmptyDownloadsCard()
              else
                ...reciterGroups.expand(
                  (group) => <Widget>[
                    _buildReciterSection(group),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ThemeData theme, AudioDownloadsSummary summary) {
    final EquranColors colors = context.equranColors;
    final localizations = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadii.large),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.primaryStrong.withAlpha(42),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.offlineAudio,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.surahAyahSummary(
                summary.surahCount,
                summary.ayahCount,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onPrimaryMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AudioDownloadService.formatBytes(summary.totalSizeBytes),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: summary.allDownloads.isEmpty
                    ? null
                    : () => _clearAll(summary),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.onPrimary,
                  foregroundColor: colors.primary,
                ),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: Text(localizations.clearAll),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupPreviewCard(
    ThemeData theme,
    AudioDownloadsSummary summary,
  ) {
    final EquranColors colors = context.equranColors;
    final bool hasDownloads = summary.allDownloads.isNotEmpty;
    final localizations = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.cleaning_services_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.cleanupPreview,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _CleanupPreviewRow(
              label: localizations.downloadedSurahs,
              value: '${summary.surahCount}',
            ),
            _CleanupPreviewRow(
              label: localizations.downloadedAyahs,
              value: '${summary.ayahCount}',
            ),
            _CleanupPreviewRow(
              label: localizations.potentialSpaceToFree,
              value: AudioDownloadService.formatBytes(summary.totalSizeBytes),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.cleanupDoesNotRemoveData,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                onPressed: hasDownloads ? () => _clearAll(summary) : null,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(localizations.reviewDeletion),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDownloadsCard() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.download_done_outlined),
              title: Text(localizations.noDownloadedAudioYet),
              subtitle: Text(
                localizations.downloadedAudioEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildReciterSection(ReciterDownloadsGroup group) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final List<AudioDownloadEntry> surahs = group.surahs;
    final List<_SurahAyahDownloadsGroup> ayahSurahs = _groupAyahsBySurah(
      group.ayahs,
    );
    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.record_voice_over_rounded),
              title: Text(
                reciterDisplayName(group.reciterCode),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${localizations.surahAyahSummary(surahs.length, group.ayahCount)} • ${AudioDownloadService.formatBytes(group.sizeBytes)}',
              ),
            ),
            const Divider(height: 1),
            if (surahs.isNotEmpty)
              _buildGroupHeader(localizations.surahs, surahs.length),
            ...surahs.map(_buildDownloadTile),
            if (surahs.isNotEmpty && ayahSurahs.isNotEmpty)
              const Divider(height: 1),
            if (ayahSurahs.isNotEmpty)
              _buildGroupHeader(localizations.ayahs, group.ayahCount),
            ...ayahSurahs.map(_buildAyahSurahTile),
          ],
        ),
    );
  }

  List<_SurahAyahDownloadsGroup> _groupAyahsBySurah(
    List<AudioDownloadEntry> ayahs,
  ) {
    final Map<int, List<AudioDownloadEntry>> grouped =
        <int, List<AudioDownloadEntry>>{};
    for (final AudioDownloadEntry entry in ayahs) {
      grouped.putIfAbsent(entry.surah, () => <AudioDownloadEntry>[]).add(entry);
    }

    final List<_SurahAyahDownloadsGroup> groups = grouped.entries
        .map(
          (entry) =>
              _SurahAyahDownloadsGroup(surah: entry.key, entries: entry.value),
        )
        .toList();
    groups.sort((a, b) => a.surah.compareTo(b.surah));
    return groups;
  }

  Widget _buildAyahSurahTile(_SurahAyahDownloadsGroup group) {
    final localizations = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      collapsedShape: const Border(),
      shape: const Border(),
      title: Text(localizedSurahName(localizations, group.surah)),
      subtitle: Text(
        '${localizations.ayahs}: ${group.ayahCount} • ${AudioDownloadService.formatBytes(group.sizeBytes)}',
      ),
      childrenPadding: const EdgeInsetsDirectional.fromSTEB(44, 0, 8, 8),
      children: group.entries
          .map((entry) => _buildNestedDownloadTile(entry))
          .toList(growable: false),
    );
  }

  Widget _buildGroupHeader(String title, int count) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(AudioDownloadEntry entry) {
    return ListTile(
      leading: const Icon(Icons.offline_pin_rounded),
      title: Text(entry.title),
      subtitle: Text(
        '${entry.subtitle} • ${AudioDownloadService.formatBytes(entry.sizeBytes)}',
      ),
      trailing: IconButton(
        tooltip: AppLocalizations.of(context)!.deleteDownload,
        onPressed: () => _deleteEntry(entry),
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }

  Widget _buildNestedDownloadTile(AudioDownloadEntry entry) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 0),
      title: Text(entry.title),
      subtitle: Text(
        '${entry.subtitle} • ${AudioDownloadService.formatBytes(entry.sizeBytes)}',
      ),
      trailing: IconButton(
        tooltip: AppLocalizations.of(context)!.deleteDownload,
        onPressed: () => _deleteEntry(entry),
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }
}

class _CleanupPreviewRow extends StatelessWidget {
  const _CleanupPreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
