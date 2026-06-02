import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';

class FeatureGateService {
  final BuildContext context;

  const FeatureGateService(this.context);

  bool get isPremium {
    try {
      return context.read<MonetizationCubit>().state.isPremium;
    } catch (_) {
      return false;
    }
  }

  bool canUseAI() {
    if (isPremium) {
      return true;
    }

    try {
      return context.read<EntryQuotaCubit>().state.canSaveAi;
    } catch (_) {
      return false;
    }
  }

  bool canUseAdvancedReports() => isPremium;
  bool canRemoveAds() => isPremium;
}

class FeatureGate {
  final BuildContext context;
  const FeatureGate(this.context);

  bool get isPremium {
    try {
      return context.read<MonetizationCubit>().state.isPremium;
    } catch (_) {
      return false;
    }
  }
}
