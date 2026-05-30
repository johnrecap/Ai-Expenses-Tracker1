import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

import '../../../core/ai/ai_expense_parser.dart';
import '../../../core/ai/models/ai_parsed_expense.dart';
import '../../../core/ai/smart_completion.dart';
import 'ai_gateway_client.dart';

/// {@template ai_expense_service}
/// High-level service that connects the AI parser, smart completion, and the
/// local Drift database to produce a fully-formed expense draft.
///
/// This is the bridge between raw natural language input and a concrete
/// [Expense] model ready for the UI or repository layer.
///
/// Usage:
/// ```dart
/// final service = AiExpenseService(
///   parser: parser,
///   smartCompletion: smartCompletion,
///   expenseRepository: expenseRepo,
/// );
/// final result = await service.processInput('lunch 50 at restaurant');
/// ```
/// {@endtemplate}
class AiExpenseService {
  /// Creates an [AiExpenseService].
  ///
  /// [parser] extracts structured data from free-form text.
  /// [smartCompletion] fills missing fields using historical DB context.
  /// [expenseRepository] is used to persist the final expense.
  AiExpenseService({
    required this.parser,
    required this.smartCompletion,
    required this.expenseRepository,
  });

  /// The AI parser (network or local heuristic).
  final AiExpenseParser parser;

  /// The smart completion engine backed by Drift.
  final SmartCompletion smartCompletion;

  /// Repository for persisting expenses.
  final ExpenseRepository expenseRepository;

  /// Processes [userInput] end-to-end: parse → complete → convert to draft.
  ///
  /// Returns an [AiExpenseResult] containing the parsed data, the completed
  /// version, the generated [Expense] draft, and a confidence score.
  Future<AiExpenseResult> processInput(String userInput) async {
    if (userInput.trim().isEmpty) {
      return AiExpenseResult.empty(userInput);
    }

    try {
      // 1. Parse raw input.
      final parsed = await parser.parse(userInput);

      // 2. Fill missing fields from database context.
      final completed = await smartCompletion.complete(parsed);

      // 3. Convert to an Expense draft.
      final draft = _toDraft(completed);

      // 4. Calculate overall confidence.
      final overallConfidence = _calculateOverallConfidence(completed, draft);

      return AiExpenseResult(
        parsed: parsed,
        completed: completed,
        draft: draft,
        confidence: overallConfidence,
        canSave: draft != null && completed.confidence >= 0.5,
      );
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AiExpenseService processing failed',
        error: e,
        stackTrace: stackTrace,
        name: 'AiExpenseService',
      );
      return AiExpenseResult.empty(userInput);
    }
  }

  /// Persists [draft] to the local database via [expenseRepository].
  ///
  /// Returns the saved expense ID, or `null` on failure.
  Future<String?> saveDraft(Expense draft) async {
    try {
      // Ensure the expense has a valid ID.
      final expenseToSave = draft.expenseId.isEmpty
          ? draft.copyWith(
              expenseId: const Uuid().v4(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : draft;

      await expenseRepository.createExpense(expenseToSave);
      return expenseToSave.expenseId;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AiExpenseService save failed',
        error: e,
        stackTrace: stackTrace,
        name: 'AiExpenseService',
      );
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Converts a completed [AiParsedExpense] into an [Expense] draft.
  Expense? _toDraft(AiParsedExpense completed) {
    if (completed.amount == null || completed.amount! <= 0) {
      return null;
    }

    final category = _resolveCategory(completed.category);
    final date = completed.date ?? DateTime.now();

    return Expense(
      expenseId: '',
      category: category,
      date: date,
      amount: completed.amount!,
      description: completed.note ?? completed.originalInput,
      currency: completed.currency ?? 'EGP',
      source: ExpenseSource.aiText,
      paymentMethod: PaymentMethod.cash,
    );
  }

  /// Resolves a category name to a concrete [Category] model.
  Category _resolveCategory(String? categoryName) {
    final categories = smartCompletion.store.categories;

    if (categoryName != null && categoryName.isNotEmpty) {
      final match = categories.firstWhere(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => Category.empty,
      );
      if (match.categoryId.isNotEmpty) {
        return match;
      }
    }

    // Fallback to a generic "other" category if available.
    final other = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'other',
      orElse: () => Category.empty,
    );
    if (other.categoryId.isNotEmpty) {
      return other;
    }

    // Ultimate fallback.
    return Category.empty.copyWith(
      categoryId: 'other',
      name: 'Other',
      icon: 'category',
      color: 0xFF9E9E9E,
    );
  }

  /// Calculates an overall confidence score for the result.
  double _calculateOverallConfidence(AiParsedExpense completed, Expense? draft) {
    if (draft == null) return 0.0;

    var score = completed.confidence;

    // Boost if amount is present and reasonable.
    if (completed.amount != null && completed.amount! > 0) {
      score += 0.1;
    }

    // Boost if category was resolved from existing data.
    if (completed.category != null &&
        smartCompletion.store.categories.any(
          (c) => c.name.toLowerCase() == completed.category!.toLowerCase(),
        )) {
      score += 0.1;
    }

    // Boost if currency matches the user's primary currency.
    final settings = smartCompletion.store.settings;
    if (settings != null &&
        completed.currency != null &&
        completed.currency!.toUpperCase() == settings.baseCurrency.toUpperCase()) {
      score += 0.05;
    }

    return score.clamp(0.0, 1.0);
  }
}

/// {@template ai_expense_result}
/// The outcome of processing a single piece of natural language input.
/// {@endtemplate}
class AiExpenseResult {
  /// Creates an [AiExpenseResult].
  const AiExpenseResult({
    required this.parsed,
    required this.completed,
    required this.draft,
    required this.confidence,
    required this.canSave,
  });

  /// Factory for an empty / failed result.
  factory AiExpenseResult.empty(String originalInput) {
    final emptyParsed = AiParsedExpense(
      amount: null,
      currency: null,
      category: null,
      date: null,
      note: null,
      confidence: 0.0,
      missingFields: const <String>[
        'amount',
        'currency',
        'category',
        'date',
        'note',
      ],
      originalInput: originalInput,
    );
    return AiExpenseResult(
      parsed: emptyParsed,
      completed: emptyParsed,
      draft: null,
      confidence: 0.0,
      canSave: false,
    );
  }

  /// The raw AI-parsed result (before database completion).
  final AiParsedExpense parsed;

  /// The completed result after database inference.
  final AiParsedExpense completed;

  /// The generated [Expense] draft, or `null` if conversion failed.
  final Expense? draft;

  /// Overall confidence score (0.0 to 1.0).
  final double confidence;

  /// Whether the draft is complete enough to be saved.
  final bool canSave;

  /// Returns `true` if the user should review the draft before saving.
  bool get needsReview => confidence < 0.85 || completed.missingFields.isNotEmpty;
}
