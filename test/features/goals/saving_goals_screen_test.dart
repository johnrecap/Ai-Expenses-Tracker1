import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/goals/presentation/saving_goals_screen.dart';
import 'package:expenses_tracker/features/goals/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavingGoalsScreen', () {
    testWidgets('creates a real saving goal from form input', (tester) async {
      final repo = _FakeSavingGoalRepository();
      await _pumpGoals(tester, repo);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('saving_goal_name')), 'Emergency Fund');
      await tester.enterText(find.byKey(const Key('saving_goal_target')), '5000');
      await tester.enterText(find.byKey(const Key('saving_goal_current')), '1000');
      await tester.tap(find.byKey(const Key('saving_goal_save')));
      await tester.pumpAndSettle();

      expect(repo.created, hasLength(1));
      expect(repo.created.single.name, 'Emergency Fund');
      expect(repo.created.single.targetAmount, 5000);
      expect(repo.created.single.currentAmount, 1000);
      expect(repo.created.single.currency, 'EGP');
      expect(repo.created.single.userId, 'user-1');
    });

    testWidgets('edits progress and deletes an existing goal', (tester) async {
      final goal = _goal(id: 'goal-1', name: 'Laptop', target: 3000, current: 500);
      final repo = _FakeSavingGoalRepository([goal]);
      await _pumpGoals(tester, repo);

      await tester.tap(find.byKey(const Key('saving_goal_edit_goal-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('saving_goal_target')), '3500');
      await tester.tap(find.byKey(const Key('saving_goal_save')));
      await tester.pumpAndSettle();

      expect(repo.updated.last.name, 'Laptop');
      expect(repo.updated.last.targetAmount, 3500);

      await tester.tap(find.byKey(const Key('saving_goal_progress_goal-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('saving_goal_progress_amount')), '1200');
      await tester.tap(find.byKey(const Key('saving_goal_progress_save')));
      await tester.pumpAndSettle();

      expect(repo.updated.last.currentAmount, 1200);

      await tester.tap(find.byKey(const Key('saving_goal_delete_goal-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repo.deleted, contains('goal-1'));
    });

    testWidgets('validates progress cannot exceed target', (tester) async {
      final repo = _FakeSavingGoalRepository([
        _goal(id: 'goal-1', name: 'Laptop', target: 3000, current: 500),
      ]);
      await _pumpGoals(tester, repo);

      await tester.tap(find.byKey(const Key('saving_goal_progress_goal-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('saving_goal_progress_amount')), '5000');
      await tester.tap(find.byKey(const Key('saving_goal_progress_save')));
      await tester.pump();

      expect(find.text('Current amount cannot exceed the target.'), findsOneWidget);
      expect(repo.updated, isEmpty);
    });
  });
}

Future<void> _pumpGoals(
  WidgetTester tester,
  _FakeSavingGoalRepository repo,
) async {
  final authRepository = _FakeAuthRepository();
  final settingsRepository = _FakeSettingsRepository(
    UserSettings.defaults(userId: 'user-1').copyWith(baseCurrency: 'EGP'),
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) => AuthBloc(authRepository)..add(AuthUserChanged(authRepository.currentUser)),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(settingsRepository)..loadSettings(),
        ),
        BlocProvider<SavingGoalBloc>(
          create: (_) => SavingGoalBloc(repo)..add(SavingGoalsWatch()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const SavingGoalsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SavingGoal _goal({
  required String id,
  required String name,
  required double target,
  required double current,
}) {
  return SavingGoal(
    goalId: id,
    userId: 'user-1',
    name: name,
    targetAmount: target,
    currentAmount: current,
    currency: 'EGP',
    color: 0xFF42A5F5,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

class _FakeSavingGoalRepository implements SavingGoalRepository {
  _FakeSavingGoalRepository([List<SavingGoal> initial = const []]) : goals = [...initial];

  final List<SavingGoal> goals;
  final List<SavingGoal> created = [];
  final List<SavingGoal> updated = [];
  final List<String> deleted = [];

  @override
  Future<void> createSavingGoal(SavingGoal goal) async {
    created.add(goal);
    goals.add(goal);
  }

  @override
  Future<void> deleteSavingGoal(String goalId) async {
    deleted.add(goalId);
    goals.removeWhere((goal) => goal.goalId == goalId);
  }

  @override
  Future<List<SavingGoal>> getSavingGoals() async => [...goals];

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {
    updated.add(goal);
    final index = goals.indexWhere((existing) => existing.goalId == goal.goalId);
    if (index == -1) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
  }

  @override
  Stream<List<SavingGoal>> watchSavingGoals() => Stream.value([...goals]);
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    settings = settings.copyWith(baseCurrency: currencyCode);
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference languagePreference) async {
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Stream<UserSettings> watchSettings() => Stream.value(settings);
}

class _FakeAuthRepository implements AuthRepository {
  final _user = const AppUser(
    userId: 'user-1',
    email: 'user@example.com',
    displayName: 'User',
  );

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser> get user => Stream.value(_user);

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateEmail(String email) async => _user;

  @override
  Future<AppUser> signIn({required String email, required String password}) async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => _user;

  @override
  Future<AppUser> updateDisplayName(String displayName) async => _user;

  @override
  Future<AppUser> reauthenticateWithGoogle() async => _user;
}
