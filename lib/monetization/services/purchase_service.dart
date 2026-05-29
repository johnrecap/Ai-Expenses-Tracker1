import 'package:flutter/material.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseService {
  final BuildContext context;

  const PurchaseService(this.context);

  Future<bool> purchasePremium() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      context.read<MonetizationCubit>().setPremium(true);
    }
    return true;
  }

  Future<bool> restorePurchases() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }
}
