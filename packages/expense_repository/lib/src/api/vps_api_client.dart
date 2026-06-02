import 'dart:convert';
import 'package:http/http.dart' as http;

class VpsApiConfig {
  final String baseUrl;

  const VpsApiConfig({required this.baseUrl});

  factory VpsApiConfig.fromEnvironment() {
    const url = String.fromEnvironment('VPS_API_BASE_URL', defaultValue: '');
    return const VpsApiConfig(baseUrl: url);
  }

  bool get isConfigured => baseUrl.isNotEmpty;
}

class VpsApiClient {
  final Uri baseUri;
  final Future<String?> Function() tokenProvider;
  final http.Client _client;

  VpsApiClient({
    required this.baseUri,
    required this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> bootstrap(String _) async {
    final response = await _get('/v1/bootstrap');
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> pushChanges({
    required String deviceId,
    required List<Map<String, dynamic>> changes,
  }) async {
    final response = await _post(
      '/v1/sync/push',
      {'deviceId': deviceId, 'changes': changes},
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> pullChanges({required String? cursor}) async {
    final query = <String, String>{};
    if (cursor != null) query['cursor'] = cursor;
    final response = await _get('/v1/sync/pull', queryParameters: query);
    return _decodeMap(response);
  }

  Future<http.Response> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final token = await tokenProvider();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await _client
        .get(_uri(path, queryParameters: queryParameters), headers: headers)
        .timeout(const Duration(seconds: 15));
    _ensureSuccess(response);
    return response;
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final token = await tokenProvider();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await _client
        .post(_uri(path), headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    _ensureSuccess(response);
    return response;
  }

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final base = baseUri.toString().replaceFirst(RegExp(r'/$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw VpsApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class VpsApiException implements Exception {
  final int statusCode;
  final String body;

  const VpsApiException({required this.statusCode, required this.body});

  @override
  String toString() => 'VpsApiException(statusCode: $statusCode)';
}
