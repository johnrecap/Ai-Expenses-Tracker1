import 'dart:convert';
import 'dart:developer' as developer;

import 'models/ai_parsed_expense.dart';
import 'language_detector.dart';
import 'ai_prompts.dart';

/// {@template ai_expense_parser}
/// Parses natural language user input into structured [AiParsedExpense] data.
///
/// This parser uses an external AI service (via the Cloudflare Worker gateway)
/// to extract expense fields from free-form text. It supports both Arabic and
/// English inputs and provides confidence scores along with missing field
/// detection.
///
/// The parser is designed to be stateless and can be injected into BLoCs or
/// services. All network calls are async and should be wrapped with appropriate
/// error handling in the presentation layer.
/// {@endtemplate}
class AiExpenseParser {
  /// Creates an [AiExpenseParser] instance.
  ///
  /// [httpClient] is used to make POST requests to the AI gateway.
  /// [gatewayUrl] is the Cloudflare Worker endpoint (no API keys in source).
  /// [languageDetector] detects whether input is Arabic or English.
  AiExpenseParser({
    required this.httpClient,
    required this.gatewayUrl,
    LanguageDetector? languageDetector,
  })  : _languageDetector = languageDetector ?? const LanguageDetector(),
        _prompts = AiPrompts(
          languageDetector: languageDetector ?? const LanguageDetector(),
        );

  /// HTTP client for making AI gateway requests.
  final dynamic httpClient;

  /// URL of the AI gateway (Cloudflare Worker).
  final String gatewayUrl;

  final LanguageDetector _languageDetector;
  final AiPrompts _prompts;

  /// Parses [userInput] into an [AiParsedExpense].
  ///
  /// Returns a structured result with confidence and missing fields.
  /// If the AI service is unavailable, returns a fallback with
  /// confidence 0.0 and all fields marked as missing.
  ///
  /// Example:
  /// ```dart
  /// final result = await parser.parse('I spent 50 EGP on lunch today');
  /// print(result.amount); // 50.0
  /// print(result.currency); // "EGP"
  /// print(result.confidence); // 0.95
  /// ```
  Future<AiParsedExpense> parse(String userInput) async {
    if (userInput.trim().isEmpty) {
      return AiParsedExpense(
        amount: null,
        currency: null,
        category: null,
        date: null,
        note: null,
        confidence: 0.0,
        missingFields: const <String>[
          'amount',
          'currency',
          'category',
          'date',
          'note',
        ],
        originalInput: userInput,
      );
    }

    try {
      final prompt = _prompts.parser(userInput);
      final response = await _callAiGateway(prompt);

      if (response == null) {
        return _fallback(userInput);
      }

      final json = jsonDecode(response) as Map<String, dynamic>;
      final parsed = AiParsedExpense.fromJson(json);

      // Ensure originalInput is always the raw user text.
      return parsed.copyWith(originalInput: userInput);
    } on FormatException catch (e, stackTrace) {
      developer.log(
        'AI parser JSON decode error',
        error: e,
        stackTrace: stackTrace,
        name: 'AiExpenseParser',
      );
      return _fallback(userInput);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AI parser network/service error',
        error: e,
        stackTrace: stackTrace,
        name: 'AiExpenseParser',
      );
      return _fallback(userInput);
    }
  }

  /// Performs a lightweight parse using local heuristics only (no network).
  ///
  /// This is useful for offline mode or when the AI service is unavailable.
  /// It extracts amounts using regex and guesses the category from keywords.
  ///
  /// The returned confidence will be lower than the AI-powered [parse] method.
  AiParsedExpense parseLocal(String userInput) {
    final lower = userInput.toLowerCase();
    double? amount;
    String? currency;
    String? category;
    DateTime? date;
    String? note;
    final missingFields = <String>['amount', 'currency', 'category', 'date'];

    // Extract amount: look for numbers with optional decimal.
    final amountRegExp = RegExp(r'(\d+(?:\.\d+)?)');
    final amountMatch = amountRegExp.firstMatch(userInput);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!);
      if (amount != null) missingFields.remove('amount');
    }

    // Extract currency: look for EGP, USD, or pound/dollar keywords.
    if (lower.contains('egp') ||
        lower.contains('pound') ||
        lower.contains('جنيه') ||
        lower.contains('جنيه')) {
      currency = 'EGP';
      missingFields.remove('currency');
    } else if (lower.contains('usd') ||
        lower.contains('dollar') ||
        lower.contains('دولار')) {
      currency = 'USD';
      missingFields.remove('currency');
    }

    // Guess category from keywords.
    final categoryKeywords = <String, String>{
      'food': r'food|lunch|dinner|breakfast|restaurant|meal|أكل|غدا|فطار|طعام',
      'transport': r'transport|taxi|bus|metro|uber|train|مواصلات|تاكسي|أوبر',
      'shopping': r'shopping|clothes|shoes|market|mall|تسوق|ملابس',
      'bills': r'bill|electric|water|gas|internet|phone|فاتورة|كهرباء|ماية',
      'entertainment': r'movie|cinema|game|concert|fun|سينما|لعب',
      'health': r'doctor|hospital|medicine|pharmacy|health|دكتور|صيدلية',
    };

    for (final entry in categoryKeywords.entries) {
      if (RegExp(entry.value, caseSensitive: false).hasMatch(lower)) {
        category = entry.key;
        missingFields.remove('category');
        break;
      }
    }

    // Use the full input as a note if no other fields were found.
    if (amount != null || category != null) {
      note = userInput.trim();
      missingFields.remove('note');
    }

    // Try to parse a date from the input (very basic).
    final dateRegExp = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final dateMatch = dateRegExp.firstMatch(userInput);
    if (dateMatch != null) {
      final day = int.tryParse(dateMatch.group(1)!);
      final month = int.tryParse(dateMatch.group(2)!);
      final yearStr = dateMatch.group(3)!;
      final year = yearStr.length == 2
          ? 2000 + int.parse(yearStr)
          : int.tryParse(yearStr);
      if (day != null && month != null && year != null) {
        date = DateTime(year, month, day);
        missingFields.remove('date');
      }
    }

    // If no explicit date found, assume today.
    if (date == null) {
      date = DateTime.now();
      missingFields.remove('date');
    }

    // Calculate a rough confidence score.
    const totalFields = 5;
    final foundFields = totalFields - missingFields.length;
    final confidence = foundFields / totalFields;

    return AiParsedExpense(
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      note: note,
      confidence: confidence.clamp(0.0, 1.0),
      missingFields: List<String>.unmodifiable(missingFields),
      originalInput: userInput,
    );
  }

  /// Returns the detected language code ("ar" or "en") for [input].
  String detectLanguage(String input) => _languageDetector.detect(input);

  /// Calls the AI gateway with the given [prompt].
  ///
  /// Returns the raw response body as a String, or `null` on failure.
  /// Subclasses may override this to use a different HTTP client.
  Future<String?> _callAiGateway(String prompt) async {
    try {
      // Using dynamic to avoid hard dependency on a specific http package.
      // The caller is expected to pass an http client with a compatible API.
      final response = await httpClient.post(
        Uri.parse(gatewayUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final body = response.body as String;
        return body;
      }

      developer.log(
        'AI gateway returned status ${response.statusCode}',
        name: 'AiExpenseParser',
      );
      return null;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AI gateway call failed',
        error: e,
        stackTrace: stackTrace,
        name: 'AiExpenseParser',
      );
      return null;
    }
  }

  /// Returns a fallback [AiParsedExpense] when AI parsing fails.
  AiParsedExpense _fallback(String userInput) {
    return AiParsedExpense(
      amount: null,
      currency: null,
      category: null,
      date: null,
      note: null,
      confidence: 0.0,
      missingFields: const <String>[
        'amount',
        'currency',
        'category',
        'date',
        'note',
      ],
      originalInput: userInput,
    );
  }
}
