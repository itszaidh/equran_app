import 'package:equran/backend/library.dart'
    show AudioDownloadEntry, AudioDownloadService, AudioDownloadsSummary;
import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';

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
    _summaryFuture = AudioDownloadService().summary();
  }

  void _refresh() {
    setState(() {
      _summaryFuture = AudioDownloadService().summary();
    });
  }

  Future<void> _deleteEntry(AudioDownloadEntry entry) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Delete Download?'),
        content: Text('Remove ${entry.title} from offline storage?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AudioDownloadService().deleteEntry(entry);
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted ${entry.title}')));
    }
  }

  Future<void> _clearAll(AudioDownloadsSummary summary) async {
    if (summary.allDownloads.isEmpty) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Delete All Downloads?'),
        content: Text(
          'This will remove ${summary.allDownloads.length} downloaded audio files (${AudioDownloadService.formatBytes(summary.totalSizeBytes)}).',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AudioDownloadService().clearAll();
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted all downloaded audio.')),
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
              _buildSection(
                title: 'Downloaded Surahs',
                emptyText: 'No downloaded surahs yet.',
                entries: summary.surahDownloads,
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Downloaded Ayahs',
                emptyText: 'No downloaded ayahs yet.',
                entries: summary.ayahDownloads,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ThemeData theme, AudioDownloadsSummary summary) {
    final ColorScheme colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Offline Audio',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.surahDownloads.length} surahs • ${summary.ayahDownloads.length} ayahs',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AudioDownloadService.formatBytes(summary.totalSizeBytes),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: summary.allDownloads.isEmpty
                    ? null
                    : () => _clearAll(summary),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Clear All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String emptyText,
    required List<AudioDownloadEntry> entries,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Text(
                '${entries.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Divider(height: 1),
            if (entries.isEmpty)
              ListTile(
                leading: const Icon(Icons.download_done_outlined),
                title: Text(emptyText),
              )
            else
              ...entries.map(_buildDownloadTile),
          ],
        ),
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
        tooltip: 'Delete download',
        onPressed: () => _deleteEntry(entry),
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }
}
