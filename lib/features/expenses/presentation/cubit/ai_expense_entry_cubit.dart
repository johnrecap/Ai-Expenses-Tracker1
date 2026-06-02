// ignore_for_file: prefer_initializing_formals

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../ai/data/ai_gateway_client.dart';
import '../../../ai/data/ai_gateway_models.dart';
import '../../domain/ai_expense_draft_mapper.dart';

part 'ai_expense_entry_state.dart';

typedef AiExpenseIdFactory = String Function();

class AiExpenseEntryCubit extends Cubit<AiExpenseEntryState> {
  AiExpenseEntryCubit({
    required AiGatewayClient gatewayClient,
    required ExpenseRepository expenseRepository,
    AiExpenseDraftMapper mapper = const AiExpenseDraftMapper(),
    AiExpenseIdFactory? expenseIdFactory,
  }) : _gatewayClient = gatewayClient,
       _expenseRepository = expenseRepository,
       _mapper = mapper,
       _expenseIdFactory = expenseIdFactory ?? (() => const Uuid().v4()),
       super(const AiExpenseEntryState());

  final AiGatewayClient _gatewayClient;
  final ExpenseRepository _expenseRepository;
  final AiExpenseDraftMapper _mapper;
  final AiExpenseIdFactory _expenseIdFactory;

  void textChanged(String value) {
    emit(
      state.copyWith(
        status: value.trim().isEmpty ? AiExpenseEntryStatus.empty : AiExpenseEntryStatus.typing,
        input: value,
        errorMessage: '',
        clearDraft: true,
        clearQuota: true,
      ),
    );
  }

  Future<void> parseText({
    required String locale,
    required String defaultCurrency,
    required List<Category> categories,
    PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
    DateTime? now,
  }) async {
    final input = state.input.trim();
    if (input.isEmpty) {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.parseFailed,
          errorMessage: 'Enter expense text first.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AiExpenseEntryStatus.parsing,
        errorMessage: '',
        clearDraft: true,
        clearQuota: true,
      ),
    );
    final localDraft = _tryBuildLocalDraft(
      input: input,
      defaultCurrency: defaultCurrency,
      defaultPaymentMethod: _detectPaymentMethod(input) ?? defaultPaymentMethod,
      categories: categories,
      now: now ?? DateTime.now(),
    );
    if (localDraft != null) {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.draftReady,
          draft: localDraft,
        ),
      );
      return;
    }

    try {
      final response = await _gatewayClient.parseExpense(
        AiGatewayParseTextRequest(
          input: input,
          now: now ?? DateTime.now(),
          locale: locale,
          defaultCurrency: defaultCurrency,
          clientRequestId: const Uuid().v4(),
          categories: categories
              .map(
                (category) => AiGatewayCategorySnapshot(
                  categoryId: category.categoryId,
                  name: category.name,
                  isArchived: category.isArchived,
                ),
              )
              .toList(),
        ),
      );
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.draftReady,
          draft: _mapper.fromGatewayDraft(
            response: response,
            categories: categories,
            defaultPaymentMethod: _detectPaymentMethod(input) ?? defaultPaymentMethod,
          ),
          quota: response.quota,
        ),
      );
    } on AiGatewayClientException catch (error) {
      emit(
        state.copyWith(
          status: _statusForGatewayError(error.code),
          errorMessage: error.message,
          quota: error.quota,
          clearDraft: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.parseFailed,
          errorMessage: 'AI parsing failed. You can retry or enter manually.',
          clearDraft: true,
          clearQuota: true,
        ),
      );
    }
  }

  void updateDraft(AiExpenseDraftSelection draft) {
    emit(
      state.copyWith(
        status: AiExpenseEntryStatus.draftReady,
        draft: draft,
        errorMessage: '',
      ),
    );
  }

  Future<void> saveDraft({
    required String userId,
    required List<Category> categories,
    required List<WalletAccount> wallets,
    PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
  }) async {
    final draft = state.draft;
    if (draft == null) {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.parseFailed,
          errorMessage: 'No AI draft is ready to save.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AiExpenseEntryStatus.saving, errorMessage: ''));
    try {
      final expense = _mapper.toExpense(
        draft: draft,
        userId: userId,
        categories: categories,
        wallets: wallets,
        expenseId: _expenseIdFactory(),
        defaultPaymentMethod: defaultPaymentMethod,
      );
      await _expenseRepository.createExpense(expense);
      emit(state.copyWith(status: AiExpenseEntryStatus.saved));
    } on AiExpenseDraftMappingException catch (error) {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.draftReady,
          errorMessage: 'Complete missing fields: ${error.missingFields.join(', ')}.',
          draft: draft.copyWith(missingFields: error.missingFields),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: AiExpenseEntryStatus.draftReady,
          errorMessage: 'Failed to save expense. Please try again.',
        ),
      );
    }
  }

  AiExpenseEntryStatus _statusForGatewayError(AiGatewayErrorCode code) {
    return switch (aiGatewayUserStateKindFor(code)) {
      AiGatewayUserStateKind.authRequired => AiExpenseEntryStatus.authRequired,
      AiGatewayUserStateKind.limitReached => AiExpenseEntryStatus.quotaBlocked,
      AiGatewayUserStateKind.networkRetry => AiExpenseEntryStatus.networkFailure,
      AiGatewayUserStateKind.gatewayUnavailable => AiExpenseEntryStatus.gatewayUnavailable,
      AiGatewayUserStateKind.genericFailure => AiExpenseEntryStatus.parseFailed,
    };
  }

  PaymentMethod? _detectPaymentMethod(String input) {
    final normalized = input.toLowerCase();
    if (RegExp(r'\b(bank transfer|transfer|instapay|wire)\b').hasMatch(normalized) ||
        normalized.contains('تحويل') ||
        normalized.contains('انستاباي')) {
      return PaymentMethod.bankTransfer;
    }
    if (RegExp(r'\b(visa|card|credit|debit|mastercard)\b').hasMatch(normalized) ||
        normalized.contains('فيزا') ||
        normalized.contains('كارت') ||
        normalized.contains('بطاقة')) {
      return PaymentMethod.visa;
    }
    if (RegExp(
          r'\b(wallet|mobile wallet|vodafone cash|orange cash|etisalat cash)\b',
        ).hasMatch(normalized) ||
        normalized.contains('محفظ') ||
        normalized.contains('فودافون كاش') ||
        normalized.contains('اورنج كاش') ||
        normalized.contains('اتصالات كاش')) {
      return PaymentMethod.wallet;
    }
    if (RegExp(r'\b(cash|cashy)\b').hasMatch(normalized) ||
        normalized.contains('كاش') ||
        normalized.contains('نقد')) {
      return PaymentMethod.cash;
    }
    return null;
  }

  AiExpenseDraftSelection? _tryBuildLocalDraft({
    required String input,
    required String defaultCurrency,
    required PaymentMethod defaultPaymentMethod,
    required List<Category> categories,
    required DateTime now,
  }) {
    final amount = _extractAmount(input);
    if (amount == null || amount <= 0) return null;

    final category = _detectCategory(input, categories);
    if (category == null) return null;

    return AiExpenseDraftSelection(
      amount: amount,
      currency: _detectCurrency(input) ?? defaultCurrency.trim().toUpperCase(),
      date: now,
      categoryId: category.categoryId,
      categoryName: category.name,
      description: _cleanDescription(input),
      paymentMethod: defaultPaymentMethod,
      confidence: 0.72,
      missingFields: const [],
    );
  }

  double? _extractAmount(String input) {
    final normalized = input.replaceAll(',', '.');
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  String? _detectCurrency(String input) {
    final normalized = input.toLowerCase();
    if (normalized.contains('egp') ||
        normalized.contains('pound') ||
        normalized.contains('جنيه') ||
        normalized.contains('جنية')) {
      return 'EGP';
    }
    if (normalized.contains('usd') ||
        normalized.contains('dollar') ||
        normalized.contains('دولار')) {
      return 'USD';
    }
    if (normalized.contains('sar') ||
        normalized.contains('riyal') ||
        normalized.contains('ريال')) {
      return 'SAR';
    }
    return null;
  }

  Category? _detectCategory(String input, List<Category> categories) {
    final active = categories.where((category) => !category.isArchived).toList();
    if (active.isEmpty) return null;
    final normalized = input.toLowerCase();

    for (final category in active) {
      final name = category.name.trim().toLowerCase();
      if (name.isNotEmpty && normalized.contains(name)) return category;
    }

    final keywordGroups = <List<String>, List<String>>{
      ['food', 'meal', 'restaurant', 'مطعم', 'اكل', 'أكل', 'غدا', 'غداء', 'فطار']: [
        'food',
        'restaurant',
        'meals',
        'اكل',
        'أكل',
      ],
      ['taxi', 'uber', 'bus', 'metro', 'transport', 'مواصلات', 'تاكسي', 'اوبر', 'أوبر']: [
        'transport',
        'transportation',
        'مواصلات',
      ],
      ['bill', 'electric', 'water', 'gas', 'internet', 'فاتورة', 'كهربا', 'كهرباء', 'نت']: [
        'bills',
        'utilities',
        'utility',
        'فواتير',
      ],
      ['shopping', 'market', 'mall', 'clothes', 'تسوق', 'سوبر', 'ماركت']: [
        'shopping',
        'groceries',
        'تسوق',
      ],
      ['doctor', 'pharmacy', 'medicine', 'دكتور', 'صيدلية', 'دواء']: [
        'health',
        'healthcare',
        'medical',
        'صحة',
      ],
    };

    for (final entry in keywordGroups.entries) {
      if (!entry.key.any((keyword) => normalized.contains(keyword.toLowerCase()))) continue;
      for (final category in active) {
        final normalizedName = category.name.trim().toLowerCase();
        final normalizedId = category.categoryId.trim().toLowerCase();
        if (entry.value.contains(normalizedName) || entry.value.contains(normalizedId)) {
          return category;
        }
      }
    }
    return null;
  }

  String _cleanDescription(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
