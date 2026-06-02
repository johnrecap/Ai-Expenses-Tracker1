import 'package:expense_repository/expense_repository.dart';

import '../../ai/data/ai_gateway_models.dart';

class AiExpenseDraftSelection {
  const AiExpenseDraftSelection({
    this.amount,
    this.currency,
    this.date,
    this.categoryId,
    this.categoryName,
    this.walletAccountId,
    this.walletAccountName,
    this.description,
    this.merchant,
    this.paymentMethod,
    this.confidence = 0,
    this.gatewayRequestId,
    this.missingFields = const [],
  });

  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? categoryId;
  final String? categoryName;
  final String? walletAccountId;
  final String? walletAccountName;
  final String? description;
  final String? merchant;
  final PaymentMethod? paymentMethod;
  final double confidence;
  final String? gatewayRequestId;
  final List<String> missingFields;

  bool get hasRequiredBase =>
      amount != null &&
      amount! > 0 &&
      date != null &&
      (currency?.trim().isNotEmpty ?? false) &&
      ((categoryId?.trim().isNotEmpty ?? false) || (categoryName?.trim().isNotEmpty ?? false));

  AiExpenseDraftSelection copyWith({
    double? amount,
    String? currency,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    String? walletAccountId,
    String? walletAccountName,
    String? description,
    String? merchant,
    PaymentMethod? paymentMethod,
    double? confidence,
    String? gatewayRequestId,
    List<String>? missingFields,
  }) {
    return AiExpenseDraftSelection(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      walletAccountId: walletAccountId ?? this.walletAccountId,
      walletAccountName: walletAccountName ?? this.walletAccountName,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      confidence: confidence ?? this.confidence,
      gatewayRequestId: gatewayRequestId ?? this.gatewayRequestId,
      missingFields: missingFields ?? this.missingFields,
    );
  }
}

class AiExpenseDraftMappingException implements Exception {
  const AiExpenseDraftMappingException(this.missingFields);

  final List<String> missingFields;

  @override
  String toString() => 'AiExpenseDraftMappingException($missingFields)';
}

class AiExpenseDraftMapper {
  const AiExpenseDraftMapper();

  AiExpenseDraftSelection fromGatewayDraft({
    required AiGatewayDraftResponse response,
    required List<Category> categories,
    PaymentMethod? defaultPaymentMethod,
  }) {
    final draft = response.draft;
    final category = _resolveCategory(
      categories: categories,
      categoryId: draft.categoryId,
      categoryName: draft.categoryName,
    );
    final missing = <String>{
      ...draft.missingFields,
      if (draft.amount == null || draft.amount! <= 0) 'amount',
      if (draft.date == null) 'date',
      if (draft.currency == null || draft.currency!.trim().isEmpty) 'currency',
      if (category == null) 'category',
    }.toList();

    return AiExpenseDraftSelection(
      amount: draft.amount,
      currency: draft.currency,
      date: draft.date,
      categoryId: category?.categoryId ?? draft.categoryId,
      categoryName: category?.name ?? draft.categoryName,
      description: draft.description,
      merchant: draft.merchant,
      paymentMethod: draft.paymentMethod == null
          ? defaultPaymentMethod
          : PaymentMethod.fromStorageValue(draft.paymentMethod),
      confidence: draft.confidence,
      gatewayRequestId: response.requestId,
      missingFields: missing,
    );
  }

  Expense toExpense({
    required AiExpenseDraftSelection draft,
    required String userId,
    required List<Category> categories,
    required List<WalletAccount> wallets,
    required String expenseId,
    PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
    DateTime? now,
  }) {
    final category = _resolveCategory(
      categories: categories,
      categoryId: draft.categoryId,
      categoryName: draft.categoryName,
    );
    final wallet = _resolveWallet(
      wallets: wallets,
      walletId: draft.walletAccountId,
      walletName: draft.walletAccountName,
    );
    final missing = <String>[
      if (draft.amount == null || draft.amount! <= 0) 'amount',
      if (draft.date == null) 'date',
      if (draft.currency == null || draft.currency!.trim().isEmpty) 'currency',
      if (category == null) 'category',
    ];
    if (missing.isNotEmpty) {
      throw AiExpenseDraftMappingException(missing);
    }

    final timestamp = now ?? DateTime.now();
    return Expense(
      expenseId: expenseId,
      userId: userId,
      category: category!,
      date: draft.date!,
      amount: draft.amount!,
      description: draft.description?.trim(),
      merchant: draft.merchant,
      paymentMethod: wallet == null
          ? draft.paymentMethod ?? defaultPaymentMethod
          : PaymentMethod.wallet,
      currency: draft.currency!.trim().toUpperCase(),
      source: ExpenseSource.aiText,
      walletAccountId: wallet?.walletId,
      walletAccountName: wallet?.name,
      aiActionId: draft.gatewayRequestId,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Category? _resolveCategory({
    required List<Category> categories,
    String? categoryId,
    String? categoryName,
  }) {
    final active = categories.where((category) => !category.isArchived);
    final trimmedId = categoryId?.trim();
    if (trimmedId != null && trimmedId.isNotEmpty) {
      for (final category in active) {
        if (category.categoryId == trimmedId) return category;
      }
    }
    final normalizedName = _normalize(categoryName);
    if (normalizedName == null) return null;
    for (final category in active) {
      if (_normalize(category.name) == normalizedName) return category;
    }
    return null;
  }

  WalletAccount? _resolveWallet({
    required List<WalletAccount> wallets,
    String? walletId,
    String? walletName,
  }) {
    final trimmedId = walletId?.trim();
    if (trimmedId != null && trimmedId.isNotEmpty) {
      for (final wallet in wallets) {
        if (wallet.walletId == trimmedId) return wallet;
      }
    }
    final normalizedName = _normalize(walletName);
    if (normalizedName == null) return null;
    for (final wallet in wallets) {
      if (_normalize(wallet.name) == normalizedName) return wallet;
    }
    return null;
  }

  String? _normalize(String? value) {
    final trimmed = value?.trim().toLowerCase();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
