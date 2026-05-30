import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;
import 'package:equran/utils/quran_text.dart';

import '../models/hifz_entry.dart';
import '../models/hifz_unit.dart';
import '../hifz_limits.dart';
import '../hifz_surah_data.dart';
import '../hifz_scheduler.dart';
import '../hifz_db.dart';
import 'hifz_complete_screen.dart';
import '../hifz_frontier_service.dart';

import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/backend/settings_db.dart';
import 'package:equran/backend/hifz_db.dart';
import 'package:equran/backend/transliteration_service.dart';
import 'package:equran/backend/quran_stream_url.dart';
import 'package:equran/backend/audio_downloads.dart';
import 'package:equran/l10n/app_localizations.dart';

enum _Phase { listen, recall, rating }

enum _Track { newAyah, sabqi, manzil }

class _SessionCard {
  final HifzEntry entry;
  final _Track track;

  const _SessionCard({required this.entry, required this.track});

  _Phase get startPhase =>
      track == _Track.newAyah ? _Phase.listen : _Phase.recall;
}

class HifzSessionPage extends StatefulWidget {
  final HifzUnit? unit;
  final List<HifzEntry>? entries;

  const HifzSessionPage({this.unit, this.entries, super.key});

  @override
  State<HifzSessionPage> createState() => _HifzSessionPageState();
}

class _HifzSessionPageState extends State<HifzSessionPage>
    with TickerProviderStateMixin {
  HifzUnit get _unit => widget.unit ?? _fallbackUnit!;
  HifzUnit? _fallbackUnit;

  // Session queue — three tracks combined
  List<_SessionCard> _queue = [];
  int _currentIndex = 0;

  // Current card phase
  _Phase _phase = _Phase.listen;

  // Blanking state
  List<String> _words = [];
  Set<int> _blankedIndices = {};
  bool _allRevealed = false;

  // Ayah text
  String _arabicText = '';
  String _prevAyahEnd = '';

  bool _loadingAyah = true;
  bool _audioEnabled = true;

  // Preferences & translation
  bool _showTransliteration = false;
  bool _showTranslation = false;
  String _currentTransliteration = '';
  String _currentTranslation = '';

  // Session stats
  final Map<String, int> _ratingCounts = {
    'again': 0,
    'gotIt': 0,
    'fail': 0,
    'pass': 0,
  };
  int _newGraduated = 0;
  final DateTime _sessionStart = DateTime.now();

  // Animation controllers
  late AnimationController _cardSlideController;
  late Animation<Offset> _cardSlideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Audio players & subscriptions
  AudioPlayer? _audioPlayer;
  bool _audioPlaying = false;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completeSubscription;

  // Precomputed projected intervals for ratings
  Map<String, int> _projectedIntervals = {};
  final Map<String, int> _lapseThisSession = {};

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    if (widget.unit == null && widget.entries != null) {
      assert(
        false,
        'HifzSessionPage: entries parameter is not supported. '
        'Use unit instead. See Phase 3 for caller fixes.',
      );
    }

    // Ensure frontier has content ready
    try {
      final unit = widget.unit ?? _fallbackUnit;
      if (unit != null) {
        await HifzFrontierService.ensureFrontierReady(unit);
      }
    } catch (_) {}

    // Now build the queue with fresh data
    _buildQueue();
    _initAnimations();

    if (_queue.isEmpty) {
      // Still empty — show empty state
      setState(() => _loadingAyah = false);
      return;
    }

    await _loadAyahData(_queue[0]);
  }

  void _buildQueue() {
    final unitId = _unit.id;

    // Track 1 — New ayahs
    final newEntries = HifzDB.getNewAyahsForUnit(
      unitId,
      HifzLimits.maxNewPerDay - HifzLimits.todayNewCount,
    ).map((e) => _SessionCard(entry: e, track: _Track.newAyah)).toList();

    // Track 2 — Sabqi (recent revision)
    final sabqiEntries = HifzDB.getSabqiAyahs(
      unitId,
    ).map((e) => _SessionCard(entry: e, track: _Track.sabqi)).toList();

    // Track 3 — Manzil (older SM-2 due)
    final manzilEntries = HifzDB.getManzilAyahs(unitId)
        .take(HifzLimits.maxReviewPerDay - HifzLimits.todayReviewCount)
        .map((e) => _SessionCard(entry: e, track: _Track.manzil))
        .toList();

    // Combine in order — never shuffle
    _queue = [...sabqiEntries, ...manzilEntries, ...newEntries];
  }

  void _initAnimations() {
    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _cardSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.2, 0)).animate(
          CurvedAnimation(
            parent: _cardSlideController,
            curve: Curves.easeInOut,
          ),
        );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Audio setup
    _audioPlayer = AudioPlayer();
    _stateSubscription = _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlaying = state == PlayerState.playing;
        });
      }
    });
    _completeSubscription = _audioPlayer!.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _audioPlaying = false;
        });
      }
    });
  }

  void _precomputeIntervals() {
    if (_queue.isEmpty || _currentIndex >= _queue.length) return;
    setState(() {
      _projectedIntervals = HifzScheduler.previewIntervals(
        _queue[_currentIndex].entry,
      );
    });
  }

  Future<void> _loadAyahData(_SessionCard card) async {
    setState(() => _loadingAyah = true);

    final entry = card.entry;

    try {
      // 1. Fetch Arabic verse text
      final arabic = quranVerseText(entry.surah, entry.ayah);

      // 2. Fetch previous ayah end as cue for revision tracks
      String prevEnd = '';
      if (card.track != _Track.newAyah && entry.sequenceIndex != null) {
        final seqIdx = entry.sequenceIndex!;
        if (seqIdx > 0) {
          final unitEntries = HifzDB.getUnitEntries(entry.unitId!);
          final prev = unitEntries.firstWhere(
            (e) => e.sequenceIndex == seqIdx - 1,
            orElse: () => entry,
          );
          if (prev != entry) {
            final prevText = quranVerseText(prev.surah, prev.ayah);
            final prevWords = prevText.trim().split(' ');
            prevEnd = prevWords
                .skip(math.max(0, prevWords.length - 4))
                .join(' ');
          }
        }
      }

      final words = arabic
          .trim()
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();
      final blanked = _computeBlankedIndices(
        words.length,
        card.track,
        entry.introducedRepetitions,
      );

      // 3. Fetch transliteration
      final transliteration = await QuranTransliterationService.instance
          .verseTransliteration(entry.surah, entry.ayah);

      // 4. Fetch translation
      final translation = quran.cleanTranslationText(
        quran.getVerseTranslation(
          entry.surah,
          entry.ayah,
          translation: quran
              .Translation
              .values[SettingsDB().get("translation", defaultValue: 0)],
        ),
      );

      if (mounted) {
        setState(() {
          _arabicText = arabic;
          _prevAyahEnd = prevEnd;
          _words = words;
          _blankedIndices = blanked;
          _allRevealed = false;
          _loadingAyah = false;
          _phase = card.startPhase;
          _audioEnabled =
              card.track == _Track.newAyah && _phase == _Phase.listen;
          _showTransliteration = card.track == _Track.newAyah
              ? HifzPrefs.showTransliterationByDefault()
              : false;
          _showTranslation = card.track == _Track.newAyah
              ? HifzPrefs.showTranslationByDefault()
              : false;
          _currentTransliteration = transliteration;
          _currentTranslation = translation;
        });

        _fadeController.reset();
        unawaited(_fadeController.forward());
        _precomputeIntervals();

        if (card.track == _Track.newAyah) {
          final prefsBox = SettingsDB();
          final autoPlay =
              prefsBox.get('hifzAutoPlayAudio', defaultValue: false) as bool;
          if (autoPlay) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _playAudio();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _arabicText = 'Error loading ayah: $e';
          _prevAyahEnd = '';
          _words = [];
          _loadingAyah = false;
        });
      }
    }
  }

  Set<int> _computeBlankedIndices(int wordCount, _Track track, int introReps) {
    if (wordCount == 0) return {};

    if (track != _Track.newAyah) {
      // Sabqi/Manzil — blank everything
      return Set<int>.from(List.generate(wordCount, (i) => i));
    }

    // Randomly select indices to blank based on rep count
    final rng = math.Random();
    final allIndices = List.generate(wordCount, (i) => i);

    int blankCount;
    switch (introReps) {
      case 0:
        blankCount = 1;
        break;
      case 1:
        blankCount = (wordCount / 2).ceil();
        break;
      default:
        blankCount = wordCount;
        break;
    }

    blankCount = math.min(blankCount, wordCount);
    allIndices.shuffle(rng);
    return Set<int>.from(allIndices.take(blankCount));
  }

  Future<void> _submitRating(String rating) async {
    final card = _queue[_currentIndex];
    final entry = card.entry;

    if (card.track == _Track.newAyah) {
      // Learn phase — use recordLearnRepetition not SM-2
      final graduated = HifzScheduler.recordLearnRepetition(entry, rating);
      await HifzDB.saveEntry(entry);
      await HifzLimits.incrementNew();

      if (graduated) _newGraduated++;

      // If rated 'again' and not graduated,
      // re-insert the card 3 positions ahead
      // so they see it again this session
      // Cap re-insertions at 3 per card
      if (rating == 'again' && !graduated) {
        final key = '${entry.surah}:${entry.ayah}';
        final lapses = _lapseThisSession[key] ?? 0;
        if (lapses < 3) {
          _lapseThisSession[key] = lapses + 1;
          final insertAt = math.min(_currentIndex + 4, _queue.length);
          _queue.insert(insertAt, card);
        }
      }
    } else {
      // Sabqi / Manzil — use fail/pass review flow
      final (updatedEntry, log) = HifzScheduler.review(entry, rating);
      await HifzDB.saveEntry(updatedEntry);
      await HifzDB.saveLog(log);
      await HifzLimits.incrementReview();

      if (rating == 'fail') {
        final key = '${entry.surah}:${entry.ayah}';
        final lapses = _lapseThisSession[key] ?? 0;
        if (lapses < 3) {
          _lapseThisSession[key] = lapses + 1;
          final insertAt = math.min(_currentIndex + 4, _queue.length);
          _queue.insert(insertAt, card);
        }
      }
    }

    _ratingCounts[rating] = (_ratingCounts[rating] ?? 0) + 1;

    await _advanceToNext();
  }

  Future<void> _advanceToNext() async {
    // Stop audio if playing
    if (_audioPlaying) {
      await _audioPlayer?.stop();
    }

    if (_currentIndex >= _queue.length - 1) {
      if (mounted) {
        final duration = DateTime.now().difference(_sessionStart);

        // BEFORE navigating to complete screen:
        await HifzFrontierService.advanceAfterSession(
          unit: _unit,
          graduatedToday: _newGraduated,
        );

        // THEN navigate:
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HifzCompleteScreen(
              ratingCounts: _ratingCounts,
              sessionDuration: duration,
              totalReviewed: _currentIndex + 1,
              newGraduated: _newGraduated,
              unit: _unit,
            ),
          ),
        );
      }
      return;
    }

    // Slide current card out left
    await _cardSlideController.forward();

    if (mounted) {
      setState(() => _currentIndex++);

      // Reset slide to right (next card slides in)
      _cardSlideController.reset();

      // Load new ayah data
      await _loadAyahData(_queue[_currentIndex]);
    }
  }

  void _confirmExit() {
    final colors = context.equranColors;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          title: Text(
            dialogL10n.hifzExitSessionTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            dialogL10n.hifzExitSessionBody(_currentIndex, _queue.length),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                dialogL10n.hifzExitCancel,
                style: TextStyle(color: colors.textMuted),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                dialogL10n.hifzExitConfirm,
                style: TextStyle(color: colors.warning),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // dismiss dialog
                Navigator.of(context).pop(); // exit session page
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _playAudio() async {
    if (!_audioEnabled) return;
    if (_loadingAyah || _queue.isEmpty) return;

    final entry = _queue[_currentIndex].entry;

    if (_audioPlaying) {
      await _audioPlayer?.stop();
      return;
    }

    try {
      final AudioDownloadService downloads = AudioDownloadService();
      final File? offlineFile = await downloads.playbackAyahFile(
        entry.surah,
        entry.ayah,
      );

      if (offlineFile != null && offlineFile.existsSync()) {
        await _audioPlayer?.play(DeviceFileSource(offlineFile.path));
      } else {
        final String url = await QuranAudioService().getAyahUrl(
          entry.surah,
          entry.ayah,
        );
        await _audioPlayer?.play(UrlSource(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: context.equranColors.warning,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cardSlideController.dispose();
    _fadeController.dispose();
    _stateSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_queue.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colors.primary,
                  size: 72,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.hifzEmptySessionTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.hifzEmptySessionBody(_unit.displayName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.hifzEmptySessionButton),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = _queue[_currentIndex];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textSecondary),
          onPressed: _confirmExit,
        ),
        title: Text(
          _unit.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TrackLabel(track: currentCard.track),
                const SizedBox(width: 8),
                Text(
                  '${_currentIndex + 1}/${_queue.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _queue.length,
              backgroundColor: colors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              minHeight: 3,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCardContent(colors, theme, currentCard),
              ),
            ),
          ),
          _buildBottomActionArea(colors, theme),
        ],
      ),
    );
  }

  Widget _buildCardContent(
    EquranColors colors,
    ThemeData theme,
    _SessionCard card,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final entry = card.entry;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? l10n.hifzStatsNextDueValue(
                    quran.getSurahNameArabic(entry.surah),
                    entry.ayah,
                  )
                : l10n.hifzStatsNextDueValue(
                    HifzSurahData.name(entry.surah),
                    entry.ayah,
                  ),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_loadingAyah)
            SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            if (_phase == _Phase.listen)
              _buildListenText(colors)
            else
              _buildRecallText(colors),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (card.track == _Track.newAyah) ...[
                    _ToggleButton(
                      icon: Icons.translate,
                      active: _showTransliteration,
                      onTap: () {
                        setState(() {
                          _showTransliteration = !_showTransliteration;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _ToggleButton(
                      icon: Icons.language,
                      active: _showTranslation,
                      onTap: () {
                        setState(() {
                          _showTranslation = !_showTranslation;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                  _audioEnabled
                      ? _ToggleButton(
                          icon: _audioPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.volume_up_outlined,
                          active: _audioPlaying,
                          onTap: _playAudio,
                        )
                      : Tooltip(
                          message: l10n.hifzAudioDisabledTooltip,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Opacity(
                            opacity: 0.35,
                            child: _ToggleButton(
                              icon: Icons.volume_up_outlined,
                              active: false,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.hifzAudioDisabledTooltip,
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showTransliteration
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _currentTransliteration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showTranslation
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                      child: Text(
                        _currentTranslation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListenText(EquranColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Text(
        _arabicText,
        style: TextStyle(
          fontFamily: 'UthmanicHafs',
          fontSize: 28,
          color: colors.textPrimary,
          height: 2.2,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildRecallText(EquranColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (_prevAyahEnd.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.medium),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.hifzPrevAyahCueLabel,
                  style: TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 18,
                    color: colors.textMuted,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  _prevAyahEnd,
                  style: TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 22,
                    color: colors.textSecondary,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            spacing: 6,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _words.asMap().entries.map((e) {
              final i = e.key;
              final word = e.value;

              // Not in blanked set — always shown
              if (!_blankedIndices.contains(i) || _allRevealed) {
                return _RevealedWord(
                  word: word,
                  isJustRevealed: _allRevealed && _blankedIndices.contains(i),
                );
              }

              // Blanked word — tap to reveal
              return _BlankWord(
                word: word,
                onReveal: () {
                  setState(() {
                    _blankedIndices.remove(i);
                    // Check if all blanks revealed
                    if (_blankedIndices.isEmpty) {
                      _allRevealed = true;
                      _phase = _Phase.rating;
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionArea(EquranColors colors, ThemeData theme) {
    Widget child;
    final l10n = AppLocalizations.of(context)!;
    final currentCard = _queue[_currentIndex];

    if (_phase == _Phase.listen) {
      child = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 52),
          ),
          onPressed: () {
            setState(() {
              _phase = _Phase.recall;
              _audioEnabled = false;
            });
            if (_audioPlaying) {
              _audioPlayer?.stop();
            }
          },
          child: Text(
            l10n.hifzImReady,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (_phase == _Phase.recall) {
      child = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.surfaceAlt,
            foregroundColor: colors.textPrimary,
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 52),
            side: BorderSide(color: colors.border),
          ),
          onPressed: () {
            setState(() {
              _allRevealed = true;
              _blankedIndices.clear();
              _phase = _Phase.rating;
              _audioEnabled = false;
            });
          },
          child: Text(
            l10n.hifzRevealAll,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      // _Phase.rating
      if (currentCard.track == _Track.newAyah) {
        // Show only two buttons (wider)
        child = Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _submitRating('again'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    border: Border.all(color: colors.border, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Center(
                    child: Text(
                      l10n.hifzRatingTryAgain,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _submitRating('gotIt'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Center(
                    child: Text(
                      l10n.hifzRatingGotIt,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        // Sabqi / Manzil: show fail/pass review buttons
        child = _buildRatingButtons();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(top: false, child: child),
    );
  }

  Widget _buildRatingButtons() {
    final colors = context.equranColors;
    final failLabel = 'Fail';
    final passLabel = 'Pass';

    return Row(
      children: [
        _RatingButton(
          label: failLabel,
          interval: _projectedIntervals['fail'] ?? 1,
          bgColor: colors.surfaceAlt,
          borderColor: colors.border,
          labelColor: colors.textSecondary,
          intervalColor: colors.textMuted,
          onTap: () => _submitRating('fail'),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: passLabel,
          interval: _projectedIntervals['pass'] ?? 4,
          bgColor: colors.primary.withAlpha(38), // 15%
          borderColor: colors.primary.withAlpha(76), // 30%
          labelColor: colors.primary,
          intervalColor: colors.primarySoft,
          onTap: () => _submitRating('pass'),
        ),
      ],
    );
  }
}

class _BlankWord extends StatelessWidget {
  final String word;
  final VoidCallback onReveal;

  const _BlankWord({required this.word, required this.onReveal});

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final wordWidth = (word.length * 14.0).clamp(32.0, 120.0);

    return GestureDetector(
      onTap: onReveal,
      child: Container(
        width: wordWidth,
        height: 38,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}

class _RevealedWord extends StatefulWidget {
  final String word;
  final bool isJustRevealed;

  const _RevealedWord({required this.word, required this.isJustRevealed});

  @override
  State<_RevealedWord> createState() => _RevealedWordState();
}

class _RevealedWordState extends State<_RevealedWord> {
  bool _highlighted = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isJustRevealed) {
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _highlighted = false;
          });
        }
      });
    } else {
      _highlighted = false;
    }
  }

  @override
  void didUpdateWidget(covariant _RevealedWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isJustRevealed && !oldWidget.isJustRevealed) {
      _timer?.cancel();
      setState(() {
        _highlighted = true;
      });
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _highlighted = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final targetColor = (widget.isJustRevealed && _highlighted)
        ? colors.primary
        : colors.textPrimary;

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 500),
      tween: ColorTween(
        begin: widget.isJustRevealed ? colors.primary : colors.textPrimary,
        end: targetColor,
      ),
      builder: (context, color, child) {
        return Text(
          widget.word,
          style: TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: 26,
            color: color ?? colors.textPrimary,
            height: 2.0,
          ),
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceAlt,
          border: Border.all(
            color: active
                ? colors.primary.withValues(alpha: 0.3)
                : colors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? colors.primary : colors.textMuted,
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final int interval;
  final Color bgColor;
  final Color borderColor;
  final Color labelColor;
  final Color intervalColor;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.interval,
    required this.bgColor,
    required this.borderColor,
    required this.labelColor,
    required this.intervalColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.large),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                HifzScheduler.formatInterval(interval),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: intervalColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackLabel extends StatelessWidget {
  final _Track track;
  const _TrackLabel({required this.track});

  Color _trackColor(BuildContext context, _Track t) {
    final colors = context.equranColors;
    switch (t) {
      case _Track.newAyah:
        return colors.primary;
      case _Track.sabqi:
        return colors.accentGold;
      case _Track.manzil:
        return colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _trackColor(context, track);
    final theme = Theme.of(context);
    String trackName;
    switch (track) {
      case _Track.newAyah:
        trackName = l10n.hifzTrackNewLabel;
        break;
      case _Track.sabqi:
        trackName = l10n.hifzTrackRevisionLabel;
        break;
      case _Track.manzil:
        trackName = l10n.hifzTrackMaintenanceLabel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        trackName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
