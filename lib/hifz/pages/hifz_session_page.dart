import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;

import '../models/hifz_entry.dart';
import '../hifz_limits.dart';
import '../hifz_surah_data.dart';
import '../hifz_scheduler.dart';
import '../hifz_db.dart';
import 'hifz_complete_screen.dart';

import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/backend/settings_db.dart';
import 'package:equran/backend/hifz_db.dart';
import 'package:equran/backend/transliteration_service.dart';
import 'package:equran/backend/quran_stream_url.dart';
import 'package:equran/backend/audio_downloads.dart';
import 'package:equran/l10n/app_localizations.dart';

enum _Phase { learn, recall, rating }

class HifzSessionPage extends StatefulWidget {
  final List<HifzEntry> entries;
  const HifzSessionPage({required this.entries, super.key});

  @override
  State<HifzSessionPage> createState() => _HifzSessionPageState();
}

class _HifzSessionPageState extends State<HifzSessionPage>
    with TickerProviderStateMixin {
  List<HifzEntry> _queue = [];
  int _currentIndex = 0;
  _Phase _phase = _Phase.learn;
  bool _showTransliteration = false;
  bool _showTranslation = false;
  Set<int> _revealedWordIndices = {};
  bool _allRevealed = false;

  // Ayah text data
  String _currentArabicText = '';
  String _currentTransliteration = '';
  String _currentTranslation = '';
  bool _loadingAyah = true;

  // Audio state
  AudioPlayer? _audioPlayer;
  bool _audioPlaying = false;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completeSubscription;

  // Animation controllers
  late AnimationController _cardSlideController;
  late Animation<Offset> _cardSlideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Precomputed projected intervals for the rating buttons
  Map<String, int> _projectedIntervals = {};

  // Session stats tracking
  final Map<String, int> _ratingCounts = {
    'again': 0,
    'hard': 0,
    'good': 0,
    'easy': 0,
  };
  final Map<String, int> _lapseThisSession = {};
  final DateTime _sessionStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _buildQueue();
    _initAnimations();

    if (_queue.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    } else {
      _loadAyahData(_queue[0]);
    }
  }

  void _buildQueue() {
    final due = widget.entries.where((e) => e.isDue).toList();
    final newEntries = widget.entries
        .where((e) => e.status == 'new')
        .take(HifzLimits.maxNewPerDay - HifzLimits.todayNewCount)
        .toList();

    // Shuffle review entries, new at end
    due.shuffle();
    _queue = [...due, ...newEntries];
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
        _queue[_currentIndex],
      );
    });
  }

  Future<void> _loadAyahData(HifzEntry entry) async {
    setState(() => _loadingAyah = true);

    try {
      // 1. Fetch Arabic verse text
      final arabicText = quran.getVerse(entry.surah, entry.ayah);

      // 2. Fetch transliteration
      final transliteration = await QuranTransliterationService.instance
          .verseTransliteration(entry.surah, entry.ayah);

      // 3. Fetch translation
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
          _currentArabicText = arabicText;
          _currentTransliteration = transliteration;
          _currentTranslation = translation;
          _loadingAyah = false;
          _revealedWordIndices = {};
          _allRevealed = false;
          _phase = _Phase.learn;
          _showTransliteration = HifzPrefs.showTransliterationByDefault();
          _showTranslation = HifzPrefs.showTranslationByDefault();
        });

        _fadeController.reset();
        unawaited(_fadeController.forward());
        _precomputeIntervals();

        if (HifzPrefs.autoPlayAudioOnLearn()) {
          unawaited(_playAudio());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentArabicText = 'Error loading ayah: $e';
          _currentTransliteration = '';
          _currentTranslation = '';
          _loadingAyah = false;
        });
      }
    }
  }

  Future<void> _submitRating(String rating) async {
    if (_queue.isEmpty || _currentIndex >= _queue.length) return;
    final entry = _queue[_currentIndex];

    // Run SM-2 algorithm
    final (updatedEntry, log) = HifzScheduler.review(entry, rating);

    // Persist to Hive
    await HifzDB.saveEntry(updatedEntry);
    await HifzDB.saveLog(log);

    // Update daily counters
    if (entry.status == 'new') {
      await HifzLimits.incrementNew();
    } else {
      await HifzLimits.incrementReview();
    }

    // Track session stats
    _ratingCounts[rating] = (_ratingCounts[rating] ?? 0) + 1;

    // If rated 'again', re-insert the card later
    // in the queue so user sees it again this session
    if (rating == 'again') {
      final String key = '${entry.surah}:${entry.ayah}';
      final int lapses = _lapseThisSession[key] ?? 0;
      if (lapses < 3) {
        _lapseThisSession[key] = lapses + 1;
        // Insert a copy 3–5 positions ahead (already capped safely)
        final insertAt = math.min(_currentIndex + 4, _queue.length);
        _queue.insert(insertAt, updatedEntry);
      }
    }

    // Advance to next card or complete
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HifzCompleteScreen(
              ratingCounts: _ratingCounts,
              sessionDuration: duration,
              totalReviewed: _currentIndex + 1,
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
            dialogL10n.hifzExitSession,
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
    if (_loadingAyah || _queue.isEmpty) return;

    final entry = _queue[_currentIndex];

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
    if (_queue.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colors = context.equranColors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentEntry = _queue[_currentIndex];

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
          l10n.hifzSessionProgress(_currentIndex + 1, _queue.length),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _TrackBadge(track: currentEntry.track)),
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
                child: _buildCardContent(colors, theme, currentEntry),
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
    HifzEntry entry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? l10n.hifzStatsNextDueValue(quran.getSurahNameArabic(entry.surah), entry.ayah)
                : l10n.hifzStatsNextDueValue(HifzSurahData.name(entry.surah), entry.ayah),
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
            if (_phase == _Phase.learn)
              _buildLearnText(colors)
            else
              _buildRecallText(colors, entry),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToggleButton(
                  icon: Icons.translate,
                  label: l10n.hifzToggleTransliteration,
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
                  label: l10n.hifzToggleTranslation,
                  active: _showTranslation,
                  onTap: () {
                    setState(() {
                      _showTranslation = !_showTranslation;
                    });
                  },
                ),
                const SizedBox(width: 16),
                _ToggleButton(
                  icon: _audioPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_outlined,
                  label: l10n.hifzToggleListen,
                  active: _audioPlaying,
                  onTap: _playAudio,
                ),
              ],
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

  Widget _buildLearnText(EquranColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Text(
        _currentArabicText,
        style: TextStyle(
          fontFamily: 'Hafs',
          fontSize: 28,
          color: colors.textPrimary,
          height: 2.2,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildRecallText(EquranColors colors, HifzEntry entry) {
    final words = _currentArabicText.trim().split(' ');
    final blankIndices = <int>{};
    final String blankingLevel =
        SettingsDB().get('hifzBlankingLevel', defaultValue: 'auto') as String;

    int activeRep;
    if (blankingLevel == 'easy') {
      activeRep = 0;
    } else if (blankingLevel == 'medium') {
      activeRep = 1;
    } else if (blankingLevel == 'hard') {
      activeRep = 2;
    } else {
      activeRep = entry.repetitions;
    }

    final int wordCount = words.length;
    if (activeRep == 0) {
      for (int i = 0; i < wordCount; i++) {
        if (i % 3 == 1) {
          blankIndices.add(i);
        }
      }
    } else if (activeRep == 1) {
      for (int i = 0; i < wordCount; i++) {
        if (i % 2 == 0) {
          blankIndices.add(i);
        }
      }
    } else {
      for (int i = 0; i < wordCount; i++) {
        blankIndices.add(i);
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 6,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: words.asMap().entries.map((e) {
          final index = e.key;
          final word = e.value;
          final shouldBlank =
              blankIndices.contains(index) &&
              !_revealedWordIndices.contains(index) &&
              !_allRevealed;

          return shouldBlank
              ? _BlankWord(
                  word: word,
                  onReveal: () {
                    setState(() {
                      _revealedWordIndices.add(index);
                      if (_revealedWordIndices.length >= blankIndices.length) {
                        _allRevealed = true;
                        _phase = _Phase.rating;
                      }
                    });
                  },
                )
              : _RevealedWord(
                  word: word,
                  isJustRevealed: _revealedWordIndices.contains(index),
                );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActionArea(EquranColors colors, ThemeData theme) {
    Widget child;
    final l10n = AppLocalizations.of(context)!;

    if (_phase == _Phase.learn) {
      child = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
          onPressed: () {
            setState(() {
              _phase = _Phase.recall;
            });
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
      child = TextButton(
        onPressed: () {
          setState(() {
            _allRevealed = true;
            _phase = _Phase.rating;
          });
        },
        child: Text(
          l10n.hifzRevealAll,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      child = _buildRatingButtons();
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _RatingButton(
          label: l10n.hifzRatingAgain,
          interval: _projectedIntervals['again'] ?? 1,
          bgColor: colors.surfaceAlt,
          borderColor: colors.border,
          labelColor: colors.textSecondary,
          intervalColor: colors.textMuted,
          onTap: () => _submitRating('again'),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: l10n.hifzRatingHard,
          interval: _projectedIntervals['hard'] ?? 1,
          bgColor: colors.goldSoft,
          borderColor: colors.accentGold.withAlpha(102), // 40%
          labelColor: colors.warning,
          intervalColor: colors.accentGold,
          onTap: () => _submitRating('hard'),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: l10n.hifzRatingGood,
          interval: _projectedIntervals['good'] ?? 4,
          bgColor: colors.primary.withAlpha(38), // 15%
          borderColor: colors.primary.withAlpha(76), // 30%
          labelColor: colors.primary,
          intervalColor: colors.primarySoft,
          onTap: () => _submitRating('good'),
        ),
        const SizedBox(width: 8),
        _RatingButton(
          label: l10n.hifzRatingEasy,
          interval: _projectedIntervals['easy'] ?? 8,
          bgColor: colors.mint,
          borderColor: colors.primary.withAlpha(51), // 20%
          labelColor: colors.primary,
          intervalColor: colors.primary,
          onTap: () => _submitRating('easy'),
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
            fontFamily: 'Hafs',
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
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? colors.primary.withAlpha(38) : colors.surfaceAlt,
              border: Border.all(
                color: active ? colors.primary.withAlpha(76) : colors.border,
              ),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? colors.primary : colors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textMuted,
            ),
          ),
        ],
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

    if (track == 'Hifz') {
      bgColor = colors.primary.withAlpha(38);
      textColor = colors.primary;
      label = l10n.hifzTitle;
    } else if (track == 'Murajaah') {
      bgColor = colors.accentGold.withAlpha(38);
      textColor = colors.accentGold;
      label = l10n.hifzTrackRevision;
    } else {
      bgColor = colors.surfaceAlt;
      textColor = colors.textMuted;
      label = track;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
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
