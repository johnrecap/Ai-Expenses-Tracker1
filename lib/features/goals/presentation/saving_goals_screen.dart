import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/progress_ring.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/goals/saving_goal_bloc/saving_goal_bloc.dart';
import 'widgets/goal_card.dart';

class SavingGoalsScreen extends StatelessWidget {
  const SavingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<SavingGoalBloc, SavingGoalState>(
            builder: (context, state) {
              final goals = state is SavingGoalSuccess ? state.goals : <SavingGoal>[];

              return Column(
                children: [
                  const AppTopBar(title: 'Saving Goals'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Goals', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.sm),
                          if (state is SavingGoalLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (goals.isEmpty)
                            const EmptyState(icon: Icons.savings, title: 'No saving goals yet')
                          else
                            ...goals.map((goal) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: GoalCard(goal: goal),
                            )),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  AppBottomNav(
                    selectedIndex: 2,
                    onDestinationSelected: (i) {
                      switch (i) {
                        case 0: context.go(AppRoutes.home);
                        case 1: context.go(AppRoutes.reports);
                        case 2: context.go(AppRoutes.budgets);
                        case 3: context.go(AppRoutes.wallets);
                        case 4: context.go(AppRoutes.settings);
                        default:

                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
