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

  bool _initialized = false;
  List<LocaleName> _availableLocales = const <LocaleName>[];
  LocaleName? _systemLocale;

  List<LocaleName> get availableLocales => _availableLocales;
  String? get systemLocaleId => _systemLocale?.localeId;
  bool get isListening => _speechToText.isListening;

  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
  }) async {
    if (_initialized && _speechToText.isAvailable) {
      return _speechToText.isAvailable;
    }

    final isAvailable = await _speechToText.initialize(
      onError: onError,
      onStatus: onStatus,
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

  Future<void> listen({
    required String localeId,
    required bool onDevice,
    required SpeechResultListener onResult,
    Duration pauseFor = const Duration(seconds: 4),
    Duration listenFor = const Duration(seconds: 45),
    SpeechSoundLevelChange? onSoundLevelChange,
  }) async {
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
        cancelOnError: true,
      ),
    );
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
}
