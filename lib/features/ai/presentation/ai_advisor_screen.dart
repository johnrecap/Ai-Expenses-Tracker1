import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/ai/models/ai_insight.dart';
import 'package:expenses_tracker/core/ai/models/ai_recommendation.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/features/ai/services/advisor_service.dart';
import 'widgets/ai_suggestion_card.dart';

/// {@template ai_advisor_screen}
/// The AI Advisor screen showing personalized financial insights and
/// actionable recommendations based on the user's spending history.
///
/// Uses the real [AdvisorService] (not a mock) to generate insights
/// locally or via the AI gateway. Supports both Arabic and English
/// with full RTL/LTR layout awareness.
/// {@endtemplate}
class AiAdvisorScreen extends StatefulWidget {
  /// {@macro ai_advisor_screen}
  const AiAdvisorScreen({super.key, required this.advisorService});

  /// The advisor service that generates insights and recommendations.
  final AdvisorService advisorService;

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  List<AiInsight> _insights = [];
  List<AiRecommendation> _recommendations = [];
  bool _loadingInsights = true;
  bool _loadingRecommendations = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadInsights(),
      _loadRecommendations(),
    ]);
  }

  Future<void> _loadInsights() async {
    try {
      final insights = await widget.advisorService.getInsights();
      if (mounted) {
        setState(() {
          _insights = insights;
          _loadingInsights = false;
          _error = null;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _loadingInsights = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recs = await widget.advisorService.getRecommendations();
      if (mounted) {
        setState(() {
          _recommendations = recs;
          _loadingRecommendations = false;
          _error = null;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _loadingRecommendations = false;
          _error = e.toString();
        });
      }
    }
  }

  bool get _isLoading => _loadingInsights || _loadingRecommendations;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: isRTL ? 'المستشار الذكي' : 'AI Advisor',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onSurface),
                  onPressed: () => context.push('/ai/assistant'),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: _buildBody(isRTL),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isRTL) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_error != null && _insights.isEmpty && _recommendations.isEmpty) {
      return _buildErrorState(isRTL);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'رؤى يومية' : "Today's Insights",
            Icons.insights,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_insights.isEmpty)
            _buildEmptyState(
              isRTL ? 'لا توجد رؤى حالياً' : 'No insights yet',
            )
          else
            ..._insights.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AiInsightCard(
                  title: entry.value.title,
                  summary: entry.value.summary,
                  severity: entry.value.severity,
                  onTap: entry.value.relatedRoute != null
                      ? () => context.push(entry.value.relatedRoute!)
                      : null,
                ),
              );
            }),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader(
            isRTL ? 'التوصيات' : 'Recommendations',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_recommendations.isEmpty)
            _buildEmptyState(
              isRTL ? 'لا توجد توصيات حالياً' : 'No recommendations yet',
            )
          else
            ..._recommendations.asMap().entries.map((entry) {
              return AiSuggestionCard(
                title: entry.value.title,
                body: entry.value.body,
                potentialSavings: entry.value.potentialSavings,
                onTap: () {
                  // Navigate to related action if route exists
                  // TODO: wire to specific action screens
                },
                onDismiss: () {
                  setState(() {
                    _recommendations.removeAt(entry.key);
                  });
                },
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryContainer),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          message,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isRTL) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              isRTL
                  ? 'فشل في تحميل البيانات. المرجو المحاولة مرة أخرى.'
                  : 'Failed to load AI advice. Please try again.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerLine(width: 120, height: 14),
          const SizedBox(height: AppSpacing.sm),
          _buildShimmerCard(),
          const SizedBox(height: AppSpacing.md),
          _buildShimmerCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildShimmerLine(width: 140, height: 14),
          const SizedBox(height: AppSpacing.sm),
          _buildShimmerCard(),
          const SizedBox(height: AppSpacing.md),
          _buildShimmerCard(),
        ],
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
    );
  }
}
