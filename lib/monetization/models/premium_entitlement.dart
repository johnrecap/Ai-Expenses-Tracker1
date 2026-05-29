class PremiumEntitlement {
  final bool isActive;
  final DateTime? expiryDate;
  final String? plan;
  const PremiumEntitlement({this.isActive = false, this.expiryDate, this.plan});
}
