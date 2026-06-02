import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('local-only no-cloud-write contract', () {
    test('localOnly factory output contains no Firebase or migration repositories', () {
      final factory = AuthenticatedRepositoryFactory(
        runtimeMode: RepositoryRuntimeMode.localOnly,
        localStoreFactory: (userId) => LocalRepositoryStore(userId: userId),
      );

      final bundle = factory.create(userId: 'ignored-cloud-user');
      final repositories = <Object>[
        bundle.expenseRepository,
        bundle.categoryRepository,
        bundle.categoryAliasRepository,
        bundle.categoryBudgetRepository,
        bundle.budgetRepository,
        bundle.settingsRepository,
        bundle.recurringExpenseRepository,
        bundle.savingGoalRepository,
        bundle.aiActionLogRepository,
        bundle.walletAccountRepository,
        bundle.transferRepository,
      ];

      for (final repository in repositories) {
        expect(repository, isNot(isA<FirebaseExpenseRepo>()));
        expect(repository, isNot(isA<FirebaseCategoryRepository>()));
        expect(repository, isNot(isA<FirebaseCategoryAliasRepository>()));
        expect(repository, isNot(isA<FirebaseCategoryBudgetRepository>()));
        expect(repository, isNot(isA<FirebaseBudgetRepository>()));
        expect(repository, isNot(isA<FirebaseSettingsRepository>()));
        expect(repository, isNot(isA<FirebaseRecurringExpenseRepository>()));
        expect(repository, isNot(isA<FirebaseSavingGoalRepository>()));
        expect(repository, isNot(isA<FirebaseAiActionLogRepository>()));
        expect(repository, isNot(isA<FirebaseWalletAccountRepository>()));
        expect(repository, isNot(isA<FirebaseTransferRepository>()));
        expect(repository, isNot(isA<MigrationComparisonExpenseRepository>()));
      }
    });

    test('legacy cloud modes must be selected explicitly', () {
      expect(
        RepositoryRuntimeMode.fromEnvironment(value: 'firebaseLegacy'),
        RepositoryRuntimeMode.firebaseLegacy,
      );
      expect(
        RepositoryRuntimeMode.fromEnvironment(value: 'vpsLocalFirst'),
        RepositoryRuntimeMode.vpsLocalFirst,
      );
      expect(
        RepositoryRuntimeMode.fromEnvironment(value: 'migrationComparison'),
        RepositoryRuntimeMode.migrationComparison,
      );
    });
  });
}
