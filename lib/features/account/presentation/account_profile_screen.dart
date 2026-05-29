import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/features/account/cubit/account_profile_cubit.dart';
import 'package:expenses_tracker/features/account/models/account_identity.dart';
import 'package:expenses_tracker/features/account/models/reauth_request.dart';
import 'package:expenses_tracker/features/account/services/account_deletion_service.dart';
import 'package:expenses_tracker/features/account/services/account_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({required this.user, super.key});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final profileService = DefaultAccountProfileService.instance;
    return BlocProvider(
      create: (_) => AccountProfileCubit(
        user: user,
        profileService: profileService,
        deletionService: AccountDeletionService(accountProfileService: profileService),
      )..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountProfileCubit, AccountProfileState>(
      listenWhen: (prev, curr) => prev.messageKey != curr.messageKey && curr.messageKey != null,
      listener: (context, state) {
        final msg = _messageText(state.messageKey);
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
        }
        if (state.status == AccountProfileStatus.deleted) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.onSurface),
            title: Text('Account Profile', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
          ),
          body: AppBackground(
            child: state.status == AccountProfileStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(top: false, child: ListView(padding: const EdgeInsets.all(AppSpacing.containerPadding), children: [
                    _IdentityCard(state: state),
                    const SizedBox(height: AppSpacing.md),
                    _ActionsCard(state: state),
                    const SizedBox(height: AppSpacing.md),
                    _DeleteCard(state: state),
                  ])),
          ),
        );
      },
    );
  }

  String? _messageText(AccountProfileMessageKey? key) {
    if (key == null) return null;
    return {
      AccountProfileMessageKey.loadFailed: 'Failed to load profile.',
      AccountProfileMessageKey.displayNameInvalid: 'Display name is required.',
      AccountProfileMessageKey.displayNameUpdated: 'Display name updated.',
      AccountProfileMessageKey.displayNameUpdateFailed: 'Could not update display name.',
      AccountProfileMessageKey.passwordResetSent: 'Password reset email sent.',
      AccountProfileMessageKey.passwordResetFailed: 'Could not send password reset.',
      AccountProfileMessageKey.emailInvalid: 'Enter a valid email.',
      AccountProfileMessageKey.emailUpdated: 'Email updated.',
      AccountProfileMessageKey.emailUpdateFailed: 'Could not update email.',
      AccountProfileMessageKey.reauthRequired: 'Please sign in again to continue.',
      AccountProfileMessageKey.reauthSucceeded: 'Verified.',
      AccountProfileMessageKey.reauthFailed: 'Verification failed.',
      AccountProfileMessageKey.reauthCanceled: 'Verification canceled.',
      AccountProfileMessageKey.reauthUnavailable: 'Verification not available.',
      AccountProfileMessageKey.deleteConfirmationRequired: 'Please confirm deletion.',
      AccountProfileMessageKey.dataDeleteFailed: 'Could not delete data.',
      AccountProfileMessageKey.authDeleteFailed: 'Could not delete account.',
      AccountProfileMessageKey.accountDeleted: 'Account deleted.',
      AccountProfileMessageKey.accountDeleteFailed: 'Could not delete account.',
    }[key];
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.state});
  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    final name = AccountIdentity.displayName(user: state.user, localDisplayName: state.localDisplayName, fallbackUserLabel: 'User');
    final secondary = AccountIdentity.secondaryIdentity(user: state.user, localDisplayName: state.localDisplayName);

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryContainer.withAlpha(80),
            child: Text(AccountIdentity.initials(name), style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
              if (secondary != null) Text(secondary, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            ]),
          ),
          IconButton(
            onPressed: state.isBusy ? null : () => _showEditNameDialog(context),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        const Divider(color: AppColors.surfaceContainerHigh),
        _Row(icon: Icons.email_outlined, label: 'Email', value: state.user.email?.trim().isNotEmpty == true ? state.user.email!.trim() : 'N/A'),
        _Row(icon: Icons.login_outlined, label: 'Provider', value: state.capabilities.providerLabel),
        _Row(
          icon: Icons.badge_outlined, label: 'Account ID', value: state.user.userId,
          trailing: IconButton(
            onPressed: () { Clipboard.setData(ClipboardData(text: state.user.userId)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copied'))); },
            icon: const Icon(Icons.copy_outlined, size: 18, color: AppColors.onSurfaceVariant),
          ),
        ),
      ]),
    );
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: state.localDisplayName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Enter your name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (!context.mounted || result == null) return;
    context.read<AccountProfileCubit>().saveDisplayName(result);
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.state});
  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
          title: Text('Reset Password', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text(state.capabilities.canSendPasswordReset ? 'Send a password reset email' : 'Not available',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          enabled: state.capabilities.canSendPasswordReset && !state.isBusy,
          trailing: state.status == AccountProfileStatus.sendingPasswordReset
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: state.capabilities.canSendPasswordReset && !state.isBusy
              ? () => context.read<AccountProfileCubit>().sendPasswordReset() : null,
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          leading: const Icon(Icons.alternate_email_outlined, color: AppColors.primary),
          title: Text('Update Email', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text(state.capabilities.canUpdateEmail ? 'Change your email address' : 'Not available',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          enabled: state.capabilities.canUpdateEmail && !state.isBusy,
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: state.capabilities.canUpdateEmail && !state.isBusy ? () => _showEmailDialog(context) : null,
        ),
      ]),
    );
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: state.user.email ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Email'),
        content: TextField(controller: ctrl, autofocus: true, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'name@example.com')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { final v = ctrl.text.trim(); if (!v.contains('@')) return; Navigator.pop(context, v); }, child: const Text('Update')),
        ],
      ),
    );
    ctrl.dispose();
    if (!context.mounted || result == null) return;
    context.read<AccountProfileCubit>().updateEmail(result);
  }
}

class _DeleteCard extends StatelessWidget {
  const _DeleteCard({required this.state});
  final AccountProfileState state;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
        title: Text('Delete Account', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
        subtitle: Text('Permanently delete all data', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        enabled: state.capabilities.canDeleteAccount && !state.isBusy,
        trailing: state.status == AccountProfileStatus.deletingAccount
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: state.capabilities.canDeleteAccount && !state.isBusy ? () => _showDeleteDialog(context) : null,
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete all your data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Forever', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    context.read<AccountProfileCubit>().deleteAccount(warningConfirmed: true);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.trailing});
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero, dense: true,
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      title: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      subtitle: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
      trailing: trailing,
    );
  }
}
