import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('local-only repository factory', () {
    test('localOnly is the default runtime mode', () {
      expect(RepositoryRuntimeMode.fromEnvironment(), RepositoryRuntimeMode.localOnly);
      expect(
        const AuthenticatedRepositoryFactory().runtimeMode,
        RepositoryRuntimeMode.localOnly,
      );
    });

    test('creates local repositories with one local store scope', () {
      final stores = <LocalStoreInterface>[];
      final factory = AuthenticatedRepositoryFactory(
        localStoreFactory: (userId) {
          expect(userId, AuthenticatedRepositoryFactory.localOnlyUserId);
          final store = LocalRepositoryStore(userId: userId);
          stores.add(store);
          return store;
        },
      );

      final bundle = factory.createLocalOnly();

      expect(stores, hasLength(1));
      expect(bundle.expenseRepository, isA<LocalExpenseRepository>());
      expect(bundle.categoryRepository, isA<LocalCategoryRepository>());
      expect(bundle.categoryAliasRepository, isA<LocalCategoryAliasRepository>());
      expect(bundle.categoryBudgetRepository, isA<LocalCategoryBudgetRepository>());
      expect(bundle.budgetRepository, isA<LocalBudgetRepository>());
      expect(bundle.settingsRepository, isA<LocalSettingsRepository>());
      expect(bundle.recurringExpenseRepository, isA<LocalRecurringExpenseRepository>());
      expect(bundle.savingGoalRepository, isA<LocalSavingGoalRepository>());
      expect(bundle.aiActionLogRepository, isA<LocalAiActionLogRepository>());
      expect(bundle.walletAccountRepository, isA<LocalWalletAccountRepository>());
      expect(bundle.transferRepository, isA<LocalTransferRepository>());

      expect((bundle.expenseRepository as LocalExpenseRepository).store, same(stores.single));
      expect((bundle.categoryRepository as LocalCategoryRepository).store, same(stores.single));
      expect((bundle.budgetRepository as LocalBudgetRepository).store, same(stores.single));
      expect((bundle.settingsRepository as LocalSettingsRepository).store, same(stores.single));
      expect((bundle.savingGoalRepository as LocalSavingGoalRepository).store, same(stores.single));
    });
  });
}
