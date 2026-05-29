import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';

class FeatureGateService {
  final BuildContext context;

  const FeatureGateService(this.context);

  bool get isPremium => context.read<MonetizationCubit>().state.isPremium;

  bool canUseAI() => isPremium || _dailyAiCount() < 5;
  bool canExport() => isPremium;
  bool canUseAdvancedReports() => isPremium;
  bool canRemoveAds() => isPremium;

  int _dailyAiCount() => 0;
}

class FeatureGate {
  final BuildContext context;
  const FeatureGate(this.context);

  bool get isPremium => context.read<MonetizationCubit>().state.isPremium;
}
