import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entitlement_snapshot.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdPolicy', () {
    test('premium entitlement hides every ad placement', () {
      for (final placement in AdPlacement.values) {
        final decision = AdPolicy.evaluate(
          placement: placement,
          isPremium: true,
          providerAvailable: true,
          consent: ConsentState.granted(),
        );

        expect(decision.allowed, isFalse, reason: placement.name);
        expect(decision.message, contains('premium'));
      }
    });

    test('free users can only see non-blocking ads when provider and consent allow', () {
      for (final placement in [
        AdPlacement.nonCriticalBanner,
        AdPlacement.nonCriticalInterstitial,
        AdPlacement.rewardedNormalEntries,
        AdPlacement.rewardedAiEntries,
        AdPlacement.rewardedAiCredit,
      ]) {
        final decision = AdPolicy.evaluate(
          placement: placement,
          isPremium: false,
          providerAvailable: true,
          consent: ConsentState.granted(),
        );

        expect(decision.allowed, isTrue, reason: placement.name);
      }
    });

    test('ads never interrupt expense entry, saving, typing, or AI parsing', () {
      for (final placement in [
        AdPlacement.expenseEntry,
        AdPlacement.expenseSave,
        AdPlacement.aiTyping,
        AdPlacement.aiParsing,
      ]) {
        final decision = AdPolicy.evaluate(
          placement: placement,
          isPremium: false,
          providerAvailable: true,
          consent: ConsentState.granted(),
        );

        expect(decision.allowed, isFalse, reason: placement.name);
        expect(decision.message, contains('interrupt'));
      }
    });

    test('provider unavailable and unknown consent keep ads off', () {
      final noProvider = AdPolicy.evaluate(
        placement: AdPlacement.nonCriticalBanner,
        isPremium: false,
        providerAvailable: false,
        consent: ConsentState.granted(),
      );
      final noConsent = AdPolicy.evaluate(
        placement: AdPlacement.nonCriticalBanner,
        isPremium: false,
        providerAvailable: true,
        consent: ConsentState.unavailable(),
      );

      expect(noProvider.allowed, isFalse);
      expect(noConsent.allowed, isFalse);
    });
  });

  group('MonetizationCubit ads', () {
    test('premium local entitlement prevents showing an otherwise available ad', () async {
      final cubit = MonetizationCubit(adService: _AvailableAdService());
      addTearDown(cubit.close);

      await cubit.load();
      cubit.setPremium(true);

      final result = await cubit.showInterstitialAd();

      expect(cubit.state.showAds, isFalse);
      expect(result.shown, isFalse);
      expect(result.message, contains('premium'));
    });

    test('blocked placements do not call the ad provider', () async {
      final service = _AvailableAdService();
      final cubit = MonetizationCubit(adService: service);
      addTearDown(cubit.close);

      await cubit.load();
      final result = await cubit.showInterstitialAd(placement: AdPlacement.expenseSave);

      expect(result.shown, isFalse);
      expect(result.message, contains('interrupt'));
      expect(service.interstitialCalls, 0);
    });
  });
}

class _AvailableAdService implements AdService {
  int interstitialCalls = 0;

  @override
  Future<AdServiceStatus> initialize() async => const AdServiceStatus.available();

  @override
  void dispose() {}

  @override
  Future<AdShowResult> hideBanner() async => const AdShowResult.shown('Banner hidden');

  @override
  Future<AdShowResult> showBanner() async => const AdShowResult.shown('Banner shown');

  @override
  Future<AdShowResult> showInterstitial() async {
    interstitialCalls += 1;
    return const AdShowResult.shown();
  }

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async {
    return const RewardedAdResult.verified(rewardEventId: 'reward-test-1');
  }
}
