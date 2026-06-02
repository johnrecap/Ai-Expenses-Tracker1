// ignore_for_file: prefer_initializing_formals

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary_builder.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary_cache.dart';
import 'package:expenses_tracker/features/ai/domain/ai_advice_cache.dart';
import 'package:expenses_tracker/features/ai/domain/ai_advice_request_mapper.dart';
import 'package:expenses_tracker/features/ai/domain/local_advice_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

typedef AiAdviceRequester =
    Future<AiGatewayAdviceResponse> Function(
      AiGatewayAdviceRequest request,
    );

class AiAdviceScreen extends StatefulWidget {
  const AiAdviceScreen({
    super.key,
    AdviceSummaryCache? summaryCache,
    LocalAdviceGenerator? adviceGenerator,
    AiAdviceRequester? adviceRequester,
    AiAdviceRequestMapper? requestMapper,
    AiAdviceCache? adviceCache,
  }) : _summaryCache = summaryCache,
       _adviceGenerator = adviceGenerator,
       _adviceRequester = adviceRequester,
       _requestMapper = requestMapper,
       _adviceCache = adviceCache;

  final AdviceSummaryCache? _summaryCache;
  final LocalAdviceGenerator? _adviceGenerator;
  final AiAdviceRequester? _adviceRequester;
  final AiAdviceRequestMapper? _requestMapper;
  final AiAdviceCache? _adviceCache;

  @override
  State<AiAdviceScreen> createState() => _AiAdviceScreenState();
}

class _AiAdviceScreenState extends State<AiAdviceScreen> {
  late AdviceSummaryCache _summaryCache;
  late LocalAdviceGenerator _adviceGenerator;
  late AiAdviceRequester _adviceRequester;
  late AiAdviceRequestMapper _requestMapper;
  late AiAdviceCache _adviceCache;
  late AdviceSummary _summary;
  String? _aiMessage;
  String? _aiAdvice;
  bool _isRefreshing = false;
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _adviceGenerator = widget._adviceGenerator ?? const LocalAdviceGenerator();
    _summaryCache = widget._summaryCache ?? AdviceSummaryCache.seeded(AdviceSummary.empty());
    _adviceRequester =
        widget._adviceRequester ?? ((request) => AiGatewayClient().getAdvice(request));
    _requestMapper = widget._requestMapper ?? const AiAdviceRequestMapper();
    _adviceCache = widget._adviceCache ?? AiAdviceCache();
    _summary = _summaryCache.currentSummary ?? AdviceSummary.empty();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectRepositoriesAndRefresh());
  }

  Future<void> _connectRepositoriesAndRefresh() async {
    if (widget._summaryCache != null || !mounted) return;

    final repositoryCache = _cacheFromRepositories(context);
    if (repositoryCache == null) return;
    _summaryCache = repositoryCache;
    await _refreshSummary();
  }

  AdviceSummaryCache? _cacheFromRepositories(BuildContext context) {
    try {
      return AdviceSummaryCache(
        builder: const AdviceSummaryBuilder(),
        expenseRepository: context.read<ExpenseRepository>(),
        budgetRepository: context.read<BudgetRepository>(),
        walletRepository: context.read<WalletAccountRepository>(),
        savingGoalRepository: context.read<SavingGoalRepository>(),
        recurringExpenseRepository: context.read<RecurringExpenseRepository>(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> _refreshSummary() async {
    setState(() => _isRefreshing = true);
    final summary = await _summaryCache.refresh();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _isRefreshing = false;
    });
  }

  Future<void> _requestAiAdvice() async {
    if (_isAiLoading) return;
    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() {
      _isAiLoading = true;
      _aiMessage = null;
    });

    try {
      final summary = await _summaryCache.read();
      final request = _requestMapper.map(
        summary,
        locale: locale,
        now: DateTime.now(),
      );
      final cached = _adviceCache.read(
        summaryHash: summary.summaryHash,
        period: request.period,
        locale: locale,
      );
      if (cached != null) {
        if (!mounted) return;
        setState(() {
          _summary = summary;
          _aiAdvice = cached.advice;
          _aiMessage = _localized(
            context,
            ar: 'تم عرض آخر نصيحة محفوظة.',
            en: 'Showing cached AI advice.',
          );
          _isAiLoading = false;
        });
        return;
      }

      final response = await _adviceRequester(request);
      _adviceCache.write(
        summaryHash: summary.summaryHash,
        period: request.period,
        locale: locale,
        response: response,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _aiAdvice = response.advice;
        _aiMessage = null;
        _isAiLoading = false;
      });
    } on AiGatewayClientException catch (error) {
      if (!mounted) return;
      final userMessage = error.userMessage;
      setState(() {
        _aiMessage = '${userMessage.title} ${userMessage.body}';
        _isAiLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _aiMessage = _localized(
          context,
          ar: 'تعذر تشغيل نصيحة AI الآن. النصائح المحلية ما زالت ظاهرة.',
          en: 'AI advice could not run now. Local advice is still available.',
        );
        _isAiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final localAdvice = _adviceGenerator.generate(_summary, locale: locale);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: locale == 'ar' ? 'نصائح محلية' : 'AI Advice',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  children: [
                    _LocalSummaryHeader(summary: _summary, isRefreshing: _isRefreshing),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      locale == 'ar' ? 'نصائح فورية من بيانات الجهاز' : 'Instant local advice',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final advice in localAdvice) ...[
                      AiInsightCard(
                        title: advice.title,
                        summary: advice.body,
                        severity: _severityLabel(advice.severity, locale),
                      ),
                      const SizedBox(height: AppSpacing.cardGutter),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _AskAiSection(
                      locale: locale,
                      message: _aiMessage,
                      aiAdvice: _aiAdvice,
                      isLoading: _isAiLoading,
                      onPressed: _requestAiAdvice,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _severityLabel(LocalAdviceSeverity severity, String locale) {
    switch (severity) {
      case LocalAdviceSeverity.high:
        return locale == 'ar' ? 'مهم' : 'High';
      case LocalAdviceSeverity.medium:
        return locale == 'ar' ? 'تنبيه' : 'Medium';
      case LocalAdviceSeverity.low:
        return null;
    }
  }

  static String _localized(
    BuildContext context, {
    required String ar,
    required String en,
  }) {
    return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  }
}

class _LocalSummaryHeader extends StatelessWidget {
  const _LocalSummaryHeader({
    required this.summary,
    required this.isRefreshing,
  });

  final AdviceSummary summary;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale == 'ar'
                      ? 'النصائح المحلية تعمل بدون إنترنت'
                      : 'Local advice works offline',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  locale == 'ar'
                      ? 'مصروفات الشهر: ${summary.totalSpent.toStringAsFixed(2)} ${summary.currency}'
                      : 'This month: ${summary.totalSpent.toStringAsFixed(2)} ${summary.currency}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _AskAiSection extends StatelessWidget {
  const _AskAiSection({
    required this.locale,
    required this.message,
    required this.aiAdvice,
    required this.isLoading,
    required this.onPressed,
  });

  final String locale;
  final String? message;
  final String? aiAdvice;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ar' ? 'Ask AI عند الطلب' : 'Ask AI on demand',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            locale == 'ar'
                ? 'النصائح فوق محلية وفورية. لما يتوصل الـ gateway، الزر ده هيبعت ملخص صغير فقط بعد موافقتك.'
                : 'The tips above are local and instant. Once the gateway is wired, this button will send only a compact summary after you tap.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isLoading ? 'Loading...' : 'Ask AI'),
          ),
          if (aiAdvice != null && aiAdvice!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AiInsightCard(
              title: locale == 'ar' ? 'نصيحة AI' : 'AI advice',
              summary: aiAdvice!,
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
