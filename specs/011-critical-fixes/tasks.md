# Tasks: Critical Fixes — Phase 1

**Branch**: `011-critical-fixes` | **Plan**: `specs/011-critical-fixes/plan.md`

## Batch 11: Onboarding + Dashboard + Safety (P0-P1)

### T11.1 — Wire OnboardingCubit into App widget and onboarding screens

**Why**: Onboarding collects 3 preferences but saves nothing. `OnboardingCubit` is dead code.

**Expected result**: After completing onboarding, preferences persisted. Returning users skip onboarding.

**Scope**:
- UPDATE: `lib/app/app.dart` — add `BlocProvider<OnboardingCubit>` with `SettingsRepository`
- UPDATE: `lib/features/onboarding/presentation/language_screen.dart` — call `cubit.setLanguage()` on selection
- UPDATE: `lib/features/onboarding/presentation/base_currency_screen.dart` — call `cubit.setCurrency()`
- UPDATE: `lib/features/onboarding/presentation/notifications_screen.dart` — call `cubit.setNotifications()` + `completeOnboarding()`
- UPDATE: `lib/features/onboarding/presentation/splash_screen.dart` — check `onboardingCompleted`

**Implementation notes**: Replace hardcoded `context.go('/onboarding/currency')` with `AppRoutes` constants. Use `context.read<OnboardingCubit>()`.

**Verification**: Sign up as new user → complete onboarding → check Firestore settings → restart → skip onboarding, go to home.

**Stop condition**: Onboarding flow functional end-to-end.

---

### T11.2 — Reload ReportCubit and BudgetBloc after expense creation

**Why**: Dashboard shows stale data. `ReportCubit.load()` runs once at startup.

**Expected result**: After `CreateExpenseSuccess`, ReportCubit reloads and dashboard updates.

**Scope**:
- UPDATE: `lib/app/app.dart` Builder — add `BlocListener<CreateExpenseBloc>` around the widget tree
- Or UPDATE: `lib/features/dashboard/presentation/home_dashboard_screen.dart` — listen for and handle `CreateExpenseSuccess`

**Implementation**: In `app.dart` or dashboard, add listener:
```dart
BlocListener<CreateExpenseBloc, CreateExpenseState>(
  listenWhen: (_, current) => current is CreateExpenseSuccess,
  listener: (context, _) {
    context.read<ReportCubit>().load();
  },
)
```

**Verification**: Add expense → return to dashboard → hero card shows updated total.

**Stop condition**: Dashboard reflects new expenses within seconds.

---

### T11.3 — Fix AI assistant route

**Why**: `context.go(AppRoutes.aiAssistant)` fails — no route registered.

**Expected result**: Sparkle button on dashboard opens AI assistant.

**Scope**:
- UPDATE: `lib/app/router.dart` — register `GoRoute(path: AppRoutes.aiAssistant, ...)`
- OR UPDATE: `lib/features/dashboard/presentation/home_dashboard_screen.dart:51` — change to `showModalBottomSheet(AiAssistantSheet())`

**Preferred approach**: Show as bottom sheet (matches design intent).

**Verification**: Tap sparkle icon → AI assistant sheet opens.

**Stop condition**: AI assistant accessible from dashboard.

---

### T11.4 — Add null guard to BudgetBloc stream

**Why**: `add(BudgetUpdated(budget!))` on `Stream<Budget?>` crashes on null emission.

**Expected result**: Null from stream handled gracefully.

**Scope**: `lib/features/budgets/budget_bloc/budget_bloc.dart`

**Implementation**:
```dart
await for (final budget in _repo.watchCurrentMonthBudget(...)) {
  if (budget != null) add(BudgetUpdated(budget));
}
```

**Verification**: If Firestore returns null budget, app doesn't crash.

**Stop condition**: No `!` assertions on nullable stream values.

---

### T11.5 — Store AuthBloc stream subscription

**Why**: `_authBloc.stream.listen(...)` return discarded. Potential leak.

**Expected result**: Subscription stored and cancelled in dispose.

**Scope**: `lib/app/app.dart`

**Implementation**: Add `StreamSubscription<AuthState>? _authSub` field. Store in initState, cancel in dispose.

**Verification**: App launches, signs in/out normally.

**Stop condition**: Subscription lifecycle fully managed.

---

### T11.6 — Fix AppRadii.sheet for RTL

**Why**: `topLeft`/`topRight` doesn't flip in Arabic. Sheet corners wrong.

**Expected result**: `BorderRadiusDirectional.only(topStart, topEnd)`.

**Scope**: `lib/core/theme/app_radii.dart`

**Verification**: Arabic mode → bottom sheet corners on correct side.

**Stop condition**: RTL sheet corners correct.

---

### T11.7 — Fix empty catch blocks in RecurringExpenseBloc

**Why**: 3 empty `catch (_) {}` silently discard Firestore write errors.

**Expected result**: Errors emitted to UI as `error` state.

**Scope**: `lib/screens/recurring_expenses/blocs/recurring_expense_bloc.dart`

**Verification**: Offline mode → create recurring expense → shows error, not silent fail.

**Stop condition**: Zero empty catch blocks in any BLoC.

---

### T11.8 — Fix wallets + subscriptions screens type safety

**Why**: Unsafe `as` casts from `dynamic` crash on type mismatch.

**Expected result**: Proper model types instead of `dynamic`.

**Scope**:
- `lib/features/wallets/presentation/wallets_accounts_screen.dart`
- `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`

**Implementation**: Replace `dynamic` with proper `WalletAccount` / `Subscription` models from `expense_repository`, or safely handle mock data with null checks.

**Verification**: Screens render without crash even if data structure changes.

**Stop condition**: Zero `dynamic` type casts to concrete types without guards.

---

## Dependency Order

```
T11.5 (subscription fix) → independent first
T11.1 (onboarding wire) → depends on SettingsCubit being available
T11.2 (dashboard refresh) → after OnboardingCubit available
T11.3 (AI route) — independent
T11.4 (BudgetBloc guard) — independent
T11.6 (RTL radii) — independent
T11.7 (recurring blocs) — independent
T11.8 (type safety) — independent
```

Tasks T11.3-T11.8 can run in parallel.

## Verification

```powershell
flutter analyze
flutter build apk --release
```

Manual: Add expense → dashboard updates. Onboarding flow persists. AI button works. Arabic sheets correct.
