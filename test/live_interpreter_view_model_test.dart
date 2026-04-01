import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:synthex/service/native_permission_service.dart';
import 'package:synthex/service/native_speech_to_text_service.dart';
import 'package:synthex/service/native_text_to_speech_service.dart';
import 'package:synthex/service/native_translation_service.dart';
import 'package:synthex/view/live_interpreter/model/language_option.dart';
import 'package:synthex/view/live_interpreter/view_model/live_interpreter_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveInterpreterViewModel', () {
    test('init uses the default English to German pair', () async {
      final FakeTranslationService translationService =
          FakeTranslationService();
      final LiveInterpreterViewModel model = LiveInterpreterViewModel(
        permissionService: FakePermissionService(),
        speechService: FakeSpeechService(systemLocaleId: 'tr_TR'),
        textToSpeechService: FakeTextToSpeechService(),
        translationService: translationService,
      );

      await model.init();

      expect(model.sourceLanguage.label, 'English');
      expect(model.targetLanguage.label, 'German');
      expect(translationService.preparedPairs, <String>['en->de']);
    });

    test('swapLanguages retranslates the current transcript', () async {
      final FakeTranslationService translationService =
          FakeTranslationService();
      final LiveInterpreterViewModel model = LiveInterpreterViewModel(
        permissionService: FakePermissionService(),
        speechService: FakeSpeechService(systemLocaleId: 'en_US'),
        textToSpeechService: FakeTextToSpeechService(),
        translationService: translationService,
      );

      await model.init();
      final String initialSourceLabel = model.sourceLanguage.label;
      final String initialTargetLabel = model.targetLanguage.label;
      model.transcript = 'hello world';

      await model.swapLanguages();
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(model.sourceLanguage.label, initialTargetLabel);
      expect(model.targetLanguage.label, initialSourceLabel);
      expect(
        model.translatedText,
        '${model.sourceLanguage.bcpCode}->${model.targetLanguage.bcpCode}:hello world',
      );
    });

    test('clearTranscript resets both transcript buffers', () {
      final LiveInterpreterViewModel model = LiveInterpreterViewModel(
        permissionService: FakePermissionService(),
        speechService: FakeSpeechService(systemLocaleId: 'en_US'),
        textToSpeechService: FakeTextToSpeechService(),
        translationService: FakeTranslationService(),
      );

      model.transcript = 'hello';
      model.translatedText = 'merhaba';

      model.clearTranscript();

      expect(model.transcript, isEmpty);
      expect(model.translatedText, isEmpty);
    });

    test(
      'startListening falls back to the device recognizer when offline STT is unavailable',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
          onDeviceSpeech: false,
        );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: FakeTextToSpeechService(),
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.startListening();

        expect(model.isSessionActive, isTrue);
        expect(model.isListening, isTrue);
        expect(model.errorText, isEmpty);
        expect(speechService.listenRequests.single.onDevice, isFalse);
        expect(model.statusText, 'Listening in English. Release to stop.');
      },
    );

    test('startListening clears previous transcript and translation', () async {
      final LiveInterpreterViewModel model = LiveInterpreterViewModel(
        permissionService: FakePermissionService(),
        speechService: FakeSpeechService(systemLocaleId: 'en_US'),
        textToSpeechService: FakeTextToSpeechService(),
        translationService: FakeTranslationService(),
      );

      await model.init();
      model.transcript = 'old transcript';
      model.translatedText = 'old translation';

      await model.startListening();

      expect(model.transcript, isEmpty);
      expect(model.translatedText, isEmpty);
    });

    test('hands-free mode rearms after silence for the next phrase', () async {
      final FakeSpeechService speechService = FakeSpeechService(
        systemLocaleId: 'en_US',
      );
      final LiveInterpreterViewModel model = LiveInterpreterViewModel(
        permissionService: FakePermissionService(),
        speechService: speechService,
        textToSpeechService: FakeTextToSpeechService(),
        translationService: FakeTranslationService(),
      );

      await model.init();
      await model.setHandsFreeMode(true);
      final String sourceLabel = model.sourceLanguage.label;
      await model.startListening();
      speechService.emitStatus(SpeechToText.notListeningStatus);
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(model.isSessionActive, isTrue);
      expect(model.isListening, isTrue);
      expect(speechService.listenRequests.length, 2);
      expect(
        speechService.listenRequests.first.pauseFor,
        const Duration(milliseconds: 3500),
      );
      expect(
        model.statusText,
        'Hands-free listening on-device in $sourceLabel...',
      );
    });

    test(
      'hands-free mode retries when the first iOS no-match rearm does not start',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: FakeTextToSpeechService(),
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.setHandsFreeMode(true);
        await model.startListening();

        speechService.queuedListenResults.addAll(<bool>[false, true]);
        speechService.emitStatus(SpeechToText.notListeningStatus);
        speechService.emitError('error_no_match', permanent: true);
        speechService.emitStatus(SpeechToText.doneStatus);

        await Future<void>.delayed(const Duration(milliseconds: 1700));

        expect(model.isSessionActive, isTrue);
        expect(model.isListening, isTrue);
        expect(model.errorText, isEmpty);
        expect(speechService.listenRequests.length, 3);
      },
    );

    test(
      'hands-free mode auto-speaks the translated final result and rearms',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final FakeTextToSpeechService textToSpeechService =
            FakeTextToSpeechService();
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: textToSpeechService,
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.setHandsFreeMode(true);
        final String expectedTranslation =
            '${model.sourceLanguage.bcpCode}->${model.targetLanguage.bcpCode}:hello there';
        await model.startListening();
        speechService.emitResult('hello there', finalResult: true);
        speechService.emitStatus(SpeechToText.doneStatus);
        await Future<void>.delayed(const Duration(milliseconds: 900));

        expect(model.translatedText, expectedTranslation);
        expect(textToSpeechService.spokenTexts, <String>[expectedTranslation]);
        expect(model.isSessionActive, isTrue);
        expect(model.isListening, isTrue);
        expect(speechService.listenRequests.length, 2);
      },
    );

    test(
      'hands-free mode waits for delayed TTS playback before rearming the mic',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final FakeTextToSpeechService textToSpeechService =
            FakeTextToSpeechService(
              startDelay: const Duration(milliseconds: 350),
              completionDelay: const Duration(milliseconds: 1200),
              returnBeforeCompletion: true,
            );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: textToSpeechService,
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.setHandsFreeMode(true);
        await model.startListening();
        speechService.emitResult('hello there', finalResult: true);
        speechService.emitStatus(SpeechToText.doneStatus);
        await Future<void>.delayed(const Duration(milliseconds: 900));

        expect(model.isSpeaking, isTrue);
        expect(model.isListening, isFalse);
        expect(speechService.listenRequests.length, 1);

        await Future<void>.delayed(const Duration(milliseconds: 1600));

        expect(model.isSpeaking, isFalse);
        expect(model.isListening, isTrue);
        expect(speechService.listenRequests.length, 2);
      },
    );

    test(
      'hands-free mode ignores likely TTS echo instead of looping the last translation',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final FakeTextToSpeechService textToSpeechService =
            FakeTextToSpeechService();
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: textToSpeechService,
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.setHandsFreeMode(true);
        await model.startListening();
        speechService.emitResult('hello there', finalResult: true);
        speechService.emitStatus(SpeechToText.doneStatus);
        await Future<void>.delayed(const Duration(milliseconds: 900));

        final String echoText = model.translatedText;

        speechService.emitResult(echoText, finalResult: true);
        speechService.emitStatus(SpeechToText.doneStatus);
        await Future<void>.delayed(const Duration(milliseconds: 900));

        expect(textToSpeechService.spokenTexts, <String>[echoText]);
        expect(model.transcript, 'hello there');
        expect(model.translatedText, echoText);
        expect(speechService.listenRequests.length, 3);
      },
    );

    test(
      'hands-free mode clears the previous turn when new speech begins',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final FakeTextToSpeechService textToSpeechService =
            FakeTextToSpeechService();
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: textToSpeechService,
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.setHandsFreeMode(true);
        await model.startListening();
        speechService.emitResult('first phrase', finalResult: true);
        speechService.emitStatus(SpeechToText.doneStatus);
        await Future<void>.delayed(const Duration(milliseconds: 900));
        final String expectedTranslation =
            '${model.sourceLanguage.bcpCode}->${model.targetLanguage.bcpCode}:first phrase';
        speechService.emitResult('second phrase', finalResult: false);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(model.transcript, 'second phrase');
        expect(model.translatedText, isEmpty);
        expect(textToSpeechService.spokenTexts, <String>[expectedTranslation]);
      },
    );

    test(
      'finishHoldTurn waits briefly before stopping and keeps the last words',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final FakeTextToSpeechService textToSpeechService =
            FakeTextToSpeechService();
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: textToSpeechService,
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.startListening();
        speechService.emitResult('hello there', finalResult: false);

        final Future<void> finishFuture = model.finishHoldTurn();
        await Future<void>.delayed(const Duration(milliseconds: 150));

        expect(speechService.stopCalls, 0);
        expect(model.statusText, 'Finishing your last words...');

        await finishFuture;

        final String expectedTranslation =
            '${model.sourceLanguage.bcpCode}->${model.targetLanguage.bcpCode}:hello there';
        expect(speechService.stopCalls, 1);
        expect(model.transcript, 'hello there');
        expect(model.translatedText, expectedTranslation);
        expect(textToSpeechService.spokenTexts, <String>[expectedTranslation]);
        expect(model.isSessionActive, isFalse);
        expect(model.isListening, isFalse);
      },
    );

    test(
      'stale listening status after stop does not reactivate the session',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: FakeTextToSpeechService(),
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.startListening();
        await model.stopListening();
        speechService.emitStatus(SpeechToText.listeningStatus);

        expect(model.isSessionActive, isFalse);
        expect(model.isListening, isFalse);
        expect(model.statusText, 'Press and hold the mic button, then speak.');
      },
    );

    test(
      'session remains active while the mic is held and the recognizer cycles between phrases',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: FakeTextToSpeechService(),
          translationService: FakeTranslationService(),
        );

        await model.init();
        await model.startListening();
        speechService.emitStatus(SpeechToText.notListeningStatus);
        await Future<void>.delayed(const Duration(milliseconds: 450));

        expect(model.isSessionActive, isTrue);
        expect(speechService.listenRequests.length, 2);
        expect(
          model.statusText,
          'Listening on-device in English. Release to stop.',
        );
      },
    );

    test(
      'stopListening aborts startup when the user releases before speech begins',
      () async {
        final FakeSpeechService speechService = FakeSpeechService(
          systemLocaleId: 'en_US',
        );
        final LiveInterpreterViewModel model = LiveInterpreterViewModel(
          permissionService: FakePermissionService(),
          speechService: speechService,
          textToSpeechService: FakeTextToSpeechService(),
          translationService: FakeTranslationService(
            prepareDelay: const Duration(milliseconds: 120),
          ),
        );

        await model.init();
        final Future<void> startFuture = model.startListening();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await model.stopListening();
        await startFuture;

        expect(model.isSessionActive, isFalse);
        expect(model.isListening, isFalse);
        expect(speechService.listenRequests, isEmpty);
        expect(model.statusText, 'Press and hold the mic button, then speak.');
      },
    );
  });
}

class FakePermissionService extends NativePermissionService {
  @override
  Future<PermissionStatus> microphoneStatus() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> requestMicrophonePermission() async =>
      PermissionStatus.granted;
}

class FakeSpeechService extends NativeSpeechToTextService {
  FakeSpeechService({required this.systemLocaleId, this.onDeviceSpeech = true});

  @override
  final String? systemLocaleId;

  final bool onDeviceSpeech;
  final List<FakeListenRequest> listenRequests = <FakeListenRequest>[];
  final List<bool> queuedListenResults = <bool>[];
  int stopCalls = 0;
  bool _isListening = false;
  SpeechErrorListener? _errorListener;
  SpeechStatusListener? _statusListener;
  SpeechResultListener? _resultListener;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
  }) async {
    _errorListener = onError;
    _statusListener = onStatus;
    return true;
  }

  @override
  String? resolveLocaleId(String bcpCode) {
    return '${bcpCode}_TEST';
  }

  @override
  NativeSpeechSessionConfig resolveSessionConfig({
    required String bcpCode,
    String? fallbackLocaleId,
  }) {
    final String resolvedLocaleId = onDeviceSpeech
        ? '${bcpCode}_TEST'
        : (fallbackLocaleId ?? '${bcpCode}_TEST').replaceAll('-', '_');

    return NativeSpeechSessionConfig(
      localeId: resolvedLocaleId,
      onDevice: onDeviceSpeech,
    );
  }

  @override
  Future<bool> listen({
    required String localeId,
    required bool onDevice,
    required SpeechResultListener onResult,
    Duration pauseFor = const Duration(seconds: 4),
    Duration listenFor = const Duration(seconds: 45),
    SpeechSoundLevelChange? onSoundLevelChange,
  }) async {
    _resultListener = onResult;
    listenRequests.add(
      FakeListenRequest(
        localeId: localeId,
        onDevice: onDevice,
        pauseFor: pauseFor,
      ),
    );
    final bool shouldStart = queuedListenResults.isEmpty
        ? true
        : queuedListenResults.removeAt(0);
    if (shouldStart) {
      _isListening = true;
      _statusListener?.call(SpeechToText.listeningStatus);
    }

    return shouldStart;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _isListening = false;
  }

  void emitStatus(String status) {
    if (status == SpeechToText.listeningStatus) {
      _isListening = true;
    } else if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _isListening = false;
    }
    _statusListener?.call(status);
  }

  void emitResult(String text, {required bool finalResult}) {
    _resultListener?.call(
      SpeechRecognitionResult(<SpeechRecognitionWords>[
        SpeechRecognitionWords(text, null, 0.92),
      ], finalResult),
    );
  }

  void emitError(String errorMsg, {required bool permanent}) {
    _errorListener?.call(SpeechRecognitionError(errorMsg, permanent));
  }
}

class FakeTextToSpeechService extends NativeTextToSpeechService {
  FakeTextToSpeechService({
    this.startDelay = Duration.zero,
    this.completionDelay = Duration.zero,
    this.returnBeforeCompletion = false,
  });

  final List<String> spokenTexts = <String>[];
  final Duration startDelay;
  final Duration completionDelay;
  final bool returnBeforeCompletion;
  void Function()? _onStart;
  void Function()? _onComplete;

  @override
  Future<void> initialize({
    void Function()? onStart,
    void Function()? onComplete,
    void Function(String message)? onError,
  }) async {
    _onStart = onStart;
    _onComplete = onComplete;
  }

  @override
  Future<void> speak({required String text, required String bcpCode}) async {
    spokenTexts.add(text);
    final Future<void> playback = Future<void>(() async {
      if (startDelay > Duration.zero) {
        await Future<void>.delayed(startDelay);
      }
      _onStart?.call();

      if (completionDelay > Duration.zero) {
        await Future<void>.delayed(completionDelay);
      }
      _onComplete?.call();
    });

    if (!returnBeforeCompletion) {
      await playback;
    }
  }

  @override
  Future<void> stop() async {
    _onComplete?.call();
  }
}

class FakeTranslationService extends NativeTranslationService {
  FakeTranslationService({this.prepareDelay = Duration.zero});

  final List<String> preparedPairs = <String>[];
  final Duration prepareDelay;

  @override
  Future<void> prepare({
    required LanguageOption sourceLanguage,
    required LanguageOption targetLanguage,
  }) async {
    if (prepareDelay > Duration.zero) {
      await Future<void>.delayed(prepareDelay);
    }
    preparedPairs.add('${sourceLanguage.bcpCode}->${targetLanguage.bcpCode}');
  }

  @override
  Future<String> translate({
    required String text,
    required LanguageOption sourceLanguage,
    required LanguageOption targetLanguage,
  }) async {
    return '${sourceLanguage.bcpCode}->${targetLanguage.bcpCode}:$text';
  }

  @override
  Future<void> dispose() async {}
}

class FakeListenRequest {
  FakeListenRequest({
    required this.localeId,
    required this.onDevice,
    required this.pauseFor,
  });

  final String localeId;
  final bool onDevice;
  final Duration pauseFor;
}
