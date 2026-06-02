import 'package:expenses_tracker/feature_flags/feature_gate_service.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseService', () {
    test('purchasePremium is unavailable without verified store entitlement', () async {
      final result = await const PurchaseService().purchasePremium();

      expect(result.status, PurchaseFlowStatus.unavailable);
      expect(result.isVerifiedPremium, isFalse);
    });

    test('restorePurchases is unavailable without server entitlement check', () async {
      final result = await const PurchaseService().restorePurchases();

      expect(result.status, PurchaseFlowStatus.unavailable);
      expect(result.isVerifiedPremium, isFalse);
    });
  });

  group('AdService', () {
    test('unavailable ad service does not report load or show success', () async {
      const service = UnavailableAdService();

      final status = await service.initialize();
      final interstitial = await service.showInterstitial();
      final banner = await service.showBanner();
      final reward = await service.showRewardedAd(AdPlacement.rewardedNormalEntries);

      expect(status.isAvailable, isFalse);
      expect(interstitial.shown, isFalse);
      expect(banner.shown, isFalse);
      expect(reward.verified, isFalse);
      expect(reward.status, RewardedAdResultStatus.unavailable);
    });

    test('monetization cubit does not show ads when provider is unavailable', () async {
      final cubit = MonetizationCubit(adService: const UnavailableAdService());
      addTearDown(cubit.close);

      await cubit.load();
      final showResult = await cubit.showInterstitialAd();

      expect(cubit.state.initialized, isTrue);
      expect(cubit.state.adsAvailable, isFalse);
      expect(cubit.state.showAds, isFalse);
      expect(showResult.shown, isFalse);
    });
  });

  group('FeatureGateService', () {
    testWidgets('falls back to free gates when MonetizationCubit is missing', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final gate = FeatureGateService(capturedContext);

      expect(gate.isPremium, isFalse);
      expect(gate.canUseAdvancedReports(), isFalse);
      expect(gate.canRemoveAds(), isFalse);
    });
  });
}
