import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:equran/backend/library.dart'
    show
        AndroidAudioDisplayMode,
        AudioDownloadService,
        DownloadNotifications,
        DownloadableResource,
        ResourceDownloadService,
        ResourceInstallException,
        ResourceInstallState,
        ResourceInstallStore,
        PlayerAudioService,
        QuranTransliterationService,
        ResumeStateDB,
        ResumeStateEntry,
        SurahTiming,
        SurahTimingRepository,
        SettingsDB,
        FavouritesDB,
        prettyBytes;
import 'package:hive/hive.dart' show Box;
import 'package:equran/l10n/app_localizations.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/utils/app_slider_theme.dart';
import 'package:equran/utils/number_formatting.dart';
import 'package:equran/utils/quran_display.dart';
import 'package:equran/utils/quran_text.dart';
import 'package:equran/utils/reciter.dart';
import 'package:equran/utils/responsive_nav.dart';
import 'package:equran/services/frame_rate_policy_manager.dart';
import 'package:equran/widgets/app_selection_dialog.dart';
import 'package:equran/widgets/number_badge.dart';
import 'package:equran/widgets/read_quran_card.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran/quran.dart' as quran;
import 'package:equran/backend/playback_cache_service.dart';

const List<String> _surahTransliterations = <String>[
  'Al-Fatihah',
  'Al-Baqarah',
  "Ali 'Imran",
  'An-Nisa',
  "Al-Ma'idah",
  "Al-An'am",
  "Al-A'raf",
  'Al-Anfal',
  'At-Tawbah',
  'Yunus',
  'Hud',
  'Yusuf',
  "Ar-Ra'd",
  'Ibrahim',
  'Al-Hijr',
  'An-Nahl',
  'Al-Isra',
  'Al-Kahf',
  'Maryam',
  'Ta-Ha',
  'Al-Anbiya',
  'Al-Hajj',
  "Al-Mu'minun",
  'An-Nur',
  'Al-Furqan',
  "Ash-Shu'ara",
  'An-Naml',
  'Al-Qasas',
  'Al-Ankabut',
  'Ar-Rum',
  'Luqman',
  'As-Sajdah',
  'Al-Ahzab',
  'Saba',
  'Fatir',
  'Ya-Sin',
  'As-Saffat',
  'Sad',
  'Az-Zumar',
  'Ghafir',
  'Fussilat',
  'Ash-Shura',
  'Az-Zukhruf',
  'Ad-Dukhan',
  'Al-Jathiyah',
  'Al-Ahqaf',
  'Muhammad',
  'Al-Fath',
  'Al-Hujurat',
  'Qaf',
  'Adh-Dhariyat',
  'At-Tur',
  'An-Najm',
  'Al-Qamar',
  'Ar-Rahman',
  "Al-Waqi'ah",
  'Al-Hadid',
  'Al-Mujadilah',
  'Al-Hashr',
  'Al-Mumtahanah',
  'As-Saff',
  "Al-Jumu'ah",
  'Al-Munafiqun',
  'At-Taghabun',
  'At-Talaq',
  'At-Tahrim',
  'Al-Mulk',
  'Al-Qalam',
  'Al-Haqqah',
  "Al-Ma'arij",
  'Nuh',
  'Al-Jinn',
  'Al-Muzzammil',
  'Al-Muddaththir',
  'Al-Qiyamah',
  'Al-Insan',
  'Al-Mursalat',
  'An-Naba',
  "An-Nazi'at",
  'Abasa',
  'At-Takwir',
  'Al-Infitar',
  'Al-Mutaffifin',
  'Al-Inshiqaq',
  'Al-Buruj',
  'At-Tariq',
  "Al-A'la",
  'Al-Ghashiyah',
  'Al-Fajr',
  'Al-Balad',
  'Ash-Shams',
  'Al-Layl',
  'Ad-Duha',
  'Ash-Sharh',
  'At-Tin',
  'Al-Alaq',
  'Al-Qadr',
  'Al-Bayyinah',
  'Az-Zalzalah',
  'Al-Adiyat',
  "Al-Qari'ah",
  'At-Takathur',
  'Al-Asr',
  'Al-Humazah',
  'Al-Fil',
  'Quraysh',
  "Al-Ma'un",
  'Al-Kawthar',
  'Al-Kafirun',
  'An-Nasr',
  'Al-Masad',
  'Al-Ikhlas',
  'Al-Falaq',
  'An-Nas',
];

const String _playerDesignAsset = 'assets/media/images/app/design.webp';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WidgetsBindingObserver {
  static const MethodChannel _playerPageChannel = MethodChannel(
    'com.app.equran/read_page',
  );
  static const String _frameRatePolicySource = 'full_player_page';
  static const String _playerPagePointerSource = 'full_player_page_pointer';
  static const String _playerPageSeekSource = 'full_player_page_seek';
  static const String _sleepTimerDurationMode = 'duration';
  static const String _sleepTimerEndSurahMode = 'endSurah';
  static const Duration _expandedProgressTickInterval = Duration(
    milliseconds: 33,
  );

  final ja.AudioPlayer _justAudio = ja.AudioPlayer();
  final ap.AudioPlayer _fallbackAudio = ap.AudioPlayer();
  final AudioDownloadService _downloads = AudioDownloadService();
  final SurahTimingRepository _timingRepository = SurahTimingRepository();
  final Random _random = Random();
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<Duration> _elapsedNotifier = ValueNotifier<Duration>(
    Duration.zero,
  );
  final ValueNotifier<int?> _activeAyahNotifier = ValueNotifier<int?>(null);

  late final bool _useAudioplayersFallback;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<ja.PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _fallbackPositionSubscription;
  StreamSubscription<Duration>? _fallbackDurationSubscription;
  StreamSubscription<ap.PlayerState>? _fallbackStateSubscription;
  StreamSubscription<void>? _fallbackCompleteSubscription;

  int _selectedSurah = 1;
  int? _loadedSurah;
  bool? _loadedFromOffline;
  String? _loadedReciterCode;

  bool _isLoading = false;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  bool _isTimingLoading = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _playingFromOffline = false;
  bool _shuffleEnabled = false;
  bool _loopEnabled = false;
  bool _showAyahText = false;
  bool _isCompletingTrack = false;
  bool _isPlayerPageForeground = true;
  bool _showProgressThumb = false;
  bool _isScrubbing = false;
  int _progressVisualBlockCount = 0;
  int _timingLoadGeneration = 0;
  int? _activeAyah;
  int? _timingSurah;
  int? _transliterationSurah;
  double? _pendingSeekProgress;
  Duration? _scrubPreviewPosition;
  Duration? _pendingInitialResumePosition;
  DateTime? _lastListeningPersistedAt;
  String? _timingReciterCode;
  bool? _selectionTimingSupported;
  ResourceInstallState? _selectionTimingInstallState;
  SurahTiming? _surahTiming;
  List<String> _surahTransliterationsCache = const <String>[];

  double _playbackRate = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _progressVisualTicker;
  Timer? _progressThumbTimer;
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndsAt;
  String? _sleepTimerLabel;
  String? _sleepTimerMode;
  DateTime? _positionSampledAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _useAudioplayersFallback =
        !kIsWeb && (Platform.isLinux || Platform.isWindows);

    final dynamic rate = SettingsDB().get("playbackRate", defaultValue: 1.0);
    if (rate is num) {
      _playbackRate = rate.toDouble().clamp(0.5, 2.0);
    }

    _loadListeningResumeState();
    _bindAudioListeners();
    _refreshDownloadState();
    unawaited(_loadTimingForSelection(surah: _selectedSurah));
    _consumeResumeListeningRequest();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isPlayerPageForeground = true;
      FrameRatePolicyManager.instance.setAppLifecyclePaused(
        false,
        reason: 'full_player_resumed',
      );
      unawaited(_updateKeepScreenOn());
      _syncProgressVisualPolicy(syncPosition: true);
      return;
    }

    _isPlayerPageForeground = false;
    FrameRatePolicyManager.instance.setAppLifecyclePaused(
      true,
      reason: 'full_player_lifecycle_paused',
    );
    _syncProgressVisualPolicy();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_setKeepScreenOn(false));
    }
  }

  void _bindAudioListeners() {
    if (_useAudioplayersFallback) {
      _fallbackPositionSubscription = _fallbackAudio.onPositionChanged.listen((
        position,
      ) {
        if (_isScrubbing) return;
        _setAudioPosition(position);
      });

      _fallbackDurationSubscription = _fallbackAudio.onDurationChanged.listen((
        duration,
      ) {
        _safeSetState(() {
          _duration = duration;
        });
        _rescheduleEndOfSurahSleepTimer();
        _syncProgressVisualPolicy(syncPosition: true);
      });

      _fallbackStateSubscription = _fallbackAudio.onPlayerStateChanged.listen((
        state,
      ) {
        final Duration currentPosition = _estimatedAudioPosition();
        _safeSetState(() {
          _isPlaying = state == ap.PlayerState.playing;
          _isPaused = state == ap.PlayerState.paused;
          _position = currentPosition;
          _positionSampledAt = _isPlaying ? DateTime.now() : null;
          if (_isLoading) {
            if (_isPlaying) {
              _isLoading = false;
            }
          } else if (_isPaused || state == ap.PlayerState.stopped) {
            _isLoading = false;
          }
        });
        unawaited(
          AndroidAudioDisplayMode.setAudioPlaybackActive(
            state == ap.PlayerState.playing,
          ),
        );
        _persistListeningResume(force: true);
        _syncProgressVisualPolicy(syncPosition: true);
      });

      _fallbackCompleteSubscription = _fallbackAudio.onPlayerComplete.listen((
        _,
      ) async {
        await _handleTrackComplete();
      });
      return;
    }

    _positionSubscription = _justAudio.positionStream.listen((position) {
      if (_isScrubbing) return;
      _setAudioPosition(position);
    });

    _durationSubscription = _justAudio.durationStream.listen((duration) {
      _safeSetState(() {
        _duration = duration ?? Duration.zero;
      });
      _rescheduleEndOfSurahSleepTimer();
      _syncProgressVisualPolicy(syncPosition: true);
    });

    _stateSubscription = _justAudio.playerStateStream.listen((state) async {
      final bool isActivePlayback =
          state.playing && state.processingState == ja.ProcessingState.ready;
      final bool isLoading =
          state.processingState == ja.ProcessingState.loading ||
          state.processingState == ja.ProcessingState.buffering;
      final Duration currentPosition = _justAudio.position;
      _safeSetState(() {
        _isPlaying = isActivePlayback;
        _isPaused =
            !state.playing && state.processingState == ja.ProcessingState.ready;
        _position = currentPosition;
        _positionSampledAt = isActivePlayback ? DateTime.now() : null;
        if (isLoading) {
          _isLoading = true;
        } else if (isActivePlayback ||
            _isPaused ||
            state.processingState == ja.ProcessingState.completed) {
          _isLoading = false;
        }
      });

      if (state.processingState == ja.ProcessingState.completed) {
        await _handleTrackComplete();
      }
      _persistListeningResume(force: true);
      unawaited(AndroidAudioDisplayMode.setAudioPlaybackActive(state.playing));
      _syncProgressVisualPolicy(syncPosition: true);
    });
  }

  Future<void> _handleTrackComplete() async {
    if (_isCompletingTrack) return;
    _isCompletingTrack = true;

    try {
      _safeSetState(() {
        _position = Duration.zero;
        _positionSampledAt = null;
        _setActiveAyahValue(null);
        _isPlaying = false;
        _isPaused = false;
      });
      _syncProgressVisualPolicy(syncPosition: true);

      if (_loopEnabled) {
        await _playSurah(_selectedSurah, forceRestart: true);
      } else if (_shuffleEnabled) {
        final int next = _randomSurah(excluding: _selectedSurah);
        await _playSurah(next, forceRestart: true);
      } else {
        await _playNext();
      }
    } finally {
      _isCompletingTrack = false;
    }
  }

  void _syncActivePlaybackTrack() {
    if (_isPlaying && _loadedReciterCode != null) {
      PlaybackCacheService.instance.updateActiveTrack(
        surah: _selectedSurah,
        reciterCode: _loadedReciterCode!,
        isPlaying: _isPlaying,
        isOffline: _playingFromOffline,
      );
    } else {
      PlaybackCacheService.instance.clearActiveTrack();
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _syncActivePlaybackTrack();
  }

  void _syncFrameRatePolicy(String reason) {
    if (!mounted) {
      FrameRatePolicyManager.instance.resetSource(
        _frameRatePolicySource,
        reason: 'full_player_unmounted',
      );
      return;
    }

    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final bool routeCurrent = route?.isCurrent ?? true;
    final bool expandedPlayerVisible =
        _isPlayerPageForeground &&
        routeCurrent &&
        _progressVisualBlockCount == 0;

    FrameRatePolicyManager.instance.updatePlaybackSurface(
      source: _frameRatePolicySource,
      audioPlaying: _isPlaying,
      expandedPlayerVisible: expandedPlayerVisible,
      miniPlayerVisible: false,
      reason: reason,
    );
  }

  bool get _shouldRenderProgressVisuals {
    if (!mounted) return false;
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    return _isPlayerPageForeground &&
        (route?.isCurrent ?? true) &&
        !_isScrubbing &&
        _progressVisualBlockCount == 0;
  }

  bool get _shouldRunProgressVisualTicker {
    return _shouldRenderProgressVisuals &&
        _isPlaying &&
        (_duration > Duration.zero || (_showAyahText && _surahTiming != null));
  }

  bool get _shouldAnimateProgressVisuals {
    // Android refresh hints are owned by FrameRatePolicyManager. This flag
    // keeps the legacy display-mode compatibility path inactive.
    return false;
  }

  String get _progressVisualMode {
    if (!_isPlayerPageForeground) return 'hidden';
    if (!mounted) return 'disposed';
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (!(route?.isCurrent ?? true)) return 'covered';
    if (_isScrubbing) return 'dragging';
    return 'full player';
  }

  void _syncProgressVisualPolicy({bool syncPosition = false}) {
    if (!mounted) return;

    unawaited(
      AndroidAudioDisplayMode.setVisualProgressActive(
        _shouldAnimateProgressVisuals,
      ),
    );
    _syncFrameRatePolicy('full_player_progress_policy');

    if (_shouldRunProgressVisualTicker) {
      _startProgressVisualTicker();
    } else {
      _stopProgressVisualTicker('policy stopped');
    }

    if (syncPosition && _shouldRenderProgressVisuals) {
      _syncProgressNotifier();
    }
  }

  void _setAudioPosition(Duration position) {
    if (!mounted) return;
    final Duration effectivePosition = position;
    _position = effectivePosition;
    _positionSampledAt = _isPlaying && !_isScrubbing ? DateTime.now() : null;
    if (_isPlaying && !_isScrubbing && _progressVisualTicker != null) {
      _persistListeningResume();
      return;
    }
    if (!_isPlaying || _isScrubbing || _shouldRenderProgressVisuals) {
      _syncProgressNotifier();
      final bool ayahChanged = _setActiveAyahForPosition(effectivePosition);
      _persistListeningResume(force: ayahChanged);
      return;
    }
    _persistListeningResume();
  }

  void _syncProgressNotifier() {
    if (!mounted) return;
    _setProgressVisualValue(_positionForProgress());
  }

  void _setProgressVisualValue(Duration position) {
    final double progress = _progressForPosition(position);
    final Duration elapsedLabelPosition = Duration(seconds: position.inSeconds);
    if (_elapsedNotifier.value != elapsedLabelPosition) {
      _elapsedNotifier.value = elapsedLabelPosition;
    }
    if (_progressNotifier.value != progress) {
      _progressNotifier.value = progress;
    }
  }

  double _progressForPosition(Duration position) {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / _duration.inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  void _startProgressVisualTicker() {
    if (_progressVisualTicker != null) return;
    _logProgressTicker(
      'started full player progress ticker '
      'interval=${_expandedProgressTickInterval.inMilliseconds}ms '
      'mode=$_progressVisualMode',
    );
    FrameRatePolicyManager.debugLogExpandedProgressTicker(
      owner: 'full_player_page',
      interval: _expandedProgressTickInterval,
    );
    _progressVisualTicker = Timer.periodic(
      _expandedProgressTickInterval,
      (_) => _tickProgressVisual(),
    );
  }

  void _stopProgressVisualTicker(String reason) {
    final Timer? ticker = _progressVisualTicker;
    if (ticker == null) return;
    ticker.cancel();
    _progressVisualTicker = null;
    _logProgressTicker(
      'stopped full player progress ticker ($reason) '
      'mode=$_progressVisualMode',
    );
  }

  void _tickProgressVisual() {
    if (!_shouldRunProgressVisualTicker) {
      _stopProgressVisualTicker('tick found inactive');
      return;
    }

    final Duration position = _estimatedAudioPosition();
    _setProgressVisualValue(position);
    final bool ayahChanged = _setActiveAyahForPosition(position);
    if (ayahChanged) {
      _persistListeningResume(force: true);
    }
  }

  Duration _estimatedAudioPosition() {
    final DateTime? sampledAt = _positionSampledAt;
    Duration position = _position;
    if (_isPlaying && !_isScrubbing && sampledAt != null) {
      final Duration elapsed = DateTime.now().difference(sampledAt);
      final int elapsedMicros = (elapsed.inMicroseconds * _playbackRate)
          .round();
      position += Duration(microseconds: elapsedMicros);
    }
    if (_duration > Duration.zero && position > _duration) return _duration;
    if (position < Duration.zero) return Duration.zero;
    return position;
  }

  void _logProgressTicker(String message) {
    if (!kDebugMode) return;
    debugPrint('PlayerPage: $message');
  }

  Future<T> _withProgressVisualsPaused<T>(Future<T> Function() action) async {
    AndroidAudioDisplayMode.notifyUserActivity();
    _progressVisualBlockCount++;
    FrameRatePolicyManager.instance.setModalOpen(
      true,
      reason: 'full_player_modal_open',
    );
    _syncProgressVisualPolicy(syncPosition: true);
    unawaited(AndroidAudioDisplayMode.setLowFpsSuppressed(true));
    try {
      return await action();
    } finally {
      if (_progressVisualBlockCount > 0) {
        _progressVisualBlockCount--;
      }
      if (_progressVisualBlockCount == 0) {
        FrameRatePolicyManager.instance.setModalOpen(
          false,
          reason: 'full_player_modal_closed',
        );
      }
      _syncProgressVisualPolicy(syncPosition: true);
      unawaited(AndroidAudioDisplayMode.setLowFpsSuppressed(false));
    }
  }

  Future<void> _setKeepScreenOn(bool enabled) async {
    if (kIsWeb) return;

    try {
      await _playerPageChannel.invokeMethod<void>(
        'setKeepScreenOn',
        <String, bool>{'enabled': enabled},
      );
    } catch (_) {
      // Unsupported platforms simply keep their normal sleep behavior.
    }
  }

  Future<void> _updateKeepScreenOn() async {
    await _setKeepScreenOn(mounted && _showAyahText);
  }

  void _toggleAyahText() {
    unawaited(_handleToggleAyahText());
  }

  Future<void> _handleToggleAyahText() async {
    if (_showAyahText) {
      setState(() {
        _showAyahText = false;
      });
      unawaited(_updateKeepScreenOn());
      return;
    }

    final bool timingReady = await _ensureTimingReadyForAyahText();
    if (!timingReady || !mounted) return;
    setState(() {
      _showAyahText = true;
    });
    unawaited(_updateKeepScreenOn());
  }

  String _surahName(int surah) => _surahTransliterations[surah - 1];

  String _localizedSurahName(int surah) {
    return localizedSurahName(AppLocalizations.of(context)!, surah);
  }

  String _selectedReciterCode() => PlayerAudioService().selectedReciter.code;

  String _selectedReciterName() {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return PlayerAudioService().selectedReciter.displayName(
      arabic: isArabicLocalizations(localizations),
    );
  }

  void _loadListeningResumeState() {
    final List<ResumeStateEntry> entries =
        ResumeStateDB().box.values
            .whereType<ResumeStateEntry>()
            .where((entry) => entry.kind == 'listening' && entry.surah != null)
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (entries.isEmpty) return;

    final ResumeStateEntry entry = entries.first;
    final int surah = entry.surah!.clamp(1, 114).toInt();
    final Duration position = Duration(
      milliseconds: (entry.positionMillis ?? 0).clamp(0, 1 << 31).toInt(),
    );
    _selectedSurah = surah;
    _position = position;
    _positionSampledAt = null;
    _pendingInitialResumePosition = position > Duration.zero ? position : null;
    _setActiveAyahValue(entry.ayah);
    _syncProgressNotifier();
  }

  void _consumeResumeListeningRequest() {
    final dynamic value = SettingsDB().get('resumeListeningRequestAt');
    if (value == null) return;
    unawaited(SettingsDB().delete('resumeListeningRequestAt'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_playSurah(_selectedSurah));
    });
  }

  void _persistListeningResume({bool force = false}) {
    final DateTime now = DateTime.now();
    if (!force &&
        _lastListeningPersistedAt != null &&
        now.difference(_lastListeningPersistedAt!) <
            const Duration(seconds: 5)) {
      return;
    }
    _lastListeningPersistedAt = now;
    final Duration position = _estimatedAudioPosition();
    final int ayah = _displayedAyah(_activeAyahForPosition(position));
    unawaited(
      ResumeStateDB().put(
        'listening:last',
        ResumeStateEntry(
          id: 'listening:last',
          kind: 'listening',
          surah: _selectedSurah,
          ayah: ayah,
          positionMillis: position.inMilliseconds,
          title: _surahName(_selectedSurah),
          subtitle: 'Ayah $ayah - ${_selectedReciterName()}',
          updatedAt: now,
        ),
      ),
    );
  }

  Future<String> _surahStreamUrl(int surah) =>
      PlayerAudioService().getSurahUrl(surah);

  void _syncTimingForCurrentSelection() {
    final String reciterCode = _selectedReciterCode();
    if (_timingSurah == _selectedSurah && _timingReciterCode == reciterCode) {
      return;
    }
    final int targetSurah = _selectedSurah;
    _timingSurah = targetSurah;
    _timingReciterCode = reciterCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _selectedSurah != targetSurah ||
          _selectedReciterCode() != reciterCode) {
        return;
      }
      unawaited(
        _loadTimingForSelection(surah: targetSurah, reciterCode: reciterCode),
      );
    });
  }

  Future<void> _loadTimingForSelection({
    required int surah,
    String? reciterCode,
  }) async {
    final String effectiveReciterCode = reciterCode ?? _selectedReciterCode();
    final int generation = ++_timingLoadGeneration;

    _safeSetState(() {
      _timingSurah = surah;
      _timingReciterCode = effectiveReciterCode;
      _surahTiming = null;
      _setActiveAyahValue(null);
      _selectionTimingSupported = null;
      _selectionTimingInstallState = null;
      _isTimingLoading = true;
    });

    final DownloadableResource? timingResource =
        await SurahTimingRepository.timingResourceForReciter(
          effectiveReciterCode,
        );
    if (!mounted || generation != _timingLoadGeneration) return;

    if (timingResource == null) {
      _safeSetState(() {
        _selectionTimingSupported = false;
        _selectionTimingInstallState = null;
        _isTimingLoading = false;
      });
      return;
    }

    final ResourceInstallState installState = ResourceInstallStore.instance
        .installStateFor(timingResource);
    _safeSetState(() {
      _selectionTimingSupported = true;
      _selectionTimingInstallState = installState;
    });

    if (installState == ResourceInstallState.notDownloaded) {
      _safeSetState(() {
        _isTimingLoading = false;
      });
      return;
    }

    final SurahTiming? timing = await _timingRepository.loadSurahTiming(
      reciterCode: effectiveReciterCode,
      surahNumber: surah,
    );
    if (!mounted || generation != _timingLoadGeneration) return;

    _safeSetState(() {
      _surahTiming = timing;
      _selectionTimingSupported = true;
      _selectionTimingInstallState = installState;
      _isTimingLoading = false;
    });
    _setActiveAyahForPosition(_positionForProgress());
  }

  Future<bool> _ensureTimingReadyForAyahText() async {
    final String reciterCode = _selectedReciterCode();
    final DownloadableResource? timingResource =
        await SurahTimingRepository.timingResourceForReciter(reciterCode);
    if (!mounted) return false;

    if (timingResource == null) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      _safeSetState(() {
        _selectionTimingSupported = false;
        _selectionTimingInstallState = null;
        _surahTiming = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timingsUnavailable)));
      return false;
    }

    if (!ResourceInstallStore.instance.isInstalled(timingResource)) {
      final bool downloaded = await _promptDownloadTimingResource(
        timingResource,
      );
      if (!downloaded || !mounted) return false;
    }

    await _loadTimingForSelection(
      surah: _selectedSurah,
      reciterCode: reciterCode,
    );
    if (!mounted) return false;
    if (_surahTiming == null) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timingsUnavailableSurah)));
      return false;
    }
    return true;
  }

  Future<bool> _promptDownloadTimingResource(
    DownloadableResource resource,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? shouldDownload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.downloadTimings),
        content: Text(
          l10n.reciterNeedsTimings(prettyBytes(resource.sizeBytes)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.download),
          ),
        ],
      ),
    );
    if (shouldDownload != true) return false;

    try {
      await ResourceDownloadService.instance.downloadAndInstall(resource);
      _timingRepository.clearCache();
      if (mounted) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.installedLabel(resource.name))),
        );
      }
      return true;
    } on ResourceInstallException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.unableToInstallTimings)));
      }
    }
    return false;
  }

  int? _activeAyahForPosition(Duration position) {
    final SurahTiming? timing = _surahTiming;
    if (timing == null) return null;
    final int? timedAyah = timing.timingForPosition(position)?.ayahNumber;
    if (timedAyah != null) return timedAyah;
    if (timing.ayahs.isEmpty) return null;
    return position < timing.ayahs.first.start
        ? 1
        : timing.ayahs.last.ayahNumber;
  }

  bool _setActiveAyahForPosition(Duration position) {
    final int? nextAyah = _activeAyahForPosition(position);
    return _setActiveAyahValue(nextAyah);
  }

  bool _setActiveAyahValue(int? ayah) {
    if (ayah == _activeAyah && _activeAyahNotifier.value == ayah) {
      return false;
    }
    _activeAyah = ayah;
    if (_activeAyahNotifier.value != ayah) {
      _activeAyahNotifier.value = ayah;
    }
    return true;
  }

  void _updateActiveAyah(Duration position) {
    _setActiveAyahForPosition(position);
  }

  int _wrapSurah(int value) {
    if (value < 1) return 114;
    if (value > 114) return 1;
    return value;
  }

  int _randomSurah({required int excluding}) {
    int candidate = excluding;
    while (candidate == excluding) {
      candidate = _random.nextInt(114) + 1;
    }
    return candidate;
  }

  Future<File> _surahFile(int surah) async {
    return _downloads.surahFile(surah);
  }

  Future<bool> _hasOfflineFile(int surah) async {
    return _downloads.hasSurah(surah);
  }

  Future<void> _refreshDownloadState() async {
    final bool isDownloaded = await _hasOfflineFile(_selectedSurah);
    _safeSetState(() {
      _isDownloaded = isDownloaded;
    });
  }

  Future<void> _setPlaybackRate(double value) async {
    final double rate = _useAudioplayersFallback ? 1.0 : value.clamp(0.5, 2.0);
    final Duration currentPosition = _useAudioplayersFallback
        ? await _fallbackAudio.getCurrentPosition() ?? _position
        : _justAudio.position;
    _safeSetState(() {
      _position = currentPosition;
      _positionSampledAt = _isPlaying ? DateTime.now() : null;
      _playbackRate = rate;
    });
    _syncProgressNotifier();
    await SettingsDB().put("playbackRate", rate);

    if (_useAudioplayersFallback) {
      await _fallbackAudio.setPlaybackRate(rate);
    } else {
      await _justAudio.setSpeed(rate);
    }
  }

  Future<void> _selectReciter(PlayerReciter reciter) async {
    if (reciter.code == _selectedReciterCode()) return;
    final bool shouldResumePlayback = _isPlaying || _isLoading;

    await SettingsDB().put("player_reciter", reciter.code);
    _loadedSurah = null;
    _loadedFromOffline = null;
    _loadedReciterCode = null;
    await _refreshDownloadState();

    if (shouldResumePlayback) {
      await _playSurah(_selectedSurah, forceRestart: true);
      return;
    }

    await _stopCurrentTrack();
    _safeSetState(() {
      _position = Duration.zero;
      _positionSampledAt = null;
      _duration = Duration.zero;
      _playingFromOffline = false;
    });
    _syncProgressNotifier();
    unawaited(
      _loadTimingForSelection(surah: _selectedSurah, reciterCode: reciter.code),
    );
  }

  Future<void> _startTrack({
    required int surah,
    required bool playOffline,
  }) async {
    final Duration? initialSeek = _pendingInitialResumePosition;
    final String surahOptionLabel = AppLocalizations.of(context)!.surahOption;
    _pendingInitialResumePosition = null;
    if (_useAudioplayersFallback) {
      await _fallbackAudio.stop();
      _safeSetState(() {
        _position = Duration.zero;
        _positionSampledAt = null;
        _duration = Duration.zero;
        _setActiveAyahValue(null);
      });
      _syncProgressNotifier();

      if (playOffline) {
        final File file = await _surahFile(surah);
        await _fallbackAudio.play(ap.DeviceFileSource(file.path));
      } else {
        final String url = await _surahStreamUrl(surah);
        await _fallbackAudio.play(ap.UrlSource(url));
      }
      await _fallbackAudio.setPlaybackRate(_playbackRate);
      if (initialSeek != null && initialSeek > Duration.zero) {
        await _fallbackAudio.seek(initialSeek);
        _safeSetState(() {
          _position = initialSeek;
          _positionSampledAt = null;
        });
        _syncProgressNotifier();
      }
      return;
    }

    final Uri sourceUri;
    if (playOffline) {
      final File file = await _surahFile(surah);
      sourceUri = Uri.file(file.path);
    } else {
      final String url = await _surahStreamUrl(surah);
      sourceUri = Uri.parse(url);
    }

    _safeSetState(() {
      _position = Duration.zero;
      _positionSampledAt = null;
      _duration = Duration.zero;
      _setActiveAyahValue(null);
    });
    _syncProgressNotifier();

    await _justAudio.setAudioSource(
      ja.AudioSource.uri(
        sourceUri,
        tag: MediaItem(
          id: 'surah-$surah-${playOffline ? "offline" : "stream"}',
          album: 'eQuran',
          title: _localizedSurahName(surah),
          artist: _selectedReciterName(),
          displayDescription: '$surahOptionLabel $surah',
          artUri: Uri.parse('asset:///assets/media/images/icon.webp'),
        ),
      ),
    );
    await _justAudio.setSpeed(_playbackRate);
    if (initialSeek != null && initialSeek > Duration.zero) {
      await _justAudio.seek(initialSeek);
      _safeSetState(() {
        _position = initialSeek;
        _positionSampledAt = null;
      });
      _syncProgressNotifier();
    }
    unawaited(_justAudio.play());
  }

  Future<void> _resumeCurrentTrack() async {
    if (_useAudioplayersFallback) {
      final Duration currentPosition =
          await _fallbackAudio.getCurrentPosition() ?? _position;
      _safeSetState(() {
        _position = currentPosition;
        _positionSampledAt = null;
      });
      _syncProgressVisualPolicy(syncPosition: true);
      await _fallbackAudio.resume();
      await _fallbackAudio.setPlaybackRate(_playbackRate);
    } else {
      final Duration currentPosition = _justAudio.position;
      _safeSetState(() {
        _position = currentPosition;
        _positionSampledAt = null;
      });
      _syncProgressVisualPolicy(syncPosition: true);
      unawaited(_justAudio.play());
      await _justAudio.setSpeed(_playbackRate);
    }
  }

  Future<void> _pauseCurrentTrack() async {
    if (_useAudioplayersFallback) {
      await _fallbackAudio.pause();
    } else {
      await _justAudio.pause();
    }
    final Duration currentPosition = _useAudioplayersFallback
        ? await _fallbackAudio.getCurrentPosition() ?? _position
        : _justAudio.position;
    _safeSetState(() {
      _position = currentPosition;
      _positionSampledAt = null;
      _isPlaying = false;
      _isPaused = true;
    });
    await AndroidAudioDisplayMode.setAudioPlaybackActive(false);
    _syncProgressVisualPolicy(syncPosition: true);
    _persistListeningResume(force: true);
  }

  Future<void> _stopCurrentTrack() async {
    if (_useAudioplayersFallback) {
      await _fallbackAudio.stop();
    } else {
      await _justAudio.stop();
    }
    _safeSetState(() {
      _isPlaying = false;
      _isPaused = false;
      _setActiveAyahValue(null);
      _showAyahText = false;
    });
    await _setKeepScreenOn(false);
    await AndroidAudioDisplayMode.setAudioPlaybackActive(false);
    _syncProgressVisualPolicy();
    _persistListeningResume(force: true);
  }

  Future<void> _setSleepTimer(
    Duration duration,
    String label, {
    String mode = _sleepTimerDurationMode,
    bool startPlayback = true,
  }) async {
    if (duration <= Duration.zero) return;
    _sleepTimer?.cancel();
    final DateTime endsAt = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      await _stopCurrentTrack();
      _safeSetState(() {
        _sleepTimer = null;
        _sleepTimerEndsAt = null;
        _sleepTimerLabel = null;
        _sleepTimerMode = null;
      });
    });
    _safeSetState(() {
      _sleepTimerEndsAt = endsAt;
      _sleepTimerLabel = label;
      _sleepTimerMode = mode;
    });
    if (startPlayback) {
      await _startOrContinuePlaybackForSleepTimer();
    }
  }

  Future<void> _setSleepTimerUntil(
    Duration target,
    String label, {
    required String mode,
    bool startPlayback = true,
  }) async {
    final Duration currentPosition = _estimatedAudioPosition();
    final Duration remaining = target - currentPosition;
    await _setSleepTimer(
      remaining,
      label,
      mode: mode,
      startPlayback: startPlayback,
    );
  }

  Future<void> _startOrContinuePlaybackForSleepTimer() async {
    if (_isPlaying || _isLoading) return;
    if (_isPaused || _loadedSurah == _selectedSurah) {
      await _resumeCurrentTrack();
      return;
    }
    await _playSurah(_selectedSurah);
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _safeSetState(() {
      _sleepTimer = null;
      _sleepTimerEndsAt = null;
      _sleepTimerLabel = null;
      _sleepTimerMode = null;
    });
  }

  String _sleepTimerSummary() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DateTime? endsAt = _sleepTimerEndsAt;
    if (endsAt == null) return l10n.off;
    final Duration remaining = endsAt.difference(DateTime.now());
    if (remaining.isNegative) return l10n.sleepingSoon;
    final int minutes =
        remaining.inMinutes + (remaining.inSeconds % 60 == 0 ? 0 : 1);
    return l10n.sleepingInMinutes(minutes);
  }

  String _sleepTimerOptionsSubtitle() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_sleepTimerEndsAt != null) return _sleepTimerSummary();
    if (_sleepTimerMode == _sleepTimerEndSurahMode) {
      return l10n.pendingLabel(_sleepTimerLabel ?? l10n.endOfSurah);
    }
    return l10n.off;
  }

  void _clearScheduledSleepTimer({bool keepMode = false}) {
    _sleepTimer?.cancel();
    _safeSetState(() {
      _sleepTimer = null;
      _sleepTimerEndsAt = null;
      if (!keepMode) {
        _sleepTimerLabel = null;
        _sleepTimerMode = null;
      }
    });
  }

  void _rescheduleEndOfSurahSleepTimer() {
    if (_sleepTimerMode != _sleepTimerEndSurahMode) return;
    if (_duration <= Duration.zero) return;
    final Duration remaining = _duration - _estimatedAudioPosition();
    if (remaining <= Duration.zero) {
      _cancelSleepTimer();
      return;
    }
    unawaited(
      _setSleepTimer(
        remaining,
        AppLocalizations.of(context)!.endOfSurah,
        mode: _sleepTimerEndSurahMode,
        startPlayback: false,
      ),
    );
  }

  Future<void> _applySleepTimerSelection(String value) async {
    if (value.startsWith('duration:')) {
      final int? minutes = int.tryParse(value.substring('duration:'.length));
      if (minutes == null) return;
      await _setSleepTimer(
        Duration(minutes: minutes),
        AppLocalizations.of(context)!.minutesShort(minutes),
        mode: _sleepTimerDurationMode,
      );
      return;
    }

    if (value == _sleepTimerEndSurahMode) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      _safeSetState(() {
        _sleepTimerLabel = l10n.endOfSurah;
        _sleepTimerMode = _sleepTimerEndSurahMode;
      });
      if (_duration > Duration.zero) {
        await _setSleepTimerUntil(
          _duration,
          l10n.endOfSurah,
          mode: _sleepTimerEndSurahMode,
        );
      } else {
        await _startOrContinuePlaybackForSleepTimer();
      }
    }
  }

  Future<void> _seekCurrentTrack(Duration position) async {
    if (_useAudioplayersFallback) {
      await _fallbackAudio.seek(position);
    } else {
      await _justAudio.seek(position);
    }
    _persistListeningResume(force: true);
  }

  Future<void> _playSurah(int surah, {bool forceRestart = false}) async {
    if (forceRestart) {
      _pendingInitialResumePosition = null;
    }
    final int previousSurah = _selectedSurah;
    final String reciterCode = _selectedReciterCode();
    unawaited(_loadTimingForSelection(surah: surah, reciterCode: reciterCode));
    _safeSetState(() {
      _selectedSurah = surah;
      _isLoading = true;
    });
    if (_sleepTimerMode == _sleepTimerEndSurahMode &&
        (previousSurah != surah || forceRestart)) {
      _sleepTimerLabel = AppLocalizations.of(context)!.endOfSurah;
      _clearScheduledSleepTimer(keepMode: true);
    }

    try {
      final bool shouldPlayOffline = await _hasOfflineFile(surah);

      _safeSetState(() {
        _selectedSurah = surah;
        _isDownloaded = shouldPlayOffline;
        _playingFromOffline = shouldPlayOffline;
      });

      final bool sameTrack =
          _loadedSurah == surah &&
          _loadedFromOffline == shouldPlayOffline &&
          _loadedReciterCode == reciterCode &&
          !forceRestart;

      if (sameTrack && _isPaused) {
        await _resumeCurrentTrack();
      } else {
        await _startTrack(surah: surah, playOffline: shouldPlayOffline);
        _loadedSurah = surah;
        _loadedFromOffline = shouldPlayOffline;
        _loadedReciterCode = reciterCode;
      }
    } catch (_) {
      if (mounted) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.unableToPlaySurahAudio)));
      }
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;
    if (_isPlaying) {
      await _pauseCurrentTrack();
      return;
    }
    await _playSurah(_selectedSurah);
  }

  Future<void> _playPrevious() async {
    await _playSurah(_wrapSurah(_selectedSurah - 1), forceRestart: true);
  }

  Future<void> _playNext() async {
    final int nextSurah = _shuffleEnabled
        ? _randomSurah(excluding: _selectedSurah)
        : _wrapSurah(_selectedSurah + 1);
    await _playSurah(nextSurah, forceRestart: true);
  }

  Future<void> _seek(double fraction) async {
    if (_duration.inMilliseconds <= 0) return;
    final int ms = (_duration.inMilliseconds * fraction).round();
    await _seekCurrentTrack(Duration(milliseconds: ms));
  }

  Duration _positionForProgress() {
    return _scrubPreviewPosition ?? _estimatedAudioPosition();
  }

  void _revealProgressThumb() {
    _progressThumbTimer?.cancel();
    if (!_showProgressThumb && mounted) {
      setState(() {
        _showProgressThumb = true;
      });
    }
  }

  void _hideProgressThumbSoon() {
    _progressThumbTimer?.cancel();
    _progressThumbTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _showProgressThumb = false;
      });
    });
  }

  Widget _buildProgressSlider({
    required BuildContext context,
    required double progress,
  }) {
    final SliderThemeData sliderTheme = AppSliderTheme.standard(context);
    return SliderTheme(
      data: sliderTheme.copyWith(
        overlayColor: _showProgressThumb
            ? sliderTheme.overlayColor
            : Colors.transparent,
      ),
      child: Slider(
        value: (_pendingSeekProgress ?? progress).clamp(0.0, 1.0),
        onChangeStart: (value) {
          AndroidAudioDisplayMode.notifyUserActivity();
          FrameRatePolicyManager.instance.setUserDragging(
            true,
            source: _playerPageSeekSource,
            reason: 'full_player_seek_start',
          );
          unawaited(AndroidAudioDisplayMode.setLowFpsSuppressed(true));
          _revealProgressThumb();
          _safeSetState(() {
            _isScrubbing = true;
            _pendingSeekProgress = value;
            final int pendingMs = (_duration.inMilliseconds * value).round();
            _scrubPreviewPosition = Duration(milliseconds: pendingMs);
            _setActiveAyahForPosition(_scrubPreviewPosition!);
          });
          _syncProgressVisualPolicy();
        },
        onChanged: (value) {
          _revealProgressThumb();
          _safeSetState(() {
            _pendingSeekProgress = value;
            final int pendingMs = (_duration.inMilliseconds * value).round();
            _scrubPreviewPosition = Duration(milliseconds: pendingMs);
            _setActiveAyahForPosition(_scrubPreviewPosition!);
          });
        },
        onChangeEnd: (value) async {
          _hideProgressThumbSoon();
          final int pendingMs = (_duration.inMilliseconds * value).round();
          try {
            await _seek(value);
          } finally {
            final bool shouldResumeVisualEstimate = _isPlaying;
            _safeSetState(() {
              _position = Duration(milliseconds: pendingMs);
              _positionSampledAt = shouldResumeVisualEstimate
                  ? DateTime.now()
                  : null;
              _isScrubbing = false;
              _pendingSeekProgress = null;
              _scrubPreviewPosition = null;
            });
            _updateActiveAyah(Duration(milliseconds: pendingMs));
            _syncProgressVisualPolicy(syncPosition: true);
            _persistListeningResume(force: true);
            FrameRatePolicyManager.instance.setUserDragging(
              false,
              source: _playerPageSeekSource,
              reason: 'full_player_seek_end',
            );
            unawaited(AndroidAudioDisplayMode.setLowFpsSuppressed(false));
          }
        },
      ),
    );
  }

  Widget _buildProgressSliderListenable(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: _progressNotifier,
        builder: (context, progress, _) {
          return _buildProgressSlider(context: context, progress: progress);
        },
      ),
    );
  }

  Future<void> _selectSurah(int? surah) async {
    if (surah == null) return;
    await _playSurah(surah, forceRestart: true);
  }

  Widget _buildSurahSelectionList({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool closeOnSelect,
    ScrollController? scrollController,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      itemCount: 114,
      itemBuilder: (context, index) {
        final int surah = index + 1;
        final bool isSelected = surah == _selectedSurah;
        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.transparent,
          tileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
          selectedColor: colorScheme.onSurface,
          textColor: colorScheme.onSurface,
          iconColor: colorScheme.onSurfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          onTap: () async {
            if (closeOnSelect) {
              Navigator.of(context).pop(surah);
              return;
            }
            await _selectSurah(surah);
          },
          leading: SurahNumberBadge(
            number: surah,
            size: 38,
            active: isSelected,
          ),
          title: Text(localizedSurahName(l10n, surah)),
          subtitle: Text('${l10n.surahOption} $surah'),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
              : null,
        );
      },
    );
  }

  Future<void> _openSurahPickerSheet() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool useSideSheet = screenSize.width >= 700;
    final int? selectedSurah = await _withProgressVisualsPaused(() {
      if (useSideSheet) {
        return showDialog<int>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            final double sheetWidth = min(430.0, screenSize.width * 0.46);
            return Dialog(
              alignment: Alignment.centerRight,
              insetPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SizedBox(
                width: sheetWidth,
                height: min(720.0, screenSize.height - 48),
                child: Material(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.queue_music_rounded),
                        title: Text(
                          l10n.chooseSurah,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: l10n.close,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildSurahSelectionList(
                          theme: theme,
                          colorScheme: colorScheme,
                          closeOnSelect: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      return showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.large),
          ),
        ),
        builder: (context) {
          final double screenHeight = MediaQuery.sizeOf(context).height;
          final double initialSize = min(
            0.62,
            520 / screenHeight,
          ).clamp(0.42, 0.62).toDouble();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialSize,
            minChildSize: 0.32,
            maxChildSize: 0.94,
            builder: (context, scrollController) {
              return Material(
                color: colorScheme.surfaceContainer,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.queue_music_rounded),
                      title: Text(
                        l10n.chooseSurah,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _buildSurahSelectionList(
                        theme: theme,
                        colorScheme: colorScheme,
                        closeOnSelect: true,
                        scrollController: scrollController,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });

    await _selectSurah(selectedSurah);
  }

  Future<void> _showUpgradedSleepTimerSheet() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final EquranColors colors = context.equranColors;

    int minutes = 15;
    if (_sleepTimerEndsAt != null) {
      minutes = _sleepTimerEndsAt!
          .difference(DateTime.now())
          .inMinutes
          .clamp(1, 120);
    }
    bool endOfSurah = _sleepTimerMode == _sleepTimerEndSurahMode;

    final TextEditingController textController = TextEditingController(
      text: '$minutes',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.large),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void increment(int val) {
              int current = int.tryParse(textController.text) ?? 15;
              current = (current + val).clamp(1, 240);
              textController.text = '$current';
              setSheetState(() {
                minutes = current;
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(AppRadii.medium),
                        ),
                        child: Icon(
                          Icons.bedtime_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sleep Timer Settings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Numeric Minute Picker Container
                  Card(
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Numeric Minutes Duration',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              // Minus Button
                              IconButton(
                                onPressed: endOfSurah
                                    ? null
                                    : () => increment(-5),
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                ),
                                color: colorScheme.primary,
                                iconSize: 28,
                              ),
                              // Text Field Input
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: TextField(
                                    controller: textController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    enabled: !endOfSurah,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: endOfSurah
                                              ? colorScheme.onSurfaceVariant
                                                    .withAlpha(128)
                                              : colorScheme.onSurface,
                                        ),
                                    decoration: const InputDecoration(
                                      suffixText: 'min',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      final int? parsed = int.tryParse(val);
                                      if (parsed != null) {
                                        minutes = parsed.clamp(1, 240);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              // Plus Button
                              IconButton(
                                onPressed: endOfSurah
                                    ? null
                                    : () => increment(5),
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                                color: colorScheme.primary,
                                iconSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // End of Surah Toggle Card
                  Card(
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: SwitchListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                      secondary: Icon(
                        Icons.queue_music_rounded,
                        color: endOfSurah
                            ? colorScheme.primary
                            : colors.textSecondary,
                      ),
                      title: const Text(
                        'End of Surah',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text(
                        'Auto-kill the stream exactly when the current track finishes',
                      ),
                      value: endOfSurah,
                      onChanged: (val) {
                        setSheetState(() {
                          endOfSurah = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Apply / Stop Buttons
                  Row(
                    children: <Widget>[
                      if (_sleepTimerEndsAt != null ||
                          _sleepTimerMode != null) ...<Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _cancelSleepTimer();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Turn Off'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (endOfSurah) {
                              await _applySleepTimerSelection(
                                _sleepTimerEndSurahMode,
                              );
                            } else {
                              final int val =
                                  int.tryParse(textController.text) ?? minutes;
                              await _setSleepTimer(
                                Duration(minutes: val),
                                l10n.minutesShort(val),
                                mode: _sleepTimerDurationMode,
                              );
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Set Timer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(textController.dispose);
  }

  Future<void> _showPlayerOptionsSheet() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    await _withProgressVisualsPaused(() {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainer,
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.large),
          ),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              Future<void> selectReciter() async {
                final PlayerReciter? selected =
                    await _showReciterPickerDialog();
                if (selected == null || !mounted) return;
                await _selectReciter(selected);
                if (sheetContext.mounted) setSheetState(() {});
              }

              Future<void> openSurahPicker() async {
                Navigator.of(sheetContext).pop();
                await _openSurahPickerSheet();
              }

              Future<void> handleDownload() async {
                if (_isDownloaded) {
                  await _confirmDeleteSurahDownload();
                } else if (!_isDownloading) {
                  await _downloadSurah();
                }
                if (sheetContext.mounted) setSheetState(() {});
              }

              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.68,
                minChildSize: 0.38,
                maxChildSize: 0.92,
                builder: (context, scrollController) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(18),
                              borderRadius: BorderRadius.circular(
                                AppRadii.medium,
                              ),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.playerOptions,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildPlayerOptionsSection(
                        context: context,
                        title: l10n.recitation,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.queue_music_rounded),
                            title: Text(l10n.surahOption),
                            subtitle: Text(_localizedSurahName(_selectedSurah)),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: openSurahPicker,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.record_voice_over_rounded,
                            ),
                            title: Text(l10n.reciterOption),
                            subtitle: Text(_selectedReciterName()),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: selectReciter,
                          ),
                          _buildSliderOption(
                            context: context,
                            title: l10n.playbackSpeed,
                            subtitle: '${_playbackRate.toStringAsFixed(2)}x',
                            value: _playbackRate,
                            min: 0.5,
                            max: 2.0,
                            divisions: 6,
                            label: '${_playbackRate.toStringAsFixed(2)}x',
                            onChanged: _useAudioplayersFallback
                                ? null
                                : (value) async {
                                    final double normalized =
                                        (value * 4).round() / 4;
                                    await _setPlaybackRate(normalized);
                                    if (sheetContext.mounted) {
                                      setSheetState(() {});
                                    }
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildPlayerOptionsSection(
                        context: context,
                        title: l10n.offline,
                        children: <Widget>[
                          ListTile(
                            leading: _isDownloading
                                ? SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    _isDownloaded
                                        ? Icons.check_circle_rounded
                                        : Icons.download_rounded,
                                    color: _isDownloaded
                                        ? colorScheme.primary
                                        : null,
                                  ),
                            title: Text(
                              _isDownloaded
                                  ? l10n.deleteDownloadedMp3
                                  : l10n.downloadMp3,
                            ),
                            subtitle: Text(
                              _isDownloaded
                                  ? l10n.availableOffline
                                  : l10n.notSaved,
                            ),
                            onTap: _isDownloading ? null : handleDownload,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildPlayerOptionsSection(
                        context: context,
                        title: l10n.playback,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.bedtime_outlined),
                            title: Text(l10n.sleepTimerOption),
                            subtitle: Text(_sleepTimerOptionsSubtitle()),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () async {
                              await _showUpgradedSleepTimerSheet();
                              if (sheetContext.mounted) {
                                setSheetState(() {});
                              }
                            },
                          ),
                          SwitchListTile(
                            secondary: const Icon(Icons.shuffle_rounded),
                            title: Text(l10n.shuffleOption),
                            subtitle: Text(
                              _shuffleEnabled ? l10n.enabled : l10n.disabled,
                            ),
                            value: _shuffleEnabled,
                            onChanged: (value) {
                              setState(() {
                                _shuffleEnabled = value;
                              });
                              setSheetState(() {});
                            },
                          ),
                          SwitchListTile(
                            secondary: const Icon(Icons.repeat_rounded),
                            title: Text(l10n.loopCurrentSurah),
                            subtitle: Text(
                              _loopEnabled ? l10n.enabled : l10n.disabled,
                            ),
                            value: _loopEnabled,
                            onChanged: (value) {
                              setState(() {
                                _loopEnabled = value;
                              });
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  Widget _buildPlayerOptionsSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double>? onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(subtitle),
          Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value.clamp(min, max).toDouble(),
            label: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<PlayerReciter?> _showReciterPickerDialog() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<PlayerReciter> reciters = PlayerReciter.values.toList()
      ..sort(
        (a, b) =>
            a.englishName.toLowerCase().compareTo(b.englishName.toLowerCase()),
      );

    final Map<String, bool> downloadedReciters = {};
    for (final reciter in reciters) {
      downloadedReciters[reciter.code] = await _downloads.hasSurahForReciter(
        _selectedSurah,
        reciter.code,
      );
    }

    if (!mounted) return null;

    return showDialog<PlayerReciter>(
      context: context,
      builder: (context) => AppSelectionDialog<PlayerReciter>(
        title: l10n.reciterOption,
        icon: Icons.record_voice_over_rounded,
        selectedValue: PlayerAudioService().selectedReciter,
        options: reciters
            .map(
              (reciter) => AppSelectionOption<PlayerReciter>(
                value: reciter,
                title: reciter.displayName(arabic: isArabicLocalizations(l10n)),
                leading: downloadedReciters[reciter.code] == true
                    ? const Icon(
                        Icons.offline_pin_rounded,
                        color: Colors.greenAccent,
                      )
                    : const Icon(Icons.record_voice_over_outlined, size: 20),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _downloadSurah() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String surahName = _localizedSurahName(_selectedSurah);
    _safeSetState(() {
      _isDownloading = true;
    });

    try {
      final int notificationId = DownloadNotifications.notificationId(
        'surah-$_selectedSurah',
      );
      final String title = l10n.downloadingName(surahName);
      await DownloadNotifications.progress(
        id: notificationId,
        title: title,
        progress: null,
      );
      await _downloads.downloadSurah(
        _selectedSurah,
        onProgress: (progress) => unawaited(
          DownloadNotifications.progress(
            id: notificationId,
            title: title,
            progress: progress.fraction,
          ),
        ),
      );
      await DownloadNotifications.complete(
        id: notificationId,
        title: l10n.downloadedName(surahName),
      );
      await _refreshDownloadState();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.downloadedName(surahName))));
      }
    } catch (_) {
      await DownloadNotifications.fail(
        id: DownloadNotifications.notificationId('surah-$_selectedSurah'),
        title: l10n.failedDownloadName(surahName),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedDownloadSurahAudio)));
      }
    } finally {
      _safeSetState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _deleteSurahDownloadConfirmed() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String surahName = _localizedSurahName(_selectedSurah);
    try {
      await _downloads.deleteSurah(_selectedSurah);

      if (_playingFromOffline && _loadedSurah == _selectedSurah) {
        await _stopCurrentTrack();
        _loadedSurah = null;
        _loadedFromOffline = null;
        _loadedReciterCode = null;
        _safeSetState(() {
          _position = Duration.zero;
          _positionSampledAt = null;
          _duration = Duration.zero;
          _setActiveAyahValue(null);
          _isPlaying = false;
          _isPaused = false;
          _playingFromOffline = false;
        });
        _syncProgressNotifier();
      }

      await _refreshDownloadState();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deletedMp3Name(surahName))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedDeleteDownloadedSurah)),
        );
      }
    }
  }

  Future<void> _confirmDeleteSurahDownload() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String surahName = _localizedSurahName(_selectedSurah);
    final bool? confirm = await _withProgressVisualsPaused(() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded),
            title: Text(l10n.deleteDownloadedMp3Question),
            content: Text(l10n.removeSurahFromOffline(surahName)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          );
        },
      );
    });

    if (confirm == true) {
      await _deleteSurahDownloadConfirmed();
    }
  }

  @override
  void dispose() {
    PlaybackCacheService.instance.clearActiveTrack();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_setKeepScreenOn(false));
    FrameRatePolicyManager.instance.setPlayerDisposed(
      true,
      reason: 'full_player_disposed',
    );
    FrameRatePolicyManager.instance.resetSource(
      _frameRatePolicySource,
      reason: 'full_player_disposed',
    );
    FrameRatePolicyManager.instance.setPointerActive(
      false,
      source: _playerPagePointerSource,
      reason: 'full_player_disposed',
    );
    FrameRatePolicyManager.instance.setUserDragging(
      false,
      source: _playerPageSeekSource,
      reason: 'full_player_disposed',
    );
    FrameRatePolicyManager.instance.setPlayerDisposed(
      false,
      reason: 'full_player_dispose_complete',
    );
    unawaited(AndroidAudioDisplayMode.setAudioPlaybackActive(false));
    unawaited(AndroidAudioDisplayMode.setVisualProgressActive(false));
    unawaited(AndroidAudioDisplayMode.setLowFpsSuppressed(false));
    _progressThumbTimer?.cancel();
    _sleepTimer?.cancel();
    _stopProgressVisualTicker('dispose');
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _fallbackPositionSubscription?.cancel();
    _fallbackDurationSubscription?.cancel();
    _fallbackStateSubscription?.cancel();
    _fallbackCompleteSubscription?.cancel();

    _justAudio.dispose();
    _fallbackAudio.dispose();
    _progressNotifier.dispose();
    _elapsedNotifier.dispose();
    _activeAyahNotifier.dispose();
    super.dispose();
  }

  void _notifyAudioUserActivity() {
    AndroidAudioDisplayMode.notifyUserActivity();
  }

  Widget _buildAudioInteractionBoundary({required Widget child}) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FrameRatePolicyManager.instance.setPointerActive(
          true,
          source: _playerPagePointerSource,
          reason: 'full_player_pointer_down',
        );
        _notifyAudioUserActivity();
      },
      onPointerMove: (_) => _notifyAudioUserActivity(),
      onPointerUp: (_) {
        FrameRatePolicyManager.instance.setPointerActive(
          false,
          source: _playerPagePointerSource,
          reason: 'full_player_pointer_up',
        );
        _notifyAudioUserActivity();
      },
      onPointerCancel: (_) {
        FrameRatePolicyManager.instance.setPointerActive(
          false,
          source: _playerPagePointerSource,
          reason: 'full_player_pointer_cancel',
        );
        _notifyAudioUserActivity();
      },
      onPointerSignal: (_) => _notifyAudioUserActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _notifyAudioUserActivity();
          return false;
        },
        child: child,
      ),
    );
  }

  String? _timingStatusText() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_isTimingLoading) return l10n.loadingSyncedAyah;
    if (_surahTiming != null) return null;
    if (_selectionTimingSupported == false) {
      return l10n.syncedAyahUnavailableReciter;
    }
    if (_selectionTimingInstallState == ResourceInstallState.notDownloaded) {
      return l10n.downloadTimingsToSyncAyahs;
    }
    if (_selectionTimingSupported == true) {
      return l10n.syncedAyahUnavailableSurah;
    }
    return null;
  }

  Widget _buildActiveAyahCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required int? activeAyah,
  }) {
    final String? statusText = _timingStatusText();
    if (statusText != null) {
      return _buildPlayerMessageCard(
        theme: theme,
        colorScheme: colorScheme,
        message: statusText,
        loading: _isTimingLoading,
      );
    }

    final int ayah = _displayedAyah(activeAyah);
    final bool showTransliteration =
        SettingsDB().get("showTransliteration", defaultValue: false) == true;
    final bool showTranslation =
        SettingsDB().get("enableTranslation", defaultValue: true) == true;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: double.infinity,
          child: ReadQuranCard(
            key: ValueKey<String>('player-ayah-$_selectedSurah-$ayah'),
            currentChapter: _selectedSurah,
            currentVerse: ayah,
            totalVerses: quran.getVerseCount(_selectedSurah),
            juzNumber: quran.getJuzNumber(_selectedSurah, ayah),
            basmala: _selectedSurah != 1 && ayah == 1 && _selectedSurah != 9
                ? quran.basmala
                : null,
            verse: quranVerseText(_selectedSurah, ayah),
            translation: quran.cleanTranslationText(
              quran.getVerseTranslation(
                _selectedSurah,
                ayah,
                translation: quran.Translation.values[_translationIndex()],
              ),
            ),
            transliteration: showTransliteration
                ? _cardTransliterationForAyah(ayah)
                : '',
            showActions: false,
            showTransliteration: showTransliteration,
            showTranslation: showTranslation,
            fontSize: _doubleSetting("fontSize", 31.0),
            fontSizeTranslation: _doubleSetting("fontSizeTranslation", 12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAyahCardListenable({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return ValueListenableBuilder<int?>(
      valueListenable: _activeAyahNotifier,
      builder: (context, activeAyah, _) {
        return RepaintBoundary(
          child: _buildActiveAyahCard(
            theme: theme,
            colorScheme: colorScheme,
            activeAyah: activeAyah,
          ),
        );
      },
    );
  }

  Widget _buildNowPlayingHero({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDesktop,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isArabic = isArabicLocalizations(l10n);
    final int ayahCount = quran.getVerseCount(_selectedSurah);
    final bool offlineReady = _playingFromOffline || _isDownloaded;
    final Color artBackground = Color.alphaBlend(
      context.equranColors.primary.withAlpha(
        theme.brightness == Brightness.dark ? 46 : 30,
      ),
      context.equranColors.mint,
    );
    final EquranColors equranColors = context.equranColors;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 760 : 560),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 34 : 24,
              vertical: isDesktop ? 36 : 30,
            ),
            decoration: BoxDecoration(
              gradient: equranColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadii.large),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: equranColors.primaryStrong.withAlpha(54),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: isDesktop ? 84 : 72,
                  height: isDesktop ? 84 : 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        artBackground,
                        Color.alphaBlend(
                          colorScheme.tertiary.withValues(alpha: 0.10),
                          artBackground,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.36),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.14,
                          child: Image.asset(
                            _playerDesignAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Icon(
                        _isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.play_arrow_rounded,
                        size: isDesktop ? 42 : 36,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    quran.getSurahNameArabic(_selectedSurah),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style:
                        (isDesktop
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineMedium)
                            ?.copyWith(
                              color: equranColors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!isArabic) ...<Widget>[
                  Text(
                    _surahName(_selectedSurah),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style:
                        (isDesktop
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              color: equranColors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  _selectedReciterName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: equranColors.onPrimaryMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _buildNowPlayingChip(
                      theme: theme,
                      colorScheme: colorScheme,
                      icon: Icons.format_list_numbered_rtl_rounded,
                      label: l10n.ayahsCount(ayahCount),
                    ),
                    _buildNowPlayingChip(
                      theme: theme,
                      colorScheme: colorScheme,
                      icon: offlineReady
                          ? Icons.offline_pin_rounded
                          : Icons.cloud_rounded,
                      label: offlineReady ? l10n.offlineReady : l10n.streaming,
                    ),
                    if (_sleepTimerEndsAt != null)
                      _buildNowPlayingChip(
                        theme: theme,
                        colorScheme: colorScheme,
                        icon: Icons.bedtime_outlined,
                        label: _sleepTimerSummary(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingChip({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerMessageCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String message,
    required bool loading,
  }) {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        elevation: theme.brightness == Brightness.light ? 3 : 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          side: BorderSide(
            color: theme.brightness == Brightness.light
                ? colorScheme.primary.withAlpha(28)
                : colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (loading)
                SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: colorScheme.primary,
                  ),
                )
              else
                Icon(
                  Icons.sync_problem_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

  int _displayedAyah([int? activeAyah]) {
    final int ayahCount = quran.getVerseCount(_selectedSurah);
    return (activeAyah ?? _activeAyah ?? 1).clamp(1, ayahCount).toInt();
  }

  int _translationIndex() {
    final dynamic savedIndex = SettingsDB().get("translation", defaultValue: 0);
    if (savedIndex is num) {
      return savedIndex.toInt().clamp(0, quran.Translation.values.length - 1);
    }
    return 0;
  }

  double _doubleSetting(String key, double defaultValue) {
    final dynamic value = SettingsDB().get(key, defaultValue: defaultValue);
    return value is num ? value.toDouble() : defaultValue;
  }

  Future<void> _loadSelectedSurahTransliterations() async {
    final int surah = _selectedSurah;
    final List<String> transliterations = await QuranTransliterationService
        .instance
        .versesForSurah(surah);
    if (!mounted || surah != _selectedSurah) return;
    setState(() {
      _transliterationSurah = surah;
      _surahTransliterationsCache = transliterations;
    });
  }

  String _cardTransliterationForAyah(int ayah) {
    if (_transliterationSurah != _selectedSurah) {
      unawaited(_loadSelectedSurahTransliterations());
      return '';
    }
    if (ayah < 1 || ayah > _surahTransliterationsCache.length) return '';
    return _surahTransliterationsCache[ayah - 1].trim();
  }

  @override
  Widget build(BuildContext context) {
    _syncTimingForCurrentSelection();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final Size mediaSize = mediaQuery.size;
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final bool hasFoldableDisplayFeature = mediaQuery.displayFeatures.any((
          DisplayFeature feature,
        ) {
          return feature.type == DisplayFeatureType.hinge ||
              feature.type == DisplayFeatureType.fold;
        });
        final bool isFoldableLayout = hasFoldableDisplayFeature && width >= 720;
        final bool isLargeLandscapeTablet =
            !hasFoldableDisplayFeature &&
            mediaSize.shortestSide >= 720 &&
            mediaSize.longestSide >= 1180 &&
            mediaSize.width > mediaSize.height;
        final bool isExtraLargeTablet =
            !hasFoldableDisplayFeature &&
            mediaSize.shortestSide >= 900 &&
            width >= 1100;
        final bool isDesktop =
            !isFoldableLayout &&
            (width >= 1250 || isLargeLandscapeTablet || isExtraLargeTablet);
        final bool isCompactWidescreenLayout = isDesktop && width < 1250;
        final double desktopHeightScale = isDesktop
            ? ((height - 540) / 260).clamp(0.78, 1.0).toDouble()
            : 1.0;
        final double desktopBottomBarMinHeight =
            (width >= 1500 ? 132 : 124) * desktopHeightScale;
        final double desktopBottomBarVerticalPadding = 18 * desktopHeightScale;
        final double playerControlIconSize = isDesktop
            ? (34 * desktopHeightScale).clamp(28.0, 34.0).toDouble()
            : 34.0;
        final double secondaryControlIconSize = isDesktop
            ? (26 * desktopHeightScale).clamp(22.0, 26.0).toDouble()
            : 25.0;
        final double secondaryControlSize = isDesktop
            ? (46 * desktopHeightScale).clamp(40.0, 46.0).toDouble()
            : 44.0;
        final double playButtonPadding = isDesktop
            ? (20 * desktopHeightScale).clamp(15.0, 20.0).toDouble()
            : 20.0;
        final double playButtonSize =
            playerControlIconSize + (playButtonPadding * 2);
        final double loadingIndicatorSize = isDesktop
            ? (30 * desktopHeightScale).clamp(24.0, 30.0).toDouble()
            : 30.0;
        final double foldableRightPanelLift = isFoldableLayout
            ? (height * 0.035).clamp(18.0, 32.0).toDouble()
            : 0.0;
        final double maxContentWidth = isDesktop
            ? min(width, 1120.0)
            : isFoldableLayout
            ? min(width, 900.0)
            : 560;
        final double desktopCenterWidth = isCompactWidescreenLayout
            ? (width * 0.54).clamp(380.0, 500.0).toDouble()
            : (width * 0.45).clamp(600.0, 740.0).toDouble();
        final double timeLabelWidth = _duration.inHours > 0 ? 76.0 : 56.0;
        final AppLocalizations l10n = AppLocalizations.of(context)!;

        Widget buildTimeLabel(
          Duration value, {
          TextAlign textAlign = TextAlign.left,
        }) {
          return SizedBox(
            width: timeLabelWidth,
            child: Text(
              formatDurationLabel(value),
              maxLines: 1,
              softWrap: false,
              textAlign: textAlign,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        Widget buildElapsedTimeLabel({TextAlign textAlign = TextAlign.left}) {
          return ValueListenableBuilder<Duration>(
            valueListenable: _elapsedNotifier,
            builder: (context, position, _) {
              return buildTimeLabel(position, textAlign: textAlign);
            },
          );
        }

        final header = Padding(
          padding: EdgeInsets.only(bottom: isDesktop ? 14 : 8),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: Navigator.of(context).canPop()
                    ? () => Navigator.of(context).pop()
                    : null,
                style: ResponsiveNav.iconButtonStyle(context),
                icon: Icon(
                  Navigator.of(context).canPop()
                      ? Icons.arrow_back_rounded
                      : Icons.library_music_outlined,
                  size: ResponsiveNav.iconSize(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _localizedSurahName(_selectedSurah),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:
                          (isDesktop
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedReciterName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.chooseSurah,
                onPressed: _openSurahPickerSheet,
                style: ResponsiveNav.iconButtonStyle(context),
                icon: Icon(
                  Icons.queue_music_rounded,
                  size: ResponsiveNav.iconSize(context),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: _showAyahText ? l10n.hideAyahText : l10n.showAyahText,
                onPressed: _toggleAyahText,
                style: ResponsiveNav.iconButtonStyle(context),
                icon: Icon(
                  Icons.menu_book_rounded,
                  color: _showAyahText ? colorScheme.primary : null,
                  size: ResponsiveNav.iconSize(context),
                ),
              ),
            ],
          ),
        );

        Widget buildPlayPauseChild() {
          return SizedBox.square(
            dimension: playerControlIconSize,
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: loadingIndicatorSize,
                      height: loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: playerControlIconSize,
                    ),
            ),
          );
        }

        Widget buildPlayPauseButton() {
          return SizedBox.square(
            dimension: playButtonSize,
            child: FilledButton(
              onPressed: _togglePlayPause,
              style: FilledButton.styleFrom(
                fixedSize: Size.square(playButtonSize),
                minimumSize: Size.square(playButtonSize),
                maximumSize: Size.square(playButtonSize),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: buildPlayPauseChild(),
            ),
          );
        }

        Widget buildSecondaryControl({
          required IconData icon,
          required String tooltip,
          required VoidCallback onPressed,
          bool selected = false,
        }) {
          return IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: secondaryControlIconSize,
            style: IconButton.styleFrom(
              fixedSize: Size.square(secondaryControlSize),
              minimumSize: Size.square(secondaryControlSize),
              maximumSize: Size.square(secondaryControlSize),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.0),
              foregroundColor: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          );
        }

        Widget buildFavoriteButton() {
          return ValueListenableBuilder<Box<dynamic>>(
            valueListenable: FavouritesDB().listener,
            builder: (context, box, _) {
              final bool isFav = box.containsKey('surah_fav:$_selectedSurah');
              return IconButton(
                tooltip: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                onPressed: () async {
                  final String key = 'surah_fav:$_selectedSurah';
                  if (isFav) {
                    await FavouritesDB().delete(key);
                  } else {
                    await FavouritesDB().put(
                      key,
                      DateTime.now().toIso8601String(),
                    );
                  }
                },
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav
                      ? Colors.redAccent
                      : colorScheme.onSurfaceVariant,
                ),
                iconSize: secondaryControlIconSize,
                style: IconButton.styleFrom(
                  fixedSize: Size.square(secondaryControlSize),
                  minimumSize: Size.square(secondaryControlSize),
                  maximumSize: Size.square(secondaryControlSize),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isFav
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.0,
                        ),
                ),
              );
            },
          );
        }

        Widget buildTransportControls({double gap = 12}) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildFavoriteButton(),
                  SizedBox(width: gap),
                  buildSecondaryControl(
                    tooltip: l10n.shuffleOption,
                    onPressed: () {
                      setState(() {
                        _shuffleEnabled = !_shuffleEnabled;
                      });
                    },
                    icon: Icons.shuffle_rounded,
                    selected: _shuffleEnabled,
                  ),
                  SizedBox(width: gap),
                  IconButton(
                    tooltip: l10n.previous,
                    onPressed: _playPrevious,
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: playerControlIconSize,
                  ),
                  SizedBox(width: gap),
                  buildPlayPauseButton(),
                  SizedBox(width: gap),
                  IconButton(
                    tooltip: l10n.next,
                    onPressed: _playNext,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: playerControlIconSize,
                  ),
                  SizedBox(width: gap),
                  buildSecondaryControl(
                    tooltip: l10n.loopCurrentSurah,
                    onPressed: () {
                      setState(() {
                        _loopEnabled = !_loopEnabled;
                      });
                    },
                    icon: Icons.repeat_rounded,
                    selected: _loopEnabled,
                  ),
                  SizedBox(width: gap),
                  buildSecondaryControl(
                    tooltip: l10n.playerOptions,
                    onPressed: _showPlayerOptionsSheet,
                    icon: Icons.more_horiz_rounded,
                  ),
                ],
              ),
            ),
          );
        }

        final Widget nowPlayingHero = _showAyahText
            ? _buildActiveAyahCardListenable(
                theme: theme,
                colorScheme: colorScheme,
              )
            : _buildNowPlayingHero(
                theme: theme,
                colorScheme: colorScheme,
                isDesktop: isDesktop,
              );

        final Widget playbackPanel = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildProgressSliderListenable(context),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildElapsedTimeLabel(),
                buildTimeLabel(_duration, textAlign: TextAlign.right),
              ],
            ),
            const SizedBox(height: 8),
            buildTransportControls(gap: isDesktop ? 10 : 14),
          ],
        );

        final Widget desktopBottomBar = Container(
          padding: EdgeInsets.symmetric(
            horizontal: max(18, 24 * desktopHeightScale),
            vertical: desktopBottomBarVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: desktopBottomBarMinHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: desktopCenterWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    buildTransportControls(gap: 10),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        buildElapsedTimeLabel(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildProgressSliderListenable(context),
                        ),
                        const SizedBox(width: 8),
                        buildTimeLabel(_duration, textAlign: TextAlign.right),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final Widget foldableNowPlaying = Transform.translate(
          offset: Offset(0, -foldableRightPanelLift),
          child: Padding(
            padding: EdgeInsets.only(bottom: foldableRightPanelLift),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: nowPlayingHero),
                const SizedBox(height: 12),
                playbackPanel,
              ],
            ),
          ),
        );

        final Widget mobileNowPlaying = Transform.translate(
          offset: const Offset(0, -6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: nowPlayingHero),
              const SizedBox(height: 10),
              playbackPanel,
            ],
          ),
        );

        final Widget bodyContent = isDesktop
            ? Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: nowPlayingHero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  desktopBottomBar,
                ],
              )
            : isFoldableLayout
            ? foldableNowPlaying
            : mobileNowPlaying;

        return _buildAudioInteractionBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primaryContainer.withValues(alpha: 0.85),
                  colorScheme.tertiaryContainer.withValues(alpha: 0.40),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
                  colorScheme.surface,
                ],
                stops: const <double>[0.0, 0.45, 0.75, 1.0],
              ),
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          header,
                          Expanded(child: ClipRect(child: bodyContent)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
