import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/goals/presentation/widgets/goal_card.dart';
import 'package:expenses_tracker/features/goals/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  State<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  List<SavingGoal> _lastGoals = const [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavingGoalBloc, SavingGoalState>(
      listener: (context, state) {
        if (state is SavingGoalSuccess) {
          _lastGoals = state.goals;
        } else if (state is SavingGoalActionSuccess) {
          _showMessage(context, state.message);
        } else if (state is SavingGoalFailure) {
          _showMessage(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final goals = state is SavingGoalSuccess ? state.goals : _lastGoals;
        final isBusy = state is SavingGoalSaving;

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: 'Saving Goals',
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add goal',
                      onPressed: isBusy ? null : () => _openGoalForm(context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Goals',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (state is SavingGoalLoading && goals.isEmpty)
                            const Center(child: CircularProgressIndicator())
                          else if (goals.isEmpty)
                            Column(
                              children: [
                                const EmptyState(
                                  icon: Icons.savings,
                                  title: 'No saving goals yet',
                                  subtitle: 'Add a target and track your progress.',
                                ),
                                ElevatedButton.icon(
                                  onPressed: isBusy ? null : () => _openGoalForm(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Goal'),
                                ),
                              ],
                            )
                          else
                            ...goals.map(
                              (goal) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: GoalCard(
                                  goal: goal,
                                  onEdit: isBusy ? null : () => _openGoalForm(context, goal: goal),
                                  onUpdateProgress: isBusy
                                      ? null
                                      : () => _openProgressForm(context, goal),
                                  onDelete: isBusy ? null : () => _confirmDelete(context, goal),
                                ),
                              ),
                            ),
                          if (isBusy) ...[
                            const SizedBox(height: AppSpacing.md),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        ],
                      ),
                    ),
                  ),
                  AppBottomNav(
                    selectedIndex: 2,
                    onDestinationSelected: (i) {
                      switch (i) {
                        case 0:
                          context.go(AppRoutes.home);
                        case 1:
                          context.go(AppRoutes.reports);
                        case 2:
                          context.go(AppRoutes.budgets);
                        case 3:
                          context.go(AppRoutes.wallets);
                        case 4:
                          context.go(AppRoutes.settings);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: isBusy ? null : () => _openGoalForm(context),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: AppColors.onPrimary),
          ),
        );
      },
    );
  }

  Future<void> _openGoalForm(BuildContext context, {SavingGoal? goal}) async {
    final result = await showModalBottomSheet<SavingGoal>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GoalFormSheet(
        existingGoal: goal,
        userId: _currentUserId(context),
        currency: _baseCurrency(context),
      ),
    );

    if (!context.mounted || result == null) return;
    if (goal == null) {
      context.read<SavingGoalBloc>().add(SavingGoalCreate(result));
    } else {
      context.read<SavingGoalBloc>().add(SavingGoalUpdate(result));
    }
  }

  Future<void> _openProgressForm(BuildContext context, SavingGoal goal) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _ProgressDialog(goal: goal),
    );
    if (!context.mounted || amount == null) return;
    context.read<SavingGoalBloc>().add(
      SavingGoalUpdate(
        goal.copyWith(currentAmount: amount, updatedAt: DateTime.now()),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavingGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    context.read<SavingGoalBloc>().add(SavingGoalDelete(goal.goalId));
  }

  String _currentUserId(BuildContext context) {
    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) return state.user.userId;
    } catch (_) {
      return '';
    }
    return '';
  }

  String _baseCurrency(BuildContext context) {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
      if (state is SettingsSaving) return state.tentative.baseCurrency;
    } catch (_) {
      return UserSettings.defaultBaseCurrency;
    }
    return UserSettings.defaultBaseCurrency;
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    showAppToast(context, message, isError: isError);
  }
}

class _GoalFormSheet extends StatefulWidget {
  const _GoalFormSheet({
    required this.userId,
    required this.currency,
    this.existingGoal,
  });

  final SavingGoal? existingGoal;
  final String userId;
  final String currency;

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  String? _error;
  DateTime? _deadline;
  int _color = 0xFF42A5F5;

  static const _colors = [
    0xFF42A5F5,
    0xFFFF7043,
    0xFF66BB6A,
    0xFFAB47BC,
    0xFFFFCA28,
    0xFF26C6DA,
  ];

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    if (goal != null) {
      _nameCtrl.text = goal.name;
      _targetCtrl.text = _formatAmount(goal.targetAmount);
      _currentCtrl.text = _formatAmount(goal.currentAmount);
      _deadline = goal.deadline;
      _deadlineCtrl.text = _formatDate(goal.deadline);
      _color = goal.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingGoal;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              existing == null ? 'New Goal' : 'Edit Goal',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('saving_goal_name'),
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('saving_goal_target'),
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_AmountInputFormatter()],
              decoration: InputDecoration(labelText: 'Target (${widget.currency})'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('saving_goal_current'),
              controller: _currentCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_AmountInputFormatter()],
              decoration: InputDecoration(labelText: 'Current saved (${widget.currency})'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('saving_goal_deadline'),
              controller: _deadlineCtrl,
              readOnly: true,
              onTap: _pickDeadline,
              decoration: InputDecoration(
                labelText: 'Deadline',
                suffixIcon: _deadline == null
                    ? const Icon(Icons.calendar_today_outlined)
                    : IconButton(
                        tooltip: 'Clear deadline',
                        onPressed: () {
                          setState(() {
                            _deadline = null;
                            _deadlineCtrl.clear();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Color',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
                    foregroundDecoration: _color == color
                        ? BoxDecoration(
                            border: Border.all(color: AppColors.onSurface, width: 2),
                            shape: BoxShape.circle,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              key: const Key('saving_goal_save'),
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(existing == null ? 'Create Goal' : 'Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime(now.year, now.month + 1, now.day),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 20),
    );
    if (selected == null) return;
    setState(() {
      _deadline = selected;
      _deadlineCtrl.text = _formatDate(selected);
    });
  }

  void _save() {
    final existing = widget.existingGoal;
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim());
    final current = double.tryParse(
      _currentCtrl.text.trim().isEmpty ? '0' : _currentCtrl.text.trim(),
    );
    if (name.isEmpty) {
      setState(() => _error = 'Enter a goal name.');
      return;
    }
    if (target == null || target <= 0) {
      setState(() => _error = 'Enter a positive target.');
      return;
    }
    if (current == null || current < 0) {
      setState(() => _error = 'Enter a valid saved amount.');
      return;
    }
    if (current > target) {
      setState(() => _error = 'Current amount cannot exceed the target.');
      return;
    }

    final now = DateTime.now();
    Navigator.pop(
      context,
      SavingGoal(
        goalId: existing?.goalId ?? 'goal-${now.microsecondsSinceEpoch}',
        userId: existing?.userId ?? widget.userId,
        name: name,
        targetAmount: target,
        currentAmount: current,
        currency: existing?.currency ?? widget.currency,
        deadline: _deadline,
        color: _color,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}

class _ProgressDialog extends StatefulWidget {
  const _ProgressDialog({required this.goal});

  final SavingGoal goal;

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _formatAmount(widget.goal.currentAmount));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: TextField(
        key: const Key('saving_goal_progress_amount'),
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_AmountInputFormatter()],
        decoration: InputDecoration(
          labelText: 'Current saved (${widget.goal.currency})',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('saving_goal_progress_save'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final amount = double.tryParse(_ctrl.text.trim());
    if (amount == null || amount < 0) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    if (amount > widget.goal.targetAmount) {
      setState(() => _error = 'Current amount cannot exceed the target.');
      return;
    }
    Navigator.pop(context, amount);
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty || RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

String _formatAmount(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
