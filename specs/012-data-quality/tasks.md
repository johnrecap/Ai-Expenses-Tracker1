# Tasks: Data Quality — Phase 2

**Branch**: `012-data-quality` | **Plan**: `specs/012-data-quality/plan.md`

## Batch 12: Categories + Settings + Dead Code

### T12.1 — Integrate CategoryBloc into expense filter sheet

**Why**: Hardcoded 5 categories break filtering with real data.

**Expected result**: Filter sheet reads `CategoryBloc` state. Category chips render from actual categories.

**Scope**: `lib/features/expenses/presentation/expense_filters_sheet.dart`

**Implementation**: Replace `_allCategories` with `BlocBuilder<CategoryBloc>`. Use `state.categories`.

**Verification**: Open filter sheet → categories match user's Firestore categories.

**Stop condition**: No hardcoded category list in filter sheet.

---

### T12.2 — Wire category budgets list to repository

**Why**: `category_budgets_list_screen.dart` has 6 hardcoded rows.

**Expected result**: Screen loads from `CategoryBudgetRepository` via `BudgetBloc` state or direct repository access.

**Scope**: `lib/features/budgets/presentation/category_budgets_list_screen.dart`

**Implementation**: Add optional `categoryBudgets` parameter or use `BlocBuilder<BudgetBloc>`.

**Verification**: Open category budgets → data from Firestore, not hardcoded.

**Stop condition**: No hardcoded budget data.

---

### T12.3 — Persist settings toggles via SettingsCubit

**Why**: Notification, dark mode, biometric toggles are local state only.

**Expected result**: Toggle changes call `SettingsCubit` methods.

**Scope**: `lib/features/settings/presentation/settings_screen.dart`

**Implementation**: Add update methods to `SettingsCubit` or use `saveSettings()` with updated `UserSettings`. Wire toggle `onChanged` to cubit calls.

**Verification**: Toggle dark mode → restart app → toggle remains on.

**Stop condition**: All settings toggles persist across app restarts.

---

### T12.4 — Delete all duplicate BLoC files in `screens/`

**Why**: 18 byte-identical duplicates create maintenance risk. Only `features/` versions are imported.

**Scope**: Delete files:
```
lib/screens/auth/blocs/auth_bloc/*
lib/screens/home/blocs/get_expenses_bloc/*
lib/screens/add_expense/blocs/create_expense_bloc/*
lib/screens/expenses/blocs/expense_filter_cubit/*
lib/screens/reports/cubit/report_cubit.dart
lib/screens/budget/blocs/budget_bloc/*
lib/screens/saving_goals/blocs/saving_goal_bloc/*
lib/screens/onboarding/blocs/onboarding_cubit.dart
lib/screens/settings/blocs/settings_bloc/*
lib/screens/splash_screen.dart
lib/screens/recurring_expenses/blocs/recurring_expense_bloc.dart (also dead)
lib/screens/home/widgets/sync_status_banner.dart
lib/screens/subscriptions/services/subscription_summary_service.dart
lib/screens/reports/services/monthly_financial_story_service.dart
```

**Verification**: `flutter analyze` — zero import errors for deleted files.

**Stop condition**: Only `features/` BLoCs remain. No `screens/` directory under `lib/`.

---

### T12.5 — Delete 3 unused BLoC files

**Why**: `GuidedTourCubit`, `AppLockCubit`, `RecurringExpenseBloc` never used.

**Scope**:
```
lib/guided_tour/cubit/guided_tour_cubit.dart (plus models/, widgets/)
lib/screens/app_lock/cubit/app_lock_cubit.dart
lib/screens/recurring_expenses/blocs/recurring_expense_bloc.dart (if not deleted in T12.4)
```

**Verification**: `flutter analyze` — no references to deleted files.

**Stop condition**: Zero dead BLoC files.

---

### T12.6 — Consolidate AI code into `features/ai/`

**Why**: AI feature split across `lib/ai/` and `lib/features/ai/`.

**Expected result**: All AI code under `lib/features/ai/` with subdirectories: `ai_cubit/`, `services/`, `presentation/`.

**Scope**:
- MOVE: `lib/ai/cubit/ai_assistant_cubit.dart` → `lib/features/ai/ai_cubit/`
- MOVE: `lib/ai/services/*` → `lib/features/ai/services/`
- DELETE: `lib/ai/` directory
- UPDATE: all imports in consumer files

**Verification**: `flutter analyze` passes. AI functionality unchanged.

**Stop condition**: No `lib/ai/` directory. All AI imports resolve correctly.

---

### T12.7 — Remove 7 empty directories

**Why**: Empty dirs confuse navigation and create false assumptions.

**Scope**:
```
lib/features/budgets/presentation/widgets/
lib/features/settings/presentation/widgets/
lib/features/subscriptions/presentation/widgets/
lib/features/wallets/presentation/widgets/
lib/ai/models/
lib/screens/account/views/
lib/screens/account/cubit/
```

**Verification**: Directories no longer exist.

**Stop condition**: Zero empty directories under `lib/features/`.

---

### T12.8 — Convert router.dart to package: imports

**Why**: Inconsistent import style vs rest of codebase.

**Expected result**: All 24 screen imports use `package:expenses_tracker/features/...`.

**Scope**: `lib/app/router.dart`

**Verification**: `flutter analyze` — no relative imports in router.dart.

**Stop condition**: Zero relative imports in router.dart.

---

### T12.9 — Add moneySnapshot serialization

**Why**: Field declared but never persisted. Lost on Firestore write.

**Expected result**: `moneySnapshot` in `toDocument()` and `fromDocument()`.

**Scope**: `packages/expense_repository/lib/src/entities/expense_entity.dart`

**Verification**: Create expense with moneySnapshot → read back → field preserved.

**Stop condition**: moneySnapshot round-trips through Firestore.

---

### T12.10 — Add error message to GetExpensesFailure

**Why**: No message field — UI can't show error details.

**Expected result**: `GetExpensesFailure(String message)` with populated message.

**Scope**: `lib/features/expenses/get_expenses_bloc/get_expenses_bloc.dart`

**Verification**: Force error → UI shows descriptive error message.

**Stop condition**: GetExpensesFailure has message field.

---

### T12.11 — Fix subscription vendor substring crash

**Why**: `vendor.substring(0, 2)` crashes on 1-char names.

**Expected result**: Safe substring with min length check.

**Scope**: `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`

**Implementation**: `vendor.length >= 2 ? vendor.substring(0, 2).toUpperCase() : vendor.toUpperCase()`

**Verification**: Create subscription with 1-char vendor → no crash.

**Stop condition**: No crash on short vendor names.

---

## Dependency Order

```
T12.4 (dead code) → T12.5 (more dead code) → T12.6 (AI consolidate) → T12.7 (empty dirs)
T12.1 (filter categories) — parallel with T12.2 (category budgets)
T12.3 (settings persist) — independent
T12.8 (router imports) — independent
T12.9 (moneySnapshot) — independent
T12.10 (getExpensesFailure) — independent
T12.11 (vendor crash) — independent
```

## Verification

```powershell
flutter analyze
flutter build apk --release
```
