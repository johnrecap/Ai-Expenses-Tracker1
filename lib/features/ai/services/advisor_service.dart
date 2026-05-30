import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

import '../../../core/ai/ai_prompts.dart';
import '../../../core/ai/language_detector.dart';
import '../../../core/ai/models/ai_insight.dart' as core;
import '../../../core/ai/models/ai_recommendation.dart' as core;
import 'ai_api_service.dart';

/// {@template advisor_service}
/// Generates AI-driven financial insights and recommendations based on the
/// user's actual spending history stored in the local Drift database.
///
/// The service calculates aggregates (monthly totals, category breakdowns,
/// daily averages) from existing [expenses] and [budget] tables, then either:
///
/// 1. Sends a structured prompt to the AI gateway for rich, natural-language
///    insights, or
/// 2. Falls back to locally-generated insights when the gateway is unavailable.
///
/// All insights include a confidence / severity score and an estimated
/// potential savings amount.
/// {@endtemplate}
class AdvisorService {
  /// Creates an [AdvisorService].
  ///
  /// [store] provides synchronous access to the local Drift-backed data.
  /// [aiApiService] is optional; when `null` a default [AiApiService] is
  /// created so the service always attempts to route through the proxy.
  /// [languageDetector] decides whether to return Arabic or English content.
  AdvisorService({
    required this.store,
    AiApiService? aiApiService,
    LanguageDetector? languageDetector,
  })  : aiApiService = aiApiService ?? AiApiService(),
        _prompts = AiPrompts(
          languageDetector: languageDetector ?? const LanguageDetector(),
        );

  /// The local store interface backed by Drift (SQLite).
  final LocalStoreInterface store;

  /// Optional AI API service for rich natural-language insights.
  final AiApiService? aiApiService;

  final AiPrompts _prompts;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Generates a list of [AiInsight]s based on the user's spending patterns.
  ///
  /// Insights highlight trends, anomalies, and actionable observations.
  /// The [language] parameter overrides auto-detection (useful when the UI
  /// already knows the user's preference).
  Future<List<core.AiInsight>> getInsights({String? language}) async {
    final lang = language ?? _detectUserLanguage();
    final context = _buildSpendingContext();

    try {
      if (aiApiService != null) {
        final insights = await _fetchInsightsFromAi(context, lang);
        if (insights.isNotEmpty) return insights;
      }
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AdvisorService AI insights failed, falling back to local',
        error: e,
        stackTrace: stackTrace,
        name: 'AdvisorService',
      );
    }

    return _generateLocalInsights(context, lang);
  }

  /// Generates a list of [AiRecommendation]s with concrete savings suggestions.
  ///
  /// Recommendations are ordered by highest potential savings first.
  Future<List<core.AiRecommendation>> getRecommendations({String? language}) async {
    final lang = language ?? _detectUserLanguage();
    final context = _buildSpendingContext();

    try {
      if (aiApiService != null) {
        final recommendations = await _fetchRecommendationsFromAi(context, lang);
        if (recommendations.isNotEmpty) return recommendations;
      }
    } on Exception catch (e, stackTrace) {
      developer.log(
        'AdvisorService AI recommendations failed, falling back to local',
        error: e,
        stackTrace: stackTrace,
        name: 'AdvisorService',
      );
    }

    return _generateLocalRecommendations(context, lang);
  }

  /// Returns a quick spending summary suitable for displaying in a dashboard
  /// card or chat bubble.
  SpendingSummary getSpendingSummary() {
    return _buildSpendingContext();
  }

  // -------------------------------------------------------------------------
  // Spending context builder
  // -------------------------------------------------------------------------

  SpendingSummary _buildSpendingContext() {
    final now = DateTime.now();
    final expenses = store.expenses;

    // Current month boundaries
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlyExpenses = expenses.where(
      (Expense e) => e.date.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(monthEnd.add(const Duration(seconds: 1))),
    ).toList();

    final monthlyTotal = monthlyExpenses.fold<double>(
      0.0,
      (double sum, Expense e) => sum + e.amount,
    );

    // Category breakdown
    final categoryBreakdown = <String, double>{};
    for (final e in monthlyExpenses) {
      final name = e.categoryName;
      categoryBreakdown[name] = (categoryBreakdown[name] ?? 0.0) + e.amount;
    }

    // Daily average
    final daysInMonth = monthEnd.day;
    final dailyAverage = daysInMonth > 0 ? monthlyTotal / daysInMonth : 0.0;

    // Budget
    final budget = store.budget;
    final monthlyBudget = budget?.amount;

    // Previous month for trend calculation
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prevMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    final prevMonthExpenses = expenses.where(
      (Expense e) => e.date.isAfter(prevMonthStart.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(prevMonthEnd.add(const Duration(seconds: 1))),
    ).toList();
    final prevMonthTotal = prevMonthExpenses.fold<double>(
      0.0,
      (double sum, Expense e) => sum + e.amount,
    );

    // Top category
    String? topCategory;
    double topCategoryAmount = 0.0;
    for (final entry in categoryBreakdown.entries) {
      if (entry.value > topCategoryAmount) {
        topCategoryAmount = entry.value;
        topCategory = entry.key;
      }
    }

    // All-time totals
    final allTimeTotal = expenses.fold<double>(0.0, (double sum, Expense e) => sum + e.amount);

    return SpendingSummary(
      monthlyTotal: monthlyTotal,
      categoryBreakdown: categoryBreakdown,
      monthlyBudget: monthlyBudget,
      dailyAverage: dailyAverage,
      previousMonthTotal: prevMonthTotal,
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
      allTimeTotal: allTimeTotal,
      expenseCount: monthlyExpenses.length,
    );
  }

  // -------------------------------------------------------------------------
  // Gateway integration
  // -------------------------------------------------------------------------

  Future<List<core.AiInsight>> _fetchInsightsFromAi(
    SpendingSummary context,
    String lang,
  ) async {
    final prompt = _prompts.advisor(
      monthlyTotal: context.monthlyTotal,
      categoryBreakdown: context.categoryBreakdown,
      monthlyBudget: context.monthlyBudget,
      dailyAverage: context.dailyAverage,
      language: lang,
    );

    final response = await aiApiService!.getAdvice(prompt);
    if (response == null || response.isEmpty) return const [];

    // Parse the response - AI returns text, we convert to insights
    return _parseAiResponseToInsights(response, lang);
  }

  List<core.AiInsight> _parseAiResponseToInsights(String response, String lang) {
    final insights = <core.AiInsight>[];
    
    // Simple parsing - split by lines and create insights
    final lines = response.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    for (var i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.length < 10) continue;
      
      insights.add(core.AiInsight(
        id: 'ai-insight-${DateTime.now().millisecondsSinceEpoch}-$i',
        title: line.length > 50 ? line.substring(0, 50) : line,
        summary: line,
        severity: i == 0 ? 'high' : 'medium',
        generatedAt: DateTime.now(),
      ));
    }
    
    return insights;
  }

  Future<List<core.AiRecommendation>> _fetchRecommendationsFromAi(
    SpendingSummary context,
    String lang,
  ) async {
    final prompt = _prompts.advisor(
      monthlyTotal: context.monthlyTotal,
      categoryBreakdown: context.categoryBreakdown,
      monthlyBudget: context.monthlyBudget,
      dailyAverage: context.dailyAverage,
      language: lang,
    );

    final response = await aiApiService!.getAdvice(prompt);
    if (response == null || response.isEmpty) return const [];

    return _parseAiResponseToRecommendations(response, lang);
  }

  List<core.AiRecommendation> _parseAiResponseToRecommendations(String response, String lang) {
    final recommendations = <core.AiRecommendation>[];
    
    final lines = response.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    for (var i = 0; i < lines.length && i < 3; i++) {
      final line = lines[i].trim();
      if (line.length < 10) continue;
      
      recommendations.add(core.AiRecommendation(
        id: 'ai-rec-${DateTime.now().millisecondsSinceEpoch}-$i',
        title: line.length > 50 ? line.substring(0, 50) : line,
        body: line,
        potentialSavings: 0.0,
        generatedAt: DateTime.now(),
      ));
    }
    
    return recommendations;
  }

  // -------------------------------------------------------------------------
  // Local / offline insight generation
  // -------------------------------------------------------------------------

  List<core.AiInsight> _generateLocalInsights(
    SpendingSummary context,
    String lang,
  ) {
    final insights = <core.AiInsight>[];
    final now = DateTime.now();

    // 1. Budget overrun insight
    if (context.monthlyBudget != null && context.monthlyBudget! > 0) {
      final percentUsed =
          (context.monthlyTotal / context.monthlyBudget! * 100).round();
      if (percentUsed >= 100) {
        insights.add(_buildInsight(
          lang: lang,
          titleAr: 'تجاوزت الميزانية',
          titleEn: 'Budget Overrun',
          summaryAr:
              'لقد تجاوزت ميزانيتك الشهرية بنسبة $percentUsed%. الإجمالي: ${context.monthlyTotal.toStringAsFixed(2)} جنيه.',
          summaryEn:
              'You have exceeded your monthly budget by $percentUsed%. Total spent: ${context.monthlyTotal.toStringAsFixed(2)} EGP.',
          severity: 'high',
          route: '/budgets',
        ));
      } else if (percentUsed >= 80) {
        insights.add(_buildInsight(
          lang: lang,
          titleAr: 'اقتربت من الميزانية',
          titleEn: 'Approaching Budget Limit',
          summaryAr:
              'استهلكت $percentUsed% من ميزانيتك. ابقى ${(context.monthlyBudget! - context.monthlyTotal).toStringAsFixed(2)} جنيه.',
          summaryEn:
              'You have used $percentUsed% of your budget. Remaining: ${(context.monthlyBudget! - context.monthlyTotal).toStringAsFixed(2)} EGP.',
          severity: 'medium',
          route: '/budgets',
        ));
      }
    }

    // 2. Month-over-month trend
    if (context.previousMonthTotal > 0) {
      final change = context.monthlyTotal - context.previousMonthTotal;
      final percentChange =
          (change / context.previousMonthTotal * 100).abs().round();
      if (change > 0 && percentChange > 15) {
        insights.add(_buildInsight(
          lang: lang,
          titleAr: 'ارتفاع في المصاريف',
          titleEn: 'Spending Increase',
          summaryAr:
              'مصاريفك ازدادت بنسبة $percentChange% عن الشهر الماضي.',
          summaryEn:
              'Your spending increased by $percentChange% compared to last month.',
          severity: 'medium',
          route: '/reports',
        ));
      } else if (change < 0 && percentChange > 15) {
        insights.add(_buildInsight(
          lang: lang,
          titleAr: 'تقليص في المصاريف',
          titleEn: 'Spending Decrease',
          summaryAr:
              'أحسنت! مصاريفك قلت بنسبة $percentChange% عن الشهر الماضي.',
          summaryEn:
              'Great job! Your spending decreased by $percentChange% compared to last month.',
          severity: 'low',
          route: '/reports',
        ));
      }
    }

    // 3. Top category insight
    if (context.topCategory != null && context.topCategoryAmount > 0) {
      final percentOfTotal = context.monthlyTotal > 0
          ? (context.topCategoryAmount / context.monthlyTotal * 100).round()
          : 0;
      insights.add(_buildInsight(
        lang: lang,
        titleAr: 'أكبر فئة مصروفات',
        titleEn: 'Top Spending Category',
        summaryAr:
            '${context.topCategory} هي أكبر فئة مصروفاتك هذا الشهر بنسبة $percentOfTotal% من إجمالي المصاريف.',
        summaryEn:
            '${context.topCategory} is your top spending category this month, making up $percentOfTotal% of total expenses.',
        severity: 'low',
        route: '/expenses',
      ));
    }

    // 4. Daily average insight
    if (context.dailyAverage > 0) {
      final projectedMonthTotal = context.dailyAverage * now.day;
      if (context.monthlyBudget != null &&
          context.monthlyBudget! > 0 &&
          projectedMonthTotal > context.monthlyBudget!) {
        insights.add(_buildInsight(
          lang: lang,
          titleAr: 'توقع تجاوز الميزانية',
          titleEn: 'Budget Projection',
          summaryAr:
              'بمعدل المصاريف اليومي الحالي ، قد تتجاوز الميزانية بنهاية الشهر.',
          summaryEn:
              'At your current daily spending rate, you are projected to exceed your budget by month-end.',
          severity: 'high',
          route: '/budgets',
        ));
      }
    }

    return insights;
  }

  List<core.AiRecommendation> _generateLocalRecommendations(
    SpendingSummary context,
    String lang,
  ) {
    final recommendations = <core.AiRecommendation>[];

    // 1. Reduce top category spending
    if (context.topCategory != null && context.topCategoryAmount > 0) {
      final potentialSavings = context.topCategoryAmount * 0.15;
      recommendations.add(_buildRecommendation(
        lang: lang,
        titleAr: 'قلل مصاريف ${context.topCategory}',
        titleEn: 'Reduce ${context.topCategory} Spending',
        bodyAr:
            'إنهاء مصاريف ${context.topCategory} بنسبة 15% قد يوفر لك ${potentialSavings.toStringAsFixed(2)} جنيه شهرياً.',
        bodyEn:
            'Reducing your ${context.topCategory} expenses by 15% could save you ${potentialSavings.toStringAsFixed(2)} EGP per month.',
        potentialSavings: potentialSavings,
      ));
    }

    // 2. Budget-based recommendation
    if (context.monthlyBudget != null &&
        context.monthlyBudget! > 0 &&
        context.monthlyTotal > context.monthlyBudget!) {
      final overspend = context.monthlyTotal - context.monthlyBudget!;
      recommendations.add(_buildRecommendation(
        lang: lang,
        titleAr: 'التحكم في المصاريف',
        titleEn: 'Control Your Spending',
        bodyAr:
            'لقد تجاوزت ميزانيتك بمبلغ ${overspend.toStringAsFixed(2)} جنيه. حاول تحديد إنفاق يومي للبقاء ضمن الميزانية.',
        bodyEn:
            'You have exceeded your budget by ${overspend.toStringAsFixed(2)} EGP. Try setting a daily spending limit to stay within budget.',
        potentialSavings: overspend,
      ));
    }

    // 3. General savings tip based on daily average
    if (context.dailyAverage > 0) {
      final dailySavings = context.dailyAverage * 0.1;
      final monthlySavings = dailySavings * 30;
      recommendations.add(_buildRecommendation(
        lang: lang,
        titleAr: 'وفر يومياً',
        titleEn: 'Daily Savings Habit',
        bodyAr:
            'توفير مبلغ ${dailySavings.toStringAsFixed(2)} جنيه يومياً قد يوفر لك ${monthlySavings.toStringAsFixed(2)} جنيه شهرياً.',
        bodyEn:
            'Saving just ${dailySavings.toStringAsFixed(2)} EGP per day could accumulate to ${monthlySavings.toStringAsFixed(2)} EGP per month.',
        potentialSavings: monthlySavings,
      ));
    }

    // Sort by highest potential savings first.
    recommendations.sort((a, b) => b.potentialSavings.compareTo(a.potentialSavings));
    return recommendations;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _detectUserLanguage() {
    final settings = store.settings;
    if (settings != null) {
      final lang = settings.languagePreference.storageValue.toLowerCase();
      if (lang.startsWith('ar')) return 'ar';
    }
    return 'en';
  }

  core.AiInsight _buildInsight({
    required String lang,
    required String titleAr,
    required String titleEn,
    required String summaryAr,
    required String summaryEn,
    required String severity,
    String? route,
  }) {
    return core.AiInsight(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}-${titleEn.hashCode}',
      title: lang == 'ar' ? titleAr : titleEn,
      summary: lang == 'ar' ? summaryAr : summaryEn,
      severity: severity,
      relatedRoute: route,
      generatedAt: DateTime.now(),
    );
  }

  core.AiRecommendation _buildRecommendation({
    required String lang,
    required String titleAr,
    required String titleEn,
    required String bodyAr,
    required String bodyEn,
    required double potentialSavings,
  }) {
    return core.AiRecommendation(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}-${titleEn.hashCode}',
      title: lang == 'ar' ? titleAr : titleEn,
      body: lang == 'ar' ? bodyAr : bodyEn,
      potentialSavings: potentialSavings,
      generatedAt: DateTime.now(),
    );
  }
}

/// {@template spending_summary}
/// Aggregated spending data used to generate insights and recommendations.
/// {@endtemplate}
class SpendingSummary {
  /// Creates a [SpendingSummary].
  const SpendingSummary({
    required this.monthlyTotal,
    required this.categoryBreakdown,
    this.monthlyBudget,
    required this.dailyAverage,
    required this.previousMonthTotal,
    this.topCategory,
    required this.topCategoryAmount,
    required this.allTimeTotal,
    required this.expenseCount,
  });

  /// Total expenses for the current month.
  final double monthlyTotal;

  /// Map of category name → total amount for the current month.
  final Map<String, double> categoryBreakdown;

  /// The user's monthly budget, or `null` if not set.
  final double? monthlyBudget;

  /// Average daily spending for the current month.
  final double dailyAverage;

  /// Total expenses for the previous month.
  final double previousMonthTotal;

  /// The category with the highest spending this month.
  final String? topCategory;

  /// The amount spent in the top category.
  final double topCategoryAmount;

  /// Total of all recorded expenses (all time).
  final double allTimeTotal;

  /// Number of expenses recorded this month.
  final int expenseCount;

  /// Calculates the percentage of the budget used (0-100+).
  double get budgetUsedPercent {
    if (monthlyBudget == null || monthlyBudget! <= 0) return 0.0;
    return (monthlyTotal / monthlyBudget! * 100).clamp(0.0, double.infinity);
  }

  /// Whether the user is currently over budget.
  bool get isOverBudget =>
      monthlyBudget != null && monthlyBudget! > 0 && monthlyTotal > monthlyBudget!;

  /// The month-over-month change as a percentage.
  double get monthOverMonthPercent {
    if (previousMonthTotal <= 0) return 0.0;
    return ((monthlyTotal - previousMonthTotal) / previousMonthTotal * 100);
  }
}
