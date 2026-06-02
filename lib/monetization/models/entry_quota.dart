enum EntryQuotaKind {
  normal,
  ai,
}

enum EntryQuotaRewardPlacement {
  rewardedNormalEntries,
  rewardedAiEntries,
}

enum EntryQuotaDecisionType {
  allowed,
  blocked,
  premiumBypass,
  unavailable,
}

enum EntryQuotaMutationStatus {
  consumed,
  granted,
  duplicate,
  dismissed,
  skipped,
  failed,
  blocked,
  premiumBypass,
  unavailable,
}

class EntryQuotaDefaults {
  const EntryQuotaDefaults._();

  static const int normalDailyLimit = 5;
  static const int aiDailyLimit = 3;
  static const int rewardedNormalGrant = 5;
  static const int rewardedAiGrant = 2;
  static const String defaultScopeId = 'local-device';
}

String entryQuotaDateKey(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

class EntryQuotaSnapshot {
  const EntryQuotaSnapshot({
    required this.scopeId,
    required this.quotaDate,
    required this.normalDailyLimit,
    required this.normalConsumed,
    required this.normalRewardedRemaining,
    required this.aiDailyLimit,
    required this.aiConsumed,
    required this.aiRewardedRemaining,
    required this.isPremium,
    required this.lastResetAt,
  });

  final String scopeId;
  final String quotaDate;
  final int normalDailyLimit;
  final int normalConsumed;
  final int normalRewardedRemaining;
  final int aiDailyLimit;
  final int aiConsumed;
  final int aiRewardedRemaining;
  final bool isPremium;
  final DateTime lastResetAt;

  int get normalRemaining => _remaining(
    dailyLimit: normalDailyLimit,
    consumed: normalConsumed,
    rewardedRemaining: normalRewardedRemaining,
  );

  int get aiRemaining => _remaining(
    dailyLimit: aiDailyLimit,
    consumed: aiConsumed,
    rewardedRemaining: aiRewardedRemaining,
  );

  int remainingFor(EntryQuotaKind kind) {
    switch (kind) {
      case EntryQuotaKind.normal:
        return normalRemaining;
      case EntryQuotaKind.ai:
        return aiRemaining;
    }
  }

  bool hasRemainingFor(EntryQuotaKind kind) => remainingFor(kind) > 0;

  EntryQuotaSnapshot copyWith({
    String? scopeId,
    String? quotaDate,
    int? normalDailyLimit,
    int? normalConsumed,
    int? normalRewardedRemaining,
    int? aiDailyLimit,
    int? aiConsumed,
    int? aiRewardedRemaining,
    bool? isPremium,
    DateTime? lastResetAt,
  }) {
    return EntryQuotaSnapshot(
      scopeId: scopeId ?? this.scopeId,
      quotaDate: quotaDate ?? this.quotaDate,
      normalDailyLimit: normalDailyLimit ?? this.normalDailyLimit,
      normalConsumed: normalConsumed ?? this.normalConsumed,
      normalRewardedRemaining: normalRewardedRemaining ?? this.normalRewardedRemaining,
      aiDailyLimit: aiDailyLimit ?? this.aiDailyLimit,
      aiConsumed: aiConsumed ?? this.aiConsumed,
      aiRewardedRemaining: aiRewardedRemaining ?? this.aiRewardedRemaining,
      isPremium: isPremium ?? this.isPremium,
      lastResetAt: lastResetAt ?? this.lastResetAt,
    );
  }

  factory EntryQuotaSnapshot.fresh({
    required String scopeId,
    required DateTime now,
    bool isPremium = false,
  }) {
    return EntryQuotaSnapshot(
      scopeId: scopeId,
      quotaDate: entryQuotaDateKey(now),
      normalDailyLimit: EntryQuotaDefaults.normalDailyLimit,
      normalConsumed: 0,
      normalRewardedRemaining: 0,
      aiDailyLimit: EntryQuotaDefaults.aiDailyLimit,
      aiConsumed: 0,
      aiRewardedRemaining: 0,
      isPremium: isPremium,
      lastResetAt: now,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'scopeId': scopeId,
      'quotaDate': quotaDate,
      'normalDailyLimit': normalDailyLimit,
      'normalConsumed': normalConsumed,
      'normalRewardedRemaining': normalRewardedRemaining,
      'aiDailyLimit': aiDailyLimit,
      'aiConsumed': aiConsumed,
      'aiRewardedRemaining': aiRewardedRemaining,
      'isPremium': isPremium,
      'lastResetAt': lastResetAt.toIso8601String(),
    };
  }

  factory EntryQuotaSnapshot.fromJson(Map<String, Object?> json) {
    return EntryQuotaSnapshot(
      scopeId: json['scopeId'] as String,
      quotaDate: json['quotaDate'] as String,
      normalDailyLimit: json['normalDailyLimit'] as int,
      normalConsumed: json['normalConsumed'] as int,
      normalRewardedRemaining: json['normalRewardedRemaining'] as int,
      aiDailyLimit: json['aiDailyLimit'] as int,
      aiConsumed: json['aiConsumed'] as int,
      aiRewardedRemaining: json['aiRewardedRemaining'] as int,
      isPremium: json['isPremium'] as bool? ?? false,
      lastResetAt: DateTime.parse(json['lastResetAt'] as String),
    );
  }

  static int _remaining({
    required int dailyLimit,
    required int consumed,
    required int rewardedRemaining,
  }) {
    final remaining = dailyLimit - consumed + rewardedRemaining;
    if (remaining < 0) {
      return 0;
    }
    return remaining;
  }
}

class EntryQuotaConsumption {
  const EntryQuotaConsumption({
    required this.operationId,
    required this.scopeId,
    required this.quotaDate,
    required this.kind,
    required this.expenseId,
    required this.createdAt,
  });

  final String operationId;
  final String scopeId;
  final String quotaDate;
  final EntryQuotaKind kind;
  final String? expenseId;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'operationId': operationId,
      'scopeId': scopeId,
      'quotaDate': quotaDate,
      'kind': kind.name,
      'expenseId': expenseId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EntryQuotaConsumption.fromJson(Map<String, Object?> json) {
    return EntryQuotaConsumption(
      operationId: json['operationId'] as String,
      scopeId: json['scopeId'] as String,
      quotaDate: json['quotaDate'] as String,
      kind: EntryQuotaKind.values.byName(json['kind'] as String),
      expenseId: json['expenseId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class EntryQuotaRewardGrant {
  const EntryQuotaRewardGrant({
    required this.rewardEventId,
    required this.scopeId,
    required this.quotaDate,
    required this.placement,
    required this.amount,
    required this.createdAt,
    required this.grantedAt,
  });

  final String rewardEventId;
  final String scopeId;
  final String quotaDate;
  final EntryQuotaRewardPlacement placement;
  final int amount;
  final DateTime createdAt;
  final DateTime grantedAt;

  EntryQuotaKind get kind {
    switch (placement) {
      case EntryQuotaRewardPlacement.rewardedNormalEntries:
        return EntryQuotaKind.normal;
      case EntryQuotaRewardPlacement.rewardedAiEntries:
        return EntryQuotaKind.ai;
    }
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'rewardEventId': rewardEventId,
      'scopeId': scopeId,
      'quotaDate': quotaDate,
      'placement': placement.name,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'grantedAt': grantedAt.toIso8601String(),
    };
  }

  factory EntryQuotaRewardGrant.fromJson(Map<String, Object?> json) {
    return EntryQuotaRewardGrant(
      rewardEventId: json['rewardEventId'] as String,
      scopeId: json['scopeId'] as String,
      quotaDate: json['quotaDate'] as String,
      placement: EntryQuotaRewardPlacement.values.byName(json['placement'] as String),
      amount: json['amount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      grantedAt: DateTime.parse(json['grantedAt'] as String),
    );
  }
}

class EntryQuotaDecision {
  const EntryQuotaDecision({
    required this.type,
    required this.kind,
    required this.snapshot,
    required this.message,
  });

  final EntryQuotaDecisionType type;
  final EntryQuotaKind kind;
  final EntryQuotaSnapshot? snapshot;
  final String message;

  bool get allowed =>
      type == EntryQuotaDecisionType.allowed || type == EntryQuotaDecisionType.premiumBypass;

  const EntryQuotaDecision.allowed({
    required EntryQuotaKind kind,
    required EntryQuotaSnapshot snapshot,
    String message = 'Entry quota is available.',
  }) : this(type: EntryQuotaDecisionType.allowed, kind: kind, snapshot: snapshot, message: message);

  const EntryQuotaDecision.blocked({
    required EntryQuotaKind kind,
    required EntryQuotaSnapshot snapshot,
    String message = 'Daily entry quota is exhausted.',
  }) : this(type: EntryQuotaDecisionType.blocked, kind: kind, snapshot: snapshot, message: message);

  const EntryQuotaDecision.premiumBypass({
    required EntryQuotaKind kind,
    EntryQuotaSnapshot? snapshot,
    String message = 'Premium users bypass free entry quotas.',
  }) : this(
         type: EntryQuotaDecisionType.premiumBypass,
         kind: kind,
         snapshot: snapshot,
         message: message,
       );

  const EntryQuotaDecision.unavailable({
    required EntryQuotaKind kind,
    String message = 'Entry limits are unavailable right now.',
  }) : this(type: EntryQuotaDecisionType.unavailable, kind: kind, snapshot: null, message: message);
}

class EntryQuotaMutationResult {
  const EntryQuotaMutationResult({
    required this.status,
    required this.snapshot,
    required this.message,
  });

  final EntryQuotaMutationStatus status;
  final EntryQuotaSnapshot? snapshot;
  final String message;

  bool get changed =>
      status == EntryQuotaMutationStatus.consumed || status == EntryQuotaMutationStatus.granted;

  bool get duplicate => status == EntryQuotaMutationStatus.duplicate;
}
