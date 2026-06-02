import 'package:flutter/material.dart';

enum PurchaseFlowStatus { unavailable, verified, cancelled, failed }

class PurchaseResult {
  const PurchaseResult({
    required this.status,
    required this.message,
  });

  final PurchaseFlowStatus status;
  final String message;

  bool get isVerifiedPremium => status == PurchaseFlowStatus.verified;

  const PurchaseResult.unavailable([
    String message =
        'Premium is unavailable until store billing and the local entitlement cache are connected.',
  ]) : this(status: PurchaseFlowStatus.unavailable, message: message);

  const PurchaseResult.verified([
    String message = 'Premium entitlement is active from the store purchase state.',
  ]) : this(status: PurchaseFlowStatus.verified, message: message);
}

class PurchaseService {
  final BuildContext? context;

  const PurchaseService([this.context]);

  Future<PurchaseResult> purchasePremium() async {
    return const PurchaseResult.unavailable();
  }

  Future<PurchaseResult> restorePurchases() async {
    return const PurchaseResult.unavailable(
      'Restore is unavailable until the store restore flow and local entitlement cache are connected.',
    );
  }
}
