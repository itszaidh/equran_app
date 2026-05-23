import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran/quran.dart' as quran;
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/home/quran_stats_page.dart'
    show IslamicPatternPainter, HeroCornerOrnamentsPainter;
import 'package:equran/l10n/app_localizations.dart';
import 'package:equran/backend/hifz_db.dart';
import '../hifz.dart';

class HifzHomePage extends StatefulWidget {
  const HifzHomePage({super.key});

  @override
  State<HifzHomePage> createState() => _HifzHomePageState();
}

class _HifzHomePageState extends State<HifzHomePage> {
  bool _gridExpanded = false;
  late final TextEditingController _surahController;
  int _selectedSurah = 1;
  int _startAyah = 1;
  int _endAyah = 7;

  @override
  void initState() {
    super.initState();
    _surahController = TextEditingController();
  }

  @override
  void dispose() {
    _surahController.dispose();
    super.dispose();
  }

  Future<void> _addRange() async {
    final colors = context.equranColors;
    final l10n = AppLocalizations.of(context)!;
    await HifzDB.addAyahRange(
      surah: _selectedSurah,
      startAyah: _startAyah,
      endAyah: _endAyah,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.hifzAyahsAdded(_endAyah - _startAyah + 1)),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _dueLabel(AppLocalizations l10n, DateTime dueDate) {
    final diff = DateTime.now().difference(dueDate);
    if (diff.isNegative) return l10n.hifzDueNow;
    return l10n.hifzOverdueDays(diff.inDays);
  }

  void _showSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HifzSettingsSheet(),
    );
  }

  void _showAllDueBottomSheet(List<HifzEntry> dueEntries) {
    final theme = Theme.of(context);
    final colors = context.equranColors;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    l10n.hifzDueForReview,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: dueEntries.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: colors.divider, height: 1),
                      itemBuilder: (context, index) {
                        final e = dueEntries[index];
                        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                        final surahName = isArabic ? quran.getSurahNameArabic(e.surah) : HifzSurahData.name(e.surah);
                        return Container(
                          color: colors.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.hifzStatsNextDueValue(surahName, e.ayah),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dueLabel(l10n, e.dueDate),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              _TrackBadge(track: e.track),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAddChip(
    String label, {
    int? surah,
    int? start,
    int? end,
    bool isLastTen = false,
    bool isJuzAmma = false,
  }) {
    final colors = context.equranColors;
    final theme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary.withAlpha(102)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () async {
        int count = 0;
        if (isLastTen) {
          for (int s = 105; s <= 114; s++) {
            final maxAyah = HifzSurahData.ayahCount(s);
            await HifzDB.addAyahRange(surah: s, startAyah: 1, endAyah: maxAyah);
            count += maxAyah;
          }
        } else if (isJuzAmma) {
          for (int s = 78; s <= 114; s++) {
            final maxAyah = HifzSurahData.ayahCount(s);
            await HifzDB.addAyahRange(surah: s, startAyah: 1, endAyah: maxAyah);
            count += maxAyah;
          }
        } else if (surah != null && start != null && end != null) {
          await HifzDB.addAyahRange(
            surah: surah,
            startAyah: start,
            endAyah: end,
          );
          count = end - start + 1;
        }
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.hifzAyahsAdded(count)),
              backgroundColor: colors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAyahPicker({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = context.equranColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: colors.primary,
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: colors.primary,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    final theme = Theme.of(context);
    final colors = context.equranColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.equranColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.hifzTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: colors.textSecondary,
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Box<HifzEntry>>(
          valueListenable: HifzDB.entriesListenable,
          builder: (context, box, _) {
            final allEntries = box.values.toList();

            // Computations for Hero summary
            final masteredCount = allEntries
                .where((e) => e.status == 'mastered')
                .length;
            final dueEntries = HifzDB.getDueEntries();
            final inReviewCount = allEntries
                .where((e) => e.status == 'review')
                .length;
            final progressFraction = masteredCount / HifzSurahData.totalAyahs;

            // Map entries by surah for progress grid performance
            final Map<int, List<HifzEntry>> entriesBySurah = {};
            for (final entry in allEntries) {
              entriesBySurah.putIfAbsent(entry.surah, () => []).add(entry);
            }

            int masteredSurahCount = 0;
            for (int surah = 1; surah <= 114; surah++) {
              final entries = entriesBySurah[surah] ?? [];
              final total = HifzSurahData.ayahCount(surah);
              if (entries.isNotEmpty &&
                  entries.where((e) => e.status == 'mastered').length ==
                      total) {
                masteredSurahCount++;
              }
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // SECTION A - HERO SUMMARY CARD
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primaryGradientStart,
                              colors.primaryGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              width: 160,
                              height: 160,
                              child: CustomPaint(
                                painter: IslamicPatternPainter(
                                  color: colors.onPrimary,
                                  opacity: 0.06,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: HeroCornerOrnamentsPainter(
                                  color: colors.accentGold.withAlpha(128),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        l10n.hifzJourneyTitle,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color: colors.onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: colors.mint.withAlpha(38),
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.pill,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          l10n.hifzNewTodayLabel(
                                            HifzLimits.todayNewCount,
                                            HifzLimits.maxNewPerDay,
                                          ),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: colors.onPrimaryMuted,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '$masteredCount',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            l10n.hifzMemorized,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colors.onPrimaryMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${dueEntries.length}',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            l10n.hifzDueToday,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colors.onPrimaryMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '$inReviewCount',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            l10n.hifzInReview,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colors.onPrimaryMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        l10n.hifzAyahsMemorized(masteredCount),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.onPrimaryMuted,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${(progressFraction * 100).toStringAsFixed(1)}%',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colors.accentGold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                    child: LinearProgressIndicator(
                                      value: progressFraction,
                                      backgroundColor: colors.onPrimary
                                          .withAlpha(51),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.onPrimary,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION B - DUE TODAY
                      _buildSectionLabel(l10n.hifzDueForReview),
                      if (dueEntries.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.large),
                            border: Border.all(color: colors.border),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.hifzAllCaughtUp,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.large),
                            border: Border.all(
                              color: colors.primary.withAlpha(51),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: colors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.hifzAyahsReady(dueEntries.length),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    l10n.hifzStartYourSession,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HifzSessionPage(entries: dueEntries),
                                  ),
                                ),
                                child: Text(
                                  l10n.hifzStart,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: math.min(5, dueEntries.length),
                          separatorBuilder: (context, index) =>
                              Divider(color: colors.divider, height: 1),
                          itemBuilder: (context, index) {
                            final e = dueEntries[index];
                            final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                            final surahName = isArabic ? quran.getSurahNameArabic(e.surah) : HifzSurahData.name(e.surah);
                            return Container(
                              color: colors.surface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.hifzStatsNextDueValue(surahName, e.ayah),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colors.textPrimary,
                                            ),
                                      ),
                                      Text(
                                        _dueLabel(l10n, e.dueDate),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(color: colors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _TrackBadge(track: e.track),
                                ],
                              ),
                            );
                          },
                        ),
                        if (dueEntries.length > 5) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showAllDueBottomSheet(dueEntries),
                            child: Text(
                              l10n.hifzShowAll(dueEntries.length),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),

                      // SECTION C - ADD NEW AYAHS
                      _buildSectionLabel(l10n.hifzAddToMemorize),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          border: Border.all(color: colors.border),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.hifzQuickAdd,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildQuickAddChip(
                                  l10n.hifzQuickAlFatiha,
                                  surah: 1,
                                  start: 1,
                                  end: 7,
                                ),
                                _buildQuickAddChip(
                                  l10n.hifzQuickAlKahf,
                                  surah: 18,
                                  start: 1,
                                  end: 110,
                                ),
                                _buildQuickAddChip(
                                  l10n.hifzQuickJuzAmma,
                                  isJuzAmma: true,
                                ),
                                _buildQuickAddChip(
                                  l10n.hifzQuickLast10,
                                  isLastTen: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: colors.divider),
                            const SizedBox(height: 12),
                            Text(
                              l10n.hifzOrChooseSurah,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.medium,
                                  ),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.medium,
                                  ),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.medium,
                                  ),
                                  borderSide: BorderSide(color: colors.primary),
                                ),
                              ),
                              initialValue: _selectedSurah,
                              dropdownColor: colors.surface,
                              iconEnabledColor: colors.primary,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                              ),
                              items: List.generate(114, (index) {
                                final surahNum = index + 1;
                                final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                                final name = isArabic ? quran.getSurahNameArabic(surahNum) : HifzSurahData.name(surahNum);
                                final count = HifzSurahData.ayahCount(surahNum);
                                return DropdownMenuItem<int>(
                                  value: surahNum,
                                  child: Text(
                                    '$surahNum. $name (${l10n.hifzTotalReviewedValue(count)})',
                                  ),
                                );
                              }),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selectedSurah = v;
                                  _startAyah = 1;
                                  _endAyah = HifzSurahData.ayahCount(v);
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAyahPicker(
                                    label: l10n.hifzFromAyah,
                                    value: _startAyah,
                                    min: 1,
                                    max: _endAyah,
                                    onChanged: (v) =>
                                        setState(() => _startAyah = v),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildAyahPicker(
                                    label: l10n.hifzToAyah,
                                    value: _endAyah,
                                    min: _startAyah,
                                    max: HifzSurahData.ayahCount(
                                      _selectedSurah,
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _endAyah = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: _addRange,
                                child: Text(
                                  l10n.hifzAddAyahsButton(
                                    _endAyah - _startAyah + 1,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION D - SURAH PROGRESS GRID
                      _buildSectionLabel(l10n.hifzSurahProgress),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          child: SizedBox(
                            height: _gridExpanded ? null : 160.0,
                            child: Stack(
                              children: [
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 10,
                                  childAspectRatio: 1.0,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  children: List.generate(114, (index) {
                                    final surah = index + 1;
                                    final entries = entriesBySurah[surah] ?? [];
                                    final total = HifzSurahData.ayahCount(
                                      surah,
                                    );
                                    final masteredCellCount = entries
                                        .where((e) => e.status == 'mastered')
                                        .length;

                                    Color cellBg;
                                    Color cellText;

                                    if (entries.isEmpty) {
                                      cellBg = colors.surfaceAlt;
                                      cellText = colors.textMuted;
                                    } else if (masteredCellCount == total) {
                                      cellBg = colors.accentGold;
                                      cellText = const Color(0xFF1a1408);
                                    } else if (masteredCellCount > 0) {
                                      cellBg = colors.primary.withAlpha(140);
                                      cellText = colors.onPrimary;
                                    } else {
                                      cellBg = colors.primary.withAlpha(64);
                                      cellText = colors.primary;
                                    }

                                    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                                    final surahName = isArabic ? quran.getSurahNameArabic(surah) : HifzSurahData.name(surah);

                                    return Tooltip(
                                      message:
                                          '$surahName: ${l10n.hifzSessionProgress(masteredCellCount, total)}',
                                      child: Material(
                                        color: cellBg,
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.small,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.small,
                                          ),
                                          onTap: () {
                                            final name = isArabic ? quran.getSurahNameArabic(surah) : HifzSurahData.name(surah);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).clearSnackBars();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '$name: ${l10n.hifzSessionProgress(masteredCellCount, total)}',
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Center(
                                            child: Text(
                                              '$surah',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: cellText,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                if (!_gridExpanded)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 60,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            colors.background.withValues(
                                              alpha: 0.0,
                                            ),
                                            colors.background,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.surfaceAlt,
                            foregroundColor: colors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _gridExpanded = !_gridExpanded;
                            });
                          },
                          child: Text(
                            _gridExpanded
                                ? l10n.hifzShowLess
                                : l10n.hifzShowAllSurahs,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          l10n.hifzSurahsMastered(masteredSurahCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HifzSettingsSheet extends StatefulWidget {
  const _HifzSettingsSheet();

  @override
  State<_HifzSettingsSheet> createState() => _HifzSettingsSheetState();
}

class _HifzSettingsSheetState extends State<_HifzSettingsSheet> {
  late int _maxNewPerDay;
  late int _maxReviewPerDay;
  late bool _showTransliteration;
  late bool _showTranslation;
  late bool _autoPlayAudio;
  late String _blankingLevel;

  @override
  void initState() {
    super.initState();
    _maxNewPerDay = HifzPrefs.maxNewPerDay();
    _maxReviewPerDay = HifzPrefs.maxReviewPerDay();
    _showTransliteration = HifzPrefs.showTransliterationByDefault();
    _showTranslation = HifzPrefs.showTranslationByDefault();
    _autoPlayAudio = HifzPrefs.autoPlayAudioOnLearn();
    _blankingLevel = HifzPrefs.blankingLevel();
  }

  Future<void> _saveSettings() async {
    await HifzPrefs.setMaxNewPerDay(_maxNewPerDay);
    await HifzPrefs.setMaxReviewPerDay(_maxReviewPerDay);
    await HifzPrefs.setShowTransliterationByDefault(_showTransliteration);
    await HifzPrefs.setShowTranslationByDefault(_showTranslation);
    await HifzPrefs.setAutoPlayAudioOnLearn(_autoPlayAudio);
    await HifzPrefs.setBlankingLevel(_blankingLevel);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hifzSettingsTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: colors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // New ayahs slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hifzSettingsNewPerDay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_maxNewPerDay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _maxNewPerDay.toDouble(),
                min: 1.0,
                max: 50.0,
                divisions: 49,
                activeColor: colors.primary,
                inactiveColor: colors.primary.withAlpha(50),
                onChanged: (val) {
                  setState(() {
                    _maxNewPerDay = val.round();
                  });
                },
              ),
              const SizedBox(height: 12),
              // Reviews per day slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hifzSettingsReviewsPerDay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_maxReviewPerDay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _maxReviewPerDay.toDouble(),
                min: 5.0,
                max: 200.0,
                divisions: 195,
                activeColor: colors.primary,
                inactiveColor: colors.primary.withAlpha(50),
                onChanged: (val) {
                  setState(() {
                    _maxReviewPerDay = val.round();
                  });
                },
              ),
              const SizedBox(height: 16),
              // Toggles
              SwitchListTile(
                title: Text(
                  l10n.hifzSettingsShowTranslit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _showTransliteration,
                activeThumbColor: colors.primary,
                activeTrackColor: colors.primary.withAlpha(128),
                onChanged: (val) {
                  setState(() {
                    _showTransliteration = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(
                  l10n.hifzSettingsShowTranslation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _showTranslation,
                activeThumbColor: colors.primary,
                activeTrackColor: colors.primary.withAlpha(128),
                onChanged: (val) {
                  setState(() {
                    _showTranslation = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(
                  l10n.hifzSettingsAutoPlayAudio,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _autoPlayAudio,
                activeThumbColor: colors.primary,
                activeTrackColor: colors.primary.withAlpha(128),
                onChanged: (val) {
                  setState(() {
                    _autoPlayAudio = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Blanking level
              Text(
                l10n.hifzSettingsBlankingLevel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _blankingChip(l10n.hifzSettingsBlankingAuto, 'auto'),
                  const SizedBox(width: 8),
                  _blankingChip(l10n.hifzSettingsBlankingEasy, 'easy'),
                  const SizedBox(width: 8),
                  _blankingChip(l10n.hifzSettingsBlankingMedium, 'medium'),
                  const SizedBox(width: 8),
                  _blankingChip(l10n.hifzSettingsBlankingHard, 'hard'),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await _saveSettings();
                  navigator.pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  l10n.hifzSettingsDone,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blankingChip(String label, String value) {
    final colors = context.equranColors;
    final theme = Theme.of(context);
    final isSelected = _blankingLevel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _blankingLevel = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected ? colors.onPrimary : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackBadge extends StatelessWidget {
  final String track;
  const _TrackBadge({required this.track});

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color bgColor;
    Color textColor;
    String label;

    if (track == 'sabaq') {
      bgColor = colors.primary.withAlpha(38);
      textColor = colors.primary;
      label = l10n.hifzTrackNew;
    } else if (track == 'sabqi') {
      bgColor = colors.accentGold.withAlpha(38);
      textColor = colors.accentGold;
      label = l10n.hifzTrackRevision;
    } else {
      bgColor = colors.surfaceAlt;
      textColor = colors.textMuted;
      label = l10n.hifzTrackMaintenance;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
