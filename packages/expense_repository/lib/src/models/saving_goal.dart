class SavingGoal {
  final String goalId;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoal({
    required this.goalId,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.currency,
    this.deadline,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent => targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  SavingGoal copyWith({
    String? goalId, String? userId, String? name, double? targetAmount,
    double? currentAmount, String? currency, DateTime? deadline,
    int? color, DateTime? createdAt, DateTime? updatedAt,
  }) {
    return SavingGoal(
      goalId: goalId ?? this.goalId, userId: userId ?? this.userId,
      name: name ?? this.name, targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount, currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline, color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
