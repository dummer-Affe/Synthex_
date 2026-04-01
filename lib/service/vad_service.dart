import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vad/vad.dart';

/// Lightweight wrapper around the Silero VAD package.
///
/// Used in hands-free mode to detect real human speech while TTS is playing.
/// The underlying [VadHandler] uses a [RecordConfig] with hardware AEC enabled
/// by default, so audio played through the device speakers (TTS echo) is
/// filtered out before it reaches the VAD model.
class VadService {
  VadHandler? _vadHandler;
  StreamSubscription<void>? _speechSubscription;
  bool _isListening = false;

  bool get isListening => _isListening;

  /// Begin listening for human voice activity.
  ///
  /// [onSpeechDetected] fires once confirmed speech is detected (after
  /// `minSpeechFrames` to avoid misfires). The callback is guaranteed to
  /// run on the main isolate.
  Future<void> startListening({
    required VoidCallback onSpeechDetected,
  }) async {
    if (_isListening) return;

    _vadHandler = VadHandler.create(isDebug: false);

    _speechSubscription = _vadHandler!.onRealSpeechStart.listen((_) {
      onSpeechDetected();
    });

    await _vadHandler!.startListening(
      positiveSpeechThreshold: 0.5,
      negativeSpeechThreshold: 0.35,
      redemptionFrames: 8,
      minSpeechFrames: 3,
      frameSamples: 1536,
      preSpeechPadFrames: 1,
      submitUserSpeechOnPause: false,
    );

    _isListening = true;
  }

  /// Stop listening and release the microphone.
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    await _speechSubscription?.cancel();
    _speechSubscription = null;

    try {
      await _vadHandler?.stopListening();
    } catch (_) {
      // Ignore errors during teardown.
    }

    _vadHandler = null;
  }

  /// Release all resources.
  Future<void> dispose() async {
    await stopListening();
  }
}
