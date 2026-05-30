import 'dart:async' show Completer;
import 'dart:developer' as developer;

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'ai_expense_service.dart';

/// {@template voice_input_service}
/// Service that records audio input and converts it to structured expense data
/// using the device's speech-to-text capabilities.
///
/// Wraps the `speech_to_text` package with a simpler API that integrates
/// directly with [AiExpenseService] to produce an [AiExpenseResult].
/// {@endtemplate}
class VoiceInputService {
  /// Creates a [VoiceInputService].
  ///
  /// [aiExpenseService] is used to process the transcribed text into a
  /// structured expense. [speechToText] can be injected for testing.
  VoiceInputService({
    required this.aiExpenseService,
    SpeechToText? speechToText,
  }) : _speech = speechToText ?? SpeechToText();

  /// The AI expense service that turns text into structured data.
  final AiExpenseService aiExpenseService;

  final SpeechToText _speech;
  bool _initialized = false;

  /// Whether the service is currently listening for voice input.
  bool get isListening => _speech.isListening;

  /// Whether the speech recognizer has been initialized.
  bool get isInitialized => _initialized;

  /// Initializes the speech-to-text engine.
  ///
  /// Must be called before [startListening].
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          developer.log('Speech status: $status', name: 'VoiceInputService');
        },
        onError: (error) {
          developer.log(
            'Speech error: ${error.errorMsg}',
            name: 'VoiceInputService',
            error: error,
          );
        },
        options: [SpeechToText.androidNoBluetooth],
      );
      _initialized = available;
      return available;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to initialize speech-to-text',
        name: 'VoiceInputService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Starts listening for voice input and returns the final transcribed text.
  ///
  /// [localeId] can be used to set a specific language (e.g. 'ar_EG', 'en_US').
  /// [listenFor] limits the total listening duration.
  /// [pauseFor] sets how long to wait after speech stops before finalizing.
  ///
  /// [onPartialResult] is called with interim transcription results.
  ///
  /// Returns the final transcribed text, or `null` if listening failed.
  Future<String?> startListening({
    String? localeId,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 5),
    void Function(String partialText)? onPartialResult,
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return null;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    String? finalText;
    final completer = Completer<String?>();

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          final text = result.recognizedWords;
          if (result.finalResult) {
            finalText = text;
            if (!completer.isCompleted) completer.complete(text);
          } else {
            onPartialResult?.call(text);
          }
        },
        listenOptions: SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          localeId: localeId,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
        ),
      );
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to start listening',
        name: 'VoiceInputService',
        error: e,
        stackTrace: stackTrace,
      );
      if (!completer.isCompleted) completer.complete(null);
    }

    // Safety timeout in case the recognizer never returns a final result.
    Future.delayed(listenFor + const Duration(seconds: 2), () {
      if (!completer.isCompleted) completer.complete(finalText);
    });

    return completer.future;
  }

  /// Stops listening immediately and returns whatever was captured so far.
  Future<String?> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    return null;
  }

  /// Cancels the current listening session without returning results.
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  /// Convenience method that listens for voice input, then processes the
  /// transcribed text through [AiExpenseService] to produce an expense draft.
  ///
  /// Returns an [AiExpenseResult] containing the parsed expense, or an empty
  /// result if transcription or parsing failed.
  Future<AiExpenseResult> listenAndParse({
    String? localeId,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 5),
    void Function(String partialText)? onPartialResult,
  }) async {
    final text = await startListening(
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: pauseFor,
      onPartialResult: onPartialResult,
    );

    if (text == null || text.trim().isEmpty) {
      return AiExpenseResult.empty('');
    }

    return aiExpenseService.processInput(text);
  }

  /// Returns a list of available speech recognition locales.
  Future<List<SpeechLocale>> getAvailableLocales() async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return const [];
    }
    try {
      final locales = await _speech.locales();
      return locales
          .map((l) => SpeechLocale(localeId: l.localeId, name: l.name))
          .toList();
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to get locales',
        name: 'VoiceInputService',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Disposes the speech recognizer.
  Future<void> dispose() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
    _initialized = false;
  }
}

/// {@template speech_locale}
/// Represents an available speech recognition locale.
/// {@endtemplate}
class SpeechLocale {
  /// Creates a [SpeechLocale].
  const SpeechLocale({required this.localeId, required this.name});

  /// The locale identifier (e.g. 'ar_EG', 'en_US').
  final String localeId;

  /// Human-readable name of the locale.
  final String name;
}
