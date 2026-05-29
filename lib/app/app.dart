import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
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
import 'package:expenses_tracker/features/ai/services/ai_service.dart';
import 'package:expenses_tracker/core/config/app_config.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'go_router_refresh_stream.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final AuthRepository _authRepository;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSub;
  AuthenticatedRepositoryBundle? _bundle;
  String? _initError;
  String? _userId;

  @override
  void initState() {
    super.initState();
    try {
      _authRepository = FirebaseAuthRepository();
      _authBloc = AuthBloc(_authRepository);
      _router = AppRouter.create(_authBloc);
      _authSub = _authBloc.stream.listen(_onAuthStateChanged);
    } catch (e) {
      _initError = e.toString();
    }
  }

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _userId = state.user.userId;
      if (_bundle == null) {
        final factory = AuthenticatedRepositoryFactory.fromEnvironment();
        final newBundle = factory.create(userId: state.user.userId);
        if (mounted) {
          setState(() { _bundle = newBundle; });
        }
      }
    } else {
      if (_bundle != null && mounted) {
        setState(() { _bundle = null; _userId = null; });
      }
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    if (_initError == null) _router.dispose();
    if (_initError == null) _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Init error: $_initError',
              style: const TextStyle(fontSize: 16, color: Colors.red)),
          ),
        ),
      );
    }

    final bundle = _bundle;
    if (bundle == null) {
      return BlocProvider.value(
        value: _authBloc,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          locale: const Locale('ar'),
        ),
      );
    }

    final now = DateTime.now();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: bundle.expenseRepository),
        RepositoryProvider<BudgetRepository>.value(value: bundle.budgetRepository),
        RepositoryProvider<SavingGoalRepository>.value(value: bundle.savingGoalRepository),
        RepositoryProvider<CategoryRepository>.value(value: bundle.categoryRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider(create: (_) => GetExpensesBloc(bundle.expenseRepository)..add(GetExpenses())),
          BlocProvider(create: (_) => CreateExpenseBloc(bundle.expenseRepository)),
          BlocProvider(create: (_) => ExpenseFilterCubit()),
          BlocProvider(create: (_) => ReportCubit(bundle.expenseRepository)..load()),
          BlocProvider(create: (_) => BudgetBloc(bundle.budgetRepository)..add(BudgetLoad(now.month, now.year))),
          BlocProvider(create: (_) => SavingGoalBloc(bundle.savingGoalRepository)..add(SavingGoalsWatch())),
          BlocProvider(create: (_) => CategoryBloc(bundle.categoryRepository, _userId ?? '')..add(const CategoriesWatched())),
          BlocProvider(create: (_) => SettingsCubit(bundle.settingsRepository)),
          BlocProvider(create: (_) => OnboardingCubit(bundle.settingsRepository)),
          BlocProvider(create: (_) => AppLanguageCubit()),
          BlocProvider(create: (_) => AiAssistantCubit(aiService: AiService(gatewayUrl: AppConfig.aiGatewayUrl))),
        ],
        child: BlocListener<CreateExpenseBloc, CreateExpenseState>(
          listener: (context, state) {
            if (state is CreateExpenseSuccess) {
              context.read<GetExpensesBloc>().add(GetExpenses());
              context.read<ReportCubit>().load();
              context.read<BudgetBloc>().add(BudgetLoad(now.month, now.year));
            }
          },
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            locale: const Locale('ar'),
          ),
        ),
      ),
    );
  }
}
