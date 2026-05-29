import 'package:expense_repository/src/local/local_repository_store.dart';
import 'package:expense_repository/expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final LocalRepositoryStore store;
  LocalExpenseRepository({required this.store});

  @override Future<void> createExpense(Expense e) async => store.upsertExpense(e);
  @override Future<void> updateExpense(Expense e) async => store.upsertExpense(e);
  @override Future<void> deleteExpense(String id) async => store.deleteExpense(id);
  @override Future<Expense?> getExpenseById(String id) async => store.expenses.where((e) => e.expenseId == id).firstOrNull;
  @override Future<List<Expense>> getExpenses() async => store.expenses;
  @override Stream<List<Expense>> watchExpenses() => store.watchExpenses();
  @override Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    final query = filter.searchQuery?.trim().toLowerCase();
    return store.expenses.where((e) {
      if (query != null && query.isNotEmpty) {
        if (!e.description.toLowerCase().contains(query) && !e.categoryName.toLowerCase().contains(query)) return false;
      }
      if (filter.startDate != null && e.date.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && e.date.isAfter(filter.endDate!)) return false;
      return true;
    }).toList();
  }
}

class LocalCategoryRepository implements CategoryRepository {
  final LocalRepositoryStore store;
  LocalCategoryRepository({required this.store});

  @override Future<void> createCategory(Category c) async => store.upsertCategory(c);
  @override Future<void> updateCategory(Category c) async => store.upsertCategory(c);
  @override Future<void> archiveCategory(Category c) async { c.isArchived = true; store.upsertCategory(c); }
  @override Future<List<Category>> getCategories({bool includeArchived = false}) async =>
      store.categories.where((c) => includeArchived || !c.isArchived).toList();
  @override Stream<List<Category>> watchCategories({bool includeArchived = false}) =>
      store.watchCategories().map((list) => list.where((c) => includeArchived || !c.isArchived).toList());
}

class LocalBudgetRepository implements BudgetRepository {
  final LocalRepositoryStore store;
  LocalBudgetRepository({required this.store});

  @override Future<void> saveBudget(Budget b) async => store.upsertBudget(b);
  @override Future<Budget?> getCurrentMonthBudget({required int month, required int year}) async => store.budget;
  @override Stream<Budget?> watchCurrentMonthBudget({required int month, required int year}) => store.watchBudget();
}

class LocalSettingsRepository implements SettingsRepository {
  final LocalRepositoryStore store;
  LocalSettingsRepository({required this.store});

  @override Future<UserSettings> getSettings() async => store.settings ?? await ensureDefaultSettings();
  @override Stream<UserSettings> watchSettings() {
    if (store.settings == null) store.upsertSettings(UserSettings.defaults(userId: store.userId));
    return store.watchSettings();
  }
  @override Future<void> saveSettings(UserSettings s) async => store.upsertSettings(s);
  @override Future<void> updateBaseCurrency(String c) async { final s = await getSettings(); await saveSettings(s.copyWith(baseCurrency: c, updatedAt: DateTime.now())); }
  @override Future<void> updateLanguagePreference(LanguagePreference p) async { final s = await getSettings(); await saveSettings(s.copyWith(languagePreference: p, updatedAt: DateTime.now())); }
  @override Future<void> updateDefaultPaymentMethod(PaymentMethod m) async { final s = await getSettings(); await saveSettings(s.copyWith(defaultPaymentMethod: m, updatedAt: DateTime.now())); }
  @override Future<UserSettings> ensureDefaultSettings() async {
    final d = UserSettings.defaults(userId: store.userId);
    store.upsertSettings(d);
    return d;
  }
}

class LocalSavingGoalRepository implements SavingGoalRepository {
  final LocalRepositoryStore store;
  LocalSavingGoalRepository({required this.store});
  @override Future<void> createSavingGoal(SavingGoal g) async => store.upsertGoal(g);
  @override Future<void> updateSavingGoal(SavingGoal g) async => store.upsertGoal(g);
  @override Future<void> deleteSavingGoal(String id) async => store.deleteGoal(id);
  @override Future<List<SavingGoal>> getSavingGoals() async => store.goals;
  @override Stream<List<SavingGoal>> watchSavingGoals() => store.watchGoals();
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
