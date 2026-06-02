class AiGatewayCategorySnapshot {
  const AiGatewayCategorySnapshot({
    required this.categoryId,
    required this.name,
    this.isArchived = false,
  });

  final String categoryId;
  final String name;
  final bool isArchived;

  Map<String, Object?> toJson() => {
    'categoryId': categoryId,
    'name': name,
    'isArchived': isArchived,
  };
}

class AiGatewayQuotaStatus {
  const AiGatewayQuotaStatus({
    required this.requestType,
    required this.allowed,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.resetAt,
  });

  final String requestType;
  final bool allowed;
  final int limit;
  final int used;
  final int remaining;
  final DateTime? resetAt;

  factory AiGatewayQuotaStatus.fromJson(Map<String, Object?> json) {
    return AiGatewayQuotaStatus(
      requestType: json['requestType'] as String? ?? '',
      allowed: json['allowed'] as bool? ?? false,
      limit: _readInt(json['limit']),
      used: _readInt(json['used']),
      remaining: _readInt(json['remaining']),
      resetAt: DateTime.tryParse(json['resetAt'] as String? ?? ''),
    );
  }
}

class AiGatewayParseTextRequest {
  const AiGatewayParseTextRequest({
    required this.input,
    required this.now,
    required this.locale,
    required this.defaultCurrency,
    this.clientRequestId,
    this.categories = const [],
    this.recentExpenses = const [],
    this.budgetSummary,
  });

  final String input;
  final DateTime now;
  final String locale;
  final String defaultCurrency;
  final String? clientRequestId;
  final List<AiGatewayCategorySnapshot> categories;
  final List<Map<String, Object?>> recentExpenses;
  final Map<String, Object?>? budgetSummary;

  Map<String, Object?> toJson() => {
    'input': input,
    'now': now.toUtc().toIso8601String(),
    'locale': locale,
    'defaultCurrency': defaultCurrency,
    if (clientRequestId != null) 'clientRequestId': clientRequestId,
    'categories': categories.map((category) => category.toJson()).toList(),
    'recentExpenses': recentExpenses,
    if (budgetSummary != null) 'budgetSummary': budgetSummary,
  };
}

class AiGatewayReceiptRequest {
  const AiGatewayReceiptRequest({
    required this.imageBase64,
    required this.mimeType,
    required this.now,
    required this.locale,
    required this.defaultCurrency,
    this.clientRequestId,
    this.imageFingerprint,
    this.categories = const [],
  });

  final String imageBase64;
  final String mimeType;
  final DateTime now;
  final String locale;
  final String defaultCurrency;
  final String? clientRequestId;
  final String? imageFingerprint;
  final List<AiGatewayCategorySnapshot> categories;

  Map<String, Object?> toJson() => {
    'imageBase64': imageBase64,
    'mimeType': mimeType,
    'now': now.toUtc().toIso8601String(),
    'locale': locale,
    'defaultCurrency': defaultCurrency,
    if (clientRequestId != null) 'clientRequestId': clientRequestId,
    if (imageFingerprint != null) 'imageFingerprint': imageFingerprint,
    'categories': categories.map((category) => category.toJson()).toList(),
  };
}

class AiGatewayAdviceRequest {
  const AiGatewayAdviceRequest({
    required this.period,
    required this.now,
    required this.locale,
    required this.defaultCurrency,
    required this.summary,
    this.clientRequestId,
  });

  final String period;
  final DateTime now;
  final String locale;
  final String defaultCurrency;
  final Map<String, Object?> summary;
  final String? clientRequestId;

  Map<String, Object?> toJson() => {
    'period': period,
    'now': now.toUtc().toIso8601String(),
    'locale': locale,
    'defaultCurrency': defaultCurrency,
    'summary': summary,
    if (clientRequestId != null) 'clientRequestId': clientRequestId,
  };
}

class AiGatewayExpenseDraft {
  const AiGatewayExpenseDraft({
    this.amount,
    this.currency,
    this.categoryName,
    this.categoryId,
    this.date,
    this.paymentMethod,
    this.description,
    this.merchant,
    this.confidence = 0,
    this.needsConfirmation = true,
    this.clarifyingQuestion,
    this.missingFields = const [],
  });

  final double? amount;
  final String? currency;
  final String? categoryName;
  final String? categoryId;
  final DateTime? date;
  final String? paymentMethod;
  final String? description;
  final String? merchant;
  final double confidence;
  final bool needsConfirmation;
  final String? clarifyingQuestion;
  final List<String> missingFields;

  bool get canSaveBase =>
      amount != null && amount! > 0 && (currency?.trim().isNotEmpty ?? false) && date != null;

  AiGatewayExpenseDraft copyWith({
    double? amount,
    String? currency,
    String? categoryName,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    String? description,
    String? merchant,
    double? confidence,
    bool? needsConfirmation,
    String? clarifyingQuestion,
    List<String>? missingFields,
  }) {
    return AiGatewayExpenseDraft(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      confidence: confidence ?? this.confidence,
      needsConfirmation: needsConfirmation ?? this.needsConfirmation,
      clarifyingQuestion: clarifyingQuestion ?? this.clarifyingQuestion,
      missingFields: missingFields ?? this.missingFields,
    );
  }

  factory AiGatewayExpenseDraft.fromJson(Map<String, Object?> json) {
    final missingFields = <String>[
      if (json['amount'] == null) 'amount',
      if (_readString(json['categoryId']) == null && _readString(json['category']) == null)
        'category',
      if (json['date'] == null) 'date',
    ];

    return AiGatewayExpenseDraft(
      amount: _readDouble(json['amount']),
      currency: _readString(json['currency']),
      categoryName: _readString(json['category']) ?? _readString(json['suggestedCategoryName']),
      categoryId: _readString(json['categoryId']),
      date: DateTime.tryParse(_readString(json['date']) ?? ''),
      paymentMethod: _readString(json['paymentMethod']),
      description: _readString(json['description']),
      merchant: _readString(json['merchant']),
      confidence: _readDouble(json['confidence']) ?? 0,
      needsConfirmation: json['needsConfirmation'] as bool? ?? true,
      clarifyingQuestion: _readString(json['clarifyingQuestion']),
      missingFields: missingFields,
    );
  }
}

class AiGatewayDraftResponse {
  const AiGatewayDraftResponse({
    required this.requestId,
    required this.draft,
    this.provider,
    this.model,
    this.quota,
  });

  final String requestId;
  final String? provider;
  final String? model;
  final AiGatewayExpenseDraft draft;
  final AiGatewayQuotaStatus? quota;
}

class AiGatewayAdviceResponse {
  const AiGatewayAdviceResponse({
    required this.requestId,
    required this.advice,
    required this.groundedSummary,
    this.provider,
    this.model,
    this.quota,
  });

  final String requestId;
  final String? provider;
  final String? model;
  final String advice;
  final String groundedSummary;
  final AiGatewayQuotaStatus? quota;
}

enum AiGatewayErrorCode {
  unauthenticated,
  quotaExceeded,
  rateLimited,
  providerTimeout,
  providerUnavailable,
  invalidProviderOutput,
  gatewayMisconfigured,
  invalidRequest,
  invalidResponse,
  network,
}

enum AiGatewayUserStateKind {
  authRequired,
  limitReached,
  networkRetry,
  gatewayUnavailable,
  genericFailure,
}

class AiGatewayUserStateMessage {
  const AiGatewayUserStateMessage({
    required this.kind,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.canRetry,
  });

  final AiGatewayUserStateKind kind;
  final String title;
  final String body;
  final String actionLabel;
  final bool canRetry;
}

class AiGatewayClientException implements Exception {
  const AiGatewayClientException({
    required this.code,
    required this.message,
    this.requestId,
    this.quota,
  });

  final AiGatewayErrorCode code;
  final String message;
  final String? requestId;
  final AiGatewayQuotaStatus? quota;

  AiGatewayUserStateMessage get userMessage {
    return aiGatewayUserStateMessageFor(code, quota: quota);
  }

  @override
  String toString() => 'AiGatewayClientException(${code.name})';
}

AiGatewayErrorCode aiGatewayErrorCodeFromWire(String? value) {
  return switch (value) {
    'unauthenticated' => AiGatewayErrorCode.unauthenticated,
    'quota_exceeded' => AiGatewayErrorCode.quotaExceeded,
    'rate_limited' => AiGatewayErrorCode.rateLimited,
    'provider_timeout' => AiGatewayErrorCode.providerTimeout,
    'provider_unavailable' => AiGatewayErrorCode.providerUnavailable,
    'invalid_provider_output' => AiGatewayErrorCode.invalidProviderOutput,
    'gateway_misconfigured' => AiGatewayErrorCode.gatewayMisconfigured,
    'invalid_request' => AiGatewayErrorCode.invalidRequest,
    _ => AiGatewayErrorCode.invalidResponse,
  };
}

String _safeMessageForCode(AiGatewayErrorCode code) {
  return aiGatewayUserStateMessageFor(code).title;
}

AiGatewayUserStateKind aiGatewayUserStateKindFor(AiGatewayErrorCode code) {
  return switch (code) {
    AiGatewayErrorCode.unauthenticated => AiGatewayUserStateKind.authRequired,
    AiGatewayErrorCode.quotaExceeded ||
    AiGatewayErrorCode.rateLimited => AiGatewayUserStateKind.limitReached,
    AiGatewayErrorCode.providerTimeout ||
    AiGatewayErrorCode.network => AiGatewayUserStateKind.networkRetry,
    AiGatewayErrorCode.providerUnavailable ||
    AiGatewayErrorCode.gatewayMisconfigured => AiGatewayUserStateKind.gatewayUnavailable,
    AiGatewayErrorCode.invalidProviderOutput ||
    AiGatewayErrorCode.invalidRequest ||
    AiGatewayErrorCode.invalidResponse => AiGatewayUserStateKind.genericFailure,
  };
}

AiGatewayUserStateMessage aiGatewayUserStateMessageFor(
  AiGatewayErrorCode code, {
  AiGatewayQuotaStatus? quota,
}) {
  final kind = aiGatewayUserStateKindFor(code);
  return switch (kind) {
    AiGatewayUserStateKind.authRequired => const AiGatewayUserStateMessage(
      kind: AiGatewayUserStateKind.authRequired,
      title: 'Sign in to use AI.',
      body: 'Your session is missing or expired. Sign in again, then try AI.',
      actionLabel: 'Sign in',
      canRetry: false,
    ),
    AiGatewayUserStateKind.limitReached => AiGatewayUserStateMessage(
      kind: AiGatewayUserStateKind.limitReached,
      title: code == AiGatewayErrorCode.rateLimited
          ? 'Too many AI requests.'
          : 'Daily AI limit reached.',
      body: code == AiGatewayErrorCode.rateLimited
          ? 'Wait a moment, then try again.'
          : _quotaLimitBody(quota),
      actionLabel: 'Try later',
      canRetry: code == AiGatewayErrorCode.rateLimited,
    ),
    AiGatewayUserStateKind.networkRetry => const AiGatewayUserStateMessage(
      kind: AiGatewayUserStateKind.networkRetry,
      title: 'Network problem.',
      body: 'Check your connection, then retry.',
      actionLabel: 'Retry',
      canRetry: true,
    ),
    AiGatewayUserStateKind.gatewayUnavailable => const AiGatewayUserStateMessage(
      kind: AiGatewayUserStateKind.gatewayUnavailable,
      title: 'AI is unavailable.',
      body: 'The AI gateway is temporarily unavailable. Try again later.',
      actionLabel: 'Retry',
      canRetry: true,
    ),
    AiGatewayUserStateKind.genericFailure => const AiGatewayUserStateMessage(
      kind: AiGatewayUserStateKind.genericFailure,
      title: 'AI could not finish.',
      body: 'Something went wrong. Retry or enter the expense manually.',
      actionLabel: 'Retry',
      canRetry: true,
    ),
  };
}

String safeAiGatewayMessage(AiGatewayErrorCode code, String? serverMessage) {
  return _safeMessageForCode(code);
}

String _quotaLimitBody(AiGatewayQuotaStatus? quota) {
  if (quota == null) {
    return 'You have used today\'s AI requests. Try again later.';
  }
  if (quota.limit > 0) {
    return 'You have used ${quota.used}/${quota.limit} AI requests today. Try again later.';
  }
  return 'You have used today\'s AI requests. Try again later.';
}

String? _readString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
