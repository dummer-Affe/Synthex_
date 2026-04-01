import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NativeSpeechSessionConfig {
  const NativeSpeechSessionConfig({
    required this.localeId,
    required this.onDevice,
  });

  final String localeId;
  final bool onDevice;
}

class NativeSpeechToTextService {
  NativeSpeechToTextService({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  SpeechErrorListener? _errorListener;
  SpeechStatusListener? _statusListener;

  bool _initialized = false;
  List<LocaleName> _availableLocales = const <LocaleName>[];
  LocaleName? _systemLocale;
  Completer<void>? _listenReadyCompleter;

  List<LocaleName> get availableLocales => _availableLocales;
  String? get systemLocaleId => _systemLocale?.localeId;
  bool get isListening => _speechToText.isListening;

  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
  }) async {
    _errorListener = onError;
    _statusListener = onStatus;

    if (_initialized && _speechToText.isAvailable) {
      return _speechToText.isAvailable;
    }

    final isAvailable = await _speechToText.initialize(
      onError: _forwardError,
      onStatus: _forwardStatus,
      finalTimeout: const Duration(milliseconds: 750),
      options: <SpeechConfigOption>[SpeechToText.androidNoBluetooth],
    );

    if (isAvailable) {
      _availableLocales = await _speechToText.locales();
      _systemLocale = await _speechToText.systemLocale();
    }

    _initialized = isAvailable;
    return isAvailable;
  }

  String? resolveLocaleId(String bcpCode) {
    final normalizedCode = bcpCode.toLowerCase();

    for (final locale in _availableLocales) {
      final normalizedLocale = locale.localeId
          .replaceAll('_', '-')
          .toLowerCase();
      if (normalizedLocale == normalizedCode) {
        return locale.localeId;
      }
    }

    for (final locale in _availableLocales) {
      final normalizedLocale = locale.localeId
          .replaceAll('_', '-')
          .toLowerCase();
      if (normalizedLocale.startsWith('$normalizedCode-') ||
          normalizedLocale.startsWith('${normalizedCode}_') ||
          normalizedLocale == normalizedCode) {
        return locale.localeId;
      }
    }

    return null;
  }

  NativeSpeechSessionConfig resolveSessionConfig({
    required String bcpCode,
    String? fallbackLocaleId,
  }) {
    final String? preferredOnDeviceLocale = resolveLocaleId(bcpCode);
    if (preferredOnDeviceLocale != null) {
      return NativeSpeechSessionConfig(
        localeId: preferredOnDeviceLocale,
        onDevice: true,
      );
    }

    return NativeSpeechSessionConfig(
      localeId: _normalizeLocaleId(fallbackLocaleId ?? bcpCode),
      onDevice: false,
    );
  }

  Future<bool> listen({
    required String localeId,
    required bool onDevice,
    required SpeechResultListener onResult,
    Duration pauseFor = const Duration(seconds: 4),
    Duration listenFor = const Duration(seconds: 45),
    SpeechSoundLevelChange? onSoundLevelChange,
  }) async {
    final Completer<void> listenReadyCompleter = Completer<void>();
    _listenReadyCompleter = listenReadyCompleter;

    await _speechToText.listen(
      onResult: onResult,
      localeId: localeId,
      onSoundLevelChange: onSoundLevelChange,
      pauseFor: pauseFor,
      listenFor: listenFor,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        onDevice: onDevice,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      ),
    );

    if (_speechToText.isListening) {
      if (identical(_listenReadyCompleter, listenReadyCompleter)) {
        _listenReadyCompleter = null;
      }
      return true;
    }

    try {
      await listenReadyCompleter.future.timeout(
        const Duration(milliseconds: 900),
      );
    } on TimeoutException {
      // Some iOS no-match completions close slowly and reject the first
      // re-arm request. The caller retries if listening never actually starts.
    } finally {
      if (identical(_listenReadyCompleter, listenReadyCompleter)) {
        _listenReadyCompleter = null;
      }
    }

    return _speechToText.isListening;
  }

  Future<void> stop() {
    return _speechToText.stop();
  }

  Future<void> cancel() {
    return _speechToText.cancel();
  }

  String _normalizeLocaleId(String localeTag) {
    return localeTag.replaceAll('-', '_');
  }

  void _forwardError(SpeechRecognitionError error) {
    _errorListener?.call(error);
  }

  void _forwardStatus(String status) {
    final Completer<void>? listenReadyCompleter = _listenReadyCompleter;
    if (status == SpeechToText.listeningStatus &&
        listenReadyCompleter != null &&
        !listenReadyCompleter.isCompleted) {
      listenReadyCompleter.complete();
    }

    _statusListener?.call(status);
  }
}
