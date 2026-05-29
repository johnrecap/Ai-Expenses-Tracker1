import 'monetization_plan.dart';

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.status, required this.plan, required this.expiryDate,
    this.isPremiumActive = false, this.shouldDisableAds = false,
  });

  final String status;
  final PlanTier plan;
  final DateTime? expiryDate;
  final bool isPremiumActive;
  final bool shouldDisableAds;

  factory EntitlementSnapshot.freeDefault() => const EntitlementSnapshot(
    status: 'active', plan: PlanTier.free, isPremiumActive: false, shouldDisableAds: false,
  );

  factory EntitlementSnapshot.premiumActive({DateTime? expiry}) => EntitlementSnapshot(
    status: 'active', plan: PlanTier.premium, isPremiumActive: true,
    shouldDisableAds: true, expiryDate: expiry,
  );
}

class AdFrequencyState {
  final int completedSaves;
  final int rewardedCreditsToday;

  const AdFrequencyState({this.completedSaves = 0, this.rewardedCreditsToday = 0});

  AdFrequencyState recordCompletedSave() => AdFrequencyState(
    completedSaves: completedSaves + 1, rewardedCreditsToday: rewardedCreditsToday,
  );

  AdFrequencyState recordRewardedCredit() => AdFrequencyState(
    completedSaves: completedSaves, rewardedCreditsToday: rewardedCreditsToday + 1,
  );
}

class ConsentState {
  final bool canRequestAds;
  final bool consentObtained;

  const ConsentState({required this.canRequestAds, required this.consentObtained});

  factory ConsentState.unavailable() => const ConsentState(canRequestAds: false, consentObtained: false);
  factory ConsentState.granted() => const ConsentState(canRequestAds: true, consentObtained: true);
  factory ConsentState.denied() => const ConsentState(canRequestAds: false, consentObtained: false);
}
