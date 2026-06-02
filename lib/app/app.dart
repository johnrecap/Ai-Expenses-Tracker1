import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/goals/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/features/ai/ai_cubit/ai_assistant_cubit.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/features/security/presentation/app_lock_gate.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/features/recurring_expenses/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/services/admob_ad_service.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:expense_repository/expense_repository.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key, this.firebaseInitialized = false});

  final bool firebaseInitialized;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final AuthRepository _authRepository;
  late final AppLockCubit _appLockCubit;
  late final RepositoryRuntimeMode _runtimeMode;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSub;
  AuthenticatedRepositoryBundle? _bundle;
  String? _initError;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLockCubit = AppLockCubit()..initialize();
    try {
      final factory = AuthenticatedRepositoryFactory.fromEnvironment();
      _runtimeMode = factory.runtimeMode;
      if (_runtimeMode == RepositoryRuntimeMode.localOnly) {
        _bundle = factory.createLocalOnly();
        _userId = AuthenticatedRepositoryFactory.localOnlyUserId;
      }
      _authRepository = authRepositoryForRuntime(
        runtimeMode: _runtimeMode,
        firebaseInitialized: widget.firebaseInitialized,
      );
      _authBloc = AuthBloc(_authRepository);
      _router = AppRouter.create(_authBloc, runtimeMode: _runtimeMode);
      _authSub = _authBloc.stream.listen(_onAuthStateChanged);
    } catch (e) {
      _initError = e.toString();
    }
  }

  void _onAuthStateChanged(AuthState state) {
    if (_runtimeMode == RepositoryRuntimeMode.localOnly) {
      return;
    }
    if (state is AuthAuthenticated) {
      _userId = state.user.userId;
      if (_bundle == null) {
        final factory = AuthenticatedRepositoryFactory.fromEnvironment();
        final newBundle = factory.create(userId: state.user.userId);
        if (mounted) {
          setState(() {
            _bundle = newBundle;
          });
        }
      }
    } else {
      if (_bundle != null && mounted) {
        setState(() {
          _bundle = null;
          _userId = null;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appLockCubit.checkOnResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    if (_initError == null) _router.dispose();
    if (_initError == null) _authBloc.close();
    _appLockCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Init error: $_initError',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      );
    }

    final bundle = _bundle;
    if (bundle == null) {
      return RepositoryProvider<AuthRepository>.value(
        value: _authRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _authBloc),
            BlocProvider(create: (_) => AppLanguageCubit()),
            BlocProvider.value(value: _appLockCubit),
          ],
          child: BlocBuilder<AppLanguageCubit, LanguagePreference>(
            builder: (context, languagePreference) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                routerConfig: _router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languagePreference.forcedLocale,
                builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
              );
            },
          ),
        ),
      );
    }

    final now = DateTime.now();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<ExpenseRepository>.value(value: bundle.expenseRepository),
        RepositoryProvider<BudgetRepository>.value(value: bundle.budgetRepository),
        RepositoryProvider<CategoryBudgetRepository>.value(
          value: bundle.categoryBudgetRepository,
        ),
        RepositoryProvider<SavingGoalRepository>.value(value: bundle.savingGoalRepository),
        RepositoryProvider<CategoryRepository>.value(value: bundle.categoryRepository),
        RepositoryProvider<CategoryAliasRepository>.value(
          value: bundle.categoryAliasRepository,
        ),
        RepositoryProvider<WalletAccountRepository>.value(value: bundle.walletAccountRepository),
        RepositoryProvider<TransferRepository>.value(value: bundle.transferRepository),
        RepositoryProvider<RecurringExpenseRepository>.value(
          value: bundle.recurringExpenseRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider(
            create: (_) => GetExpensesBloc(bundle.expenseRepository)..add(GetExpenses()),
          ),
          BlocProvider(create: (_) => CreateExpenseBloc(bundle.expenseRepository)),
          BlocProvider(create: (_) => ExpenseFilterCubit()),
          BlocProvider(create: (_) => ReportCubit(bundle.expenseRepository)..load()),
          BlocProvider(
            create: (_) =>
                BudgetBloc(bundle.budgetRepository)..add(BudgetLoad(now.month, now.year)),
          ),
          BlocProvider(
            create: (_) => SavingGoalBloc(bundle.savingGoalRepository)..add(SavingGoalsWatch()),
          ),
          BlocProvider(
            create: (_) =>
                CategoryBloc(bundle.categoryRepository, _userId ?? '')
                  ..add(const CategoriesWatched()),
          ),
          BlocProvider(create: (_) => AppLanguageCubit()),
          BlocProvider(create: (_) => SettingsCubit(bundle.settingsRepository)..loadSettings()),
          BlocProvider(create: (_) => OnboardingCubit(bundle.settingsRepository)),
          BlocProvider(create: (_) => AiAssistantCubit()),
          BlocProvider(
            create: (_) => MonetizationCubit(adService: AdMobAdService())..load(),
          ),
          BlocProvider(
            create: (_) =>
                EntryQuotaCubit(
                  service: EntryQuotaService(
                    store: LocalEntryQuotaStore(),
                    scopeId: _userId ?? AuthenticatedRepositoryFactory.localOnlyUserId,
                  ),
                )..load(),
          ),
          BlocProvider.value(value: _appLockCubit),
          BlocProvider(
            create: (_) =>
                WalletBloc(bundle.walletAccountRepository, bundle.transferRepository)
                  ..add(const WalletsWatched()),
          ),
          BlocProvider(
            create: (_) =>
                RecurringExpenseBloc(bundle.recurringExpenseRepository, _userId ?? '')
                  ..add(const RecurringExpensesWatched()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<CreateExpenseBloc, CreateExpenseState>(
              listener: (context, state) {
                if (state is CreateExpenseSuccess) {
                  context.read<GetExpensesBloc>().add(GetExpenses());
                  context.read<ReportCubit>().load();
                  context.read<BudgetBloc>().add(BudgetLoad(now.month, now.year));
                }
              },
            ),
            BlocListener<SettingsCubit, SettingsState>(
              listener: (context, state) {
                if (state is SettingsSuccess) {
                  context.read<AppLanguageCubit>().setPreference(
                    state.settings.languagePreference,
                  );
                }
              },
            ),
            BlocListener<MonetizationCubit, MonetizationState>(
              listenWhen: (previous, current) => previous.isPremium != current.isPremium,
              listener: (context, state) {
                final quotaCubit = context.read<EntryQuotaCubit>();
                quotaCubit.setPremium(state.isPremium);
                unawaited(quotaCubit.load(isPremium: state.isPremium));
              },
            ),
          ],
          child: BlocBuilder<AppLanguageCubit, LanguagePreference>(
            builder: (context, languagePreference) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                routerConfig: _router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languagePreference.forcedLocale,
                builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
              );
            },
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
AuthRepository authRepositoryForRuntime({
  required RepositoryRuntimeMode runtimeMode,
  required bool firebaseInitialized,
  AuthRepository Function()? localFactory,
  AuthRepository Function()? firebaseFactory,
}) {
  if (runtimeMode == RepositoryRuntimeMode.localOnly && !firebaseInitialized) {
    return (localFactory ?? LocalAuthRepository.new)();
  }
  return (firebaseFactory ?? FirebaseAuthRepository.new)();
}
