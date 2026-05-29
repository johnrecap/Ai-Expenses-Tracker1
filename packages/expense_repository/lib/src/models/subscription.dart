class Subscription {
  final String subscriptionId;
  final String userId;
  final String name;
  final double amount;
  final String currency;
  final String frequency;
  final DateTime nextRenewalDate;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.subscriptionId, required this.userId, required this.name,
    required this.amount, required this.currency, required this.frequency,
    required this.nextRenewalDate, this.categoryId, required this.createdAt,
    required this.updatedAt,
  });
}
