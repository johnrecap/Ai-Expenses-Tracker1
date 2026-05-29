class RecurringExpense {
  final String recurringExpenseId;
  final String userId;
  final String name;
  final double amount;
  final String currency;
  final String categoryId;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringExpense({
    required this.recurringExpenseId, required this.userId, required this.name,
    required this.amount, required this.currency, required this.categoryId,
    required this.frequency, required this.startDate, this.endDate,
    this.lastGeneratedDate, required this.createdAt, required this.updatedAt,
  });

  RecurringExpense copyWith({
    String? recurringExpenseId, String? userId, String? name,
    double? amount, String? currency, String? categoryId, String? frequency,
    DateTime? startDate, DateTime? endDate, DateTime? lastGeneratedDate,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return RecurringExpense(
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      userId: userId ?? this.userId, name: name ?? this.name,
      amount: amount ?? this.amount, currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId, frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
