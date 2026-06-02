import 'package:expense_repository/src/ai_action_log_repo.dart';
import 'package:expense_repository/src/budget_repo.dart';
import 'package:expense_repository/src/category_alias_repo.dart';
import 'package:expense_repository/src/category_budget_repo.dart';
import 'package:expense_repository/src/category_repo.dart';
import 'package:expense_repository/src/expense_repo.dart';
import 'package:expense_repository/src/firebase/firebase_ai_action_log_repo.dart';
import 'package:expense_repository/src/firebase/firebase_budget_repo.dart';
import 'package:expense_repository/src/firebase/firebase_category_alias_repo.dart';
import 'package:expense_repository/src/firebase/firebase_category_budget_repo.dart';
import 'package:expense_repository/src/firebase/firebase_category_repo.dart';
import 'package:expense_repository/src/firebase/firebase_expense_repo.dart';
import 'package:expense_repository/src/firebase/firebase_recurring_expense_repo.dart';
import 'package:expense_repository/src/firebase/firebase_saving_goal_repo.dart';
import 'package:expense_repository/src/firebase/firebase_settings_repo.dart';
import 'package:expense_repository/src/firebase/firebase_wallet_repo.dart';
import 'package:expense_repository/src/local/local_repositories.dart';
import 'package:expense_repository/src/local/drift/drift_store.dart';
import 'package:expense_repository/src/local/local_store_interface.dart';
import 'package:expense_repository/src/local/local_stubs.dart';
import 'package:expense_repository/src/recurring_expense_repo.dart';
import 'package:expense_repository/src/repository_runtime_mode.dart';
import 'package:expense_repository/src/saving_goal_repo.dart';
import 'package:expense_repository/src/settings_repo.dart';
import 'package:expense_repository/src/sync/migration_comparison_repository.dart';
import 'package:expense_repository/src/wallet_account_repo.dart';
import 'auth/auth_repository.dart';

typedef LocalRepositoryStoreFactory = LocalStoreInterface Function(String userId);

class AuthenticatedRepositoryBundle {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final CategoryAliasRepository categoryAliasRepository;
  final CategoryBudgetRepository categoryBudgetRepository;
  final BudgetRepository budgetRepository;
  final SettingsRepository settingsRepository;
  final RecurringExpenseRepository recurringExpenseRepository;
  final SavingGoalRepository savingGoalRepository;
  final AiActionLogRepository aiActionLogRepository;
  final WalletAccountRepository walletAccountRepository;
  final TransferRepository transferRepository;

  const AuthenticatedRepositoryBundle({
    required this.expenseRepository,
    required this.categoryRepository,
    required this.categoryAliasRepository,
    required this.categoryBudgetRepository,
    required this.budgetRepository,
    required this.settingsRepository,
    required this.recurringExpenseRepository,
    required this.savingGoalRepository,
    required this.aiActionLogRepository,
    required this.walletAccountRepository,
    required this.transferRepository,
  });
}

class AuthenticatedRepositoryFactory {
  static const localOnlyUserId = 'local-only-device';

  final RepositoryRuntimeMode runtimeMode;
  final LocalRepositoryStoreFactory? localStoreFactory;

  const AuthenticatedRepositoryFactory({
    this.runtimeMode = RepositoryRuntimeMode.localOnly,
    this.localStoreFactory,
  });

  factory AuthenticatedRepositoryFactory.fromEnvironment() {
    return AuthenticatedRepositoryFactory(
      runtimeMode: RepositoryRuntimeMode.fromEnvironment(),
    );
  }

  AuthenticatedRepositoryBundle create({
    required String userId,
    AuthRepository? authRepository,
  }) {
    switch (runtimeMode) {
      case RepositoryRuntimeMode.localOnly:
        return _createLocalOnlyBundle(userId: userId);
      case RepositoryRuntimeMode.firebaseLegacy:
        return _createFirebaseLegacyBundle(userId: userId);
      case RepositoryRuntimeMode.vpsLocalFirst:
        return _createVpsLocalFirstBundle(userId: userId);
      case RepositoryRuntimeMode.migrationComparison:
        return _createMigrationComparisonBundle(userId: userId);
    }
  }

  AuthenticatedRepositoryBundle createLocalOnly() {
    return _createLocalOnlyBundle(userId: localOnlyUserId);
  }

  AuthenticatedRepositoryBundle _createFirebaseLegacyBundle({required String userId}) {
    return AuthenticatedRepositoryBundle(
      expenseRepository: FirebaseExpenseRepo(userId: userId),
      categoryRepository: FirebaseCategoryRepository(userId: userId),
      categoryAliasRepository: FirebaseCategoryAliasRepository(userId: userId),
      categoryBudgetRepository: FirebaseCategoryBudgetRepository(userId: userId),
      budgetRepository: FirebaseBudgetRepository(userId: userId),
      settingsRepository: FirebaseSettingsRepository(userId: userId),
      recurringExpenseRepository: FirebaseRecurringExpenseRepository(userId: userId),
      savingGoalRepository: FirebaseSavingGoalRepository(userId: userId),
      aiActionLogRepository: FirebaseAiActionLogRepository(userId: userId),
      walletAccountRepository: FirebaseWalletAccountRepository(userId: userId),
      transferRepository: FirebaseTransferRepository(userId: userId),
    );
  }

  AuthenticatedRepositoryBundle _createVpsLocalFirstBundle({required String userId}) {
    return _createLocalOnlyBundle(userId: userId);
  }

  AuthenticatedRepositoryBundle _createLocalOnlyBundle({required String userId}) {
    final store = (localStoreFactory ?? _createDefaultLocalStore)(userId);
    return AuthenticatedRepositoryBundle(
      expenseRepository: LocalExpenseRepository(store: store),
      categoryRepository: LocalCategoryRepository(store: store),
      categoryAliasRepository: LocalCategoryAliasRepository(store: store),
      categoryBudgetRepository: LocalCategoryBudgetRepository(store: store),
      budgetRepository: LocalBudgetRepository(store: store),
      settingsRepository: LocalSettingsRepository(store: store),
      recurringExpenseRepository: LocalRecurringExpenseRepository(store: store),
      savingGoalRepository: LocalSavingGoalRepository(store: store),
      aiActionLogRepository: LocalAiActionLogRepository(store: store),
      walletAccountRepository: LocalWalletAccountRepository(store: store),
      transferRepository: LocalTransferRepository(store: store),
    );
  }

  static LocalStoreInterface _createDefaultLocalStore(String userId) {
    return DriftLocalRepositoryStore(userId: userId);
  }

  AuthenticatedRepositoryBundle _createMigrationComparisonBundle({required String userId}) {
    final legacy = _createFirebaseLegacyBundle(userId: userId);
    final migrated = _createVpsLocalFirstBundle(userId: userId);
    return AuthenticatedRepositoryBundle(
      expenseRepository: MigrationComparisonExpenseRepository(
        legacy: legacy.expenseRepository,
        migrated: migrated.expenseRepository,
      ),
      categoryRepository: migrated.categoryRepository,
      categoryAliasRepository: migrated.categoryAliasRepository,
      categoryBudgetRepository: migrated.categoryBudgetRepository,
      budgetRepository: migrated.budgetRepository,
      settingsRepository: migrated.settingsRepository,
      recurringExpenseRepository: migrated.recurringExpenseRepository,
      savingGoalRepository: migrated.savingGoalRepository,
      aiActionLogRepository: migrated.aiActionLogRepository,
      walletAccountRepository: migrated.walletAccountRepository,
      transferRepository: migrated.transferRepository,
    );
  }
}
