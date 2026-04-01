import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vad/vad.dart';

/// Lightweight wrapper around the Silero VAD package.
///
/// Used in hands-free mode to detect real human speech while TTS is playing.
/// A custom [RecordConfig] keeps the system audio mode in normal so that TTS
/// playback quality is not degraded, while still using the
/// `voiceCommunication` audio source on Android for hardware-level AEC.
class VadService {
  VadHandler? _vadHandler;
  StreamSubscription<void>? _speechSubscription;
  bool _isListening = false;

  bool get isListening => _isListening;

  /// [RecordConfig] tuned for coexistence with TTS playback.
  ///
  /// Key differences from the vad package default:
  /// - [AudioManagerMode.modeNormal] keeps TTS routed through the main
  ///   speaker at full quality (the default `modeInCommunication` reroutes
  ///   audio to the earpiece and applies aggressive processing).
  /// - `speakerphone: false` avoids forcing speaker routing changes.
  /// - `autoGain` and `noiseSuppress` are off to prevent artifacts.
  /// - `echoCancel` stays on; combined with `voiceCommunication` source,
  ///   the HAL-level AEC still filters speaker echo.
  static final RecordConfig _recordConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 16000,
    bitRate: 16,
    numChannels: 1,
    echoCancel: true,
    autoGain: false,
    noiseSuppress: false,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.voiceCommunication,
      audioManagerMode: AudioManagerMode.modeNormal,
      speakerphone: false,
      manageBluetooth: false,
    ),
  );

  Future<void> startListening({
    required VoidCallback onSpeechDetected,
  }) async {
    if (_isListening) return;

    // Set flag synchronously BEFORE any async work so a second call
    // arriving on the same event-loop turn is rejected immediately.
    _isListening = true;

    try {
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
        recordConfig: _recordConfig,
      );
    } catch (error) {
      // If start fails, clean up and re-throw so the caller knows.
      _isListening = false;
      await _speechSubscription?.cancel();
      _speechSubscription = null;
      _vadHandler = null;
      rethrow;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    await _speechSubscription?.cancel();
    _speechSubscription = null;

    final VadHandler? handler = _vadHandler;
    _vadHandler = null;

    if (handler != null) {
      try {
        await handler.stopListening();
      } catch (_) {
        // Best-effort — the recorder may already be released.
      }
      try {
        handler.dispose();
      } catch (_) {
        // Best-effort cleanup.
      }
    }
  }

  Future<void> dispose() async {
    await stopListening();
  }
}
