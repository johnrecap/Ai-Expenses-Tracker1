import 'dart:convert';
import 'package:http/http.dart' as http;

class AiGatewayClient {
  final String baseUrl;
  final http.Client _client;

  AiGatewayClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getAuthToken() async => null;

  Future<Map<String, dynamic>> parseExpense(String text, {String? authToken}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/aiParse'),
      headers: _headers(authToken),
      body: jsonEncode({'text': text}),
    ).timeout(const Duration(seconds: 10));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> extractReceipt(String imageBase64, {String? authToken}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/aiReceipt'),
      headers: _headers(authToken),
      body: jsonEncode({'image': imageBase64}),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAdvice(Map<String, dynamic> summary, {String? authToken}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/aiAdvice'),
      headers: _headers(authToken),
      body: jsonEncode({'summary': summary}),
    ).timeout(const Duration(seconds: 10));
    return _handleResponse(response);
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['ok'] == true) return body;
      throw AiGatewayException(body['error'] as String? ?? 'AI gateway error', body['code'] as String?);
    }
    throw AiGatewayException('Gateway returned ${response.statusCode}', 'http_${response.statusCode}');
  }
}

class AiGatewayException implements Exception {
  final String message;
  final String? code;
  AiGatewayException(this.message, this.code);
  @override
  String toString() => 'AiGatewayException($code): $message';
}
