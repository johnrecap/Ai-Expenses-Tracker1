# Tasks: Backend Integration & Production Architecture

**Input**: Design documents from /specs/008-backend-integration/
**Prerequisites**: plan.md (required), spec.md (required)
**Project Type**: Production Flutter mobile app with full backend

## Mandatory First Read And Skill Gate
Before generating or executing tasks, the agent MUST:
- Read AGENTS.md.
- Read .specify/memory/constitution.md.
- Read .agents/workflows/development.md.
- Read .agents/skill-matcher.json.
- Search .agents/skills/ and .agent/skills/ for relevant skills.
- Load matching SKILL.md files and follow them.

## Non-Negotiable Rules
- Use expenses_tracker package name consistently.
- Use flutter_bloc for state management and go_router for navigation.
- No AI provider keys in Flutter source (gateway only).
- No secrets in Git (use dart-define or secure storage).
- Firebase Auth tokens must refresh silently.
- Offline-first writes must queue and sync transparently.
- All user-facing strings must be localized (EN/AR).
- RTL/LTR must work for all screens.
- Responsive at 360x800, 375x812, 390x844.
- Reuse shared widgets from lib/core/widgets/ and lib/core/theme/.

## Required Task Card Format
Every non-trivial generated task must include the complete detail block below.

```text
- [ ] T000 [P?] [Story? or Area] Short action with exact file path
  - Why: Explain the reason this task exists and what risk it removes.
  - Expected result: State the concrete visible or technical outcome.
  - Inputs: List the specs, references, mock data, or design docs needed.
  - Implementation notes: Mention component reuse, route impact, responsive behavior, RTL/LTR behavior, and forbidden shortcuts.
  - Possible bugs: List likely failures for this task.
  - Fix strategy: Explain how to diagnose and repair those failures.
  - Verification: Name the command, widget test, visual viewport check, or manual check that proves the task is complete.
```


## Phase 1: Setup And Project Restructure

**Purpose**: Rename package, add all production dependencies, set up multi-package architecture, and achieve a compiling baseline before any feature work.
**Checkpoint**: `flutter analyze` passes with zero errors. App launches to splash screen.

- [ ] T001 [Setup] Rename package from `ai_expenses_tracker` to `expenses_tracker` in `pubspec.yaml`
  - Why: The app must use the production package identity as specified by the user.
  - Expected result: `pubspec.yaml` name field reads `expenses_tracker`.
  - Inputs: Existing `pubspec.yaml`.
  - Implementation notes: Only change the `name:` field. Do not change description yet.
  - Possible bugs: Accidentally changing version or other fields.
  - Fix strategy: Diff the file before/after; verify only name changed.
  - Verification: `pubspec.yaml` name field reads `expenses_tracker`.

- [ ] T002 [Setup] Global find/replace all import statements from `ai_expenses_tracker` to `expenses_tracker`
  - Why: All Dart files import the package name; mismatches cause compile errors.
  - Expected result: Zero `ai_expenses_tracker` strings remain in `lib/` and `test/`.
  - Inputs: All `.dart` files under `lib/` and `test/`.
  - Implementation notes: Use grep to find all occurrences, then replace. Check both quote styles.
  - Possible bugs: Missing occurrences in generated files, asset references, or comments.
  - Fix strategy: Run `grep -r "ai_expenses_tracker" lib test` after replacement to verify zero hits.
  - Verification: `grep` returns empty for `ai_expenses_tracker` in `lib/` and `test/`.

- [ ] T003 [P] [Setup] Add Firebase dependencies to `pubspec.yaml`
  - Why: Firebase Auth and Firestore are the primary backend.
  - Expected result: `pubspec.yaml` includes `firebase_core`, `firebase_auth`, `cloud_firestore`.
  - Inputs: plan.md dependency list.
  - Implementation notes: Use exact versions from plan.md. Add under `dependencies:` section.
  - Possible bugs: Version conflicts with existing packages; wrong indentation.
  - Fix strategy: Run `flutter pub get` after adding; resolve any version solver errors.
  - Verification: `flutter pub get` succeeds with no version conflicts.

- [ ] T004 [P] [Setup] Add state management dependencies to `pubspec.yaml`
  - Why: `flutter_bloc` is the required state management framework.
  - Expected result: `pubspec.yaml` includes `flutter_bloc`, `bloc`, `equatable`.
  - Inputs: plan.md dependency list.
  - Implementation notes: These must be in `dependencies:`, not `dev_dependencies:`.
  - Possible bugs: Adding to wrong section.
  - Fix strategy: Check pubspec structure after edit.
  - Verification: `flutter pub get` succeeds.

- [ ] T005 [P] [Setup] Add AI and utility dependencies to `pubspec.yaml`
  - Why: AI gateway, image picker, speech-to-text, export, and other utilities are required by multiple features.
  - Expected result: `pubspec.yaml` includes `http`, `image_picker`, `image`, `speech_to_text`, `csv`, `excel`, `pdf`, `path_provider`, `share_plus`, `uuid`, `crypto`, `flutter_colorpicker`, `font_awesome_flutter`.
  - Inputs: plan.md dependency list.
  - Implementation notes: Group related packages together in pubspec for readability.
  - Possible bugs: Some packages may have native setup requirements.
  - Fix strategy: Note native setup requirements for later phases.
  - Verification: `flutter pub get` succeeds.

- [ ] T006 [P] [Setup] Add monetization and notification dependencies to `pubspec.yaml`
  - Why: Ads, purchases, and local notifications are required by monetization and engagement features.
  - Expected result: `pubspec.yaml` includes `google_mobile_ads`, `in_app_purchase`, `flutter_local_notifications`, `timezone`, `local_auth`, `flutter_secure_storage`.
  - Inputs: plan.md dependency list.
  - Implementation notes: These packages require significant native configuration; add to pubspec now but configure natively in later phases.
  - Possible bugs: `google_mobile_ads` and `in_app_purchase` may conflict on some Flutter versions.
  - Fix strategy: If version conflict, find compatible versions or temporarily comment out until needed.
  - Verification: `flutter pub get` succeeds.

- [ ] T007 [Setup] Add `flutter_localizations` and `intl` to `pubspec.yaml`
  - Why: Localization is required for EN/AR support.
  - Expected result: `pubspec.yaml` includes `flutter_localizations` (sdk) and `intl: ^0.20.2`.
  - Inputs: Existing l10n setup from new app; plan.md.
  - Implementation notes: `flutter_localizations` must be under `dependencies:` as an SDK package.
  - Possible bugs: `synthetic-package` deprecation issue with `intl` versions.
  - Fix strategy: If `flutter gen-l10n` fails, check Flutter version compatibility and update `l10n.yaml` if needed.
  - Verification: `flutter pub get` succeeds.

- [ ] T008 [Setup] Create `packages/expense_repository/` directory and `pubspec.yaml`
  - Why: The repository package isolates backend logic from UI and enables reuse.
  - Expected result: `packages/expense_repository/pubspec.yaml` exists with package name `expense_repository`, dependencies on `cloud_firestore`, `uuid`, `equatable`, and Flutter SDK.
  - Inputs: `Expense-Tracker-main/packages/expense_repository/pubspec.yaml` as reference.
  - Implementation notes: Keep it minimal; add more dependencies as repositories are implemented.
  - Possible bugs: Wrong package name or missing `publish_to: 'none'`.
  - Fix strategy: Compare with reference file.
  - Verification: `cat packages/expense_repository/pubspec.yaml` shows correct structure.

- [ ] T009 [Setup] Update root `pubspec.yaml` to include `expense_repository` as a path dependency
  - Why: The main app must depend on the local repository package.
  - Expected result: Root `pubspec.yaml` has `expense_repository: path: packages/expense_repository`.
  - Inputs: Root pubspec.yaml.
  - Implementation notes: Add under `dependencies:` section.
  - Possible bugs: Wrong path format.
  - Fix strategy: Use exact format `path: packages/expense_repository`.
  - Verification: `flutter pub get` resolves the local package.

- [ ] T010 [Setup] Update `main.dart` to initialize Firebase and Bloc observer
  - Why: Firebase must be initialized before any Firebase-dependent code runs.
  - Expected result: `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp()`, sets `Bloc.observer`, then runs app.
  - Inputs: `Expense-Tracker-main/lib/main.dart` as reference.
  - Implementation notes: Keep the new app's simple structure; add Firebase init. Do not add notification init yet (Phase 9).
  - Possible bugs: Firebase not configured natively yet will cause runtime crash; this is expected and OK for this phase.
  - Fix strategy: Verify compile only; runtime Firebase test comes after native config.
  - Verification: `flutter analyze` passes; app compiles.

- [ ] T011 [Setup] Update `app_view.dart` to use `go_router` and localization delegates
  - Why: The app needs declarative routing and EN/AR localization.
  - Expected result: `app_view.dart` builds `MaterialApp.router` with `routerConfig`, `localizationsDelegates`, `supportedLocales`, and `locale` from `AppLanguageCubit`.
  - Inputs: Existing `lib/app/app.dart` and `lib/app/router.dart` from new app.
  - Implementation notes: Preserve the existing theme from `AppTheme.light()`. Add `debugShowCheckedModeBanner: false`.
  - Possible bugs: Router not yet fully configured causes runtime issues; this is OK for this phase.
  - Fix strategy: Ensure compile passes even if routes are incomplete.
  - Verification: `flutter analyze` passes.

- [ ] T012 [Setup] Run `flutter pub get` and verify zero analysis errors
  - Why: The project must compile before any feature work begins.
  - Expected result: `flutter pub get` succeeds, `flutter analyze` returns zero errors.
  - Inputs: Updated pubspec.yaml and all renamed imports.
  - Implementation notes: If analysis errors exist, fix them before proceeding. Common issues: missing imports, wrong package names, deprecated APIs.
  - Possible bugs: Version conflicts, missing SDK constraints, import path errors.
  - Fix strategy: Address each analyzer error one by one. Prioritize import errors.
  - Verification: `flutter pub get` then `flutter analyze --no-pub` both return success.

## Phase 2: Foundation

- [ ] T013 [Foundation] Define all repository interfaces in packages/expense_repository/lib/src/
  - Why: Decouple UI from backend. Expected: expense_repo.dart, category_repo.dart, budget_repo.dart, etc.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/
  - Notes: Define CRUD methods returning Future or Stream. Use domain models.
  - Bugs: Inconsistent method signatures. Fix: Define base pattern and apply consistently.
  - Verify: flutter analyze packages/expense_repository passes.

- [ ] T014 [Foundation] Define domain models in packages/expense_repository/lib/src/models/
  - Why: Shared data structures for repositories, blocs, and UI.
  - Expected: expense.dart, category.dart, budget.dart, etc. with copyWith, toJson, fromJson, Equatable.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/models/
  - Bugs: Missing Equatable causes rebuilds. Fix: Use Equatable from start.
  - Verify: All model files compile.

- [ ] T015 [Foundation] Define Firestore entity serializers in packages/expense_repository/lib/src/entities/
  - Why: Firestore needs separate serialization from domain models.
  - Expected: Entity files with fromDocument, toDocument methods.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/entities/
  - Bugs: Timestamp conversion errors. Fix: Use Timestamp.toDate() and Timestamp.fromDate().
  - Verify: Entity serialization round-trips in unit tests.

- [ ] T016 [Foundation] Create repository_runtime_mode.dart
  - Why: Support firebaseLegacy, vpsLocalFirst, migrationComparison modes.
  - Expected: Enum and fromEnvironment() factory. Default: firebaseLegacy.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/repository_runtime_mode.dart
  - Bugs: Environment variable not set. Fix: Provide explicit default.
  - Verify: Unit test for each mode string.

- [ ] T017 [Foundation] Create AuthenticatedRepositoryFactory stub
  - Why: Central factory for creating repositories based on auth state and mode.
  - Expected: Factory class accepting mode and UserId, returns AuthenticatedRepositoryBundle.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/repository_factory.dart
  - Bugs: Factory too complex. Fix: Implement one mode at a time, use strategy pattern.
  - Verify: Factory compiles and returns non-null bundle.

- [ ] T018 [Foundation] Set up l10n.yaml and create app_en.arb
  - Why: Localization must be set up before new screens are built.
  - Expected: l10n.yaml with arb-dir: lib/l10n. app_en.arb with all UI strings.
  - Inputs: All 25 existing screens; Expense-Tracker-main/lib/l10n/
  - Bugs: Missing strings cause compile errors. Fix: Run flutter gen-l10n frequently.
  - Verify: flutter gen-l10n succeeds, screens compile with AppLocalizations.

- [ ] T019 [Foundation] Create app_ar.arb with Arabic translations
  - Why: Arabic RTL is a core requirement.
  - Expected: app_ar.arb with Arabic translations for all keys in app_en.arb.
  - Inputs: app_en.arb; Expense-Tracker-main/lib/l10n/app_ar.arb
  - Bugs: Mojibake. Fix: Verify UTF-8 encoding.
  - Verify: flutter gen-l10n succeeds, Arabic displays correctly.

- [ ] T020 [Foundation] Create AppLanguageCubit in lib/l10n/
  - Why: Language switching must be reactive and persist.
  - Expected: AppLanguageCubit with Locale state, setLanguage method, persistence.
  - Inputs: Expense-Tracker-main/lib/l10n/app_language_cubit.dart
  - Bugs: Language change does not rebuild widgets. Fix: Place high in widget tree.
  - Verify: Switching language changes app language immediately.

## Phase 3: User Story 1 - Auth & Core Infrastructure

**Checkpoint**: User can complete onboarding, register, login, logout, set PIN, and view/edit profile.

- [ ] T021 [US1] Implement AuthBloc with events and states in lib/screens/auth/blocs/auth_bloc/
  - Why: Single source of truth for authentication state.
  - Expected: auth_bloc.dart, auth_event.dart, auth_state.dart with login, register, Google sign-in, logout events.
  - Inputs: Expense-Tracker-main/lib/screens/auth/blocs/auth_bloc/
  - Notes: Use firebase_auth directly. Handle authStateChanges() stream.
  - Bugs: Memory leak from auth stream. Fix: Cancel subscription in bloc close().
  - Verify: Bloc test verifying auth state transitions.

- [ ] T022 [US1] Create AuthGate widget in lib/screens/auth/views/auth_gate.dart
  - Why: Routes based on auth state (splash -> onboarding -> login -> home).
  - Expected: AuthGate listens to AuthBloc and routes accordingly.
  - Inputs: Expense-Tracker-main/lib/screens/auth/views/auth_gate.dart; existing SplashScreen.
  - Notes: Preserve existing splash and onboarding screens. Use BlocListener.
  - Bugs: Flash of wrong screen. Fix: Add loading indicator during auth check.
  - Verify: Widget test verifying routing based on auth state.

- [ ] T023 [US1] Wire onboarding screens to real Settings persistence
  - Why: Onboarding selections must persist across sessions.
  - Expected: FirstRunSetupScreen saves to SettingsRepository via SettingsCubit.
  - Inputs: Existing onboarding screens in lib/features/onboarding/
  - Notes: Convert from stateless to stateful with cubit. Preserve UI design.
  - Bugs: Onboarding re-shows every launch. Fix: Check onboardingCompleted flag.
  - Verify: Complete onboarding, kill app, relaunch - onboarding does not reappear.

- [ ] T024 [US1] Implement LoginScreen and RegisterScreen with Firebase Auth
  - Why: Email/password auth is a primary method.
  - Expected: Both screens with form validation, error handling, loading states.
  - Inputs: Expense-Tracker-main/lib/screens/auth/views/login_screen.dart and register_screen.dart
  - Notes: Preserve existing login/sign-up UI. Add form fields and Firebase calls.
  - Bugs: Weak password errors not shown. Fix: Map Firebase exceptions to localized messages.
  - Verify: Widget tests for form validation and successful auth flow.

- [ ] T025 [US1] Implement Google Sign-In integration
  - Why: Google Sign-In is the second primary auth method.
  - Expected: Google Sign-In button triggers Firebase Google auth.
  - Inputs: Expense-Tracker-main/lib/screens/auth/blocs/auth_bloc/
  - Notes: Use google_sign_in package. Handle cancellation gracefully.
  - Bugs: Plugin not configured natively. Fix: Note native config for Phase 11.
  - Verify: Compile check only. Runtime test in Phase 11.

- [ ] T026 [US1] Implement AppLockCubit and PIN/biometric screens
  - Why: App lock is a security feature.
  - Expected: AppLockCubit manages PIN. CreatePinScreen and UnlockScreen. Biometric fallback.
  - Inputs: Expense-Tracker-main/lib/screens/app_lock/
  - Notes: Store hashed PIN in flutter_secure_storage. Use crypto for hashing.
  - Bugs: PIN not stored securely; biometric crashes. Fix: Check availability before showing option.
  - Verify: Set PIN, lock app, unlock with PIN/biometric.

- [ ] T027 [US1] Implement AccountProfileCubit and profile screen
  - Why: Users need to view and edit their profile.
  - Expected: AccountProfileCubit manages profile data. Screen shows display name, email, provider.
  - Inputs: Expense-Tracker-main/lib/screens/account/
  - Notes: Profile data in Firestore users/{userId}. Display name is app-local.
  - Bugs: Profile not found for new users. Fix: Create user document on first auth.
  - Verify: Edit display name, verify persistence in UI.

- [ ] T028 [US1] Implement account deletion with reauthentication
  - Why: Compliance requirement for account deletion.
  - Expected: Warning, reauth requirement, Firestore data deletion, Auth deletion, local storage clear.
  - Inputs: Expense-Tracker-main/lib/screens/account/services/account_deletion_service.dart
  - Notes: Irreversible. Multiple confirmation steps. Reauthenticate with reauthenticateWithCredential.
  - Bugs: Partial deletion. Fix: Delete Auth account last. Wrap in try-catch.
  - Verify: Delete test account, verify no data remains.

- [ ] T029 [US1] Implement SettingsCubit with real persistence
  - Why: Settings must persist and be reactive across the app.
  - Expected: SettingsCubit manages Settings model, persists to SettingsRepository.
  - Inputs: Expense-Tracker-main/lib/screens/settings/blocs/settings_bloc/settings_cubit.dart
  - Notes: Settings include language, currency, theme, notifications, AI quota, security.
  - Bugs: Settings not loaded on app start. Fix: Load in AuthGate after auth.
  - Verify: Change setting, verify persistence across app restart.

- [ ] T030 [US1] Wire SettingsScreen with all sections and real data
  - Why: Settings is the control center for user preferences.
  - Expected: All sections: Profile, Currency/Language, Notifications, Security, AI, Monetization, Support, Export, About.
  - Inputs: Existing lib/features/settings/presentation/settings_screen.dart
  - Notes: Preserve existing UI. Add real toggles and navigation. Connect to SettingsCubit.
  - Bugs: Screen too long. Fix: Group into collapsible sections or sub-screens.
  - Verify: All settings toggle correctly. Navigation works.

## Phase 4: User Story 2 - Expenses & Categories

**Checkpoint**: User can add, edit, delete, filter expenses. Categories can be created and assigned. Data persists.

- [ ] T031 [US2] Implement FirebaseExpenseRepository in packages/expense_repository/lib/src/firebase/
  - Why: Firebase is the default backend; expense repository is most critical.
  - Expected: firebase_expense_repo.dart implements ExpenseRepository with Firestore CRUD and streams.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/firebase/firebase_expense_repo.dart
  - Notes: Use Firestore subcollection users/{userId}/expenses. Support pagination.
  - Bugs: Large lists cause memory issues. Fix: Implement pagination (limit 50).
  - Verify: Repository unit tests for CRUD operations.

- [ ] T032 [US2] Implement FirebaseCategoryRepository in packages/expense_repository/lib/src/firebase/
  - Why: Categories organize expenses and are needed for budgets and reports.
  - Expected: firebase_category_repo.dart with CRUD and watchAll stream.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/firebase/firebase_category_repo.dart
  - Notes: Categories stored in users/{userId}/categories. Support default categories.
  - Bugs: Category deletion leaves orphaned expenses. Fix: Either prevent deletion or reassign expenses.
  - Verify: CRUD operations and stream updates work.

- [ ] T033 [US2] Create GetExpensesBloc in lib/screens/expenses/blocs/
  - Why: Manages expense list state with pagination, filtering, and real-time updates.
  - Expected: get_expenses_bloc.dart with events for LoadExpenses, FilterExpenses, SortExpenses. States for Loading, Loaded, Error.
  - Inputs: Expense-Tracker-main/lib/screens/home/blocs/get_expenses_bloc/
  - Notes: Use repository.watchAll() for real-time updates. Implement pagination.
  - Bugs: Memory leak from stream subscription. Fix: Cancel in bloc close().
  - Verify: Bloc test for loading, filtering, and pagination.

- [ ] T034 [US2] Create CreateExpenseBloc in lib/screens/add_expense/blocs/
  - Why: Handles expense creation with validation and duplicate detection.
  - Expected: create_expense_bloc.dart with events for SubmitExpense, ValidateExpense. States for Initial, Validating, Submitting, Success, Error.
  - Inputs: Expense-Tracker-main/lib/screens/add_expense/blocs/create_expense_bloc/
  - Notes: Validate amount > 0, category not empty, date valid. Detect duplicates.
  - Bugs: Duplicate detection false positives. Fix: Use amount + date + category hash.
  - Verify: Bloc test for validation and duplicate detection.

- [ ] T035 [US2] Wire Add Expense screens (quick, AI text, receipt) to CreateExpenseBloc
  - Why: All three add methods must persist real data.
  - Expected: Quick add, AI text add, receipt add screens all submit to CreateExpenseBloc.
  - Inputs: Existing lib/features/expenses/presentation/add_*.dart screens.
  - Notes: Preserve existing UI. Add form validation and loading states. AI screens pre-fill then submit.
  - Bugs: AI pre-fill not clearing on cancel. Fix: Reset bloc state on screen dispose.
  - Verify: Add expenses via all three methods, verify in list.

- [ ] T036 [US2] Implement ExpenseFilterCubit in lib/screens/expenses/blocs/
  - Why: Filters allow users to find specific expenses.
  - Expected: expense_filter_cubit.dart with date range, category, payment method, search query filters.
  - Inputs: Expense-Tracker-main/lib/screens/expenses/blocs/expense_filter_cubit/
  - Notes: Filters apply to loaded expenses. Support combined filters.
  - Bugs: Filters not clearing properly. Fix: Provide clear/reset action.
  - Verify: Apply filters, verify correct results. Clear filters, verify all shown.

- [ ] T037 [US2] Wire ExpensesListScreen with real data and filter bottom sheet
  - Why: The expense list is the primary data viewing screen.
  - Expected: ExpensesListScreen shows real expenses from GetExpensesBloc. Filter bottom sheet works.
  - Inputs: Existing lib/features/expenses/presentation/expenses_list_screen.dart
  - Notes: Preserve existing UI. Add empty state, loading state, error state. Connect to blocs.
  - Bugs: List not updating after add/delete. Fix: Use watchAll stream or refresh event.
  - Verify: List updates in real-time. Filters work. Edit and delete work.

- [ ] T038 [US2] Implement expense edit and delete with confirmation
  - Why: Users need to correct mistakes and remove expenses.
  - Expected: EditExpenseScreen pre-fills data. Delete shows confirmation dialog.
  - Inputs: Existing lib/features/expenses/presentation/edit_expense_screen.dart
  - Notes: Use CreateExpenseBloc pattern for edit. Show confirmation before delete.
  - Bugs: Edit not updating conversion snapshot. Fix: Recompute snapshot when money fields change.
  - Verify: Edit expense, verify changes. Delete expense, verify removal.

- [ ] T039 [US2] Implement category creation inline in Add Expense
  - Why: Users should create categories without leaving the add flow.
  - Expected: Category creation bottom sheet or dialog from Add Expense screen.
  - Inputs: Expense-Tracker-main/lib/screens/add_expense/views/category_creation.dart
  - Notes: Allow name, color, icon selection. Save to CategoryRepository.
  - Bugs: New category not appearing in dropdown immediately. Fix: Refresh category stream.
  - Verify: Create category inline, verify it appears in dropdown.

- [ ] T040 [US2] Implement CategoriesScreen with real data
  - Why: Users need to manage categories separately.
  - Expected: CategoriesScreen shows all categories with CRUD operations.
  - Inputs: Expense-Tracker-main/lib/screens/categories/views/categories_screen.dart
  - Notes: Show category count, total spent per category. Allow edit color/icon.
  - Bugs: Category with expenses cannot be deleted. Fix: Show warning and allow reassign.
  - Verify: CRUD categories. Verify expenses update when category changes.

## Phase 5: User Story 3 - Budgets & Goals

**Checkpoint**: User can set budgets, see progress update as expenses are added, and manage saving goals.

- [ ] T041 [US3] Implement FirebaseBudgetRepository and FirebaseCategoryBudgetRepository
  - Why: Budgets track spending limits.
  - Expected: firebase_budget_repo.dart and firebase_category_budget_repo.dart with CRUD.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/firebase/
  - Notes: Store in users/{userId}/budgets and users/{userId}/categoryBudgets.
  - Bugs: Budgets not auto-creating for new month. Fix: Auto-create on first expense of month.
  - Verify: CRUD operations and stream updates.

- [ ] T042 [US3] Create BudgetBloc in lib/screens/budget/blocs/
  - Why: Manages monthly budget state and progress calculation.
  - Expected: budget_bloc.dart with events for LoadBudget, UpdateBudget. States with progress percentage.
  - Inputs: Expense-Tracker-main/lib/screens/budget/blocs/budget_bloc/
  - Notes: Calculate progress from expenses in same month. Show alert at threshold.
  - Bugs: Progress not updating when expense added. Fix: Listen to expense stream or reload on change.
  - Verify: Bloc test for budget loading and progress calculation.

- [ ] T043 [US3] Create CategoryBudgetCubit in lib/screens/category_budgets/cubit/
  - Why: Per-category budgets need separate state management.
  - Expected: category_budget_cubit.dart managing list of category budgets.
  - Inputs: Expense-Tracker-main/lib/screens/category_budgets/cubit/
  - Notes: Each category budget tracks spending in that category for the month.
  - Bugs: Category budget not found for uncategorized expenses. Fix: Handle null category.
  - Verify: Cubit test for category budget CRUD.

- [ ] T044 [US3] Wire Budgets Overview screen with real data and progress indicators
  - Why: Budget overview is the primary budget viewing screen.
  - Expected: BudgetScreen shows monthly budget with progress bar and category breakdown.
  - Inputs: Existing lib/features/budgets/presentation/budgets_overview_screen.dart
  - Notes: Preserve existing UI. Add real progress calculation. Show warning colors.
  - Bugs: Progress bar overflow on small screens. Fix: Use responsive progress bar widget.
  - Verify: Budget progress updates as expenses added. Visual indicators work.

- [ ] T045 [US3] Wire Category Budgets List and Edit Monthly Budget screens
  - Why: Users need to set and edit category-level budgets.
  - Expected: CategoryBudgetsListScreen shows per-category budgets. EditMonthlyBudgetScreen allows editing.
  - Inputs: Existing lib/features/budgets/presentation/category_budgets_list_screen.dart and edit_monthly_budget_screen.dart
  - Notes: Connect to CategoryBudgetCubit and BudgetBloc.
  - Bugs: Editing one category budget affects others. Fix: Scoped state per category.
  - Verify: Edit budget, verify persistence and UI update.

- [ ] T046 [US3] Implement FirebaseSavingGoalRepository
  - Why: Saving goals track progress toward financial targets.
  - Expected: firebase_saving_goal_repo.dart with CRUD and progress tracking.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/firebase/firebase_saving_goal_repo.dart
  - Notes: Store in users/{userId}/savingGoals. Track currentAmount vs targetAmount.
  - Bugs: Goal progress not updating when contributions added. Fix: Manual update or linked expense tracking.
  - Verify: CRUD operations and progress updates.

- [ ] T047 [US3] Create SavingGoalBloc in lib/screens/saving_goals/blocs/
  - Why: Manages saving goals state.
  - Expected: saving_goal_bloc.dart with events for LoadGoals, AddContribution, UpdateGoal.
  - Inputs: Expense-Tracker-main/lib/screens/saving_goals/blocs/saving_goal_bloc/
  - Notes: Allow adding contributions manually. Show progress ring.
  - Bugs: Contribution exceeds goal target. Fix: Allow over-contribution with visual indicator.
  - Verify: Bloc test for goal CRUD and contributions.

- [ ] T048 [US3] Wire Saving Goals screen with real data
  - Why: Saving goals screen shows all goals and their progress.
  - Expected: SavingGoalsScreen shows goals with progress rings and contribution buttons.
  - Inputs: Existing lib/features/goals/presentation/saving_goals_screen.dart
  - Notes: Preserve existing UI. Add real progress calculation. Connect to SavingGoalBloc.
  - Bugs: Progress ring not animating. Fix: Use AnimatedBuilder or AnimatedContainer.
  - Verify: Goals display correctly. Contributions update progress.

## Phase 6: User Story 4 - Reports & Analytics

**Checkpoint**: Reports display accurate data. Drilldown works. Monthly story generates.

- [ ] T049 [US4] Create ReportCubit in lib/screens/reports/cubit/
  - Why: Aggregates expense data for reports.
  - Expected: report_cubit.dart with methods for category totals, trends, monthly comparisons.
  - Inputs: Expense-Tracker-main/lib/screens/reports/cubit/report_cubit.dart
  - Notes: Group expenses by category, week, month. Calculate percentages.
  - Bugs: Reports show wrong totals for filtered date ranges. Fix: Apply date filter before aggregation.
  - Verify: Cubit test for report aggregation.

- [ ] T050 [US4] Implement ReportCalculator in lib/services/
  - Why: Pure calculation logic for reports, testable independently.
  - Expected: report_calculator.dart with methods for category breakdown, trend analysis.
  - Inputs: Expense-Tracker-main/lib/services/report_calculator.dart
  - Notes: Stateless functions accepting expense list and returning report data.
  - Bugs: Division by zero when no expenses. Fix: Return zero or empty state.
  - Verify: Unit tests for all calculation methods.

- [ ] T051 [US4] Wire Reports Main screen with real charts
  - Why: Reports main is the primary analytics screen.
  - Expected: ReportsScreen shows pie chart for categories and bar chart for trends.
  - Inputs: Existing lib/features/reports/presentation/reports_main_screen.dart
  - Notes: Use fl_chart. Preserve existing UI. Add date range selector.
  - Bugs: Charts overflow on small screens. Fix: Use AspectRatio and scrollable containers.
  - Verify: Charts render correctly with real data. Date range changes update charts.

- [ ] T052 [US4] Wire Report Drilldown screen with expense list per category
  - Why: Users need to see individual expenses in a category.
  - Expected: ReportDrilldownScreen shows expenses for selected category and date range.
  - Inputs: Existing lib/features/reports/presentation/report_drilldown_screen.dart
  - Notes: Pass categoryId and date range via go_router parameters. Use GetExpensesBloc with filter.
  - Bugs: Drilldown shows expenses outside date range. Fix: Apply both category and date filters.
  - Verify: Drilldown shows correct expenses. Navigation back works.

- [ ] T053 [US4] Implement MonthlyFinancialStoryService in lib/screens/reports/services/
  - Why: Generates narrative summary of spending behavior.
  - Expected: monthly_financial_story_service.dart analyzing expenses and generating text narrative.
  - Inputs: Expense-Tracker-main/lib/screens/reports/services/monthly_financial_story_service.dart
  - Notes: Compare to previous month. Identify top categories. Flag unusual spending.
  - Bugs: Narrative is generic or inaccurate. Fix: Use actual data with proper comparisons.
  - Verify: Unit tests for narrative generation with sample data.

- [ ] T054 [US4] Wire Monthly Financial Story screen
  - Why: Monthly story provides engaging insights.
  - Expected: MonthlyFinancialStoryScreen displays narrative with supporting metrics.
  - Inputs: Existing lib/features/reports/presentation/monthly_financial_story_screen.dart
  - Notes: Preserve existing UI. Connect to MonthlyFinancialStoryService.
  - Bugs: Story not updating when month changes. Fix: Reload on month selection.
  - Verify: Story displays correctly. Month navigation works.

## Phase 7: User Story 5 - AI Integration

**Checkpoint**: All AI features work end-to-end. Quotas enforce correctly. Fallbacks handle errors.

- [ ] T055 [US5] Implement AiGatewayClient in lib/ai/services/
  - Why: HTTP client for Cloudflare Worker AI gateway.
  - Expected: ai_gateway_client.dart with POST methods for parse, receipt, advice endpoints.
  - Inputs: Expense-Tracker-main/lib/ai/services/ai_gateway_client.dart
  - Notes: Attach Firebase Bearer token. Handle timeouts (5s). Parse JSON responses.
  - Bugs: Token expires during request. Fix: Refresh token before each call if near expiry.
  - Verify: Unit test with mocked HTTP client.

- [ ] T056 [US5] Implement FirebaseFunctionsAiClient in lib/ai/services/
  - Why: Fallback client for Firebase Functions AI endpoints.
  - Expected: remote_ai_service.dart calling Firebase Functions HTTPS endpoints.
  - Inputs: Expense-Tracker-main/lib/ai/services/remote_ai_service.dart
  - Notes: Use http package. Same interface as gateway client for easy swapping.
  - Bugs: Functions cold start causes timeout. Fix: Increase timeout or prefer gateway.
  - Verify: Unit test with mocked HTTP client.

- [ ] T057 [US5] Create AiService facade in lib/ai/services/
  - Why: Unified interface for all AI operations with provider fallback.
  - Expected: ai_service.dart routing to gateway first, then Functions fallback.
  - Inputs: Expense-Tracker-main/lib/ai/services/ai_service.dart
  - Notes: Provider selection based on availability and quota. Consistent error handling.
  - Bugs: Fallback loop on repeated failures. Fix: Limit fallback attempts per session.
  - Verify: Unit test verifying gateway preferred, fallback on failure.

- [ ] T058 [US5] Implement AI text parsing in Add Expense AI Text screen
  - Why: Natural language expense entry reduces friction.
  - Expected: AddExpenseAiTextScreen sends text to AiService, displays parsed preview, allows edit before save.
  - Inputs: Existing lib/features/expenses/presentation/add_expense_ai_text_screen.dart
  - Notes: Preserve existing UI. Add loading state. Show parsed fields in preview card.
  - Bugs: Parse returns wrong category. Fix: Allow user to override before saving.
  - Verify: Type text, verify parsed fields, save expense, verify in list.

- [ ] T059 [US5] Implement receipt extraction in Add Expense Receipt screen
  - Why: Receipt scanning automates data entry.
  - Expected: AddExpenseReceiptScreen captures image, sends to AiService, displays extracted data.
  - Inputs: Existing lib/features/expenses/presentation/add_expense_receipt_screen.dart
  - Notes: Use image_picker. Compress image before upload. Show extraction loading.
  - Bugs: Receipt extraction fails for low-quality images. Fix: Show error and allow manual entry.
  - Verify: Capture receipt, verify extraction, save expense.

- [ ] T060 [US5] Implement AI Advice screen with real advice generation
  - Why: Personalized spending advice increases engagement.
  - Expected: AiAdviceScreen requests advice based on recent spending, displays recommendations.
  - Inputs: Existing lib/features/ai/presentation/ai_advice_screen.dart
  - Notes: Send spending summary to AiService. Display advice in insight cards.
  - Bugs: Advice is generic. Fix: Send detailed category breakdown and trends.
  - Verify: Request advice, verify personalized response displays.

- [ ] T061 [US5] Implement AI History screen with queryable logs
  - Why: Users need to review past AI interactions.
  - Expected: AiHistoryScreen shows list of AI actions with input, output, timestamp.
  - Inputs: Existing lib/features/ai/presentation/ai_history_screen.dart
  - Notes: Use AiActionLogRepository. Support search/filter by action type.
  - Bugs: History grows too large. Fix: Implement pagination or retention policy.
  - Verify: AI actions appear in history after each use.

- [ ] T062 [US5] Implement AI Assistant Sheet with voice input
  - Why: Conversational interface for expense queries.
  - Expected: AiAssistantSheet allows typing or voice input, displays conversational responses.
  - Inputs: Existing lib/features/ai/presentation/ai_assistant_sheet.dart
  - Notes: Use speech_to_text for voice. Maintain conversation context.
  - Bugs: Voice input not recognized in noisy environments. Fix: Show text input fallback.
  - Verify: Type query, verify response. Test voice input.

- [ ] T063 [US5] Implement AI quota enforcement and display
  - Why: Free users need quota limits; premium users get higher limits.
  - Expected: Quota tracked per user per day. Settings screen shows remaining quota.
  - Inputs: Expense-Tracker-main/lib/ai/services/ai_usage_fallback_service.dart
  - Notes: Gateway enforces quota server-side. Client shows remaining for UX.
  - Bugs: Quota resets at wrong time. Fix: Use UTC midnight for daily reset.
  - Verify: Exceed quota, verify blocked. Upgrade to premium, verify increased.

## Phase 8: User Story 6 - Wallets & Subscriptions

**Checkpoint**: Wallets show balances. Subscriptions track renewals. Recurring expenses generate on schedule.

- [ ] T064 [US6] Implement FirebaseWalletAccountRepository
  - Why: Wallets track balances across accounts.
  - Expected: firebase_wallet_account_repo.dart with CRUD and balance calculation.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/firebase/firebase_wallet_account_repo.dart
  - Notes: Store in users/{userId}/walletAccounts. Calculate balance from assigned expenses.
  - Bugs: Balance incorrect after transfer. Fix: Include transfers in balance calculation.
  - Verify: CRUD and balance calculation unit tests.

- [ ] T065 [US6] Wire Wallets/Accounts screen with real data
  - Why: Wallets screen shows all accounts and balances.
  - Expected: WalletsAccountsScreen shows wallets with balances and expense counts.
  - Inputs: Existing lib/features/wallets/presentation/wallets_accounts_screen.dart
  - Notes: Preserve existing UI. Connect to WalletAccountRepository.
  - Bugs: Balance not updating after expense added. Fix: Use streams or refresh.
  - Verify: Wallet balances update as expenses are assigned.

- [ ] T066 [US6] Implement SubscriptionSummaryService and wire Subscription Center
  - Why: Subscriptions track recurring payments and renewal dates.
  - Expected: SubscriptionCenterScreen shows subscriptions with renewal dates and monthly impact.
  - Inputs: Existing lib/features/subscriptions/presentation/subscriptions_center_screen.dart
  - Notes: Calculate monthly impact from subscription amounts and frequencies.
  - Bugs: Renewal date calculation wrong for annual subscriptions. Fix: Use correct date math.
  - Verify: Subscriptions display correctly. Renewal dates are accurate.

- [ ] T067 [US6] Implement RecurringExpenseRepository and RecurringExpenseBloc
  - Why: Recurring expenses auto-generate on schedule.
  - Expected: Recurring expense CRUD with scheduler generating instances.
  - Inputs: Expense-Tracker-main/lib/screens/recurring_expenses/blocs/recurring_expense_bloc/
  - Notes: Generate instances based on frequency (daily, weekly, monthly, yearly).
  - Bugs: Duplicate instances generated. Fix: Track lastGeneratedDate and generate only once per period.
  - Verify: Bloc test for recurring rule CRUD and instance generation.

## Phase 9: User Story 7 - Settings, Onboarding & Guided Tour

**Checkpoint**: Settings work with live data. Tour highlights key elements. RTL works.

- [ ] T068 [US7] Implement settings live refresh without app restart
  - Why: Users expect immediate feedback when changing settings.
  - Expected: Language, currency, theme changes apply immediately via Bloc listeners.
  - Inputs: Existing settings screen and SettingsCubit.
  - Notes: Use BlocListener at app root for language/theme. Currency changes rebuild finance widgets.
  - Bugs: Theme change causes flash. Fix: Use AnimatedTheme or smooth transition.
  - Verify: Change each setting, verify immediate UI update.

- [ ] T069 [US7] Implement GuidedTourCubit and tour widgets
  - Why: Guided tour improves first-time user activation.
  - Expected: GuidedTourCubit manages step sequence. TourOverlay, TourSpotlight, TourConnector widgets.
  - Inputs: Expense-Tracker-main/lib/guided_tour/
  - Notes: Highlight key UI elements with spotlight. Support RTL connector directions.
  - Bugs: Tour targets off-screen after scroll. Fix: Scroll target into view before highlighting.
  - Verify: Tour completes successfully. RTL connectors point correctly.

- [ ] T070 [US7] Integrate guided tour into Home dashboard for first-time users
  - Why: Tour should start automatically for new users.
  - Expected: Tour starts after onboarding completion. Can be replayed from Settings.
  - Inputs: Existing HomeDashboardScreen and AuthGate.
  - Notes: Check firstRun flag. Start tour after dashboard loads.
  - Bugs: Tour starts before dashboard renders. Fix: Delay start or wait for layout.
  - Verify: Fresh install -> onboarding -> home -> tour starts. Replay from settings works.

- [ ] T071 [US7] Implement Export screen with CSV, Excel, PDF export
  - Why: Data portability is a user expectation.
  - Expected: ExportScreen allows selecting format, date range, and categories. Generates and shares file.
  - Inputs: Existing lib/features/export/ or create new screen.
  - Notes: Use csv, excel, pdf packages. Include Arabic font (Noto Sans Arabic) for PDF.
  - Bugs: PDF Arabic text garbled. Fix: Embed Arabic font in PDF generation.
  - Verify: Export in all three formats. Verify Arabic renders in PDF.

## Phase 10: User Story 8 - Monetization

**Checkpoint**: Free users see ads. Purchase flow completes. Premium unlocks features.

- [ ] T072 [US8] Integrate Google Mobile Ads with test ad units
  - Why: Ads provide revenue for free users.
  - Expected: Banner ads display on appropriate screens (expenses list, reports).
  - Inputs: Expense-Tracker-main/lib/monetization/services/google_mobile_ads_service.dart
  - Notes: Use kDebugMode to show test ads. Configure ad unit IDs via dart-define.
  - Bugs: Ads not loading in debug mode. Fix: Use test ad unit IDs for debug.
  - Verify: Ads display on supported screens in debug build.

- [ ] T073 [US8] Implement PurchaseService with in_app_purchase
  - Why: Premium upgrade requires store integration.
  - Expected: PurchaseService handles product query, purchase, and validation.
  - Inputs: Expense-Tracker-main/lib/monetization/services/purchase_service.dart
  - Notes: Query products from Play Store. Handle purchase flow. Validate server-side.
  - Bugs: Purchase not restoring after reinstall. Fix: Implement restore purchases flow.
  - Verify: Purchase flow completes in sandbox. Premium state persists.

- [ ] T074 [US8] Create MonetizationCubit and Free/Premium screen
  - Why: Manages premium state and feature gates.
  - Expected: MonetizationCubit tracks premium status. FreePremiumScreen shows features and purchase CTA.
  - Inputs: Existing lib/features/monetization/ or create new.
  - Notes: Connect to PurchaseService. Update AI quota when premium unlocked.
  - Bugs: Premium features not unlocking immediately after purchase. Fix: Refresh state after purchase confirmation.
  - Verify: Purchase premium, verify ads removed and AI quota increased.

- [ ] T075 [US8] Implement FeatureGateService for premium-gated features
  - Why: Certain features should only be available to premium users.
  - Expected: FeatureGateService checks premium status before allowing AI features, export, etc.
  - Inputs: Expense-Tracker-main/lib/monetization/services/feature_gate_service.dart
  - Notes: Gate features gracefully with upgrade prompts, not hard blocks.
  - Bugs: Free users completely blocked from core features. Fix: Only gate advanced features.
  - Verify: Free users can still track expenses. Premium users get all features.

## Phase 11: User Story 9 - Notifications & Exchange Rates

**Checkpoint**: Notifications trigger correctly. Exchange rates cache and refresh. Multi-currency conversion works.

- [ ] T076 [US9] Implement NotificationService with flutter_local_notifications
  - Why: Local notifications for budget alerts, recurring reminders, subscription renewals.
  - Expected: NotificationService initializes channels, schedules notifications.
  - Inputs: Expense-Tracker-main/lib/services/notifications/notification_service.dart
  - Notes: Request permission during onboarding. Create channels for different notification types.
  - Bugs: Notifications not showing on Android 13+. Fix: Request POST_NOTIFICATIONS permission.
  - Verify: Schedule test notification, verify it appears.

- [ ] T077 [US9] Implement NotificationScheduler for budget and recurring alerts
  - Why: Smart notifications based on user data.
  - Expected: Budget alerts when threshold exceeded. Recurring reminders before due date.
  - Inputs: Expense-Tracker-main/lib/services/notifications/notification_scheduler.dart
  - Notes: Check budget consumption after each expense add. Schedule recurring reminders.
  - Bugs: Duplicate notifications. Fix: Use unique notification IDs and cancel old ones.
  - Verify: Add expense exceeding budget, verify notification.

- [ ] T078 [US9] Implement ExchangeRateService and ExchangeRateRefreshService
  - Why: Multi-currency conversion requires current exchange rates.
  - Expected: Fetch rates from API, cache locally, refresh daily.
  - Inputs: Expense-Tracker-main/lib/services/exchange_rates/
  - Notes: Use a free exchange rate API. Cache in local storage. Show last update time.
  - Bugs: Rate API down causes failures. Fix: Use cached rates with stale warning.
  - Verify: Rates fetch and cache. Stale warning displays after 24h.

- [ ] T079 [US9] Integrate exchange rates into Reports and Budgets
  - Why: Multi-currency expenses must convert to base currency for totals.
  - Expected: Reports and budgets show amounts in base currency with conversion indicator.
  - Inputs: Existing reports and budgets screens.
  - Notes: Use cached rates for conversion. Show original currency alongside converted amount.
  - Bugs: Conversion uses wrong rate for historical expenses. Fix: Use transaction date rate if available.
  - Verify: Add expenses in different currencies. Verify converted totals in reports.

## Phase 12: User Story 10 - VPS Sync & Migration

**Checkpoint**: VPS mode syncs data bidirectionally. Migration comparison shows parity. Offline queue syncs on reconnect.

- [ ] T080 [US10] Set up Drift database schema in packages/expense_repository/
  - Why: Local-first storage requires durable SQLite schema.
  - Expected: Drift database with tables for all entities and sync changes.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/local/
  - Notes: Define tables with proper indexes. Include sync_changes table for queue.
  - Bugs: Schema migration issues on upgrade. Fix: Version schema and test migrations.
  - Verify: Database opens without errors. Tables created correctly.

- [ ] T081 [US10] Implement LocalRepositoryStore for in-memory caching
  - Why: In-memory cache provides fast UI access while sync happens in background.
  - Expected: LocalRepositoryStore holds all entity maps with StreamControllers for reactive updates.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/local/local_repository_store.dart
  - Notes: Mirror Firestore patterns but in-memory. Support ordered queries.
  - Bugs: Memory leak from unclosed streams. Fix: Close streams on dispose.
  - Verify: Store compiles. Streams emit on data change.

- [ ] T082 [US10] Implement LocalSyncQueue for pending changes
  - Why: Offline-first requires queueing changes for later sync.
  - Expected: LocalSyncQueue manages pending, syncing, synced, failed states.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/sync/local_sync_queue.dart
  - Notes: Persist queue in Drift. Support retry with exponential backoff.
  - Bugs: Queue grows unbounded. Fix: Implement max queue size and compression.
  - Verify: Queue persists across app restarts. Retry works on reconnect.

- [ ] T083 [US10] Create VpsApiClient with Firebase token authentication
  - Why: Flutter app needs to call VPS backend APIs.
  - Expected: VpsApiClient with methods for bootstrap, push, pull. Attaches Firebase Bearer token.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/api/vps_api_client.dart
  - Notes: Base URL from dart-define. Handle 401 by refreshing token.
  - Bugs: Token expires mid-request. Fix: Pre-emptive refresh before API calls.
  - Verify: Unit test with mocked HTTP client.

- [ ] T084 [US10] Implement SyncCoordinator for push/pull cycles
  - Why: Orchestrates bidirectional sync between local store and VPS.
  - Expected: SyncCoordinator pushes pending changes, pulls remote changes, applies to local store.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/sync/sync_coordinator.dart
  - Notes: Use cursors for incremental sync. Handle conflicts with last-write-wins.
  - Bugs: Sync loops infinitely. Fix: Detect no-op syncs and back off.
  - Verify: Unit tests for push, pull, conflict resolution.

- [ ] T085 [US10] Wire AuthenticatedRepositoryFactory for vpsLocalFirst mode
  - Why: Factory must create local repositories and sync coordinator in VPS mode.
  - Expected: Factory returns LocalRepositoryStore-backed repos with SyncCoordinator.
  - Inputs: Existing AuthenticatedRepositoryFactory stub from Phase 2.
  - Notes: Lazy-initialize sync on first write or explicit syncNow call.
  - Bugs: Factory creates sync coordinator before auth ready. Fix: Wait for auth state.
  - Verify: Switch to VPS mode, verify local repos and sync created.

- [ ] T086 [US10] Implement migrationComparison mode with dual repository comparison
  - Why: Verify data parity before cutting over from Firebase to VPS.
  - Expected: MigrationComparisonExpenseRepository compares reads/writes between Firebase and Local.
  - Inputs: Expense-Tracker-main/packages/expense_repository/lib/src/repository_factory.dart
  - Notes: Log discrepancies. Do not auto-correct; flag for manual review.
  - Bugs: Comparison slows down all reads. Fix: Run comparison async or on-demand.
  - Verify: Run comparison, verify parity report generated.

- [ ] T087 [US10] Add SyncStatusBanner widget to home screen
  - Why: Users need visibility into sync state.
  - Expected: Banner shows syncing, synced, offline, error states with localized messages.
  - Inputs: Expense-Tracker-main/lib/widgets/sync_status_banner.dart
  - Notes: Non-intrusive. Auto-hide when synced. Tap for details.
  - Bugs: Banner flickers rapidly. Fix: Debounce state changes.
  - Verify: Banner appears during sync, hides when complete.

## Phase 13: Polish, Testing & Release

**Checkpoint**: All tests pass. RTL QA complete. Release APK builds successfully.

- [ ] T088 [Polish] Write widget tests for all 25 screens
  - Why: Ensures UI correctness and prevents regressions.
  - Expected: At least one widget test per screen verifying render and basic interaction.
  - Inputs: All screen files in lib/screens/ and lib/features/.
  - Notes: Mock blocs/cubits with bloc_test. Use mocktail for repositories.
  - Bugs: Tests fail due to missing MediaQuery or Directionality. Fix: Wrap in testable widget helper.
  - Verify: flutter test passes for all widget tests.

- [ ] T089 [Polish] Write bloc tests for all blocs and cubits
  - Why: State management logic must be correct and testable.
  - Expected: Bloc tests for AuthBloc, GetExpensesBloc, CreateExpenseBloc, BudgetBloc, etc.
  - Inputs: All bloc files in lib/screens/**/blocs/ and lib/**/cubit/.
  - Notes: Use bloc_test package. Test initial state, event handling, error states.
  - Bugs: Tests flaky due to async timing. Fix: Use async matchers and explicit await.
  - Verify: flutter test passes for all bloc tests.

- [ ] T090 [Polish] Write repository unit tests for Firebase and Local implementations
  - Why: Backend data operations must be correct.
  - Expected: Unit tests for all repository CRUD operations using mock Firestore and in-memory Drift.
  - Inputs: All repository implementations in packages/expense_repository/.
  - Notes: Use mock Firestore for Firebase repos. Use in-memory Drift for local repos.
  - Bugs: Mock Firestore behavior differs from real Firestore. Fix: Use official firestore_mock or fake_cloud_firestore.
  - Verify: flutter test passes for all repository tests.

- [ ] T091 [Polish] Run Arabic RTL QA on all screens at all viewports
  - Why: RTL is a core requirement for Arabic users.
  - Expected: No overflow, clipped text, wrong alignment, or incorrect icon direction.
  - Inputs: All 25 screens.
  - Notes: Test at 360x800, 375x812, 390x844. Check text direction, alignment, navigation.
  - Bugs: Icons not mirrored in RTL. Fix: Use Directionality-aware icon widgets.
  - Verify: Manual QA checklist complete for all screens.

- [ ] T092 [Polish] Optimize list scrolling performance
  - Why: Large expense lists must scroll smoothly.
  - Expected: No jank when scrolling 1000+ expenses. Pagination loads seamlessly.
  - Inputs: ExpensesListScreen and filter bottom sheet.
  - Notes: Use ListView.builder. Implement pagination. Cache category lookups.
  - Bugs: List rebuilds entire content on filter change. Fix: Use const constructors and keys.
  - Verify: Profile scrolling with Flutter DevTools. Target 60fps.

- [ ] T093 [Polish] Build signed release APK
  - Why: Production artifact for distribution.
  - Expected: Signed release APK builds successfully.
  - Inputs: Android signing configuration.
  - Notes: Configure release keystore. Use dart-define for production URLs and keys.
  - Bugs: ProGuard obfuscates required classes. Fix: Configure ProGuard rules for Firebase, Drift, etc.
  - Verify: flutter build apk --release succeeds. APK installs and runs.

- [ ] T094 [Polish] Update AGENTS.md and documentation
  - Why: Project documentation must reflect the new production architecture.
  - Expected: AGENTS.md updated with new plan reference. README updated with build instructions.
  - Inputs: Existing AGENTS.md and README.md.
  - Notes: Document runtime mode switching, build commands, and backend setup.
  - Bugs: Documentation out of sync with code. Fix: Review all docs against implementation.
  - Verify: Documentation is accurate and complete.

## Dependencies And Execution Order

`	ext
Phase 1 (Setup) -> Phase 2 (Foundation) -> Phase 3 (Auth)
Phase 3 (Auth) -> Phase 4 (Expenses) -> Phase 5 (Budgets) -> Phase 6 (Reports)
Phase 4 (Expenses) -> Phase 7 (AI) [AI needs expense data]
Phase 4 (Expenses) -> Phase 8 (Wallets) [Wallets need expenses]
Phase 3 (Auth) -> Phase 9 (Settings/Tour) [Settings needs auth]
Phase 3 (Auth) -> Phase 10 (Monetization) [Purchases need auth]
Phase 4 (Expenses) -> Phase 11 (Notifications) [Budget alerts need expenses]
Phase 2 (Foundation) -> Phase 12 (VPS Sync) [Sync needs local storage]
All phases -> Phase 13 (Polish)
`

**Parallel opportunities** (tasks marked with [P]):
- T003-T007 (dependency additions) can run in parallel
- T013-T020 (foundation tasks) can run in parallel after repository interfaces are defined
- T031-T040 (expense repository and bloc tasks) can run in parallel after models are defined
- T055-T063 (AI service tasks) can run in parallel after gateway client is defined

## Implementation Strategy

**MVP Scope (User Stories 1-3)**: Auth, Expenses, Categories, Budgets
- This provides a complete functional expense tracker.
- All other features build on top of these.

**Incremental Delivery**:
1. Deliver Phase 1-3 (Auth + Onboarding) as first milestone
2. Deliver Phase 4-5 (Expenses + Budgets) as second milestone
3. Deliver Phase 6-8 (Reports + AI + Wallets) as third milestone
4. Deliver Phase 9-11 (Settings + Monetization + Notifications) as fourth milestone
5. Deliver Phase 12 (VPS Sync) as fifth milestone
6. Deliver Phase 13 (Polish + Release) as final milestone

## Notes

- Each task is independently understandable by someone with no prior context beyond the referenced files.
- Do not leave placeholders such as TBD, implement later, or add proper handling.
- Every task must have exact file paths.
- Backend work (server, functions, worker) is assumed to be ported from Expense-Tracker-main as-is. Flutter-side integration tasks are the focus of this plan.
- Native Android/iOS configuration (Firebase config, ad IDs, purchase config) is deferred to Phase 13 unless explicitly required earlier.
- The existing 25-screen UI from the new app is preserved. Only wiring to blocs and backend is changed.
