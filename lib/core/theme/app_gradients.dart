import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient primaryAction = LinearGradient(
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiAction = LinearGradient(
    colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryAi = LinearGradient(
    colors: [AppColors.secondaryContainer, AppColors.tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleCyanBlob = LinearGradient(
    colors: [Color(0x1A00E5FF), Color(0x00FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient subtleMagentaBlob = LinearGradient(
    colors: [Color(0x0DDD2269), Color(0x00FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
