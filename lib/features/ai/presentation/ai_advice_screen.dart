import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/core/mock/mock_data.dart';

class AiAdviceScreen extends StatelessWidget {
  const AiAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'AI Advice',
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Insights", style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      ...MockData.aiInsights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AiInsightCard(
                          title: insight.title,
                          summary: insight.summary,
                          severity: insight.severity,
                        ),
                      )),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Recommendations', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      _RecommendationCard(
                        title: 'Reduce dining spend',
                        body: 'Set a weekly food budget of 50 KWD to save up to 200 KWD/month.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _RecommendationCard(
                        title: 'Consolidate subscriptions',
                        body: 'Switch to an annual plan for YouTube Premium and save 15%.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _RecommendationCard(
                        title: 'Boost savings',
                        body: 'Increase your monthly savings allocation by 10% to reach your car fund goal faster.',
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassCardFill,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 20, color: AppColors.tertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
