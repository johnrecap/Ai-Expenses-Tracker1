# Feature Specification: Critical Fixes — Phase 1

**Feature Branch**: `011-critical-fixes`

**Created**: 2026-05-29

**Status**: Draft pending approval

**Input**: Full code review (2026-05-29) — 15 critical/high-severity issues blocking user functionality.

## User Stories

### US-1 — Onboarding Preferences Persist (P0)

As a new user completing onboarding, I want my language, currency, and notification choices saved so they take effect when I reach the home screen.

**Why**: Onboarding screens collect 3 preferences but navigate away without saving. `OnboardingCubit` exists but is never called. `onboardingCompleted` flag stays `false` forever.

**Acceptance**: After completing all 3 steps, preferences are persisted to Firestore. Returning user skips onboarding. Language shows in Arabic if selected.

---

### US-2 — Dashboard Updates After Adding Expense (P0)

As a user who just added an expense, I want the dashboard's hero card (total spent, budget remaining, progress bar) to reflect the new data immediately.

**Why**: `ReportCubit.load()` runs once at startup. After `CreateExpenseSuccess`, ReportCubit is stale. Dashboard shows old numbers until app restart.

**Acceptance**: Add expense → dashboard hero card updates within seconds. Budget screen progress updates.

---

### US-3 — AI Assistant Button Works (P1)

As a user, I want the sparkle button on the dashboard to open the AI Assistant.

**Why**: `context.go(AppRoutes.aiAssistant)` called at `home_dashboard_screen.dart:51` but no `GoRoute` for `/ai/assistant` exists in router. Navigation silently fails.

**Acceptance**: Tapping sparkle button opens AI Assistant bottom sheet or screen.

---

### US-4 — Google Sign-In Error Error Handling (P1)

As a user, I want the app to handle network errors gracefully when signing in, not crash or silently fail.

**Why**: `jsonDecode` in `ai_gateway_client.dart:46` and `exchange_rate_service.dart:38` lack try/catch. Malformed HTTP responses cause `FormatException` crash.

**Acceptance**: Malformed API response shows user-friendly error, not crash.

---

### US-5 — Stream Safety (P1)

As an app user, I want the app not to crash when Firebase streams emit unexpected null values.

**Why**: `budget_bloc.dart:17` uses `budget!` null assertion on `Stream<Budget?>`. If null emitted → crash. `app.dart:42` discards `StreamSubscription` return — potential leak.

**Acceptance**: Null stream values handled gracefully. Subscriptions properly managed.

---

### US-6 — RTL Sheet Corners (P1)

As an Arabic-speaking user, I want bottom sheets and dialogs to render with correct RTL corners (topStart/topEnd, not topLeft/topRight).

**Why**: `AppRadii.sheet` (used by GlassBottomSheet across all screens) hardcodes `topLeft`/`topRight`. In RTL, sheet corners appear on wrong side.

**Acceptance**: Arabic mode → sheet rounded corners on correct side.

---

### US-7 — Recurring Expense Error Handling (P2)

As a user creating recurring expenses, I want to know if the save failed rather than silently lose data.

**Why**: `recurring_expense_bloc.dart` has 3 empty `catch (_) {}` blocks. Firestore write failures silently discarded.

**Acceptance**: Failed writes show error message. User can retry.

---

### US-8 — Budget Edit Durability (P2)

As a user who edits a budget, I want the save to persist to Firestore and see confirmation.

**Why**: State persistence bug — `BudgetSaved` state auto-pops on re-entry. User ID empty on new budget creation.

**Acceptance**: Save persists. Re-entering screen loads saved budget, doesn't auto-pop.

---

### US-9 — Wallets/Subscriptions Type Safety (P2)

As a user viewing wallets and subscriptions, I want screens to handle data properly without crashing.

**Why**: `wallets_accounts_screen.dart` and `subscriptions_center_screen.dart` use unsafe `as` casts from `dynamic`. If mock data types change, app crashes.

**Acceptance**: Screens handle any data shape gracefully. No runtime crashes from type casts.

---

## Non-Functional Requirements

- `flutter analyze` zero errors
- `flutter build apk --release` succeeds
- No new dependencies added
- All BLoC event handlers have error handling
- No empty catch blocks remain (minimum `debugPrint`)

## Success Criteria

- [ ] Onboarding persists language, currency, notifications
- [ ] `OnboardingCubit` provided in widget tree, called from screens
- [ ] Dashboard refreshes after expense creation
- [ ] AI assistant button navigates or shows sheet
- [ ] RTL sheet corners correct
- [ ] Null stream values safely handled in all BLoCs
- [ ] Recurring expense errors shown to user
- [ ] Budget edit persists without auto-pop
- [ ] Wallets/subscriptions screens type-safe
