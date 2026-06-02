import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntryQuotaCubit extends Cubit<EntryQuotaState> {
  factory EntryQuotaCubit({
    required EntryQuotaService service,
    bool isPremium = false,
  }) {
    return EntryQuotaCubit._(service, isPremium);
  }

  EntryQuotaCubit._(this._service, bool isPremium) : super(EntryQuotaState(isPremium: isPremium));

  final EntryQuotaService _service;

  Future<void> load({bool? isPremium}) async {
    final premium = isPremium ?? state.isPremium;
    emit(state.copyWith(loading: true, isPremium: premium, clearError: true));
    try {
      final snapshot = await _service.loadSnapshot(isPremium: premium);
      emit(
        state.copyWith(
          loading: false,
          snapshot: snapshot,
          isPremium: premium,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          isPremium: premium,
          errorMessage: 'Entry limits are unavailable right now.',
        ),
      );
    }
  }

  Future<EntryQuotaDecision> canSave(EntryQuotaKind kind) async {
    final decision = await _service.canSave(kind, isPremium: state.isPremium);
    if (decision.snapshot != null) {
      emit(state.copyWith(snapshot: decision.snapshot, clearError: true));
    } else if (!decision.allowed) {
      emit(state.copyWith(errorMessage: decision.message));
    }
    return decision;
  }

  Future<EntryQuotaMutationResult> consumeAfterSuccessfulSave({
    required EntryQuotaKind kind,
    required String operationId,
    String? expenseId,
  }) async {
    final result = await _service.consumeAfterSuccessfulSave(
      kind: kind,
      operationId: operationId,
      expenseId: expenseId,
      isPremium: state.isPremium,
    );
    _emitMutationResult(result);
    return result;
  }

  Future<EntryQuotaMutationResult> grantReward({
    required EntryQuotaRewardPlacement placement,
    required String rewardEventId,
    int? amount,
  }) async {
    final result = await _service.grantReward(
      placement: placement,
      rewardEventId: rewardEventId,
      amount: amount,
      isPremium: state.isPremium,
    );
    _emitMutationResult(result);
    return result;
  }

  Future<EntryQuotaMutationResult> grantRewardFromAdResult({
    required EntryQuotaRewardPlacement placement,
    required RewardedAdResult adResult,
  }) async {
    if (state.isPremium) {
      final result = await _service.grantReward(
        placement: placement,
        rewardEventId: adResult.rewardEventId ?? 'premium-bypass',
        isPremium: true,
      );
      _emitMutationResult(result);
      return result;
    }

    if (adResult.verified) {
      return grantReward(
        placement: placement,
        rewardEventId: adResult.rewardEventId!,
      );
    }

    final result = EntryQuotaMutationResult(
      status: _statusForAdResult(adResult.status),
      snapshot: state.snapshot,
      message: adResult.message,
    );
    _emitMutationResult(result);
    return result;
  }

  void setPremium(bool isPremium) {
    emit(state.copyWith(isPremium: isPremium));
  }

  void _emitMutationResult(EntryQuotaMutationResult result) {
    if (result.snapshot != null) {
      emit(state.copyWith(snapshot: result.snapshot, clearError: true));
      return;
    }

    if (result.status == EntryQuotaMutationStatus.unavailable) {
      emit(state.copyWith(errorMessage: result.message));
    }
  }

  EntryQuotaMutationStatus _statusForAdResult(RewardedAdResultStatus status) {
    switch (status) {
      case RewardedAdResultStatus.verified:
        return EntryQuotaMutationStatus.failed;
      case RewardedAdResultStatus.dismissed:
        return EntryQuotaMutationStatus.dismissed;
      case RewardedAdResultStatus.skipped:
        return EntryQuotaMutationStatus.skipped;
      case RewardedAdResultStatus.unavailable:
        return EntryQuotaMutationStatus.unavailable;
      case RewardedAdResultStatus.failed:
        return EntryQuotaMutationStatus.failed;
    }
  }
}

class EntryQuotaState {
  const EntryQuotaState({
    this.loading = false,
    this.snapshot,
    this.errorMessage,
    this.isPremium = false,
  });

  final bool loading;
  final EntryQuotaSnapshot? snapshot;
  final String? errorMessage;
  final bool isPremium;

  bool get quotaUnavailable => errorMessage != null && snapshot == null;

  int get normalRemaining => snapshot?.normalRemaining ?? 0;
  int get aiRemaining => snapshot?.aiRemaining ?? 0;

  bool get canSaveNormal =>
      isPremium || (snapshot?.hasRemainingFor(EntryQuotaKind.normal) ?? false);
  bool get canSaveAi => isPremium || (snapshot?.hasRemainingFor(EntryQuotaKind.ai) ?? false);

  EntryQuotaState copyWith({
    bool? loading,
    EntryQuotaSnapshot? snapshot,
    String? errorMessage,
    bool? isPremium,
    bool clearError = false,
  }) {
    return EntryQuotaState(
      loading: loading ?? this.loading,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
