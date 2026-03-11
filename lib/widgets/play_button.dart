import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:equran/backend/library.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

class PlayButton extends StatefulWidget {
  final String url;

  const PlayButton({super.key, required this.url});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (_audioPlayer.state == PlayerState.playing) {
        _updateProgress(position);
      }
    });

    // When the audio has finished playing this is what to do...
    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _safeSetState(() {
        _isPlaying = false;
        _progress = 0.0;
      });
    });

    // Listen for errors
    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && _isPlaying) {
        _safeSetState(() {
          _hasError = true;
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _updateProgress(Duration position) async {
    Duration duration = await _audioPlayer.getDuration() ?? Duration.zero;
    if (!mounted) return;
    if (duration.inMilliseconds > 0) {
      _safeSetState(() {
        _progress = position.inMilliseconds / duration.inMilliseconds;
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Helper method to handle web CORS issues
  Future<void> _playAudio(String url) async {
    if (kIsWeb) {
      // For web, download the audio and play from bytes
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await _audioPlayer.play(BytesSource(response.bodyBytes));
        } else {
          throw Exception('Failed to load audio: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading audio on web: $e');
        // Fallback: try with CORS proxy
        final proxiedUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
        await _audioPlayer.play(UrlSource(proxiedUrl));
      }
    } else {
      // For mobile, play directly from URL
      await _audioPlayer.play(UrlSource(url));
    }
  }

  double _playbackRate() {
    final dynamic value = SettingsDB().get("playbackRate", defaultValue: 1.0);
    if (value is num) {
      return value.toDouble().clamp(0.5, 2.0);
    }
    return 1.0;
  }

  void _togglePlayPause() async {
    if (widget.url.isEmpty) {
      return;
    }

    _safeSetState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _safeSetState(() {
          _isLoading = false;
          _isPlaying = false;
        });
      } else {
        final double rate = _playbackRate();
        await _audioPlayer.setPlaybackRate(rate);
        if (_audioPlayer.state == PlayerState.paused) {
          await _audioPlayer.resume();
        } else {
          await _playAudio(widget.url);
        }
        // Re-apply because some platforms reset rate when a source is (re)started.
        await _audioPlayer.setPlaybackRate(rate);

        _safeSetState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _safeSetState(() {
        _isLoading = false;
        _isPlaying = false;
        _hasError = true;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(kIsWeb
                ? 'Unable to play audio on web. Try downloading the app for better experience.'
                : 'Failed to play audio. Please check your internet connection.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _isPlaying
            ? CircularPercentIndicator(
          radius: 20.0,
          progressColor: Theme.of(context).colorScheme.primary,
          lineWidth: 3.5,
          percent: _progress,
        )
            : const SizedBox.shrink(),
        IconButton(
          onPressed: _togglePlayPause,
          icon: _isLoading
              ? const SizedBox(
            width: 29,
            height: 29,
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          )
              : Icon(
            _hasError
                ? Icons.error_outline_rounded
                : !_isPlaying
                ? Icons.play_circle_outline_rounded
                : Icons.pause_circle_outline_rounded,
            size: 29,
            color: _hasError ? Colors.red : null,
          ),
        )
      ],
    );
  }
}
