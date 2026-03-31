// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_interpreter_view_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LiveInterpreterViewModel on _LiveInterpreterViewModelBase, Store {
  Computed<bool>? _$hasTranscriptComputed;

  @override
  bool get hasTranscript => (_$hasTranscriptComputed ??= Computed<bool>(
    () => super.hasTranscript,
    name: '_LiveInterpreterViewModelBase.hasTranscript',
  )).value;
  Computed<String>? _$modelStatusLabelComputed;

  @override
  String get modelStatusLabel =>
      (_$modelStatusLabelComputed ??= Computed<String>(
        () => super.modelStatusLabel,
        name: '_LiveInterpreterViewModelBase.modelStatusLabel',
      )).value;
  Computed<String>? _$speechLocaleLabelComputed;

  @override
  String get speechLocaleLabel =>
      (_$speechLocaleLabelComputed ??= Computed<String>(
        () => super.speechLocaleLabel,
        name: '_LiveInterpreterViewModelBase.speechLocaleLabel',
      )).value;

  late final _$sourceLanguageAtom = Atom(
    name: '_LiveInterpreterViewModelBase.sourceLanguage',
    context: context,
  );

  @override
  LanguageOption get sourceLanguage {
    _$sourceLanguageAtom.reportRead();
    return super.sourceLanguage;
  }

  @override
  set sourceLanguage(LanguageOption value) {
    _$sourceLanguageAtom.reportWrite(value, super.sourceLanguage, () {
      super.sourceLanguage = value;
    });
  }

  late final _$targetLanguageAtom = Atom(
    name: '_LiveInterpreterViewModelBase.targetLanguage',
    context: context,
  );

  @override
  LanguageOption get targetLanguage {
    _$targetLanguageAtom.reportRead();
    return super.targetLanguage;
  }

  @override
  set targetLanguage(LanguageOption value) {
    _$targetLanguageAtom.reportWrite(value, super.targetLanguage, () {
      super.targetLanguage = value;
    });
  }

  late final _$transcriptAtom = Atom(
    name: '_LiveInterpreterViewModelBase.transcript',
    context: context,
  );

  @override
  String get transcript {
    _$transcriptAtom.reportRead();
    return super.transcript;
  }

  @override
  set transcript(String value) {
    _$transcriptAtom.reportWrite(value, super.transcript, () {
      super.transcript = value;
    });
  }

  late final _$translatedTextAtom = Atom(
    name: '_LiveInterpreterViewModelBase.translatedText',
    context: context,
  );

  @override
  String get translatedText {
    _$translatedTextAtom.reportRead();
    return super.translatedText;
  }

  @override
  set translatedText(String value) {
    _$translatedTextAtom.reportWrite(value, super.translatedText, () {
      super.translatedText = value;
    });
  }

  late final _$statusTextAtom = Atom(
    name: '_LiveInterpreterViewModelBase.statusText',
    context: context,
  );

  @override
  String get statusText {
    _$statusTextAtom.reportRead();
    return super.statusText;
  }

  @override
  set statusText(String value) {
    _$statusTextAtom.reportWrite(value, super.statusText, () {
      super.statusText = value;
    });
  }

  late final _$errorTextAtom = Atom(
    name: '_LiveInterpreterViewModelBase.errorText',
    context: context,
  );

  @override
  String get errorText {
    _$errorTextAtom.reportRead();
    return super.errorText;
  }

  @override
  set errorText(String value) {
    _$errorTextAtom.reportWrite(value, super.errorText, () {
      super.errorText = value;
    });
  }

  late final _$activeSpeechLocaleAtom = Atom(
    name: '_LiveInterpreterViewModelBase.activeSpeechLocale',
    context: context,
  );

  @override
  String get activeSpeechLocale {
    _$activeSpeechLocaleAtom.reportRead();
    return super.activeSpeechLocale;
  }

  @override
  set activeSpeechLocale(String value) {
    _$activeSpeechLocaleAtom.reportWrite(value, super.activeSpeechLocale, () {
      super.activeSpeechLocale = value;
    });
  }

  late final _$isInitializingAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isInitializing',
    context: context,
  );

  @override
  bool get isInitializing {
    _$isInitializingAtom.reportRead();
    return super.isInitializing;
  }

  @override
  set isInitializing(bool value) {
    _$isInitializingAtom.reportWrite(value, super.isInitializing, () {
      super.isInitializing = value;
    });
  }

  late final _$isListeningAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isListening',
    context: context,
  );

  @override
  bool get isListening {
    _$isListeningAtom.reportRead();
    return super.isListening;
  }

  @override
  set isListening(bool value) {
    _$isListeningAtom.reportWrite(value, super.isListening, () {
      super.isListening = value;
    });
  }

  late final _$isSessionActiveAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isSessionActive',
    context: context,
  );

  @override
  bool get isSessionActive {
    _$isSessionActiveAtom.reportRead();
    return super.isSessionActive;
  }

  @override
  set isSessionActive(bool value) {
    _$isSessionActiveAtom.reportWrite(value, super.isSessionActive, () {
      super.isSessionActive = value;
    });
  }

  late final _$handsFreeModeAtom = Atom(
    name: '_LiveInterpreterViewModelBase.handsFreeMode',
    context: context,
  );

  @override
  bool get handsFreeMode {
    _$handsFreeModeAtom.reportRead();
    return super.handsFreeMode;
  }

  @override
  set handsFreeMode(bool value) {
    _$handsFreeModeAtom.reportWrite(value, super.handsFreeMode, () {
      super.handsFreeMode = value;
    });
  }

  late final _$isSpeakingAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isSpeaking',
    context: context,
  );

  @override
  bool get isSpeaking {
    _$isSpeakingAtom.reportRead();
    return super.isSpeaking;
  }

  @override
  set isSpeaking(bool value) {
    _$isSpeakingAtom.reportWrite(value, super.isSpeaking, () {
      super.isSpeaking = value;
    });
  }

  late final _$isPreparingModelsAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isPreparingModels',
    context: context,
  );

  @override
  bool get isPreparingModels {
    _$isPreparingModelsAtom.reportRead();
    return super.isPreparingModels;
  }

  @override
  set isPreparingModels(bool value) {
    _$isPreparingModelsAtom.reportWrite(value, super.isPreparingModels, () {
      super.isPreparingModels = value;
    });
  }

  late final _$autoSpeakTranslationAtom = Atom(
    name: '_LiveInterpreterViewModelBase.autoSpeakTranslation',
    context: context,
  );

  @override
  bool get autoSpeakTranslation {
    _$autoSpeakTranslationAtom.reportRead();
    return super.autoSpeakTranslation;
  }

  @override
  set autoSpeakTranslation(bool value) {
    _$autoSpeakTranslationAtom.reportWrite(
      value,
      super.autoSpeakTranslation,
      () {
        super.autoSpeakTranslation = value;
      },
    );
  }

  late final _$isSessionBusyAtom = Atom(
    name: '_LiveInterpreterViewModelBase.isSessionBusy',
    context: context,
  );

  @override
  bool get isSessionBusy {
    _$isSessionBusyAtom.reportRead();
    return super.isSessionBusy;
  }

  @override
  set isSessionBusy(bool value) {
    _$isSessionBusyAtom.reportWrite(value, super.isSessionBusy, () {
      super.isSessionBusy = value;
    });
  }

  late final _$micPermissionGrantedAtom = Atom(
    name: '_LiveInterpreterViewModelBase.micPermissionGranted',
    context: context,
  );

  @override
  bool get micPermissionGranted {
    _$micPermissionGrantedAtom.reportRead();
    return super.micPermissionGranted;
  }

  @override
  set micPermissionGranted(bool value) {
    _$micPermissionGrantedAtom.reportWrite(
      value,
      super.micPermissionGranted,
      () {
        super.micPermissionGranted = value;
      },
    );
  }

  late final _$nativeFeaturesSupportedAtom = Atom(
    name: '_LiveInterpreterViewModelBase.nativeFeaturesSupported',
    context: context,
  );

  @override
  bool get nativeFeaturesSupported {
    _$nativeFeaturesSupportedAtom.reportRead();
    return super.nativeFeaturesSupported;
  }

  @override
  set nativeFeaturesSupported(bool value) {
    _$nativeFeaturesSupportedAtom.reportWrite(
      value,
      super.nativeFeaturesSupported,
      () {
        super.nativeFeaturesSupported = value;
      },
    );
  }

  late final _$soundLevelAtom = Atom(
    name: '_LiveInterpreterViewModelBase.soundLevel',
    context: context,
  );

  @override
  double get soundLevel {
    _$soundLevelAtom.reportRead();
    return super.soundLevel;
  }

  @override
  set soundLevel(double value) {
    _$soundLevelAtom.reportWrite(value, super.soundLevel, () {
      super.soundLevel = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$requestMicrophonePermissionAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.requestMicrophonePermission',
    context: context,
  );

  @override
  Future<bool> requestMicrophonePermission() {
    return _$requestMicrophonePermissionAsyncAction.run(
      () => super.requestMicrophonePermission(),
    );
  }

  late final _$openPermissionSettingsAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.openPermissionSettings',
    context: context,
  );

  @override
  Future<void> openPermissionSettings() {
    return _$openPermissionSettingsAsyncAction.run(
      () => super.openPermissionSettings(),
    );
  }

  late final _$toggleListeningAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.toggleListening',
    context: context,
  );

  @override
  Future<void> toggleListening() {
    return _$toggleListeningAsyncAction.run(() => super.toggleListening());
  }

  late final _$setHandsFreeModeAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.setHandsFreeMode',
    context: context,
  );

  @override
  Future<void> setHandsFreeMode(bool enabled) {
    return _$setHandsFreeModeAsyncAction.run(
      () => super.setHandsFreeMode(enabled),
    );
  }

  late final _$startListeningAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.startListening',
    context: context,
  );

  @override
  Future<void> startListening() {
    return _$startListeningAsyncAction.run(() => super.startListening());
  }

  late final _$stopListeningAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.stopListening',
    context: context,
  );

  @override
  Future<void> stopListening({bool stopSpeechOutput = false}) {
    return _$stopListeningAsyncAction.run(
      () => super.stopListening(stopSpeechOutput: stopSpeechOutput),
    );
  }

  late final _$finishHoldTurnAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.finishHoldTurn',
    context: context,
  );

  @override
  Future<void> finishHoldTurn() {
    return _$finishHoldTurnAsyncAction.run(() => super.finishHoldTurn());
  }

  late final _$changeSourceLanguageAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.changeSourceLanguage',
    context: context,
  );

  @override
  Future<void> changeSourceLanguage(LanguageOption nextLanguage) {
    return _$changeSourceLanguageAsyncAction.run(
      () => super.changeSourceLanguage(nextLanguage),
    );
  }

  late final _$changeTargetLanguageAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.changeTargetLanguage',
    context: context,
  );

  @override
  Future<void> changeTargetLanguage(LanguageOption nextLanguage) {
    return _$changeTargetLanguageAsyncAction.run(
      () => super.changeTargetLanguage(nextLanguage),
    );
  }

  late final _$swapLanguagesAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.swapLanguages',
    context: context,
  );

  @override
  Future<void> swapLanguages() {
    return _$swapLanguagesAsyncAction.run(() => super.swapLanguages());
  }

  late final _$speakOriginalTextAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.speakOriginalText',
    context: context,
  );

  @override
  Future<void> speakOriginalText() {
    return _$speakOriginalTextAsyncAction.run(() => super.speakOriginalText());
  }

  late final _$speakTranslatedTextAsyncAction = AsyncAction(
    '_LiveInterpreterViewModelBase.speakTranslatedText',
    context: context,
  );

  @override
  Future<void> speakTranslatedText() {
    return _$speakTranslatedTextAsyncAction.run(
      () => super.speakTranslatedText(),
    );
  }

  late final _$_LiveInterpreterViewModelBaseActionController = ActionController(
    name: '_LiveInterpreterViewModelBase',
    context: context,
  );

  @override
  void clearTranscript() {
    final _$actionInfo = _$_LiveInterpreterViewModelBaseActionController
        .startAction(name: '_LiveInterpreterViewModelBase.clearTranscript');
    try {
      return super.clearTranscript();
    } finally {
      _$_LiveInterpreterViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleAutoSpeak() {
    final _$actionInfo = _$_LiveInterpreterViewModelBaseActionController
        .startAction(name: '_LiveInterpreterViewModelBase.toggleAutoSpeak');
    try {
      return super.toggleAutoSpeak();
    } finally {
      _$_LiveInterpreterViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sourceLanguage: ${sourceLanguage},
targetLanguage: ${targetLanguage},
transcript: ${transcript},
translatedText: ${translatedText},
statusText: ${statusText},
errorText: ${errorText},
activeSpeechLocale: ${activeSpeechLocale},
isInitializing: ${isInitializing},
isListening: ${isListening},
isSessionActive: ${isSessionActive},
handsFreeMode: ${handsFreeMode},
isSpeaking: ${isSpeaking},
isPreparingModels: ${isPreparingModels},
autoSpeakTranslation: ${autoSpeakTranslation},
isSessionBusy: ${isSessionBusy},
micPermissionGranted: ${micPermissionGranted},
nativeFeaturesSupported: ${nativeFeaturesSupported},
soundLevel: ${soundLevel},
hasTranscript: ${hasTranscript},
modelStatusLabel: ${modelStatusLabel},
speechLocaleLabel: ${speechLocaleLabel}
    ''';
  }
}
