import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';

typedef EntryQuotaClock = DateTime Function();
typedef EntryQuotaPremiumProvider = bool Function();

class EntryQuotaService {
  factory EntryQuotaService({
    required LocalEntryQuotaStore store,
    String scopeId = EntryQuotaDefaults.defaultScopeId,
    EntryQuotaClock? clock,
    EntryQuotaPremiumProvider? premiumProvider,
  }) {
    return EntryQuotaService._(
      store,
      scopeId,
      clock ?? DateTime.now,
      premiumProvider ?? (() => false),
    );
  }

  EntryQuotaService._(this._store, this._scopeId, this._clock, this._premiumProvider);

  final LocalEntryQuotaStore _store;
  final String _scopeId;
  final EntryQuotaClock _clock;
  final EntryQuotaPremiumProvider _premiumProvider;

  String get scopeId => _scopeId;

  Future<EntryQuotaSnapshot> loadSnapshot({bool? isPremium}) {
    return _store.loadSnapshot(
      scopeId: _scopeId,
      now: _clock(),
      isPremium: isPremium ?? _premiumProvider(),
    );
  }

  Future<EntryQuotaDecision> canSave(EntryQuotaKind kind, {bool? isPremium}) async {
    final premium = isPremium ?? _premiumProvider();
    if (premium) {
      final snapshot = await loadSnapshot(isPremium: true);
      return EntryQuotaDecision.premiumBypass(kind: kind, snapshot: snapshot);
    }

    try {
      final snapshot = await loadSnapshot(isPremium: false);
      if (snapshot.hasRemainingFor(kind)) {
        return EntryQuotaDecision.allowed(kind: kind, snapshot: snapshot);
      }
      return EntryQuotaDecision.blocked(kind: kind, snapshot: snapshot);
    } catch (_) {
      return EntryQuotaDecision.unavailable(kind: kind);
    }
  }

  Future<EntryQuotaMutationResult> consumeAfterSuccessfulSave({
    required EntryQuotaKind kind,
    required String operationId,
    String? expenseId,
    bool? isPremium,
  }) async {
    final premium = isPremium ?? _premiumProvider();
    if (premium) {
      EntryQuotaSnapshot? snapshot;
      try {
        snapshot = await loadSnapshot(isPremium: true);
      } catch (_) {
        snapshot = null;
      }
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.premiumBypass,
        snapshot: snapshot,
        message: 'Premium users bypass free entry quotas.',
      );
    }

    try {
      return await _store.consume(
        scopeId: _scopeId,
        kind: kind,
        operationId: operationId,
        expenseId: expenseId,
        now: _clock(),
      );
    } catch (_) {
      return const EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.unavailable,
        snapshot: null,
        message: 'Entry limits are unavailable right now.',
      );
    }
  }

  Future<EntryQuotaMutationResult> grantReward({
    required EntryQuotaRewardPlacement placement,
    required String rewardEventId,
    int? amount,
    bool? isPremium,
  }) async {
    final premium = isPremium ?? _premiumProvider();
    if (premium) {
      EntryQuotaSnapshot? snapshot;
      try {
        snapshot = await loadSnapshot(isPremium: true);
      } catch (_) {
        snapshot = null;
      }
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.premiumBypass,
        snapshot: snapshot,
        message: 'Premium users do not need rewarded entry credits.',
      );
    }

    try {
      return await _store.grantReward(
        scopeId: _scopeId,
        placement: placement,
        rewardEventId: rewardEventId,
        amount: amount,
        now: _clock(),
      );
    } catch (_) {
      return const EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.unavailable,
        snapshot: null,
        message: 'Entry limits are unavailable right now.',
      );
    }
  }
}
