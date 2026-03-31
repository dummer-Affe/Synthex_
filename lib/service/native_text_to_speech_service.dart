import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NativeTextToSpeechService {
  NativeTextToSpeechService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  bool _initialized = false;
  List<String> _availableLanguages = const <String>[];

  List<String> get availableLanguages => _availableLanguages;

  Future<void> initialize({
    VoidCallback? onStart,
    VoidCallback? onComplete,
    ValueChanged<String>? onError,
  }) async {
    if (_initialized) {
      return;
    }

    _flutterTts.setStartHandler(() => onStart?.call());
    _flutterTts.setCompletionHandler(() => onComplete?.call());
    _flutterTts.setCancelHandler(() => onComplete?.call());
    _flutterTts.setErrorHandler((message) => onError?.call(message));

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    final dynamic rawLanguages = await _flutterTts.getLanguages;
    if (rawLanguages is List) {
      _availableLanguages = rawLanguages.map((dynamic item) {
        return item.toString();
      }).toList();
    }

    _initialized = true;
  }

  String? resolveLanguage(String bcpCode) {
    final normalizedCode = bcpCode.replaceAll('_', '-').toLowerCase();

    for (final language in _availableLanguages) {
      final normalizedLanguage = language.replaceAll('_', '-').toLowerCase();
      if (normalizedLanguage == normalizedCode) {
        return language;
      }
    }

    final languagePrefix = normalizedCode.split('-').first;
    for (final language in _availableLanguages) {
      final normalizedLanguage = language.replaceAll('_', '-').toLowerCase();
      if (normalizedLanguage == languagePrefix ||
          normalizedLanguage.startsWith('$languagePrefix-')) {
        return language;
      }
    }

    return null;
  }

  Future<void> speak({
    required String text,
    required String bcpCode,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (!_initialized) {
      await initialize();
    }

    final resolvedLanguage = resolveLanguage(bcpCode) ?? bcpCode;
    await _flutterTts.stop();
    await _flutterTts.setLanguage(resolvedLanguage);
    await _flutterTts.speak(trimmedText);
  }

  Future<void> stop() {
    return _flutterTts.stop();
  }
}
