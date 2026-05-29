import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';

class EditMonthlyBudgetScreen extends StatefulWidget {
  const EditMonthlyBudgetScreen({super.key});

  @override
  State<EditMonthlyBudgetScreen> createState() => _EditMonthlyBudgetScreenState();
}

class _EditMonthlyBudgetScreenState extends State<EditMonthlyBudgetScreen> {
  double _totalBudget = 1200;
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<BudgetBloc>().state;
    if (state is BudgetLoaded && state.budget != null) {
      _totalBudget = state.budget!.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(title: 'Edit Budget', leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Monthly Budget', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('${_totalBudget.toInt()} KWD', style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface)),
                      const SizedBox(height: AppSpacing.sm),
                      Slider(
                        value: _totalBudget,
                        min: 500,
                        max: 5000,
                        divisions: 45,
                        activeColor: AppColors.primaryFixedDim,
                        onChanged: (v) => setState(() => _totalBudget = v),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: const BoxDecoration(gradient: AppGradients.primaryAction, borderRadius: AppRadii.pill),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                          onTap: () {
                            if (_justSaved) return;
                            final authState = context.read<AuthBloc>().state;
                            final userId = authState is AuthAuthenticated ? authState.user.userId : '';
                            final state = context.read<BudgetBloc>().state;
                            if (state is BudgetLoaded && state.budget != null) {
                              final updated = state.budget!.copyWith(amount: _totalBudget, updatedAt: DateTime.now());
                              context.read<BudgetBloc>().add(BudgetSave(updated));
                            } else {
                              final now = DateTime.now();
                              final budget = Budget(
                                budgetId: '${now.year}-${now.month}',
                                userId: userId,
                                month: now.month,
                                year: now.year,
                                amount: _totalBudget,
                                currency: 'KWD',
                                warningThresholdPercent: 80,
                                createdAt: now,
                                updatedAt: now,
                              );
                              context.read<BudgetBloc>().add(BudgetSave(budget));
                            }
                          },
                            borderRadius: AppRadii.pill,
                            child: const Center(child: Text('Save Budget', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600, fontSize: 16))),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BlocBuilder<BudgetBloc, BudgetState>(
                        builder: (context, state) {
                          if (state is BudgetSaving) return const Center(child: CircularProgressIndicator());
                          if (state is BudgetSaved && !_justSaved) {
                            _justSaved = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget saved')));
                              context.pop();
                            });
                            return const SizedBox.shrink();
                          }
                          if (state is BudgetError) {
                            return Text(state.message, style: const TextStyle(color: AppColors.error));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
