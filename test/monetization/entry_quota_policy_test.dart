import 'dart:io';

import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntryQuotaService policy', () {
    late Directory tempDir;
    late DateTime now;
    late EntryQuotaService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('entry_quota_policy_test_');
      now = DateTime(2026, 6, 2, 10);
      service = EntryQuotaService(
        store: LocalEntryQuotaStore(file: File('${tempDir.path}/quota.json')),
        scopeId: 'scope-1',
        clock: () => now,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('free users get five normal entries per local day', () async {
      for (var index = 0; index < EntryQuotaDefaults.normalDailyLimit; index += 1) {
        final decision = await service.canSave(EntryQuotaKind.normal);
        expect(decision.allowed, isTrue);

        final result = await service.consumeAfterSuccessfulSave(
          kind: EntryQuotaKind.normal,
          operationId: 'manual-$index',
        );
        expect(result.status, EntryQuotaMutationStatus.consumed);
      }

      final blocked = await service.canSave(EntryQuotaKind.normal);

      expect(blocked.allowed, isFalse);
      expect(blocked.type, EntryQuotaDecisionType.blocked);
      expect(blocked.snapshot?.normalRemaining, 0);
    });

    test('AI entries use the AI quota without consuming normal quota', () async {
      for (var index = 0; index < EntryQuotaDefaults.aiDailyLimit; index += 1) {
        final result = await service.consumeAfterSuccessfulSave(
          kind: EntryQuotaKind.ai,
          operationId: 'ai-$index',
        );
        expect(result.status, EntryQuotaMutationStatus.consumed);
      }

      final snapshot = await service.loadSnapshot();
      final aiBlocked = await service.canSave(EntryQuotaKind.ai);

      expect(snapshot.aiConsumed, EntryQuotaDefaults.aiDailyLimit);
      expect(snapshot.aiRemaining, 0);
      expect(snapshot.normalConsumed, 0);
      expect(snapshot.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
      expect(aiBlocked.type, EntryQuotaDecisionType.blocked);
    });

    test('failed saves do not consume quota because no success operation is recorded', () async {
      final beforeSave = await service.canSave(EntryQuotaKind.normal);
      expect(beforeSave.allowed, isTrue);

      final afterFailure = await service.loadSnapshot();

      expect(afterFailure.normalConsumed, 0);
      expect(afterFailure.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
    });

    test('duplicate operation IDs cannot double-consume', () async {
      final first = await service.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: 'same-save',
      );
      final duplicate = await service.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: 'same-save',
      );

      expect(first.status, EntryQuotaMutationStatus.consumed);
      expect(duplicate.status, EntryQuotaMutationStatus.duplicate);
      expect(duplicate.snapshot?.normalConsumed, 1);
      expect(duplicate.snapshot?.normalRemaining, EntryQuotaDefaults.normalDailyLimit - 1);
    });

    test('daily quota resets on a new local date', () async {
      await service.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: 'today-save',
      );

      now = DateTime(2026, 6, 3, 8);
      final snapshot = await service.loadSnapshot();

      expect(snapshot.quotaDate, '2026-06-03');
      expect(snapshot.normalConsumed, 0);
      expect(snapshot.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
    });

    test('premium users bypass quota and do not consume free credits', () async {
      for (var index = 0; index < 10; index += 1) {
        final decision = await service.canSave(EntryQuotaKind.ai, isPremium: true);
        final result = await service.consumeAfterSuccessfulSave(
          kind: EntryQuotaKind.ai,
          operationId: 'premium-ai-$index',
          isPremium: true,
        );

        expect(decision.type, EntryQuotaDecisionType.premiumBypass);
        expect(result.status, EntryQuotaMutationStatus.premiumBypass);
      }

      final snapshot = await service.loadSnapshot(isPremium: true);

      expect(snapshot.isPremium, isTrue);
      expect(snapshot.aiConsumed, 0);
      expect(snapshot.aiRemaining, EntryQuotaDefaults.aiDailyLimit);
    });
  });

  group('EntryQuotaCubit', () {
    test('loads and emits refreshed remaining counts after consumption', () async {
      final tempDir = await Directory.systemTemp.createTemp('entry_quota_cubit_test_');
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
      );
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit);

      final result = await cubit.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: 'manual-1',
      );

      expect(result.status, EntryQuotaMutationStatus.consumed);
      expect(cubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit - 1);
      expect(cubit.state.aiRemaining, EntryQuotaDefaults.aiDailyLimit);
    });
  });
}
