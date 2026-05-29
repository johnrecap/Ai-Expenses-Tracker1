import 'dart:convert';
import 'package:http/http.dart' as http;

class VpsApiConfig {
  final String baseUrl;

  const VpsApiConfig({required this.baseUrl});

  factory VpsApiConfig.fromEnvironment() {
    const url = String.fromEnvironment('VPS_API_BASE_URL', defaultValue: '');
    return VpsApiConfig(baseUrl: url);
  }

  bool get isConfigured => baseUrl.isNotEmpty;
}

class VpsApiClient {
  final Uri baseUri;
  final Future<String?> Function() tokenProvider;
  final http.Client _client;

  VpsApiClient({required this.baseUri, required this.tokenProvider, http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> bootstrap(String deviceId) async {
    final response = await _post('$baseUri/v1/bootstrap', {'deviceId': deviceId});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pushChanges({required String deviceId, required List<Map<String, dynamic>> changes}) async {
    final response = await _post('$baseUri/v1/sync/push', {'deviceId': deviceId, 'changes': changes});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pullChanges({required int? cursor}) async {
    final body = <String, dynamic>{};
    if (cursor != null) body['cursor'] = cursor;
    final response = await _post('$baseUri/v1/sync/pull', body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    final token = await tokenProvider();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return _client.post(Uri.parse(url), headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
  }
}
