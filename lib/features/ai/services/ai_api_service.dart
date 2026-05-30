import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/ai/models/ai_parsed_expense.dart';

/// AI API Service that routes all requests through the aaPanel AI Proxy.
///
/// No direct Gemini/Groq API keys are stored in the app. The proxy handles
/// authentication with the actual AI providers using server-side secrets.
///
/// Required .env variables:
///   PROXY_URL      – e.g. https://api.saeeddev.com
///   PROXY_API_KEY  – simple auth key sent in X-API-Key header
class AiApiService {
  late final String _proxyUrl;
  late final String _proxyApiKey;

  AiApiService() {
    _proxyUrl = (dotenv.env['PROXY_URL'] ?? '').trim();
    _proxyApiKey = (dotenv.env['PROXY_API_KEY'] ?? '').trim();
  }

  bool get isConfigured => _proxyUrl.isNotEmpty && _proxyApiKey.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-API-Key': _proxyApiKey,
      };

  /// Parse natural-language expense text via the proxy (→ Gemini).
  Future<AiParsedExpense?> parseExpense(String input) async {
    if (!isConfigured) {
      developer.log('AI Proxy not configured', name: 'AiApiService');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_proxyUrl/parseExpense'),
        headers: _headers,
        body: jsonEncode({'text': input}),
      );

      if (response.statusCode != 200) {
        developer.log(
          'Proxy /parseExpense error: ${response.statusCode} ${response.body}',
          name: 'AiApiService',
        );
        return null;
      }

      final data = jsonDecode(response.body);
      final text = data['result'] as String?;
      if (text == null) return null;

      return _parseResponse(text, input);
    } catch (e) {
      developer.log('AI parsing failed: $e', name: 'AiApiService');
      return null;
    }
  }

  /// Get financial advice via the proxy (→ Groq).
  Future<String?> getAdvice(String prompt) async {
    if (!isConfigured) {
      developer.log('AI Proxy not configured', name: 'AiApiService');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_proxyUrl/getAdvice'),
        headers: _headers,
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode != 200) {
        developer.log(
          'Proxy /getAdvice error: ${response.statusCode} ${response.body}',
          name: 'AiApiService',
        );
        return null;
      }

      final data = jsonDecode(response.body);
      return data['result'] as String?;
    } catch (e) {
      developer.log('AI advice failed: $e', name: 'AiApiService');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  AiParsedExpense? _parseResponse(String text, String originalInput) {
    try {
      final json = jsonDecode(text);
      return _createParsedExpense(json as Map<String, dynamic>, originalInput);
    } catch (e) {
      return null;
    }
  }

  AiParsedExpense _createParsedExpense(
    Map<String, dynamic> json,
    String originalInput,
  ) {
    return AiParsedExpense(
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      currency: json['currency'] as String?,
      category: json['category'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      note: json['note'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      missingFields: _getMissingFields(json),
      originalInput: originalInput,
    );
  }

  List<String> _getMissingFields(Map<String, dynamic> json) {
    final missing = <String>[];
    if (json['amount'] == null) missing.add('amount');
    if (json['category'] == null) missing.add('category');
    if (json['date'] == null) missing.add('date');
    return missing;
  }
}
