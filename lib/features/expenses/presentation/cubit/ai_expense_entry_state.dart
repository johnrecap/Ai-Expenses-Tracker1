part of 'ai_expense_entry_cubit.dart';

enum AiExpenseEntryStatus {
  empty,
  typing,
  parsing,
  draftReady,
  parseFailed,
  quotaBlocked,
  authRequired,
  networkFailure,
  gatewayUnavailable,
  saving,
  saved,
}

class AiExpenseEntryState extends Equatable {
  const AiExpenseEntryState({
    this.status = AiExpenseEntryStatus.empty,
    this.input = '',
    this.draft,
    this.errorMessage,
    this.quota,
  });

  final AiExpenseEntryStatus status;
  final String input;
  final AiExpenseDraftSelection? draft;
  final String? errorMessage;
  final AiGatewayQuotaStatus? quota;

  bool get canSave =>
      status == AiExpenseEntryStatus.draftReady && draft != null && draft!.hasRequiredBase;

  AiExpenseEntryState copyWith({
    AiExpenseEntryStatus? status,
    String? input,
    AiExpenseDraftSelection? draft,
    String? errorMessage,
    AiGatewayQuotaStatus? quota,
    bool clearDraft = false,
    bool clearQuota = false,
  }) {
    return AiExpenseEntryState(
      status: status ?? this.status,
      input: input ?? this.input,
      draft: clearDraft ? null : draft ?? this.draft,
      errorMessage: errorMessage?.isEmpty == true ? null : errorMessage ?? this.errorMessage,
      quota: clearQuota ? null : quota ?? this.quota,
    );
  }

  @override
  List<Object?> get props => [status, input, draft, errorMessage, quota];
}
