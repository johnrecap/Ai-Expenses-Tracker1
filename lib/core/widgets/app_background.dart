import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.background),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.subtleCyanBlob,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: 200,
          height: 200,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.subtleMagentaBlob,
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
