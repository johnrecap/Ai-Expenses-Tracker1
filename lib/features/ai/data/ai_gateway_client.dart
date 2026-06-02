// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import 'ai_gateway_models.dart';

typedef AiAuthTokenProvider = Future<String?> Function();
typedef AiHttpPost =
    Future<http.Response> Function(
      Uri url, {
      Map<String, String>? headers,
      Object? body,
      Encoding? encoding,
    });

class AiGatewayClient {
  AiGatewayClient({
    Uri? baseUri,
    http.Client? httpClient,
    AiAuthTokenProvider? tokenProvider,
    Duration timeout = const Duration(seconds: 8),
  }) : _baseUri = baseUri ?? AppConfig.aiGatewayUri,
       _httpClient = httpClient,
       _tokenProvider = tokenProvider ?? _firebaseTokenProvider,
       _timeout = timeout;

  final Uri _baseUri;
  final http.Client? _httpClient;
  final AiAuthTokenProvider _tokenProvider;
  final Duration _timeout;

  Future<AiGatewayDraftResponse> parseExpense(
    AiGatewayParseTextRequest request,
  ) async {
    final json = await _postJson('aiParse', request.toJson());
    return _readDraftResponse(json);
  }

  Future<AiGatewayDraftResponse> extractReceipt(
    AiGatewayReceiptRequest request,
  ) async {
    final json = await _postJson('aiReceipt', request.toJson());
    return _readDraftResponse(json);
  }

  Future<AiGatewayAdviceResponse> getAdvice(
    AiGatewayAdviceRequest request,
  ) async {
    final json = await _postJson('aiAdvice', request.toJson());
    final structured = _readStructuredJson(json);
    return AiGatewayAdviceResponse(
      requestId: _readRequestId(json),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      quota: _readQuota(json['quota']),
      advice: structured['advice'] as String? ?? '',
      groundedSummary: structured['groundedSummary'] as String? ?? '',
    );
  }

  Future<Map<String, Object?>> _postJson(
    String path,
    Map<String, Object?> payload,
  ) async {
    final token = await _tokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw const AiGatewayClientException(
        code: AiGatewayErrorCode.unauthenticated,
        message: 'Sign in to use AI.',
      );
    }

    http.Response response;
    try {
      final post = _httpClient?.post ?? http.post;
      response = await post(
        _endpoint(path),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(_timeout);
    } on TimeoutException {
      throw const AiGatewayClientException(
        code: AiGatewayErrorCode.providerTimeout,
        message: 'AI timed out.',
      );
    } on Object {
      throw const AiGatewayClientException(
        code: AiGatewayErrorCode.network,
        message: 'Network problem.',
      );
    }

    final decoded = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = aiGatewayErrorCodeFromWire(decoded['errorCode'] as String?);
      throw AiGatewayClientException(
        code: code,
        message: safeAiGatewayMessage(code, decoded['errorMessage'] as String?),
        requestId: decoded['requestId'] as String?,
        quota: _readQuota(decoded['quota']),
      );
    }

    if (decoded['ok'] != true) {
      throw const AiGatewayClientException(
        code: AiGatewayErrorCode.invalidResponse,
        message: 'AI could not finish.',
      );
    }
    return decoded;
  }

  Uri _endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = _baseUri.path.endsWith('/') ? _baseUri.path : '${_baseUri.path}/';
    return _baseUri.replace(path: '$basePath$normalizedPath');
  }

  Map<String, Object?> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } on FormatException {
      // Fall through to a safe typed error. Do not include the raw body.
    }
    throw const AiGatewayClientException(
      code: AiGatewayErrorCode.invalidResponse,
      message: 'AI could not finish.',
    );
  }

  AiGatewayDraftResponse _readDraftResponse(Map<String, Object?> json) {
    return AiGatewayDraftResponse(
      requestId: _readRequestId(json),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      quota: _readQuota(json['quota']),
      draft: AiGatewayExpenseDraft.fromJson(_readStructuredJson(json)),
    );
  }

  Map<String, Object?> _readStructuredJson(Map<String, Object?> json) {
    final structured = json['structuredJson'];
    if (structured is Map<String, Object?>) return structured;
    if (structured is Map) {
      return structured.map((key, value) => MapEntry('$key', value));
    }
    throw const AiGatewayClientException(
      code: AiGatewayErrorCode.invalidResponse,
      message: 'AI could not finish.',
    );
  }

  String _readRequestId(Map<String, Object?> json) {
    final requestId = json['requestId'] as String?;
    if (requestId == null || requestId.trim().isEmpty) {
      throw const AiGatewayClientException(
        code: AiGatewayErrorCode.invalidResponse,
        message: 'AI could not finish.',
      );
    }
    return requestId;
  }

  AiGatewayQuotaStatus? _readQuota(Object? value) {
    if (value is Map<String, Object?>) {
      return AiGatewayQuotaStatus.fromJson(value);
    }
    if (value is Map) {
      return AiGatewayQuotaStatus.fromJson(
        value.map((key, item) => MapEntry('$key', item)),
      );
    }
    return null;
  }

  static Future<String?> _firebaseTokenProvider() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}
