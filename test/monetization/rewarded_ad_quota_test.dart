import 'dart:io';

import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rewarded ad quota grants', () {
    late Directory tempDir;
    late EntryQuotaCubit quotaCubit;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rewarded_ad_quota_test_');
      quotaCubit = EntryQuotaCubit(
        service: EntryQuotaService(
          store: LocalEntryQuotaStore(file: File('${tempDir.path}/quota.json')),
          scopeId: 'scope-1',
          clock: () => DateTime(2026, 6, 2, 10),
        ),
      );
      await quotaCubit.load();
    });

    tearDown(() async {
      await quotaCubit.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('verified normal reward grants five manual entries once', () async {
      final monetization = MonetizationCubit(
        adService: _RewardedAdService([
          const RewardedAdResult.verified(rewardEventId: 'normal-reward-1'),
          const RewardedAdResult.verified(rewardEventId: 'normal-reward-1'),
        ]),
      );
      addTearDown(monetization.close);
      await monetization.load();

      final before = quotaCubit.state.normalRemaining;
      final firstAd = await monetization.showRewardedAd(
        placement: AdPlacement.rewardedNormalEntries,
      );
      final firstGrant = await quotaCubit.grantRewardFromAdResult(
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        adResult: firstAd,
      );
      final duplicateAd = await monetization.showRewardedAd(
        placement: AdPlacement.rewardedNormalEntries,
      );
      final duplicateGrant = await quotaCubit.grantRewardFromAdResult(
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        adResult: duplicateAd,
      );

      expect(firstGrant.status, EntryQuotaMutationStatus.granted);
      expect(
        firstGrant.snapshot?.normalRemaining,
        before + EntryQuotaDefaults.rewardedNormalGrant,
      );
      expect(duplicateGrant.status, EntryQuotaMutationStatus.duplicate);
      expect(
        duplicateGrant.snapshot?.normalRemaining,
        before + EntryQuotaDefaults.rewardedNormalGrant,
      );
    });

    test('verified AI reward grants two AI entries', () async {
      final monetization = MonetizationCubit(
        adService: _RewardedAdService([
          const RewardedAdResult.verified(rewardEventId: 'ai-reward-1'),
        ]),
      );
      addTearDown(monetization.close);
      await monetization.load();

      final before = quotaCubit.state.aiRemaining;
      final adResult = await monetization.showRewardedAd(
        placement: AdPlacement.rewardedAiEntries,
      );
      final grant = await quotaCubit.grantRewardFromAdResult(
        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
        adResult: adResult,
      );

      expect(grant.status, EntryQuotaMutationStatus.granted);
      expect(
        grant.snapshot?.aiRemaining,
        before + EntryQuotaDefaults.rewardedAiGrant,
      );
      expect(grant.snapshot?.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
    });

    test('unavailable ad service never returns a verified reward', () async {
      final monetization = MonetizationCubit(adService: const UnavailableAdService());
      addTearDown(monetization.close);
      await monetization.load();

      final before = quotaCubit.state.normalRemaining;
      final adResult = await monetization.showRewardedAd(
        placement: AdPlacement.rewardedNormalEntries,
      );
      final grant = await quotaCubit.grantRewardFromAdResult(
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        adResult: adResult,
      );

      expect(adResult.verified, isFalse);
      expect(grant.status, EntryQuotaMutationStatus.unavailable);
      expect(quotaCubit.state.normalRemaining, before);
    });

    test('dismissed, skipped, and failed ads grant zero credits', () async {
      final monetization = MonetizationCubit(
        adService: _RewardedAdService([
          const RewardedAdResult.dismissed(),
          const RewardedAdResult.skipped(),
          const RewardedAdResult.failed(),
        ]),
      );
      addTearDown(monetization.close);
      await monetization.load();

      final before = quotaCubit.state.aiRemaining;
      final expectedStatuses = [
        EntryQuotaMutationStatus.dismissed,
        EntryQuotaMutationStatus.skipped,
        EntryQuotaMutationStatus.failed,
      ];

      for (final expectedStatus in expectedStatuses) {
        final adResult = await monetization.showRewardedAd(
          placement: AdPlacement.rewardedAiEntries,
        );
        final grant = await quotaCubit.grantRewardFromAdResult(
          placement: EntryQuotaRewardPlacement.rewardedAiEntries,
          adResult: adResult,
        );

        expect(grant.status, expectedStatus);
        expect(quotaCubit.state.aiRemaining, before);
      }
    });
  });
}

class _RewardedAdService implements AdService {
  _RewardedAdService(this._results);

  final List<RewardedAdResult> _results;

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
    if (_results.isEmpty) {
      return const RewardedAdResult.failed();
    }
    return _results.removeAt(0);
  }
}
