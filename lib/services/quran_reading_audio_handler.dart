// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:equran/backend/library.dart'
    show
        AudioDownloadService,
        BookmarkDB,
        QuranAudioService,
        ReadingEntry,
        ResumeStateDB,
        ResumeStateEntry;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quran/quran.dart' as quran;

class QuranAudioPosition {
  const QuranAudioPosition({required this.surah, required this.ayah});

  final int surah;
  final int ayah;

  Map<String, int> toJson() => <String, int>{'surah': surah, 'ayah': ayah};

  static QuranAudioPosition? fromExtras(Map<String, dynamic>? extras) {
    if (extras == null) return null;
    final int? surah = _readInt(extras['surah']);
    final int? ayah = _readInt(extras['ayah']);
    if (surah == null || ayah == null) return null;
    return QuranReadingAudioHandler.normalizePosition(surah, ayah);
  }

  @override
  bool operator ==(Object other) {
    return other is QuranAudioPosition &&
        other.surah == surah &&
        other.ayah == ayah;
  }

  @override
  int get hashCode => Object.hash(surah, ayah);
}

class QuranAudioPlaybackError {
  const QuranAudioPlaybackError({
    required this.position,
    required this.message,
    this.code,
  });

  final QuranAudioPosition position;
  final String message;
  final int? code;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surah': position.surah,
      'ayah': position.ayah,
      'message': message,
      if (code != null) 'code': code,
    };
  }
}

class QuranReadingAudioState {
  const QuranReadingAudioState({
    required this.position,
    required this.isContinuous,
    required this.hasActiveQueue,
    this.error,
  });

  final QuranAudioPosition position;
  final bool isContinuous;
  final bool hasActiveQueue;
  final QuranAudioPlaybackError? error;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surah': position.surah,
      'ayah': position.ayah,
      'isContinuous': isContinuous,
      'hasActiveQueue': hasActiveQueue,
      if (error != null) 'error': error!.toJson(),
    };
  }
}

QuranReadingAudioHandler? _quranReadingAudioHandler;

QuranReadingAudioHandler get quranReadingAudioHandler {
  final QuranReadingAudioHandler? handler = _quranReadingAudioHandler;
  if (handler == null) {
    throw StateError('QuranReadingAudioHandler has not been initialized.');
  }
  return handler;
}

Future<QuranReadingAudioHandler> initQuranReadingAudioHandler() async {
  final QuranReadingAudioHandler existing = _quranReadingAudioHandler ??=
      await AudioService.init(
        builder: QuranReadingAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.app.equran.audio',
          androidNotificationChannelName: 'Quran Audio Playback',
          androidNotificationOngoing: true,
        ),
      );
  await existing.initialize();
  return existing;
}

class QuranReadingAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  QuranReadingAudioHandler()
    : _player = ja.AudioPlayer(maxSkipsOnError: _maxSkipsOnQueueError) {
    queue.add(const <MediaItem>[]);
    playbackState.add(_idlePlaybackState);

    _playbackEventSubscription = _player.playbackEventStream.listen(
      _broadcastPlaybackState,
      onError: _handlePlaybackStreamError,
    );
    _currentIndexSubscription = _player.currentIndexStream.listen(
      _handleQueueIndexChanged,
    );
    _playerErrorSubscription = _player.errorStream.listen(
      _handlePlayerException,
    );
  }

  static const String actionPlayAyah = 'playAyah';
  static const String actionSetContinuous = 'setContinuous';
  static const String eventSurahComplete = 'surahComplete';
  static const String eventPlaybackError = 'playbackError';
  static const String stateType = 'quranReadingAudioState';
  static const int _continuousInitialWindowSize = 5;
  static const int _continuousAppendThresholdRemaining = 2;
  static const int _continuousAppendBatchSize = 3;
  static const int _networkRetryCount = 3;
  static const int _maxSkipsOnQueueError = 0;
  static const Duration _networkRetryDelay = Duration(seconds: 1);

  static final PlaybackState _idlePlaybackState = PlaybackState(
    controls: const <MediaControl>[MediaControl.play],
    systemActions: const <MediaAction>{MediaAction.seek},
    processingState: AudioProcessingState.idle,
  );

  final ja.AudioPlayer _player;
  final StreamController<int> _currentAyahIndexController =
      StreamController<int>.broadcast();
  final StreamController<QuranAudioPosition> _currentPositionController =
      StreamController<QuranAudioPosition>.broadcast();
  final StreamController<QuranReadingAudioState> _stateController =
      StreamController<QuranReadingAudioState>.broadcast();
  final StreamController<QuranAudioPlaybackError> _errorController =
      StreamController<QuranAudioPlaybackError>.broadcast();
  final StreamController<QuranAudioPosition> _surahCompleteController =
      StreamController<QuranAudioPosition>.broadcast();

  late StreamSubscription<ja.PlaybackEvent> _playbackEventSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;
  late StreamSubscription<ja.PlayerException> _playerErrorSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  ja.ConcatenatingAudioSource _playlist = ja.ConcatenatingAudioSource(
    children: const <ja.AudioSource>[],
  );
  List<QuranAudioPosition> _queuedPositions = <QuranAudioPosition>[];
  List<MediaItem> _mediaItems = <MediaItem>[];
  QuranAudioPosition _currentPosition = const QuranAudioPosition(
    surah: 1,
    ayah: 1,
  );
  QuranAudioPlaybackError? _currentError;
  bool _initialized = false;
  bool _isContinuous = false;
  bool _isAppending = false;
  bool _isRecoveringFromError = false;
  bool _isCompletingQueue = false;
  bool _resumeAfterFocusLoss = false;
  bool _lastPlaying = false;
  int _operationId = 0;

  Stream<int> get currentAyahIndexStream => _currentAyahIndexController.stream;

  Stream<QuranAudioPosition> get currentPositionStream =>
      _currentPositionController.stream;

  Stream<QuranReadingAudioState> get readingStateStream =>
      _stateController.stream;

  Stream<QuranAudioPlaybackError> get playbackErrorStream =>
      _errorController.stream;

  Stream<QuranAudioPosition> get surahCompleteStream =>
      _surahCompleteController.stream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  QuranAudioPosition get currentPosition => _currentPosition;

  Duration get position => _player.position;

  Duration get duration => _player.duration ?? Duration.zero;

  bool get isContinuous => _isContinuous;

  bool get hasActiveQueue => _mediaItems.isNotEmpty;

  bool get playing => _player.playing;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final AudioSession session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration.speech().copyWith(
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    _interruptionSubscription = session.interruptionEventStream.listen(
      _handleAudioInterruption,
    );

    _currentPosition = _restoreLastKnownPosition();
    _emitCurrentPosition();
    _broadcastReadingState();
  }

  static QuranAudioPosition normalizePosition(int surah, int ayah) {
    final int safeSurah = surah.clamp(1, 114).toInt();
    final int safeAyah = ayah.clamp(1, quran.getVerseCount(safeSurah)).toInt();
    return QuranAudioPosition(surah: safeSurah, ayah: safeAyah);
  }

  @override
  Future<void> play() async {
    if (_mediaItems.isEmpty) {
      await _loadQueueFrom(
        _currentPosition,
        continuous: _isContinuous,
        startPosition: position,
      );
    }
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> stop() async {
    final int operationId = ++_operationId;
    await _player.stop();
    if (operationId != _operationId) return;
    await _player.clearAudioSources();
    _playlist = ja.ConcatenatingAudioSource(children: const <ja.AudioSource>[]);
    _queuedPositions = <QuranAudioPosition>[];
    _mediaItems = <MediaItem>[];
    queue.add(const <MediaItem>[]);
    mediaItem.add(null);
    playbackState.add(_idlePlaybackState);
    _broadcastReadingState();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> skipToNext() async {
    final QuranAudioPosition? nextPosition = _nextPositionInSameSurah(
      _currentPosition,
    );
    if (nextPosition == null) return;

    final int? currentIndex = _player.currentIndex;
    if (currentIndex != null && currentIndex + 1 < _queuedPositions.length) {
      await _player.seek(Duration.zero, index: currentIndex + 1);
      await _player.play();
      return;
    }

    await _loadQueueFrom(
      nextPosition,
      continuous: _isContinuous,
      playWhenReady: true,
    );
  }

  @override
  Future<void> skipToPrevious() async {
    final QuranAudioPosition? previousPosition = _previousPositionInSameSurah(
      _currentPosition,
    );
    if (previousPosition == null) return;

    final int? currentIndex = _player.currentIndex;
    if (currentIndex != null && currentIndex > 0) {
      await _player.seek(Duration.zero, index: currentIndex - 1);
      await _player.play();
      return;
    }

    await _loadQueueFrom(
      previousPosition,
      continuous: _isContinuous,
      playWhenReady: true,
    );
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queuedPositions.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case actionPlayAyah:
        final int? surah = _readInt(extras?['surah']);
        final int? ayah = _readInt(extras?['ayah']);
        if (surah == null || ayah == null) return null;
        final bool continuous = _readBool(extras?['continuous']) ?? false;
        final double? speed = _readDouble(extras?['speed']);
        if (speed != null) {
          await _player.setSpeed(speed);
        }
        await playAyah(surah, ayah, continuous: continuous);
        return null;
      case actionSetContinuous:
        final bool value = _readBool(extras?['value']) ?? false;
        await setContinuous(value);
        return null;
      default:
        return super.customAction(name, extras);
    }
  }

  Future<void> playAyah(int surah, int ayah, {required bool continuous}) async {
    final QuranAudioPosition position = normalizePosition(surah, ayah);
    await _loadQueueFrom(position, continuous: continuous, playWhenReady: true);
  }

  Future<void> setContinuous(bool value) async {
    if (_isContinuous == value && _mediaItems.isNotEmpty) {
      _broadcastReadingState();
      return;
    }

    _isContinuous = value;
    _currentError = null;
    _broadcastReadingState();

    if (_mediaItems.isEmpty) return;

    final bool wasPlaying = _player.playing;
    final Duration currentOffset = _player.position;
    await _loadQueueFrom(
      _currentPosition,
      continuous: value,
      startPosition: currentOffset,
      playWhenReady: wasPlaying,
    );
  }

  Future<void> _loadQueueFrom(
    QuranAudioPosition start, {
    required bool continuous,
    Duration startPosition = Duration.zero,
    bool playWhenReady = false,
  }) async {
    final int operationId = ++_operationId;
    _currentError = null;
    _isContinuous = continuous;
    _currentPosition = start;
    _emitCurrentPosition();
    _broadcastReadingState();

    final List<QuranAudioPosition> positions = _windowFrom(
      start,
      continuous ? _continuousInitialWindowSize : 1,
    );

    final List<ja.AudioSource> sources = <ja.AudioSource>[];
    final List<MediaItem> items = <MediaItem>[];
    for (final QuranAudioPosition position in positions) {
      final MediaItem item = _mediaItemFor(position);
      sources.add(await _audioSourceFor(position, item));
      items.add(item);
      if (operationId != _operationId) return;
    }

    _queuedPositions = positions;
    _mediaItems = items;
    _playlist = ja.ConcatenatingAudioSource(children: sources);
    queue.add(List<MediaItem>.unmodifiable(items));
    mediaItem.add(items.isEmpty ? null : items.first);

    await _player.setAudioSource(
      _playlist,
      initialIndex: 0,
      initialPosition: startPosition,
    );
    if (operationId != _operationId) return;

    _broadcastReadingState();
    if (playWhenReady) {
      await _player.play();
    }
  }

  Future<ja.AudioSource> _audioSourceFor(
    QuranAudioPosition position,
    MediaItem item,
  ) async {
    final AudioDownloadService downloads = AudioDownloadService();
    final File? offlineFile = kIsWeb
        ? null
        : await downloads.playbackAyahFile(position.surah, position.ayah);
    if (!kIsWeb && offlineFile != null && offlineFile.existsSync()) {
      return ja.AudioSource.uri(Uri.file(offlineFile.path), tag: item);
    }

    final String url = await QuranAudioService().getAyahUrl(
      position.surah,
      position.ayah,
    );
    if (!kIsWeb) {
      unawaited(downloads.cacheAyah(position.surah, position.ayah));
    }
    return ja.AudioSource.uri(Uri.parse(url), tag: item);
  }

  MediaItem _mediaItemFor(QuranAudioPosition position) {
    final String surahName = quran.getSurahName(position.surah);
    final reciter = QuranAudioService().selectedReciter;
    return MediaItem(
      id: 'surah_${position.surah}_ayah_${position.ayah}',
      album: 'eQuran',
      title: '$surahName • Ayah ${position.ayah}',
      artist: reciter.englishName,
      displayTitle: '$surahName ${position.ayah}',
      displaySubtitle: reciter.englishName,
      displayDescription: 'Surah ${position.surah}, Ayah ${position.ayah}',
      extras: <String, dynamic>{'surah': position.surah, 'ayah': position.ayah},
    );
  }

  List<QuranAudioPosition> _windowFrom(QuranAudioPosition start, int count) {
    final List<QuranAudioPosition> positions = <QuranAudioPosition>[start];
    QuranAudioPosition? next = start;
    while (positions.length < count) {
      next = _nextPositionInSameSurah(next!);
      if (next == null) break;
      positions.add(next);
    }
    return positions;
  }

  void _handleQueueIndexChanged(int? index) {
    if (index == null || index < 0 || index >= _queuedPositions.length) {
      return;
    }

    final QuranAudioPosition position = _queuedPositions[index];
    if (_currentPosition != position) {
      _currentPosition = position;
      _emitCurrentPosition();
    }
    if (index < _mediaItems.length) {
      mediaItem.add(_mediaItems[index]);
    }
    _persistCurrentPosition(position);
    _broadcastReadingState();
    unawaited(_appendMoreIfNeeded(index));
  }

  Future<void> _appendMoreIfNeeded(int currentIndex) async {
    if (!_isContinuous || _isAppending || _queuedPositions.isEmpty) return;
    final int remainingAfterCurrent =
        _queuedPositions.length - currentIndex - 1;
    if (remainingAfterCurrent > _continuousAppendThresholdRemaining) return;

    final List<QuranAudioPosition> additions = <QuranAudioPosition>[];
    QuranAudioPosition? next = _queuedPositions.last;
    while (additions.length < _continuousAppendBatchSize) {
      next = _nextPositionInSameSurah(next!);
      if (next == null) break;
      additions.add(next);
    }
    if (additions.isEmpty) return;

    _isAppending = true;
    try {
      final List<ja.AudioSource> sources = <ja.AudioSource>[];
      final List<MediaItem> items = <MediaItem>[];
      for (final QuranAudioPosition position in additions) {
        final MediaItem item = _mediaItemFor(position);
        sources.add(await _audioSourceFor(position, item));
        items.add(item);
      }
      await _playlist.addAll(sources);
      _queuedPositions = <QuranAudioPosition>[
        ..._queuedPositions,
        ...additions,
      ];
      _mediaItems = <MediaItem>[..._mediaItems, ...items];
      queue.add(List<MediaItem>.unmodifiable(_mediaItems));
    } catch (error) {
      _emitPlaybackError(
        QuranAudioPlaybackError(
          position: _currentPosition,
          message: 'Unable to load upcoming ayah audio.',
        ),
      );
    } finally {
      _isAppending = false;
    }
  }

  Future<void> _handlePlayerException(ja.PlayerException error) async {
    if (_isRecoveringFromError || _mediaItems.isEmpty) return;
    _isRecoveringFromError = true;

    final QuranAudioPosition retryPosition = _positionForError(error);
    final Duration retryOffset = _player.position;
    bool recovered = false;

    try {
      for (int attempt = 0; attempt < _networkRetryCount; attempt++) {
        await Future<void>.delayed(_networkRetryDelay);
        try {
          await _loadQueueFrom(
            retryPosition,
            continuous: _isContinuous,
            startPosition: retryOffset,
            playWhenReady: true,
          );
          recovered = true;
          break;
        } catch (_) {
          // Try again after the configured delay.
        }
      }

      if (!recovered) {
        final QuranAudioPlaybackError playbackError = QuranAudioPlaybackError(
          position: retryPosition,
          code: error.code,
          message:
              error.message ??
              'Audio connection was interrupted. Check your internet and try again.',
        );
        await _player.pause();
        _emitPlaybackError(playbackError);
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            playing: false,
            errorCode: playbackError.code,
            errorMessage: playbackError.message,
          ),
        );
      }
    } finally {
      _isRecoveringFromError = false;
    }
  }

  QuranAudioPosition _positionForError(ja.PlayerException error) {
    final int? index = error.index;
    if (index != null && index >= 0 && index < _queuedPositions.length) {
      return _queuedPositions[index];
    }
    return _currentPosition;
  }

  void _handlePlaybackStreamError(Object error, StackTrace stackTrace) {
    if (error is ja.PlayerException) {
      unawaited(_handlePlayerException(error));
      return;
    }

    _emitPlaybackError(
      QuranAudioPlaybackError(
        position: _currentPosition,
        message: 'Unable to play ayah audio.',
      ),
    );
  }

  void _broadcastPlaybackState(ja.PlaybackEvent event) {
    _lastPlaying = _player.playing;
    final AudioProcessingState processingState = _transformProcessingState(
      event.processingState,
    );
    playbackState.add(
      PlaybackState(
        controls: _controlsForState(_player.playing),
        androidCompactActionIndices: _compactActionIndices(_player.playing),
        systemActions: const <MediaAction>{
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        processingState: processingState,
        playing: _player.playing,
        updatePosition: event.updatePosition,
        bufferedPosition: event.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        errorCode: event.errorCode,
        errorMessage: event.errorMessage,
      ),
    );

    if (event.processingState == ja.ProcessingState.completed) {
      unawaited(_handleQueueCompleted());
    }
  }

  List<MediaControl> _controlsForState(bool playing) {
    return <MediaControl>[
      MediaControl.skipToPrevious,
      playing ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];
  }

  List<int> _compactActionIndices(bool playing) {
    return const <int>[0, 1, 2];
  }

  AudioProcessingState _transformProcessingState(
    ja.ProcessingState processingState,
  ) {
    return switch (processingState) {
      ja.ProcessingState.idle => AudioProcessingState.idle,
      ja.ProcessingState.loading => AudioProcessingState.loading,
      ja.ProcessingState.buffering => AudioProcessingState.buffering,
      ja.ProcessingState.ready => AudioProcessingState.ready,
      ja.ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  Future<void> _handleQueueCompleted() async {
    if (_isCompletingQueue) return;
    _isCompletingQueue = true;
    try {
      if (_isContinuous &&
          _currentPosition.ayah >=
              quran.getVerseCount(_currentPosition.surah)) {
        _surahCompleteController.add(_currentPosition);
        customEvent.add(<String, dynamic>{
          'type': eventSurahComplete,
          'surah': _currentPosition.surah,
          'ayah': _currentPosition.ayah,
        });
      }
      await stop();
    } finally {
      _isCompletingQueue = false;
    }
  }

  void _handleAudioInterruption(AudioInterruptionEvent event) {
    if (event.begin) {
      _resumeAfterFocusLoss = _isContinuous && _lastPlaying;
      return;
    }

    if (_resumeAfterFocusLoss && _isContinuous) {
      _resumeAfterFocusLoss = false;
      unawaited(play());
    }
  }

  void _emitCurrentPosition() {
    _currentAyahIndexController.add(_currentPosition.ayah);
    _currentPositionController.add(_currentPosition);
  }

  void _broadcastReadingState() {
    final QuranReadingAudioState state = QuranReadingAudioState(
      position: _currentPosition,
      isContinuous: _isContinuous,
      hasActiveQueue: _mediaItems.isNotEmpty,
      error: _currentError,
    );
    _stateController.add(state);
    customState.add(<String, dynamic>{'type': stateType, ...state.toJson()});
  }

  void _emitPlaybackError(QuranAudioPlaybackError error) {
    _currentError = error;
    _errorController.add(error);
    customEvent.add(<String, dynamic>{
      'type': eventPlaybackError,
      ...error.toJson(),
    });
    _broadcastReadingState();
  }

  void _persistCurrentPosition(QuranAudioPosition position) {
    final reciter = QuranAudioService().selectedReciter;
    unawaited(
      ResumeStateDB().put(
        'listening:last',
        ResumeStateEntry(
          id: 'listening:last',
          kind: 'listening',
          surah: position.surah,
          ayah: position.ayah,
          positionMillis: _player.position.inMilliseconds,
          title: quran.getSurahName(position.surah),
          subtitle: 'Ayah ${position.ayah} - ${reciter.englishName}',
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  QuranAudioPosition _restoreLastKnownPosition() {
    final List<ResumeStateEntry> resumeEntries =
        ResumeStateDB().box.values
            .whereType<ResumeStateEntry>()
            .where((ResumeStateEntry entry) {
              return entry.surah != null &&
                  entry.ayah != null &&
                  (entry.kind == 'reading' || entry.kind == 'listening');
            })
            .toList(growable: false)
          ..sort((ResumeStateEntry a, ResumeStateEntry b) {
            return b.updatedAt.compareTo(a.updatedAt);
          });
    if (resumeEntries.isNotEmpty) {
      final ResumeStateEntry entry = resumeEntries.first;
      return normalizePosition(entry.surah!, entry.ayah!);
    }

    final List<ReadingEntry> readingEntries =
        BookmarkDB().box.values.whereType<ReadingEntry>().toList(
          growable: false,
        )..sort((ReadingEntry a, ReadingEntry b) {
          return b.timestamp.compareTo(a.timestamp);
        });
    if (readingEntries.isNotEmpty) {
      final ReadingEntry entry = readingEntries.first;
      return normalizePosition(entry.surah, entry.verse);
    }

    return const QuranAudioPosition(surah: 1, ayah: 1);
  }

  QuranAudioPosition? _nextPositionInSameSurah(QuranAudioPosition position) {
    final int verseCount = quran.getVerseCount(position.surah);
    if (position.ayah >= verseCount) return null;
    return QuranAudioPosition(surah: position.surah, ayah: position.ayah + 1);
  }

  QuranAudioPosition? _previousPositionInSameSurah(
    QuranAudioPosition position,
  ) {
    if (position.ayah <= 1) return null;
    return QuranAudioPosition(surah: position.surah, ayah: position.ayah - 1);
  }

  Future<void> dispose() async {
    await _interruptionSubscription?.cancel();
    await _playbackEventSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _playerErrorSubscription.cancel();
    await _currentAyahIndexController.close();
    await _currentPositionController.close();
    await _stateController.close();
    await _errorController.close();
    await _surahCompleteController.close();
    await _player.dispose();
  }
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    if (value == 'true') return true;
    if (value == 'false') return false;
  }
  return null;
}

double? _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
