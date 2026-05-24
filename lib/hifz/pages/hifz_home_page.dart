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

  HifzUnitType _selectedType = HifzUnitType.surah;
  int? _selectedNumber; // surah 1-114 or juz 1-30
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Derived from search
  List<int> get _filteredNumbers {
    final query = _searchQuery.toLowerCase().trim();
    if (_selectedType == HifzUnitType.surah) {
      return List.generate(114, (i) => i + 1).where((n) {
        if (query.isEmpty) return true;
        final name = HifzSurahData.name(n).toLowerCase();
        return name.contains(query) || n.toString() == query;
      }).toList();
    } else {
      return List.generate(30, (i) => i + 1).where((n) {
        if (query.isEmpty) return true;
        return 'juz $n'.contains(query) || n.toString() == query;
      }).toList();
    }
  }

  String _unitId(int n) =>
      _selectedType == HifzUnitType.surah ? 'surah_$n' : 'juz_$n';

  bool _hasContent(HifzUnit u) =>
      HifzDB.getNewAyahsForUnit(u.id, 1).isNotEmpty ||
      HifzDB.getSabqiAyahs(u.id).isNotEmpty ||
      HifzDB.getManzilAyahs(u.id).isNotEmpty;

  void _showSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HifzSettingsSheet(),
    );
  }

  Future<void> _startUnit() async {
    if (_selectedNumber == null) return;

    // Create unit in DB (idempotent)
    final unit = await HifzDB.createUnit(
      type: _selectedType,
      unitNumber: _selectedNumber!,
    );

    // Advance frontier to unlock first batch of new ayahs
    await HifzDB.advanceFrontier(unit, HifzLimits.maxNewPerDay);

    // Navigate directly to session
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HifzSessionPage(unit: unit)),
      );
    }

    // Reset picker state
    setState(() {
      _selectedNumber = null;
      _searchQuery = '';
      _searchController.clear();
    });
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

  Widget _buildSelectedPreview(EquranColors colors, ThemeData theme) {
    final n = _selectedNumber!;
    final isAlreadyActive = HifzDB.getUnit(_unitId(n)) != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlreadyActive
            ? colors.goldSoft
            : colors.mint.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(
          color: isAlreadyActive
              ? colors.accentGold.withOpacity(0.4)
              : colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAlreadyActive ? Icons.info_outline : Icons.check_circle_outline,
            color: isAlreadyActive ? colors.warning : colors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedType == HifzUnitType.surah
                      ? HifzSurahData.name(n)
                      : 'Juz $n',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isAlreadyActive
                      ? 'Already in progress'
                      : _selectedType == HifzUnitType.surah
                      ? '${HifzSurahData.ayahCount(n)} ayahs'
                      : '${HifzJuzData.ayahsInJuz(n).length} ayahs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            final activeUnitsCount = HifzDB.getActiveUnits().length;
            final inProgressCount = allEntries
                .where((e) => e.status != 'unseen')
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

            final activeUnits = HifzDB.getActiveUnits();

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
                                            '$activeUnitsCount',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            "Active units",
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
                                            '$inProgressCount',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: colors.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            "In progress",
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

                      // SECTION B - REMINDER CARD
                      if (activeUnits.any(_hasContent)) ...[
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Units ready for review",
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: colors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      l10n.hifzStartYourSession,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                onPressed: () {
                                  final unitWithDue = activeUnits.firstWhere(
                                    (u) => _hasContent(u),
                                    orElse: () => activeUnits.first,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HifzSessionPage(unit: unitWithDue),
                                    ),
                                  );
                                },
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
                        const SizedBox(height: 24),
                      ] else ...[
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
                        ),
                        const SizedBox(height: 24),
                      ],

                      // SECTION C - ACTIVE UNITS
                      _buildSectionLabel("Active Units"),
                      ValueListenableBuilder<Box<HifzUnit>>(
                        valueListenable: HifzDB.unitsListenable,
                        builder: (context, box, _) {
                          final activeUnitsList = HifzDB.getActiveUnits();

                          if (activeUnitsList.isEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                border: Border.all(
                                  color: colors.border,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.large,
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    color: colors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'No active units — add one below',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activeUnitsList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _UnitProgressCard(
                                unit: activeUnitsList[index],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // SECTION D - ADD A UNIT
                      _buildSectionLabel("Add a Unit"),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.border, width: 1),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // UNIT TYPE TOGGLE
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedType = HifzUnitType.surah;
                                      _selectedNumber = null;
                                      _searchQuery = '';
                                      _searchController.clear();
                                    }),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedType == HifzUnitType.surah
                                            ? colors.primary
                                            : colors.surfaceAlt,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(
                                            AppRadii.pill,
                                          ),
                                          bottomLeft: Radius.circular(
                                            AppRadii.pill,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Surah',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    _selectedType ==
                                                        HifzUnitType.surah
                                                    ? colors.onPrimary
                                                    : colors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedType = HifzUnitType.juz;
                                      _selectedNumber = null;
                                      _searchQuery = '';
                                      _searchController.clear();
                                    }),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _selectedType == HifzUnitType.juz
                                            ? colors.primary
                                            : colors.surfaceAlt,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(
                                            AppRadii.pill,
                                          ),
                                          bottomRight: Radius.circular(
                                            AppRadii.pill,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Juz',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    _selectedType ==
                                                        HifzUnitType.juz
                                                    ? colors.onPrimary
                                                    : colors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // SEARCH FIELD
                            TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: _selectedType == HifzUnitType.surah
                                    ? 'Search surahs...'
                                    : 'Search juz...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textMuted,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: colors.textMuted,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: colors.surfaceAlt,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadii.pill),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // UNIT PICKER GRID
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 5,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.0,
                              children: _filteredNumbers.map((n) {
                                final isSelected = _selectedNumber == n;
                                final alreadyActive =
                                    HifzDB.getUnit(_unitId(n)) != null;

                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedNumber = isSelected ? null : n;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.primary
                                          : alreadyActive
                                          ? colors.primary.withOpacity(0.15)
                                          : colors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.medium,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : alreadyActive
                                            ? colors.primary.withOpacity(0.4)
                                            : colors.border,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            n.toString(),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? colors.onPrimary
                                                      : colors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (_selectedType ==
                                                  HifzUnitType.surah &&
                                              !isSelected)
                                            Text(
                                              HifzSurahData.name(
                                                n,
                                              ).split(' ').first,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colors.textMuted,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            // SELECTED UNIT PREVIEW
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _selectedNumber == null
                                  ? const SizedBox.shrink()
                                  : _buildSelectedPreview(colors, theme),
                            ),
                            const SizedBox(height: 16),
                            // START BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: const StadiumBorder(),
                                  minimumSize: const Size.fromHeight(52),
                                ),
                                onPressed: _selectedNumber == null
                                    ? null
                                    : _startUnit,
                                child: Text(
                                  _selectedNumber == null
                                      ? 'Select a unit above'
                                      : 'Start memorizing ${_selectedType == HifzUnitType.surah ? HifzSurahData.name(_selectedNumber!) : 'Juz $_selectedNumber'}',
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

                      // SECTION E - SURAH PROGRESS GRID
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
                                    final unit = HifzDB.getUnit('surah_$surah');
                                    final total = HifzSurahData.ayahCount(
                                      surah,
                                    );

                                    Color cellBg;
                                    Color cellText;
                                    bool hasActiveDot = false;

                                    if (unit == null) {
                                      cellBg = colors.surfaceAlt;
                                      cellText = colors.textMuted;
                                    } else {
                                      final masteredCellCount =
                                          entriesBySurah[surah]
                                              ?.where(
                                                (e) => e.status == 'mastered',
                                              )
                                              .length ??
                                          0;

                                      if (masteredCellCount == total) {
                                        cellBg = colors.accentGold;
                                        cellText = const Color(0xFF1a1408);
                                      } else if (unit.introducedAyahs == 0) {
                                        cellBg = colors.primary.withOpacity(
                                          0.15,
                                        );
                                        cellText = colors.primary;
                                        hasActiveDot = !unit.isComplete;
                                      } else {
                                        cellBg = colors.primary.withOpacity(
                                          0.5,
                                        );
                                        cellText = colors.onPrimary;
                                        hasActiveDot = !unit.isComplete;
                                      }
                                    }

                                    final masteredCellCount =
                                        entriesBySurah[surah]
                                            ?.where(
                                              (e) => e.status == 'mastered',
                                            )
                                            .length ??
                                        0;

                                    final isArabic =
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar';
                                    final surahName = isArabic
                                        ? quran.getSurahNameArabic(surah)
                                        : HifzSurahData.name(surah);

                                    Widget cellChild = Center(
                                      child: Text(
                                        '$surah',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: cellText,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    );

                                    if (hasActiveDot) {
                                      cellChild = Stack(
                                        children: [
                                          cellChild,
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              width: 3,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: colors.accentGold,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

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
                                            final name = isArabic
                                                ? quran.getSurahNameArabic(
                                                    surah,
                                                  )
                                                : HifzSurahData.name(surah);
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
                                          child: cellChild,
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

class _UnitProgressCard extends StatelessWidget {
  final HifzUnit unit;
  const _UnitProgressCard({required this.unit});

  bool _hasSessionContent(HifzUnit unit) {
    return HifzDB.getNewAyahsForUnit(unit.id, 1).isNotEmpty ||
        HifzDB.getSabqiAyahs(unit.id).isNotEmpty ||
        HifzDB.getManzilAyahs(unit.id).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final theme = Theme.of(context);

    final newCount = HifzDB.getNewAyahsForUnit(unit.id, 999).length;
    final sabqiCount = HifzDB.getSabqiAyahs(unit.id).length;
    final manzilCount = HifzDB.getManzilAyahs(unit.id).length;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: title + session button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        unit.type == HifzUnitType.surah
                            ? Icons.menu_book_rounded
                            : Icons.format_list_numbered,
                        color: colors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        unit.type == HifzUnitType.surah ? 'Surah' : 'Juz',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onPressed: _hasSessionContent(unit)
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HifzSessionPage(unit: unit),
                        ),
                      )
                    : null,
                child: Text(
                  _hasSessionContent(unit) ? 'Review' : 'Up to date',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: frontier info
          Text(
            'Next: ${HifzSurahData.name(unit.frontierSurah)} · Ayah ${unit.frontierAyah}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // Row 3: progress bar + fraction
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: unit.progressFraction,
                    backgroundColor: colors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${unit.introducedAyahs}/${unit.totalAyahs}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: due counts
          Row(
            children: [
              if (newCount > 0) _DueChip('$newCount new', colors.primary),
              if (sabqiCount > 0)
                _DueChip('$sabqiCount revision', colors.accentGold),
              if (manzilCount > 0)
                _DueChip('$manzilCount maintenance', colors.textSecondary),
              if (newCount == 0 && sabqiCount == 0 && manzilCount == 0)
                _DueChip('All caught up', colors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DueChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
