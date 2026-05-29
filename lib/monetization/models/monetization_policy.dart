import 'monetization_plan.dart';

class MonetizationPolicy {
  const MonetizationPolicy({
    required this.freeQuotaAiParse, required this.freeQuotaReceipts, required this.freeQuotaAdvice,
    required this.premiumQuotaAiParse, required this.premiumQuotaReceipts, required this.premiumQuotaAdvice,
    required this.maxRewardedCreditsPerDay,
  });

  final int freeQuotaAiParse;
  final int freeQuotaReceipts;
  final int freeQuotaAdvice;
  final int premiumQuotaAiParse;
  final int premiumQuotaReceipts;
  final int premiumQuotaAdvice;
  final int maxRewardedCreditsPerDay;

  factory MonetizationPolicy.defaults() => const MonetizationPolicy(
    freeQuotaAiParse: 5, freeQuotaReceipts: 3, freeQuotaAdvice: 3,
    premiumQuotaAiParse: 20, premiumQuotaReceipts: 15, premiumQuotaAdvice: 10,
    maxRewardedCreditsPerDay: 3,
  );

  int quotaFor(PlanTier tier, AiUsageRequestType type) {
    final isPremium = tier.isPremium;
    switch (type) {
      case AiUsageRequestType.aiParse: return isPremium ? premiumQuotaAiParse : freeQuotaAiParse;
      case AiUsageRequestType.receipt: return isPremium ? premiumQuotaReceipts : freeQuotaReceipts;
      case AiUsageRequestType.advice: return isPremium ? premiumQuotaAdvice : freeQuotaAdvice;
      default: return 0;
    }
  }
}

enum AiUsageRequestType { aiParse, receipt, advice, unknown }

class AiQuotaUsage {
  final int used;
  final int limit;
  final int rewardedCreditsAvailable;

  const AiQuotaUsage({this.used = 0, this.limit = 0, this.rewardedCreditsAvailable = 0});

  factory AiQuotaUsage.defaultFor({required AiUsageRequestType requestType, required MonetizationPolicy policy, PlanTier tier = PlanTier.free}) {
    return AiQuotaUsage(limit: policy.quotaFor(tier, requestType));
  }

  int get remaining => (limit + rewardedCreditsAvailable - used).clamp(0, limit + rewardedCreditsAvailable);
  bool get isExhausted => remaining <= 0;

  AiQuotaUsage copyWith({int? used, int? limit, int? rewardedCreditsAvailable}) => AiQuotaUsage(
    used: used ?? this.used, limit: limit ?? this.limit, rewardedCreditsAvailable: rewardedCreditsAvailable ?? this.rewardedCreditsAvailable,
  );
}

class AiUsageStatus {
  final AiUsageRequestType requestType;
  final int used;

  const AiUsageStatus({required this.requestType, this.used = 0});
}

class RewardedAdCredit {
  final String id;
  final AiUsageRequestType requestType;
  final DateTime grantedAt;
  final DateTime expiresAt;
  final String sourceAdEventId;

  const RewardedAdCredit({
    required this.id, required this.requestType, required this.grantedAt,
    required this.expiresAt, required this.sourceAdEventId,
  });
}
