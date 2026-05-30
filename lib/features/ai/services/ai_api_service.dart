import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../core/ai/models/ai_parsed_expense.dart';

/// خدمة الـ AI API المباشرة
/// 
/// تتصل مباشرة مع:
/// - Gemini API (Google) - الافتراضي
/// - Groq API - للسرعة
class AiApiService {
  late final String geminiKey;
  late final String groqKey;

  AiApiService() {
    geminiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    groqKey = dotenv.env['GROQ_API_KEY'] ?? '';
  }

  bool get isConfigured => geminiKey.isNotEmpty || groqKey.isNotEmpty;

  /// فهم المصروف من النص الطبيعي
  Future<AiParsedExpense?> parseExpense(String input) async {
    try {
      // نجرب Gemini أولاً
      final result = await _callGemini(input);
      if (result != null) return result;
      
      // لو فشل، نجرب Groq
      return await _callGroq(input);
    } catch (e) {
      developer.log('AI parsing failed: $e', name: 'AiApiService');
      return null;
    }
  }

  /// استدعاء نصائح مالية
  Future<String?> getAdvice(String prompt) async {
    try {
      return await _callGroqForChat(prompt);
    } catch (e) {
      developer.log('AI advice failed: $e', name: 'AiApiService');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Gemini API
  // ---------------------------------------------------------------------------

  Future<AiParsedExpense?> _callGemini(String input) async {
    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
    
    final response = await http.post(
      Uri.parse('$url?key=$geminiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{
            'text': _buildParserPrompt(input)
          }]
        }],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 256,
        }
      }),
    );

    if (response.statusCode != 200) {
      developer.log('Gemini error: ${response.statusCode} ${response.body}', name: 'AiApiService');
      return null;
    }

    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) return null;

    return _parseGeminiResponse(text, input);
  }

  // ---------------------------------------------------------------------------
  // Groq API
  // ---------------------------------------------------------------------------

  Future<AiParsedExpense?> _callGroq(String input) async {
    const url = 'https://api.groq.com/openai/v1/chat/completions';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $groqKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': input}
        ],
        'temperature': 0.1,
        'max_tokens': 256,
        'response_format': {'type': 'json_object'}
      }),
    );

    if (response.statusCode != 200) {
      developer.log('Groq error: ${response.statusCode} ${response.body}', name: 'AiApiService');
      return null;
    }

    final data = jsonDecode(response.body);
    final text = data['choices']?[0]?['message']?['content'] as String?;
    if (text == null) return null;

    return _parseGroqResponse(text, input);
  }

  Future<String?> _callGroqForChat(String prompt) async {
    const url = 'https://api.groq.com/openai/v1/chat/completions';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $groqKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'system', 'content': _advisorSystemPrompt},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 512,
      }),
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    return data['choices']?[0]?['message']?['content'] as String?;
  }

  // ---------------------------------------------------------------------------
  // Prompts
  // ---------------------------------------------------------------------------

  String get _systemPrompt => 
      'أنت مساعد ذكي لتحليل المصاريف. استخرج المعلومات من النص ورد بـ JSON. '
      'المخرجات: amount (رقم), currency (عملة), category (فئة), date (تاريخ), note (ملاحظة), confidence (0-1). '
      'الفئات: food, transport, shopping, bills, entertainment, health, other. '
      'لو مش متأكد حط null. التاريخ بصيغة YYYY-MM-DD.';

  String get _advisorSystemPrompt => 
      'أنت مستشار مالي ذكي. قدم نصائح قصيرة ومفيدة بالعربي.';

  String _buildParserPrompt(String input) => 
      'النص: "$input" '
      'استخرج المعلومات وارد JSON: '
      '{"amount": رقم أو null, "currency": "EGP" أو null, '
      '"category": "food|transport|shopping|bills|entertainment|health|other" أو null, '
      '"date": "YYYY-MM-DD" أو null, "note": "ملاحظة" أو null, "confidence": 0.0-1.0}';

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  AiParsedExpense? _parseGeminiResponse(String text, String originalInput) {
    try {
      final json = jsonDecode(text);
      return _createParsedExpense(json as Map<String, dynamic>, originalInput);
    } catch (e) {
      return null;
    }
  }

  AiParsedExpense? _parseGroqResponse(String text, String originalInput) {
    try {
      final json = jsonDecode(text);
      return _createParsedExpense(json as Map<String, dynamic>, originalInput);
    } catch (e) {
      return null;
    }
  }

  AiParsedExpense _createParsedExpense(Map<String, dynamic> json, String originalInput) {
    return AiParsedExpense(
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      category: json['category'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
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
