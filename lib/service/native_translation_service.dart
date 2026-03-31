import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../view/live_interpreter/model/language_option.dart';

class NativeTranslationService {
  NativeTranslationService({
    OnDeviceTranslatorModelManager? modelManager,
  }) : _modelManager = modelManager ?? OnDeviceTranslatorModelManager();

  final OnDeviceTranslatorModelManager _modelManager;

  OnDeviceTranslator? _translator;
  TranslateLanguage? _activeSourceLanguage;
  TranslateLanguage? _activeTargetLanguage;

  Future<void> prepare({
    required LanguageOption sourceLanguage,
    required LanguageOption targetLanguage,
  }) async {
    if (sourceLanguage.translateLanguage == targetLanguage.translateLanguage) {
      return;
    }

    if (_activeSourceLanguage == sourceLanguage.translateLanguage &&
        _activeTargetLanguage == targetLanguage.translateLanguage &&
        _translator != null) {
      return;
    }

    await _translator?.close();
    _translator = null;

    await _downloadIfNeeded(sourceLanguage.translateLanguage);
    await _downloadIfNeeded(targetLanguage.translateLanguage);

    _activeSourceLanguage = sourceLanguage.translateLanguage;
    _activeTargetLanguage = targetLanguage.translateLanguage;
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage.translateLanguage,
      targetLanguage: targetLanguage.translateLanguage,
    );
  }

  Future<String> translate({
    required String text,
    required LanguageOption sourceLanguage,
    required LanguageOption targetLanguage,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return '';
    }

    if (sourceLanguage.translateLanguage == targetLanguage.translateLanguage) {
      return trimmedText;
    }

    await prepare(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    return _translator!.translateText(trimmedText);
  }

  Future<void> _downloadIfNeeded(TranslateLanguage language) async {
    final isDownloaded = await _modelManager.isModelDownloaded(language.bcpCode);
    if (!isDownloaded) {
      await _modelManager.downloadModel(language.bcpCode);
    }
  }

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
  }
}
