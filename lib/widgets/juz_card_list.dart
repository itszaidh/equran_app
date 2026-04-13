import 'package:equran/utils/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quran/quran.dart' as quran;

import 'juz_card.dart';
import 'section_card.dart';

class JuzCardList extends StatefulWidget {
  const JuzCardList({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  _JuzCardListState createState() => _JuzCardListState();
}

class _JuzCardListState extends State<JuzCardList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _fallbackScrollController = ScrollController();
  final Map<int, GlobalKey> _sectionKeys = <int, GlobalKey>{};
  final Map<int, double> _sectionOffsets = <int, double>{};

  int? _activeJuzNumber;
  bool _scheduledOffsetUpdate = false;

  ScrollController? _attachedScrollController;

  @override
  void initState() {
    super.initState();
    _fallbackScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _detachScrollController();
    _fallbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ScrollController scrollController =
        PrimaryScrollController.maybeOf(context) ?? _fallbackScrollController;
    _attachScrollController(scrollController);
    final List<_JuzGroup> juzGroups = _buildJuzGroups(widget.searchQuery);

    if (juzGroups.isEmpty) {
      return const Center(child: Text('No juz results found.'));
    }

    _syncSectionKeys(juzGroups);
    _scheduleOffsetUpdate();

    return Stack(
      children: <Widget>[
        Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          interactive: true,
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 20),
            itemCount: juzGroups.length,
            itemBuilder: (BuildContext context, int index) {
              final _JuzGroup group = juzGroups[index];
              final List<QuranJuzTile> juzCards = group.entries
                  .map(
                    (_JuzEntry entry) => QuranJuzTile(
                      id: entry.surahId,
                      transliteration: entry.transliteration,
                      name: entry.name,
                      startVerse: entry.startVerse,
                      endVerse: entry.endVerse,
                    ),
                  )
                  .toList();

              return KeyedSubtree(
                key: _sectionKeys[group.juzNumber],
                child: SectionCard(
                  header: _JuzSectionHeader(
                    juzNumber: group.juzNumber,
                    surahCount: group.entries.length,
                  ),
                  children: juzCards,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          bottom: 12,
          right: 2,
          child: _JuzGuideRail(
            groups: juzGroups,
            offsets: _sectionOffsets,
            maxScrollExtent:
                scrollController.hasClients ? scrollController.position.maxScrollExtent : null,
            activeJuzNumber: _activeJuzNumber,
            onSelectJuz: _scrollToJuz,
          ),
        ),
      ],
    );
  }

  void _attachScrollController(ScrollController controller) {
    if (identical(_attachedScrollController, controller)) return;
    _detachScrollController();
    _attachedScrollController = controller;
    if (!identical(controller, _fallbackScrollController)) {
      controller.addListener(_handleScroll);
    }
  }

  void _detachScrollController() {
    if (_attachedScrollController != null &&
        !identical(_attachedScrollController, _fallbackScrollController)) {
      _attachedScrollController!.removeListener(_handleScroll);
    }
    _attachedScrollController = null;
  }

  void _handleScroll() {
    _updateActiveJuz();
  }

  void _syncSectionKeys(List<_JuzGroup> groups) {
    final Set<int> groupNumbers =
        groups.map((group) => group.juzNumber).toSet();
    _sectionKeys.removeWhere((int juzNumber, GlobalKey _) {
      return !groupNumbers.contains(juzNumber);
    });
    _sectionOffsets.removeWhere((int juzNumber, double _) {
      return !groupNumbers.contains(juzNumber);
    });

    for (final _JuzGroup group in groups) {
      _sectionKeys.putIfAbsent(group.juzNumber, GlobalKey.new);
    }
  }

  void _scheduleOffsetUpdate() {
    if (_scheduledOffsetUpdate) return;
    _scheduledOffsetUpdate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledOffsetUpdate = false;
      _updateSectionOffsets();
    });
  }

  void _updateSectionOffsets() {
    final ScrollController? controller = _attachedScrollController;
    if (controller == null || !controller.hasClients || !mounted) return;

    final Map<int, double> nextOffsets = <int, double>{};
    for (final MapEntry<int, GlobalKey> entry in _sectionKeys.entries) {
      final BuildContext? sectionContext = entry.value.currentContext;
      if (sectionContext == null) continue;

      final RenderObject? renderObject = sectionContext.findRenderObject();
      if (renderObject == null) continue;

      final RenderAbstractViewport? viewport =
          RenderAbstractViewport.of(renderObject);
      if (viewport == null) continue;

      nextOffsets[entry.key] = viewport.getOffsetToReveal(renderObject, 0).offset;
    }

    if (!mounted || nextOffsets.isEmpty) return;
    setState(() {
      _sectionOffsets
        ..clear()
        ..addAll(nextOffsets);
    });
    _updateActiveJuz();
  }

  void _updateActiveJuz() {
    final ScrollController? controller = _attachedScrollController;
    if (controller == null || !controller.hasClients || _sectionOffsets.isEmpty) {
      return;
    }

    final double currentOffset = controller.offset;
    int? nextActive;
    double bestDistance = double.infinity;

    for (final MapEntry<int, double> entry in _sectionOffsets.entries) {
      final double distance = (entry.value - currentOffset).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        nextActive = entry.key;
      }
    }

    if (nextActive != _activeJuzNumber && mounted) {
      setState(() {
        _activeJuzNumber = nextActive;
      });
    }
  }

  Future<void> _scrollToJuz(int juzNumber) async {
    final BuildContext? sectionContext = _sectionKeys[juzNumber]?.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  List<_JuzGroup> _buildJuzGroups(String searchQuery) {
    final String query = searchQuery.trim().toLowerCase();
    final List<_JuzGroup> groups = <_JuzGroup>[];

    for (int juzNumber = 1; juzNumber <= 30; juzNumber++) {
      final Map<int, List<int>> juz = quran.getSurahAndVersesFromJuz(juzNumber);
      final List<_JuzEntry> entries = <_JuzEntry>[];

      juz.forEach((surahId, verses) {
        final _JuzEntry entry = _JuzEntry(
          surahId: surahId,
          transliteration: quran.getSurahName(surahId),
          name: quran.getSurahNameArabic(surahId),
          startVerse: verses[0],
          endVerse: verses[1],
        );

        if (query.isEmpty || entry.matches(query, juzNumber)) {
          entries.add(entry);
        }
      });

      if (entries.isNotEmpty) {
        groups.add(_JuzGroup(juzNumber: juzNumber, entries: entries));
      }
    }

    return groups;
  }

  @override
  bool get wantKeepAlive => true;
}

class _JuzSectionHeader extends StatelessWidget {
  const _JuzSectionHeader({
    required this.juzNumber,
    required this.surahCount,
  });

  final int juzNumber;
  final int surahCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            "Juz' $juzNumber",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '$surahCount surahs',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _JuzGuideRail extends StatelessWidget {
  const _JuzGuideRail({
    required this.groups,
    required this.offsets,
    required this.maxScrollExtent,
    required this.activeJuzNumber,
    required this.onSelectJuz,
  });

  final List<_JuzGroup> groups;
  final Map<int, double> offsets;
  final double? maxScrollExtent;
  final int? activeJuzNumber;
  final ValueChanged<int> onSelectJuz;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double effectiveMaxScrollExtent = (maxScrollExtent == null ||
            maxScrollExtent! <= 0)
        ? 1
        : maxScrollExtent!;

    return SizedBox(
      width: 12,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: groups.map((group) {
              final double offset = offsets[group.juzNumber] ?? 0;
              final double topFraction = (offset / effectiveMaxScrollExtent)
                  .clamp(0.0, 1.0);
              final double top = topFraction * (constraints.maxHeight - 8);
              final bool isActive = activeJuzNumber == group.juzNumber;

              return Positioned(
                top: top,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelectJuz(group.juzNumber),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: isActive ? 10 : 6,
                        height: isActive ? 4 : 2,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(AppRadii.small),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _JuzGroup {
  const _JuzGroup({
    required this.juzNumber,
    required this.entries,
  });

  final int juzNumber;
  final List<_JuzEntry> entries;
}

class _JuzEntry {
  const _JuzEntry({
    required this.surahId,
    required this.transliteration,
    required this.name,
    required this.startVerse,
    required this.endVerse,
  });

  final int surahId;
  final String transliteration;
  final String name;
  final int startVerse;
  final int endVerse;

  bool matches(String query, int juzNumber) {
    return juzNumber.toString() == query;
  }
}
