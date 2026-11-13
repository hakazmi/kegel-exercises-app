import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'engine/engine_models.dart';

/// Speaks only "Squeeze" and "Relax" when voice cues are on.
class SessionVoice {
  FlutterTts? _tts;
  bool _failed = false;

  Future<void> speak(EngineEvent event, {required bool voiceOn}) async {
    if (!voiceOn || _failed) {
      return;
    }
    final String? phrase = switch (event) {
      EngineEvent.squeezeStarted => 'Squeeze',
      EngineEvent.relaxStarted => 'Relax',
      EngineEvent.restStarted || EngineEvent.done => null,
    };
    if (phrase == null) {
      return;
    }
    try {
      final FlutterTts tts = await _ensure();
      if (_failed) {
        return;
      }
      await tts.stop();
      await tts.speak(phrase);
    } on Object {
      // Missing speech engine or other TTS failure — fail silently.
      _failed = true;
    }
  }

  Future<FlutterTts> _ensure() async {
    if (_tts != null) {
      return _tts!;
    }
    final FlutterTts tts = FlutterTts();
    try {
      tts.setErrorHandler((dynamic message) {
        _failed = true;
      });
      await tts.setSpeechRate(0.45);
      await tts.setVolume(1);
      // Avoid playAndRecord / record categories — they can suppress iOS haptics.
      // Ambient + mixWithOthers keeps TTS optional and mixes with other audio.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await tts.setSharedInstance(true);
        await tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          <IosTextToSpeechAudioCategoryOptions>[
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }
      // Android: if no TTS engine / languages, disable voice without crashing.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final dynamic languages = await tts.getLanguages;
          if (languages is List && languages.isEmpty) {
            _failed = true;
          }
        } on Object {
          _failed = true;
        }
      }
    } on Object {
      // Ignore setup failures; speak may still work, or [_failed] already set.
    }
    _tts = tts;
    return tts;
  }

  Future<void> dispose() async {
    try {
      await _tts?.stop();
    } on Object {
      // Ignore.
    }
    _tts = null;
  }
}
