import 'dart:io';

import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalEntryQuotaStore', () {
    late Directory tempDir;
    late File quotaFile;
    late DateTime now;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('local_entry_quota_store_test_');
      quotaFile = File('${tempDir.path}/quota.json');
      now = DateTime(2026, 6, 2, 9);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    LocalEntryQuotaStore createStore() => LocalEntryQuotaStore(file: quotaFile);

    test('loads a fresh daily snapshot with free limits', () async {
      final snapshot = await createStore().loadSnapshot(scopeId: 'scope-1', now: now);

      expect(snapshot.scopeId, 'scope-1');
      expect(snapshot.quotaDate, '2026-06-02');
      expect(snapshot.normalDailyLimit, EntryQuotaDefaults.normalDailyLimit);
      expect(snapshot.aiDailyLimit, EntryQuotaDefaults.aiDailyLimit);
      expect(snapshot.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
      expect(snapshot.aiRemaining, EntryQuotaDefaults.aiDailyLimit);
    });

    test('persists consumption and reward grants across store recreation', () async {
      final firstStore = createStore();

      await firstStore.consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
        now: now,
      );
      await firstStore.grantReward(
        scopeId: 'scope-1',
        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
        rewardEventId: 'reward-ai-1',
        now: now,
      );

      final reloaded = await createStore().loadSnapshot(scopeId: 'scope-1', now: now);

      expect(reloaded.normalConsumed, 1);
      expect(reloaded.normalRemaining, EntryQuotaDefaults.normalDailyLimit - 1);
      expect(reloaded.aiRewardedRemaining, EntryQuotaDefaults.rewardedAiGrant);
      expect(
        reloaded.aiRemaining,
        EntryQuotaDefaults.aiDailyLimit + EntryQuotaDefaults.rewardedAiGrant,
      );
    });

    test('duplicate consumption IDs do not double-consume after restart', () async {
      await createStore().consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
        now: now,
      );

      final duplicate = await createStore().consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
        now: now,
      );

      expect(duplicate.status, EntryQuotaMutationStatus.duplicate);
      expect(duplicate.snapshot?.normalConsumed, 1);
      expect(duplicate.snapshot?.normalRemaining, EntryQuotaDefaults.normalDailyLimit - 1);
    });

    test('duplicate reward event IDs do not double-grant after restart', () async {
      await createStore().grantReward(
        scopeId: 'scope-1',
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        rewardEventId: 'reward-normal-1',
        now: now,
      );

      final duplicate = await createStore().grantReward(
        scopeId: 'scope-1',
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        rewardEventId: 'reward-normal-1',
        now: now,
      );

      expect(duplicate.status, EntryQuotaMutationStatus.duplicate);
      expect(
        duplicate.snapshot?.normalRewardedRemaining,
        EntryQuotaDefaults.rewardedNormalGrant,
      );
      expect(
        duplicate.snapshot?.normalRemaining,
        EntryQuotaDefaults.normalDailyLimit + EntryQuotaDefaults.rewardedNormalGrant,
      );
    });

    test('resets daily counters and operation IDs on new local date', () async {
      await createStore().consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
        now: now,
      );

      final tomorrow = DateTime(2026, 6, 3, 1);
      final snapshot = await createStore().loadSnapshot(scopeId: 'scope-1', now: tomorrow);
      final reusedOperation = await createStore().consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
        now: tomorrow,
      );

      expect(snapshot.quotaDate, '2026-06-03');
      expect(snapshot.normalConsumed, 0);
      expect(reusedOperation.status, EntryQuotaMutationStatus.consumed);
      expect(reusedOperation.snapshot?.normalConsumed, 1);
    });

    test('keeps only quota metadata in the persisted file', () async {
      await createStore().consume(
        scopeId: 'scope-1',
        kind: EntryQuotaKind.ai,
        operationId: 'ai-save-1',
        expenseId: 'expense-1',
        now: now,
      );

      final contents = await quotaFile.readAsString();

      expect(contents, contains('ai-save-1'));
      expect(contents, contains('expense-1'));
      expect(contents, isNot(contains('merchant')));
      expect(contents, isNot(contains('description')));
      expect(contents, isNot(contains('receipt')));
    });
  });
}
