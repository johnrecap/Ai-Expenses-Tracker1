import 'dart:io';

import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:expenses_tracker/monetization/widgets/app_ad_slot.dart';
import 'package:expenses_tracker/monetization/widgets/rewarded_quota_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium quota and ads', () {
    test('premium bypasses manual and AI quota without consuming credits', () async {
      final tempDir = await Directory.systemTemp.createTemp('premium_quota_ads_test_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final cubit = EntryQuotaCubit(
        service: EntryQuotaService(
          store: LocalEntryQuotaStore(file: File('${tempDir.path}/quota.json')),
          scopeId: 'scope-1',
          clock: () => DateTime(2026, 6, 2, 10),
        ),
        isPremium: true,
      );
      addTearDown(cubit.close);

      await cubit.load(isPremium: true);
      final manualDecision = await cubit.canSave(EntryQuotaKind.normal);
      final aiDecision = await cubit.canSave(EntryQuotaKind.ai);
      final manualConsume = await cubit.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: 'premium-manual-1',
      );
      final aiConsume = await cubit.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.ai,
        operationId: 'premium-ai-1',
      );

      expect(manualDecision.type, EntryQuotaDecisionType.premiumBypass);
      expect(aiDecision.type, EntryQuotaDecisionType.premiumBypass);
      expect(manualConsume.status, EntryQuotaMutationStatus.premiumBypass);
      expect(aiConsume.status, EntryQuotaMutationStatus.premiumBypass);
      expect(cubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
      expect(cubit.state.aiRemaining, EntryQuotaDefaults.aiDailyLimit);
    });

    test('premium does not request rewarded ads or grant rewarded credits', () async {
      final service = _AvailableAdService();
      final monetization = MonetizationCubit(adService: service);
      addTearDown(monetization.close);

      await monetization.load();
      monetization.setPremium(true);

      final result = await monetization.showRewardedAd(
        placement: AdPlacement.rewardedNormalEntries,
      );

      expect(result.verified, isFalse);
      expect(result.message, contains('premium'));
      expect(service.rewardedCalls, 0);
      expect(monetization.state.showAds, isFalse);
    });

    testWidgets('premium hides banner and inline ad slots', (tester) async {
      final monetization = MonetizationCubit(adService: _AvailableAdService());
      addTearDown(monetization.close);

      await monetization.load();
      monetization.setPremium(true);

      await tester.pumpWidget(
        BlocProvider.value(
          value: monetization,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AppAdSlot.homeBanner(),
                  AppAdSlot.expensesInline(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(AppAdSlot.homeBannerKey), findsNothing);
      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
    });

    testWidgets('premium callers can avoid rendering the rewarded sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(RewardedQuotaSheet), findsNothing);
    });
  });
}

class _AvailableAdService implements AdService {
  int rewardedCalls = 0;

  @override
  Future<AdServiceStatus> initialize() async => const AdServiceStatus.available();

  @override
  void dispose() {}

  @override
  Future<AdShowResult> hideBanner() async => const AdShowResult.shown('Banner hidden');

  @override
  Future<AdShowResult> showBanner() async => const AdShowResult.shown('Banner shown');

  @override
  Future<AdShowResult> showInterstitial() async => const AdShowResult.shown();

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async {
    rewardedCalls += 1;
    return const RewardedAdResult.verified(rewardEventId: 'premium-should-not-call');
  }
}
