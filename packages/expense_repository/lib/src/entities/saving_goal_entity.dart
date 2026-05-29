import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saving_goal.dart';

class SavingGoalEntity {
  final String goalId;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingGoalEntity({
    required this.goalId, required this.userId, required this.name,
    required this.targetAmount, required this.currentAmount, required this.currency,
    this.deadline, required this.color, this.isArchived = false,
    required this.createdAt, required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'goalId': goalId, 'userId': userId, 'name': name,
    'targetAmount': targetAmount, 'currentAmount': currentAmount,
    'currency': currency, 'color': color, 'isArchived': isArchived,
    if (deadline != null) 'deadline': Timestamp.fromDate(deadline!),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static SavingGoalEntity fromDocument(Map<String, dynamic> data) {
    final ts = (dynamic v) => v is Timestamp ? v.toDate() : null;
    return SavingGoalEntity(
      goalId: data['goalId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'EGP',
      deadline: ts(data['deadline']),
      color: data['color'] as int? ?? 0xFF6C63FF,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: ts(data['createdAt']) ?? DateTime.now(),
      updatedAt: ts(data['updatedAt']) ?? DateTime.now(),
    );
  }

  SavingGoal toModel() => SavingGoal(
    goalId: goalId, userId: userId, name: name,
    targetAmount: targetAmount, currentAmount: currentAmount,
    currency: currency, deadline: deadline, color: color,
    createdAt: createdAt, updatedAt: updatedAt,
  );

  static SavingGoalEntity fromModel(SavingGoal m) => SavingGoalEntity(
    goalId: m.goalId, userId: m.userId, name: m.name,
    targetAmount: m.targetAmount, currentAmount: m.currentAmount,
    currency: m.currency, deadline: m.deadline, color: m.color,
    createdAt: m.createdAt, updatedAt: m.updatedAt,
  );
}
