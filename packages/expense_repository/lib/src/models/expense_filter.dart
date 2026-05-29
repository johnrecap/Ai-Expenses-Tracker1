import 'payment_method.dart';

enum ExpenseSource { manual, aiText, receipt, recurring }

class ExpenseFilter {
  final String? searchQuery;
  final String? categoryId;
  final PaymentMethod? paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? excludedCategoryIds;

  const ExpenseFilter({
    this.searchQuery,
    this.categoryId,
    this.paymentMethod,
    this.startDate,
    this.endDate,
    this.excludedCategoryIds,
  });

  static const ExpenseFilter empty = ExpenseFilter();

  bool get hasActiveFilters =>
      searchQuery != null ||
      categoryId != null ||
      paymentMethod != null ||
      startDate != null ||
      endDate != null ||
      (excludedCategoryIds != null && excludedCategoryIds!.isNotEmpty);

  ExpenseFilter copyWith({
    String? searchQuery,
    String? categoryId,
    PaymentMethod? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? excludedCategoryIds,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearPayment = false,
    bool clearStart = false,
    bool clearEnd = false,
    bool clearExcludedCategories = false,
  }) {
    return ExpenseFilter(
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      paymentMethod: clearPayment ? null : paymentMethod ?? this.paymentMethod,
      startDate: clearStart ? null : startDate ?? this.startDate,
      endDate: clearEnd ? null : endDate ?? this.endDate,
      excludedCategoryIds: clearExcludedCategories
          ? null
          : excludedCategoryIds ?? this.excludedCategoryIds,
    );
  }
}
