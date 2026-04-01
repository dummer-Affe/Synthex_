import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../service/native_permission_service.dart';
import '../../../service/native_speech_to_text_service.dart';
import '../../../service/native_text_to_speech_service.dart';
import '../../../service/native_translation_service.dart';
import '../../../service/vad_service.dart';
import '../model/language_option.dart';

part 'live_interpreter_view_model.g.dart';

class LiveInterpreterViewModel extends _LiveInterpreterViewModelBase
    with _$LiveInterpreterViewModel {
  LiveInterpreterViewModel({
    super.permissionService,
    super.speechService,
    super.textToSpeechService,
    super.translationService,
    super.vadService,
  });
}

abstract class _LiveInterpreterViewModelBase with Store {
  _LiveInterpreterViewModelBase({
    NativePermissionService? permissionService,
    NativeSpeechToTextService? speechService,
    NativeTextToSpeechService? textToSpeechService,
    NativeTranslationService? translationService,
    VadService? vadService,
  }) : _permissionService = permissionService ?? NativePermissionService(),
       _speechService = speechService ?? NativeSpeechToTextService(),
       _textToSpeechService =
           textToSpeechService ?? NativeTextToSpeechService(),
       _translationService = translationService ?? NativeTranslationService(),
       _vadService = vadService ?? VadService();

  final NativePermissionService _permissionService;
  final NativeSpeechToTextService _speechService;
  final NativeTextToSpeechService _textToSpeechService;
  final NativeTranslationService _translationService;
  final VadService _vadService;

  final ObservableList<LanguageOption> supportedLanguages =
      ObservableList<LanguageOption>.of(LanguageOption.supportedLanguages);

  Timer? _translationDebounce;
  Future<void>? _prepareTranslatorTask;
  bool _keepListening = false;
  bool _restartListeningWhileActive = false;
  bool _restartQueued = false;
  bool _handsFreeTurnFinalizing = false;
  bool _holdTurnFinalizing = false;
  bool _clearOnNextSpeechResult = false;
  bool _currentTurnHasSpeech = false;
  bool _autoTtsStarted = false;
  bool _isDisposed = false;
  bool _useOnDeviceSpeech = true;
  String _committedTranscript = '';
  String _liveTranscript = '';
  bool _vadSpeechInterrupted = false;
  int _translationTicket = 0;

  @observable
  LanguageOption sourceLanguage = LanguageOption.defaultSource;

  @observable
  LanguageOption targetLanguage = LanguageOption.defaultTarget;

  @observable
  String transcript = '';

  @observable
  String translatedText = '';

  @observable
  String statusText = 'Preparing native tools...';

  @observable
  String errorText = '';

  @observable
  String activeSpeechLocale = '';

  @observable
  bool isInitializing = true;

  @observable
  bool isListening = false;

  @observable
  bool isSessionActive = false;

  @observable
  bool handsFreeMode = false;

  @observable
  bool isSpeaking = false;

  @observable
  bool isPreparingModels = false;

  @observable
  bool autoSpeakTranslation = true;

  @observable
  bool isSessionBusy = false;

  @observable
  bool micPermissionGranted = false;

  @observable
  bool nativeFeaturesSupported = true;

  @observable
  double soundLevel = 0;

  @computed
  bool get hasTranscript => transcript.trim().isNotEmpty;

  @computed
  String get modelStatusLabel {
    if (isPreparingModels) {
      return 'Downloading on-device model';
    }
    return 'On-device model ready';
  }

  @computed
  String get speechLocaleLabel {
    if (activeSpeechLocale.isEmpty) {
      return 'Speech locale unavailable';
    }
    return activeSpeechLocale.replaceAll('_', '-');
  }

  String get _currentLanguagePairKey =>
      '${sourceLanguage.bcpCode}->${targetLanguage.bcpCode}';

  bool get _isNativeMobilePlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @action
  Future<void> init() async {
    if (_isDisposed) {
      return;
    }

    nativeFeaturesSupported = _isNativeMobilePlatform;
    if (!nativeFeaturesSupported) {
      isInitializing = false;
      statusText = 'Run this feature on Android or iOS.';
      errorText =
          'This project is wired for native mobile speech and on-device translation only.';
      return;
    }

    statusText = 'Preparing native speech and offline translation...';
    errorText = '';
    isInitializing = true;

    final PermissionStatus permissionStatus = await _permissionService
        .microphoneStatus();
    micPermissionGranted = permissionStatus.isGranted;

    await _textToSpeechService.initialize(
      onStart: _handleTextToSpeechStart,
      onComplete: _handleTextToSpeechComplete,
      onError: (String message) {
        runInAction(() {
          isSpeaking = false;
          errorText = 'TTS failed: $message';
        });
        _autoTtsStarted = false;
      },
    );

    await _speechService.initialize(
      onError: _handleSpeechError,
      onStatus: _handleSpeechStatus,
    );

    _applyDefaultLanguages();
    isInitializing = false;
    unawaited(_prepareTranslator());

    if (!_speechService.isListening && !micPermissionGranted) {
      statusText = 'Grant microphone access to start speech input.';
    } else if (errorText.isEmpty) {
      statusText = _idleStatusLabel();
    }
  }

  @action
  Future<bool> requestMicrophonePermission() async {
    final PermissionStatus permissionStatus = await _permissionService
        .requestMicrophonePermission();
    micPermissionGranted = permissionStatus.isGranted;

    if (permissionStatus.isGranted) {
      errorText = '';
      statusText = 'Microphone access granted.';
      return true;
    }

    if (permissionStatus.isPermanentlyDenied || permissionStatus.isRestricted) {
      errorText =
          'Microphone access is blocked. Open system settings to continue.';
    } else {
      errorText =
          'Microphone access is required for native speech recognition.';
    }

    statusText = 'Microphone permission is missing.';
    return false;
  }

  @action
  Future<void> openPermissionSettings() async {
    await _permissionService.openSettings();
  }

  @action
  Future<void> toggleListening() async {
    if (isSessionBusy) {
      return;
    }

    if (isSessionActive) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  @action
  Future<void> setHandsFreeMode(bool enabled) async {
    if (handsFreeMode == enabled) {
      return;
    }

    final bool wasActive =
        isSessionActive || isListening || _speechService.isListening;
    if (wasActive) {
      await stopListening();
    }

    handsFreeMode = enabled;
    errorText = '';
    if (!isInitializing && !isPreparingModels) {
      statusText = _idleStatusLabel();
    }
  }

  @action
  Future<void> startListening() async {
    if (isSessionBusy || (_keepListening && (isSessionActive || isListening))) {
      return;
    }

    _resetForNewTurn(clearError: true);
    _clearOnNextSpeechResult = false;
    _currentTurnHasSpeech = false;
    _keepListening = true;
    _restartListeningWhileActive = !handsFreeMode;
    _restartQueued = false;
    _handsFreeTurnFinalizing = false;
    _holdTurnFinalizing = false;
    isSessionActive = true;
    errorText = '';
    isSessionBusy = true;

    try {
      if (!_isNativeMobilePlatform) {
        errorText = 'Native STT is only available on Android and iOS.';
        isSessionActive = false;
        _keepListening = false;
        return;
      }

      if (!micPermissionGranted) {
        final bool granted = await requestMicrophonePermission();
        if (!granted) {
          isSessionActive = false;
          _keepListening = false;
          return;
        }
      }

      if (!_keepListening || !isSessionActive || _isDisposed) {
        return;
      }

      final bool speechReady = await _speechService.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
      );
      if (!speechReady) {
        statusText = 'Speech recognizer unavailable.';
        errorText =
            'The device did not expose a native speech recognizer for this session.';
        isSessionActive = false;
        _keepListening = false;
        return;
      }

      if (!_keepListening || !isSessionActive || _isDisposed) {
        return;
      }

      statusText = 'Preparing listening session...';
      await _prepareTranslator();

      if (!_keepListening || !isSessionActive || _isDisposed) {
        return;
      }

      _updateResolvedSpeechLocale();

      if (!_keepListening || !isSessionActive || _isDisposed) {
        return;
      }

      statusText = _listeningStatusLabel();
      await _startSpeechSession(
        localeId: activeSpeechLocale,
        onDevice: _useOnDeviceSpeech,
      );
    } finally {
      isSessionBusy = false;
    }
  }

  Future<void> _startSpeechSession({
    required String localeId,
    required bool onDevice,
  }) async {
    if (_isDisposed || !_keepListening || !isSessionActive) {
      return;
    }

    _useOnDeviceSpeech = onDevice;
    activeSpeechLocale = localeId;

    try {
      await _speechService.listen(
        localeId: localeId,
        onDevice: onDevice,
        onResult: _handleSpeechResult,
        pauseFor: _speechPauseDuration,
        listenFor: _speechListenDuration,
        onSoundLevelChange: _handleSoundLevel,
      );

      if (_isDisposed || !_keepListening || !isSessionActive) {
        if (_speechService.isListening) {
          await _speechService.stop();
        }
        return;
      }

      runInAction(() {
        isSessionActive = true;
        isListening = true;
        statusText = _listeningStatusLabel();
      });
    } catch (error) {
      runInAction(() {
        isSessionActive = false;
        isListening = false;
        _keepListening = false;
        statusText = 'Could not start the speech recognizer.';
        errorText = _friendlyError(error.toString());
      });
    }
  }

  @action
  Future<void> stopListening({bool stopSpeechOutput = false}) async {
    _keepListening = false;
    _restartListeningWhileActive = false;
    _restartQueued = false;
    _handsFreeTurnFinalizing = false;
    _holdTurnFinalizing = false;
    _clearOnNextSpeechResult = false;
    _currentTurnHasSpeech = false;
    _vadSpeechInterrupted = false;
    isSessionActive = false;
    soundLevel = 0;

    if (_vadService.isListening) {
      await _vadService.stopListening();
    }

    if (!isListening && !_speechService.isListening) {
      statusText = _idleStatusLabel();
      if (stopSpeechOutput) {
        await _textToSpeechService.stop();
      }
      return;
    }

    isSessionBusy = true;
    try {
      await _speechService.stop();
      if (stopSpeechOutput) {
        await _textToSpeechService.stop();
      }
      isListening = false;
      soundLevel = 0;
      statusText = _idleStatusLabel();
    } finally {
      isSessionBusy = false;
    }
  }

  @action
  Future<void> finishHoldTurn() async {
    if (handsFreeMode) {
      await stopListening(stopSpeechOutput: true);
      return;
    }

    if (_holdTurnFinalizing) {
      return;
    }

    _restartListeningWhileActive = false;
    _restartQueued = false;
    isSessionActive = false;

    if (!isListening && !_speechService.isListening) {
      await stopListening();
      return;
    }

    _holdTurnFinalizing = true;
    isSessionBusy = true;
    statusText = 'Finishing your last words...';

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (_isDisposed || handsFreeMode || !_holdTurnFinalizing) {
        return;
      }

      _keepListening = false;
      if (isListening || _speechService.isListening) {
        await _speechService.stop();
      }

      runInAction(() {
        isListening = false;
        soundLevel = 0;
        statusText = 'Translating final speech...';
      });

      await _flushTranslation(speakOnComplete: autoSpeakTranslation);

      if (_isDisposed || !_holdTurnFinalizing) {
        return;
      }

      runInAction(() {
        statusText = _idleStatusLabel();
      });
    } finally {
      _holdTurnFinalizing = false;
      isSessionBusy = false;
    }
  }

  void _handleSpeechStatus(String status) {
    if (_isDisposed) {
      return;
    }

    if (status == SpeechToText.listeningStatus) {
      if (!_keepListening || !isSessionActive) {
        if (_speechService.isListening) {
          unawaited(_speechService.stop());
        }
        return;
      }

      runInAction(() {
        isSessionActive = true;
        isListening = true;
        statusText = _listeningStatusLabel();
      });
      return;
    }

    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      runInAction(() {
        isListening = false;
        soundLevel = 0;
        if (handsFreeMode && _keepListening && isSessionActive) {
          statusText = _currentTurnHasSpeech
              ? 'Speaking ${targetLanguage.label} translation...'
              : _sessionWaitingStatusLabel();
        } else if (_restartListeningWhileActive &&
            _keepListening &&
            isSessionActive) {
          statusText = _sessionWaitingStatusLabel();
        } else if (errorText.isEmpty) {
          _keepListening = false;
          _restartListeningWhileActive = false;
          isSessionActive = false;
          statusText = _idleStatusLabel();
        }
      });

      if (handsFreeMode && _keepListening && isSessionActive) {
        _queueHandsFreeRestart();
      } else if (_restartListeningWhileActive &&
          _keepListening &&
          isSessionActive) {
        _queueRestart();
      }
    }
  }

  void _queueHandsFreeRestart() {
    if (_handsFreeTurnFinalizing ||
        !handsFreeMode ||
        !_keepListening ||
        !isSessionActive ||
        activeSpeechLocale.isEmpty) {
      return;
    }

    _handsFreeTurnFinalizing = true;
    _vadSpeechInterrupted = false;

    Future<void>(() async {
      try {
        final bool turnHasSpeech = _currentTurnHasSpeech;
        final bool hadTurnContent =
            transcript.trim().isNotEmpty || translatedText.trim().isNotEmpty;

        // Give the final speech result time to arrive before flushing.
        if (turnHasSpeech) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
        }

        if (_isDisposed ||
            !handsFreeMode ||
            !_keepListening ||
            !isSessionActive ||
            activeSpeechLocale.isEmpty) {
          return;
        }

        if (turnHasSpeech && transcript.trim().isNotEmpty) {
          final bool willSpeak = autoSpeakTranslation;

          // Start VAD before TTS so it can detect real human speech.
          // The VAD uses hardware AEC — speaker echo is filtered out,
          // only a real voice triggers _handleVadSpeechDuringTts.
          if (willSpeak) {
            _vadSpeechInterrupted = false;
            await _vadService.startListening(
              onSpeechDetected: _handleVadSpeechDuringTts,
            );
          }

          // Translate without speaking — TTS is handled separately below
          // so we can check for VAD interruption between the two steps.
          await _flushTranslation(speakOnComplete: false);

          if (_isDisposed ||
              !handsFreeMode ||
              !_keepListening ||
              !isSessionActive ||
              activeSpeechLocale.isEmpty) {
            if (_vadService.isListening) {
              await _vadService.stopListening();
            }
            return;
          }

          // User spoke during translation — _quickSwitchToStt already
          // kicked off STT from the callback, just exit.
          if (_vadSpeechInterrupted) {
            return;
          }

          // Play translation through TTS while VAD keeps listening.
          if (willSpeak && translatedText.trim().isNotEmpty) {
            await _speakAutoTranslation(translatedText);
          }

          // Stop VAD now that TTS is done naturally.
          if (_vadService.isListening) {
            await _vadService.stopListening();
          }

          // User spoke during TTS — _quickSwitchToStt already
          // kicked off STT from the callback, just exit.
          if (_vadSpeechInterrupted) {
            return;
          }
        } else if (turnHasSpeech) {
          _translationDebounce?.cancel();
          _translationTicket += 1;
        }

        if (_isDisposed ||
            !handsFreeMode ||
            !_keepListening ||
            !isSessionActive ||
            activeSpeechLocale.isEmpty) {
          return;
        }

        // TTS completed naturally — prepare for the next turn.
        if (turnHasSpeech) {
          _clearOnNextSpeechResult = hadTurnContent;
        }
        _currentTurnHasSpeech = false;
        runInAction(() {
          errorText = '';
          statusText = _sessionWaitingStatusLabel();
        });

        // Short pause before restarting the mic.
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (_isDisposed ||
            !handsFreeMode ||
            !_keepListening ||
            !isSessionActive ||
            activeSpeechLocale.isEmpty) {
          return;
        }

        await _startSpeechSession(
          localeId: activeSpeechLocale,
          onDevice: _useOnDeviceSpeech,
        );
      } finally {
        _handsFreeTurnFinalizing = false;
      }
    });
  }

  /// Called by VAD when real human speech is detected during TTS playback.
  ///
  /// Immediately stops TTS and begins switching from VAD to STT without
  /// waiting for the [_queueHandsFreeRestart] flow to unwind. This
  /// minimises the gap between the user starting to speak and STT
  /// actually capturing their words.
  void _handleVadSpeechDuringTts() {
    if (_isDisposed || !handsFreeMode || !_keepListening || _vadSpeechInterrupted) {
      return;
    }
    _vadSpeechInterrupted = true;
    unawaited(_textToSpeechService.stop());
    unawaited(_quickSwitchToStt());
  }

  /// Stop VAD, clear state, and start STT as fast as possible.
  ///
  /// Runs independently of [_queueHandsFreeRestart] — when that flow
  /// eventually checks [_vadSpeechInterrupted] it simply returns.
  Future<void> _quickSwitchToStt() async {
    await _vadService.stopListening();

    if (_isDisposed ||
        !handsFreeMode ||
        !_keepListening ||
        !isSessionActive ||
        activeSpeechLocale.isEmpty) {
      return;
    }

    _resetForNewTurn(clearError: true);
    _clearOnNextSpeechResult = false;
    _currentTurnHasSpeech = false;

    runInAction(() {
      errorText = '';
      statusText = _listeningStatusLabel();
    });

    await _startSpeechSession(
      localeId: activeSpeechLocale,
      onDevice: _useOnDeviceSpeech,
    );
  }

  void _queueRestart() {
    if (_restartQueued ||
        !_restartListeningWhileActive ||
        !_keepListening ||
        !isSessionActive ||
        activeSpeechLocale.isEmpty) {
      return;
    }

    _restartQueued = true;
    Future<void>.delayed(const Duration(milliseconds: 350), () async {
      _restartQueued = false;
      if (_isDisposed ||
          !_restartListeningWhileActive ||
          !_keepListening ||
          !isSessionActive ||
          activeSpeechLocale.isEmpty) {
        return;
      }
      await _startSpeechSession(
        localeId: activeSpeechLocale,
        onDevice: _useOnDeviceSpeech,
      );
    });
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (_isDisposed) {
      return;
    }

    final bool isRecoverableTimeout =
        error.errorMsg.contains('speech_timeout') ||
        error.errorMsg.contains('error_no_match');

    // In hands-free mode, timeouts and no-match errors are expected between
    // phrases. Keep the session alive so _queueHandsFreeRestart can re-listen.
    if (handsFreeMode &&
        _keepListening &&
        isSessionActive &&
        isRecoverableTimeout) {
      // Don't show transient timeout noise to the user in hands-free mode.
      return;
    }

    runInAction(() {
      errorText = _friendlySpeechError(error.errorMsg);
      if (error.permanent) {
        _keepListening = false;
        _restartListeningWhileActive = false;
        isSessionActive = false;
        isListening = false;
        statusText = _idleStatusLabel();
      }
    });
  }

  void _handleSoundLevel(double level) {
    if (_isDisposed) {
      return;
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (_isDisposed) {
      return;
    }

    final String normalizedWords = _normalizeText(result.recognizedWords);
    if (normalizedWords.isEmpty) {
      return;
    }

    // If TTS is still playing when real speech arrives, cancel it.
    if (isSpeaking && _clearOnNextSpeechResult) {
      unawaited(_textToSpeechService.stop());
    }

    if (_clearOnNextSpeechResult) {
      _resetForNewTurn(clearError: true);
      _clearOnNextSpeechResult = false;
    }

    _currentTurnHasSpeech = true;
    _liveTranscript = normalizedWords;
    runInAction(() {
      transcript = _composeTranscript(
        committedTranscript: _committedTranscript,
        liveTranscript: _liveTranscript,
      );
    });
    _scheduleTranslation();

    if (result.finalResult) {
      _committedTranscript = _composeTranscript(
        committedTranscript: _committedTranscript,
        liveTranscript: normalizedWords,
      );
      _liveTranscript = '';

      runInAction(() {
        transcript = _committedTranscript;
      });
      _scheduleTranslation();
    }
  }

  void _scheduleTranslation({bool speakOnComplete = false}) {
    _translationDebounce?.cancel();
    final int requestId = ++_translationTicket;

    _translationDebounce = Timer(const Duration(milliseconds: 280), () {
      unawaited(
        _translateCurrentTranscript(
          requestId: requestId,
          speakOnComplete: speakOnComplete,
        ),
      );
    });
  }

  Future<void> _flushTranslation({bool speakOnComplete = false}) async {
    _translationDebounce?.cancel();
    final int requestId = ++_translationTicket;
    await _translateCurrentTranscript(
      requestId: requestId,
      speakOnComplete: speakOnComplete,
    );
  }

  Future<void> _translateCurrentTranscript({
    required int requestId,
    bool speakOnComplete = false,
  }) async {
    final String currentTranscript = transcript.trim();

    if (currentTranscript.isEmpty) {
      runInAction(() {
        translatedText = '';
      });
      return;
    }

    try {
      final String translation = await _translationService.translate(
        text: currentTranscript,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (_isDisposed || requestId != _translationTicket) {
        return;
      }

      runInAction(() {
        translatedText = translation;
        if (!isListening && !isSessionActive) {
          statusText = _idleStatusLabel();
        }
      });

      if (speakOnComplete && autoSpeakTranslation && translation.isNotEmpty) {
        await _speakAutoTranslation(translation);
      }
    } catch (error) {
      if (_isDisposed || requestId != _translationTicket) {
        return;
      }

      runInAction(() {
        errorText =
            'Translation failed while preparing the on-device model. ${_friendlyError(error.toString())}';
        statusText = 'Offline translation failed.';
      });
    }
  }

  @action
  Future<void> changeSourceLanguage(LanguageOption nextLanguage) async {
    if (sourceLanguage == nextLanguage) {
      return;
    }

    final bool shouldResume = isSessionActive;
    if (shouldResume) {
      await stopListening();
    }

    if (targetLanguage == nextLanguage) {
      targetLanguage = sourceLanguage;
    }

    sourceLanguage = nextLanguage;
    _updateResolvedSpeechLocale();
    await _prepareTranslator();

    if (hasTranscript) {
      _scheduleTranslation();
    }

    if (shouldResume) {
      await startListening();
    }
  }

  @action
  Future<void> changeTargetLanguage(LanguageOption nextLanguage) async {
    if (targetLanguage == nextLanguage) {
      return;
    }

    if (sourceLanguage == nextLanguage) {
      sourceLanguage = targetLanguage;
      _updateResolvedSpeechLocale();
    }

    targetLanguage = nextLanguage;
    await _prepareTranslator();

    if (hasTranscript) {
      _scheduleTranslation();
    }
  }

  @action
  Future<void> swapLanguages() async {
    final bool shouldResume = isSessionActive;
    if (shouldResume) {
      await stopListening();
    }

    final LanguageOption previousSourceLanguage = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = previousSourceLanguage;

    _updateResolvedSpeechLocale();
    await _prepareTranslator();

    if (hasTranscript) {
      _scheduleTranslation();
    }

    if (shouldResume) {
      await startListening();
    }
  }

  @action
  void clearTranscript() {
    _translationDebounce?.cancel();
    _translationTicket += 1;
    _committedTranscript = '';
    _liveTranscript = '';
    transcript = '';
    translatedText = '';
    statusText = isSessionActive
        ? (isListening ? _listeningStatusLabel() : _sessionWaitingStatusLabel())
        : 'Transcript cleared.';
    errorText = '';
  }

  @action
  Future<void> speakOriginalText() async {
    if (!hasTranscript) {
      return;
    }

    await _textToSpeechService.speak(
      text: transcript,
      bcpCode: sourceLanguage.defaultTtsLocale,
    );
  }

  @action
  Future<void> speakTranslatedText() async {
    if (translatedText.trim().isEmpty) {
      return;
    }

    await _textToSpeechService.speak(
      text: translatedText,
      bcpCode: targetLanguage.defaultTtsLocale,
    );
  }

  @action
  void toggleAutoSpeak() {
    autoSpeakTranslation = !autoSpeakTranslation;
  }

  void _applyDefaultLanguages() {
    sourceLanguage = LanguageOption.defaultSource;
    targetLanguage = LanguageOption.defaultTarget;
    if (sourceLanguage == targetLanguage) {
      targetLanguage = supportedLanguages.firstWhere(
        (LanguageOption language) => language != sourceLanguage,
        orElse: () => supportedLanguages.first,
      );
    }
    _updateResolvedSpeechLocale();
  }

  void _updateResolvedSpeechLocale() {
    final NativeSpeechSessionConfig sessionConfig = _speechService
        .resolveSessionConfig(
          bcpCode: sourceLanguage.bcpCode,
          fallbackLocaleId: sourceLanguage.defaultTtsLocale,
        );
    activeSpeechLocale = sessionConfig.localeId;
    _useOnDeviceSpeech = sessionConfig.onDevice;
  }

  Future<void> _prepareTranslator() async {
    while (!_isDisposed) {
      final String pairKey = _currentLanguagePairKey;

      if (_prepareTranslatorTask != null) {
        await _prepareTranslatorTask;
        if (pairKey == _currentLanguagePairKey) {
          return;
        }
        continue;
      }

      final LanguageOption source = sourceLanguage;
      final LanguageOption target = targetLanguage;
      _prepareTranslatorTask = _runPrepareTranslator(pairKey, source, target);

      try {
        await _prepareTranslatorTask;
      } finally {
        _prepareTranslatorTask = null;
      }

      if (pairKey == _currentLanguagePairKey) {
        return;
      }
    }
  }

  Future<void> _runPrepareTranslator(
    String pairKey,
    LanguageOption source,
    LanguageOption target,
  ) async {
    if (source == target) {
      return;
    }

    runInAction(() {
      isPreparingModels = true;
      errorText = '';
      statusText =
          'Preparing ${source.label} -> ${target.label} offline model...';
    });

    try {
      await _translationService.prepare(
        sourceLanguage: source,
        targetLanguage: target,
      );

      if (_isDisposed || pairKey != _currentLanguagePairKey) {
        return;
      }

      runInAction(() {
        isPreparingModels = false;
        if (!isListening && !isSessionActive) {
          statusText = _idleStatusLabel();
        }
      });
    } catch (error) {
      if (_isDisposed || pairKey != _currentLanguagePairKey) {
        return;
      }

      runInAction(() {
        isPreparingModels = false;
        statusText = 'Could not prepare the offline model.';
        errorText = _friendlyError(error.toString());
      });
    }
  }

  String _composeTranscript({
    required String committedTranscript,
    required String liveTranscript,
  }) {
    final List<String> parts = <String>[
      committedTranscript.trim(),
      liveTranscript.trim(),
    ].where((String part) => part.isNotEmpty).toList();

    return parts.join(' ').trim();
  }

  String _normalizeText(String rawText) {
    return rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _handleTextToSpeechStart() {
    if (_isDisposed) {
      return;
    }

    runInAction(() {
      isSpeaking = true;
    });
    _autoTtsStarted = true;
  }

  void _handleTextToSpeechComplete() {
    if (_isDisposed) {
      return;
    }

    runInAction(() {
      isSpeaking = false;
    });
  }

  Future<void> _speakAutoTranslation(String translation) async {
    _autoTtsStarted = false;

    try {
      await _textToSpeechService.speak(
        text: translation,
        bcpCode: targetLanguage.defaultTtsLocale,
      );

      final DateTime startDeadline = DateTime.now().add(
        const Duration(milliseconds: 1800),
      );
      while (!_isDisposed &&
          !_autoTtsStarted &&
          !isSpeaking &&
          DateTime.now().isBefore(startDeadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }

      if (!_autoTtsStarted && !isSpeaking) {
        return;
      }

      if (!isSpeaking) {
        return;
      }

      final DateTime completionDeadline = DateTime.now().add(
        const Duration(seconds: 20),
      );
      while (!_isDisposed &&
          isSpeaking &&
          DateTime.now().isBefore(completionDeadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      if (isSpeaking) {
        runInAction(() {
          isSpeaking = false;
        });
      }
    } finally {
      _autoTtsStarted = false;
    }
  }

  void _resetForNewTurn({bool clearError = false}) {
    _translationDebounce?.cancel();
    _translationTicket += 1;
    _committedTranscript = '';
    _liveTranscript = '';
    runInAction(() {
      transcript = '';
      translatedText = '';
      if (clearError) {
        errorText = '';
      }
    });
  }

  String _friendlySpeechError(String errorCode) {
    if (errorCode.contains('error_language_unavailable') ||
        errorCode.contains('error_language_not_supported')) {
      if (!_useOnDeviceSpeech) {
        return 'This device does not support ${sourceLanguage.label} speech recognition.';
      }
      return 'This device does not have an offline ${sourceLanguage.label} speech pack installed.';
    }

    if (errorCode.contains('error_permission')) {
      return 'Microphone or speech recognition permission was denied.';
    }

    if (errorCode.contains('error_network') ||
        errorCode.contains('error_server')) {
      if (_useOnDeviceSpeech) {
        return 'Offline speech is unavailable for ${sourceLanguage.label} on this device.';
      }
      return 'The device speech recognizer could not reach its recognition service.';
    }

    if (errorCode.contains('error_no_match')) {
      return 'No speech was detected in the last segment.';
    }

    return _friendlyError(errorCode);
  }

  String _friendlyError(String rawError) {
    final String cleanedError = rawError
        .replaceAll('Exception: ', '')
        .replaceAll('error_', '')
        .replaceAll('_', ' ')
        .trim();

    if (cleanedError.isEmpty) {
      return 'Unknown error.';
    }

    return '${cleanedError[0].toUpperCase()}${cleanedError.substring(1)}';
  }

  String _listeningStatusLabel() {
    if (handsFreeMode) {
      if (_useOnDeviceSpeech) {
        return 'Hands-free listening on-device in ${sourceLanguage.label}...';
      }
      return 'Hands-free listening in ${sourceLanguage.label}...';
    }

    if (_useOnDeviceSpeech) {
      return 'Listening on-device in ${sourceLanguage.label}. Release to stop.';
    }
    return 'Listening in ${sourceLanguage.label}. Release to stop.';
  }

  String _sessionWaitingStatusLabel() {
    if (handsFreeMode) {
      return 'Listening for speech in ${sourceLanguage.label}...';
    }
    return 'Keep holding and speak in ${sourceLanguage.label}...';
  }

  String _idleStatusLabel() {
    if (handsFreeMode) {
      if (hasTranscript) {
        return 'Tap the mic for another hands-free turn.';
      }
      return 'Tap the mic to start hands-free listening.';
    }
    if (hasTranscript) {
      return 'Press and hold the mic for another turn.';
    }
    return 'Press and hold the mic button, then speak.';
  }

  Duration get _speechPauseDuration =>
      handsFreeMode
          ? const Duration(milliseconds: 3500)
          : const Duration(seconds: 4);

  Duration get _speechListenDuration =>
      handsFreeMode
          ? const Duration(seconds: 120)
          : const Duration(seconds: 45);

  Future<void> dispose() async {
    _isDisposed = true;
    _keepListening = false;
    _restartQueued = false;
    _handsFreeTurnFinalizing = false;
    _holdTurnFinalizing = false;
    _clearOnNextSpeechResult = false;
    _currentTurnHasSpeech = false;
    isSessionActive = false;
    _translationDebounce?.cancel();

    await _vadService.dispose();
    await _speechService.stop();
    await _textToSpeechService.stop();
    await _translationService.dispose();
  }
}
