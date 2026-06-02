import 'package:expenses_tracker/monetization/models/entitlement_snapshot.dart';

enum AdServiceState { available, unavailable }

enum AdPlacement {
  nonCriticalBanner,
  nonCriticalInterstitial,
  rewardedNormalEntries,
  rewardedAiEntries,
  rewardedAiCredit,
  expenseEntry,
  expenseSave,
  aiTyping,
  aiParsing,
}

enum RewardedAdResultStatus {
  verified,
  dismissed,
  skipped,
  unavailable,
  failed,
}

class AdPolicyDecision {
  const AdPolicyDecision({
    required this.allowed,
    required this.message,
  });

  final bool allowed;
  final String message;
}

class AdPolicy {
  const AdPolicy._();

  static AdPolicyDecision evaluate({
    required AdPlacement placement,
    required bool isPremium,
    required bool providerAvailable,
    required ConsentState consent,
  }) {
    if (isPremium) {
      return const AdPolicyDecision(
        allowed: false,
        message: 'Ads are hidden for premium users.',
      );
    }
    if (!providerAvailable) {
      return const AdPolicyDecision(
        allowed: false,
        message: 'Ads are unavailable until a real ad provider is connected.',
      );
    }
    if (!consent.canRequestAds) {
      return const AdPolicyDecision(
        allowed: false,
        message: 'Ads are disabled until ad consent allows requests.',
      );
    }
    if (_blocksCoreFlow(placement)) {
      return const AdPolicyDecision(
        allowed: false,
        message: 'Ads do not interrupt expense entry, saving, typing, or AI parsing.',
      );
    }
    return const AdPolicyDecision(
      allowed: true,
      message: 'Ad placement is allowed for free users.',
    );
  }

  static bool _blocksCoreFlow(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.expenseEntry:
      case AdPlacement.expenseSave:
      case AdPlacement.aiTyping:
      case AdPlacement.aiParsing:
        return true;
      case AdPlacement.nonCriticalBanner:
      case AdPlacement.nonCriticalInterstitial:
      case AdPlacement.rewardedNormalEntries:
      case AdPlacement.rewardedAiEntries:
      case AdPlacement.rewardedAiCredit:
        return false;
    }
  }
}

class AdServiceStatus {
  const AdServiceStatus({
    required this.state,
    required this.message,
  });

  final AdServiceState state;
  final String message;

  bool get isAvailable => state == AdServiceState.available;

  const AdServiceStatus.available([String message = 'Ads are available'])
    : this(state: AdServiceState.available, message: message);

  const AdServiceStatus.unavailable([
    String message = 'Ads are unavailable until a real ad SDK is connected.',
  ]) : this(state: AdServiceState.unavailable, message: message);
}

class AdShowResult {
  const AdShowResult({
    required this.shown,
    required this.message,
  });

  final bool shown;
  final String message;

  const AdShowResult.shown([String message = 'Ad shown']) : this(shown: true, message: message);

  const AdShowResult.unavailable([
    String message = 'No verified ad provider is available.',
  ]) : this(shown: false, message: message);
}

class RewardedAdResult {
  const RewardedAdResult({
    required this.status,
    required this.message,
    this.rewardEventId,
  });

  final RewardedAdResultStatus status;
  final String message;
  final String? rewardEventId;

  bool get verified =>
      status == RewardedAdResultStatus.verified &&
      rewardEventId != null &&
      rewardEventId!.isNotEmpty;

  const RewardedAdResult.verified({
    required String rewardEventId,
    String message = 'Rewarded ad completed.',
  }) : this(
         status: RewardedAdResultStatus.verified,
         rewardEventId: rewardEventId,
         message: message,
       );

  const RewardedAdResult.dismissed([
    String message = 'Rewarded ad was dismissed before completion.',
  ]) : this(status: RewardedAdResultStatus.dismissed, message: message);

  const RewardedAdResult.skipped([
    String message = 'Rewarded ad was skipped before completion.',
  ]) : this(status: RewardedAdResultStatus.skipped, message: message);

  const RewardedAdResult.unavailable([
    String message = 'No verified rewarded ad provider is available.',
  ]) : this(status: RewardedAdResultStatus.unavailable, message: message);

  const RewardedAdResult.failed([
    String message = 'Rewarded ad failed before completion.',
  ]) : this(status: RewardedAdResultStatus.failed, message: message);
}

abstract class AdService {
  Future<AdServiceStatus> initialize();
  void dispose();
  Future<AdShowResult> showInterstitial();
  Future<AdShowResult> showBanner();
  Future<AdShowResult> hideBanner();
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement);
}

class UnavailableAdService implements AdService {
  const UnavailableAdService({
    this.reason = 'Ads are disabled until AdMob or another real ad provider is wired.',
  });

  final String reason;

  @override
  Future<AdServiceStatus> initialize() async => AdServiceStatus.unavailable(reason);

  @override
  void dispose() {}

  @override
  Future<AdShowResult> showInterstitial() async => AdShowResult.unavailable(reason);

  @override
  Future<AdShowResult> showBanner() async => AdShowResult.unavailable(reason);

  @override
  Future<AdShowResult> hideBanner() async => const AdShowResult.unavailable(
    'No ad banner is active.',
  );

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async {
    return RewardedAdResult.unavailable(reason);
  }
}
