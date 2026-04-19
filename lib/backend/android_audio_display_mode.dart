import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class AndroidAudioDisplayMode {
  static const MethodChannel _channel = MethodChannel(
    'com.app.equran/read_page',
  );

  static Future<void> setAudioPlaybackActive(bool active) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await _channel.invokeMethod<void>('setPreferredFrameRate', <String, num>{
        'frameRate': active ? 24.0 : 0.0,
      });
    } catch (_) {
      // Devices that ignore frame-rate hints should not affect playback.
    }
  }
}
