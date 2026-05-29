import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryEntity {
  final String categoryId;
  final String userId;
  final String name;
  final int totalExpenses;
  final String icon;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'categoryId': categoryId, 'userId': userId, 'name': name,
    'totalExpenses': totalExpenses, 'icon': icon, 'color': color,
    'isArchived': isArchived,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static CategoryEntity fromDocument(Map<String, dynamic> data) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return CategoryEntity(
      categoryId: data['categoryId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      totalExpenses: data['totalExpenses'] as int? ?? 0,
      icon: data['icon'] as String? ?? '',
      color: data['color'] as int? ?? 0,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: ts(data['createdAt']),
      updatedAt: ts(data['updatedAt']),
    );
  }
}
