import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expenses_tracker/monetization/models/entitlement_snapshot.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';

class MonetizationCubit extends Cubit<MonetizationState> {
  final AdService? _adService;

  MonetizationCubit({this._adService}) : super(const MonetizationState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final adStatus = await _adService?.initialize() ?? const AdServiceStatus.unavailable();
      emit(
        state.copyWith(
          loading: false,
          initialized: true,
          adsAvailable: adStatus.isAvailable,
          adStatusMessage: adStatus.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          initialized: true,
          adsAvailable: false,
          adStatusMessage: 'Ads are unavailable right now.',
        ),
      );
    }
  }

  @visibleForTesting
  void setPremium(bool isPremium) {
    assert(() {
      emit(state.copyWith(isPremium: isPremium));
      return true;
    }());
  }

  Future<AdShowResult> showInterstitialAd({
    AdPlacement placement = AdPlacement.nonCriticalInterstitial,
  }) async {
    final decision = state.adPolicyFor(placement);
    if (!decision.allowed) {
      return AdShowResult.unavailable(decision.message);
    }
    return await _adService?.showInterstitial() ?? const AdShowResult.unavailable();
  }

  Future<RewardedAdResult> showRewardedAd({
    required AdPlacement placement,
  }) async {
    if (!_isRewardedPlacement(placement)) {
      return const RewardedAdResult.unavailable('Placement is not a rewarded ad.');
    }
    final decision = state.adPolicyFor(placement);
    if (!decision.allowed) {
      return RewardedAdResult.unavailable(decision.message);
    }
    return await _adService?.showRewardedAd(placement) ?? const RewardedAdResult.unavailable();
  }

  bool _isRewardedPlacement(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.rewardedNormalEntries:
      case AdPlacement.rewardedAiEntries:
      case AdPlacement.rewardedAiCredit:
        return true;
      case AdPlacement.nonCriticalBanner:
      case AdPlacement.nonCriticalInterstitial:
      case AdPlacement.expenseEntry:
      case AdPlacement.expenseSave:
      case AdPlacement.aiTyping:
      case AdPlacement.aiParsing:
        return false;
    }
  }

  @override
  Future<void> close() {
    _adService?.dispose();
    return super.close();
  }
}

class MonetizationState {
  final bool loading;
  final bool initialized;
  final bool isPremium;
  final bool adsAvailable;
  final String adStatusMessage;

  const MonetizationState({
    this.loading = false,
    this.initialized = false,
    this.isPremium = false,
    this.adsAvailable = false,
    this.adStatusMessage = 'Ads are unavailable until a real ad provider is connected.',
  });

  bool get showAds => adPolicyFor(AdPlacement.nonCriticalBanner).allowed;

  AdPolicyDecision adPolicyFor(
    AdPlacement placement, {
    ConsentState consent = const ConsentState(canRequestAds: true, consentObtained: true),
  }) {
    return AdPolicy.evaluate(
      placement: placement,
      isPremium: isPremium,
      providerAvailable: initialized && adsAvailable,
      consent: consent,
    );
  }

  MonetizationState copyWith({
    bool? loading,
    bool? initialized,
    bool? isPremium,
    bool? adsAvailable,
    String? adStatusMessage,
  }) => MonetizationState(
    loading: loading ?? this.loading,
    initialized: initialized ?? this.initialized,
    isPremium: isPremium ?? this.isPremium,
    adsAvailable: adsAvailable ?? this.adsAvailable,
    adStatusMessage: adStatusMessage ?? this.adStatusMessage,
  );
}
