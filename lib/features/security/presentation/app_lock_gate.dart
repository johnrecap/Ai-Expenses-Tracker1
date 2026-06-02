import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/features/security/presentation/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLockGate extends StatelessWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        final blocksApp =
            state.status == AppLockStatus.loading ||
            state.status == AppLockStatus.locked ||
            state.status == AppLockStatus.unlocking;

        return Stack(
          children: [
            child,
            if (blocksApp)
              Positioned.fill(
                child: state.status == AppLockStatus.loading
                    ? const _AppLockLoadingOverlay()
                    : const UnlockScreen(),
              ),
          ],
        );
      },
    );
  }
}

class _AppLockLoadingOverlay extends StatelessWidget {
  const _AppLockLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
