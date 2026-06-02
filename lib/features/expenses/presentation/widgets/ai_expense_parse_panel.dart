import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/payment_method_selector.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:expenses_tracker/features/expenses/domain/ai_expense_draft_mapper.dart';
import 'package:expenses_tracker/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AiExpenseParsePanel extends StatefulWidget {
  const AiExpenseParsePanel({
    super.key,
    required this.categories,
    required this.defaultCurrency,
    required this.defaultPaymentMethod,
    required this.locale,
  });

  final List<Category> categories;
  final String defaultCurrency;
  final PaymentMethod defaultPaymentMethod;
  final String locale;

  @override
  State<AiExpenseParsePanel> createState() => _AiExpenseParsePanelState();
}

class _AiExpenseParsePanelState extends State<AiExpenseParsePanel> {
  final _controller = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onParse() async {
    final cubit = context.read<AiExpenseEntryCubit>();
    if (cubit.state.status == AiExpenseEntryStatus.parsing) return;

    FocusScope.of(context).unfocus();
    cubit.textChanged(_controller.text);
    await cubit.parseText(
      locale: widget.locale,
      defaultCurrency: widget.defaultCurrency,
      defaultPaymentMethod: widget.defaultPaymentMethod,
      categories: widget.categories,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiExpenseEntryCubit, AiExpenseEntryState>(
      builder: (context, state) {
        final isParsing = state.status == AiExpenseEntryStatus.parsing;
        final message = _messageForState(state);
        final draft = state.draft;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadii.lg,
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _inputFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    minLines: 3,
                    maxLines: 5,
                    onChanged: context.read<AiExpenseEntryCubit>().textChanged,
                    onSubmitted: (_) => _onParse(),
                    onTapOutside: (_) => _inputFocusNode.unfocus(),
                    scrollPadding: const EdgeInsets.all(AppSpacing.xl),
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe your expense, e.g. "Spent 250 EGP on lunch"',
                      hintMaxLines: 3,
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.outline,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.lg,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.lg,
                        borderSide: BorderSide(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.lg,
                        borderSide: BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.mic_none,
                        size: 20,
                        color: AppColors.outline,
                        semanticLabel: 'Microphone - visual only',
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: isParsing ? null : _onParse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                          ),
                          icon: isParsing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                            isParsing ? 'Parsing' : 'Parse',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              _AiGatewayStateCard(
                message: message,
                titleOverride: state.errorMessage,
                onAction: message.kind == AiGatewayUserStateKind.authRequired
                    ? () => context.go(AppRoutes.login)
                    : message.canRetry
                    ? _onParse
                    : null,
              ),
            ],
            if (draft != null) ...[
              const SizedBox(height: AppSpacing.md),
              _DraftCard(draft: draft),
            ],
          ],
        );
      },
    );
  }

  AiGatewayUserStateMessage? _messageForState(AiExpenseEntryState state) {
    return switch (state.status) {
      AiExpenseEntryStatus.authRequired => aiGatewayUserStateMessageFor(
        AiGatewayErrorCode.unauthenticated,
        quota: state.quota,
      ),
      AiExpenseEntryStatus.quotaBlocked => aiGatewayUserStateMessageFor(
        AiGatewayErrorCode.quotaExceeded,
        quota: state.quota,
      ),
      AiExpenseEntryStatus.networkFailure => aiGatewayUserStateMessageFor(
        AiGatewayErrorCode.network,
        quota: state.quota,
      ),
      AiExpenseEntryStatus.gatewayUnavailable => aiGatewayUserStateMessageFor(
        AiGatewayErrorCode.providerUnavailable,
        quota: state.quota,
      ),
      AiExpenseEntryStatus.parseFailed => aiGatewayUserStateMessageFor(
        AiGatewayErrorCode.invalidResponse,
        quota: state.quota,
      ),
      _ => null,
    };
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft});

  final AiExpenseDraftSelection draft;

  @override
  Widget build(BuildContext context) {
    final amount = draft.amount == null
        ? '-'
        : '${draft.amount!.toStringAsFixed(_currencyDecimals(draft.currency))} ${draft.currency ?? ''}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(20),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.primaryContainer.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'AI Suggestion',
                style: AppTextStyles.labelCaps.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SuggestionRow(
            label: 'Description',
            value: draft.description?.trim().isNotEmpty == true ? draft.description! : '-',
          ),
          _SuggestionRow(label: 'Amount', value: amount.trim()),
          _SuggestionRow(label: 'Category', value: draft.categoryName ?? '-'),
          _SuggestionRow(
            label: 'Payment',
            value: draft.paymentMethod == null
                ? '-'
                : paymentMethodLabel(context, draft.paymentMethod!),
          ),
          _SuggestionRow(label: 'Wallet', value: draft.walletAccountName ?? '-'),
          if (draft.missingFields.isNotEmpty)
            _SuggestionRow(
              label: 'Missing',
              value: draft.missingFields.join(', '),
            ),
        ],
      ),
    );
  }

  int _currencyDecimals(String? currency) {
    return currency?.toUpperCase() == 'KWD' ? 3 : 2;
  }
}

class _AiGatewayStateCard extends StatelessWidget {
  const _AiGatewayStateCard({
    required this.message,
    this.titleOverride,
    this.onAction,
  });

  final AiGatewayUserStateMessage message;
  final String? titleOverride;
  final VoidCallback? onAction;

  IconData get _icon {
    return switch (message.kind) {
      AiGatewayUserStateKind.authRequired => Icons.lock_outline,
      AiGatewayUserStateKind.limitReached => Icons.hourglass_empty,
      AiGatewayUserStateKind.networkRetry => Icons.wifi_off_outlined,
      AiGatewayUserStateKind.gatewayUnavailable => Icons.cloud_off_outlined,
      AiGatewayUserStateKind.genericFailure => Icons.error_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withAlpha(90),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.errorContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, size: 20, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleOverride ?? message.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (onAction != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: onAction,
                    icon: Icon(
                      message.kind == AiGatewayUserStateKind.authRequired
                          ? Icons.login_outlined
                          : Icons.refresh,
                      size: 16,
                    ),
                    label: Text(message.actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
