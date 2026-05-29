import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';

class AiAdviceScreen extends StatefulWidget {
  const AiAdviceScreen({super.key});

  @override
  State<AiAdviceScreen> createState() => _AiAdviceScreenState();
}

class _AiAdviceScreenState extends State<AiAdviceScreen> {
  final _aiService = const MockAiService();
  List<AiInsight> _insights = [];
  List<AiRecommendation> _recommendations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final insights = await _aiService.getInsights();
      final recommendations = await _aiService.getRecommendations();
      if (mounted) {
        setState(() {
          _insights = insights;
          _recommendations = recommendations;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load AI advice. Please try again.';
        });
      }
    }
  }

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
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Insights", style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          ..._insights.map((insight) => Padding(
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
          ..._recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _RecommendationCard(
              title: rec.title,
              body: rec.body,
            ),
          )),
          const SizedBox(height: 80),
        ],
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
