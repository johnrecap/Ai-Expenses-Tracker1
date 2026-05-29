class CategoryAlias {
  final String aliasId;
  final String userId;
  final String name;
  final String categoryId;
  final DateTime createdAt;

  const CategoryAlias({
    required this.aliasId, required this.userId, required this.name,
    required this.categoryId, required this.createdAt,
  });
}
