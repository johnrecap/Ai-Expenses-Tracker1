# Implementation Plan: Critical Fixes — Phase 1

**Branch**: `011-critical-fixes` | **Date**: 2026-05-29 | **Spec**: `specs/011-critical-fixes/spec.md`

**Input**: Full code review (2026-05-29) — 15 critical/high issues blocking user functionality.

## Mandatory Skills

`speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`.

## Summary

Fix 8 categories of critical/high-severity bugs discovered in the full audit: onboarding preferences never persisted, dashboard showing stale data after expense creation, broken AI assistant route, null safety crashes in BudgetBloc, stream subscription leak, RTL sheet corners wrong for Arabic, silent error swallowing in RecurringExpenseBloc, and unsafe `dynamic` type casts in wallets/subscriptions screens.

## Why

These are blocking issues that cause data loss (onboarding preferences discarded), false reporting (stale dashboard), navigation failures (AI button dead), runtime crashes (null assertion, type casts), and RTL layout bugs. Without fixes, the app cannot be considered production-ready.

## Expected Result

- Onboarding: Language, currency, and notification choices persist to Firestore. `OnboardingCubit` wired. Returning users skip onboarding.
- Dashboard: Hero card refreshes after expense creation. `ReportCubit.load()` called on `CreateExpenseSuccess`.
- AI Assistant: Sparkle button opens `AiAssistantSheet` bottom sheet.
- Safety: All stream null values guarded. Subscription lifecycle managed. `RecurringExpenseBloc` errors emitted to UI.
- RTL: `AppRadii.sheet` uses directional corners. Arabic sheets render correctly.
- Type Safety: Wallets and subscriptions screens use proper models, not `dynamic`.

## Constitution Check

| Rule | Status |
|------|--------|
| Project law read (AGENTS.md, constitution, workflows) | PASS |
| Skills before code | PASS |
| Production Flutter App Scope | PASS — Firebase/Firestore, real state management |
| flutter_bloc + go_router | PASS — preserved |
| Component reuse over duplication | PASS — fix existing, don't create new |
| RTL/LTR support | PASS — AppRadii fix enables correct RTL |
| No WebView or HTML rendering | PASS |
| Spec-driven implementation | PASS — spec + plan + tasks created |

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: `flutter_bloc`, `go_router`, `firebase_auth`, `cloud_firestore`

**Storage**: Firebase Firestore

**Testing**: `flutter analyze`, `flutter build apk --release`, manual device test on Realme RMX3760

**No new dependencies needed.**

## Project Structure

```
Files to modify:
  lib/app/app.dart                                           — T11.1,T11.2,T11.5: OnboardingCubit provider, ReportCubit listener, auth subscription storage
  lib/app/router.dart                                        — T11.3: register AiAssistantSheet route or switch to bottom sheet
  lib/features/onboarding/presentation/
    splash_screen.dart                                       — T11.1: fix onboardingCompleted check
    language_screen.dart                                     — T11.1: wire OnboardingCubit.setLanguage()
    base_currency_screen.dart                                — T11.1: wire OnboardingCubit.setCurrency()
    notifications_screen.dart                                — T11.1: wire completeOnboarding()
  lib/features/dashboard/presentation/
    home_dashboard_screen.dart                               — T11.3: fix AI button to showModalBottomSheet
  lib/features/budgets/budget_bloc/
    budget_bloc.dart                                         — T11.4: null guard on stream emission
  lib/core/theme/
    app_radii.dart                                           — T11.6: directional radii for RTL
  lib/screens/recurring_expenses/blocs/
    recurring_expense_bloc.dart                              — T11.7: emit errors, not silent catch
  lib/features/wallets/presentation/
    wallets_accounts_screen.dart                             — T11.8: type-safe model usage
  lib/features/subscriptions/presentation/
    subscriptions_center_screen.dart                         — T11.8: type-safe model usage

New files:
  (none — all changes are modifications to existing files)

Files to delete:
  (none — deletions covered in spec 012)
```

## Reuse Strategy

All fixes modify existing code, not create new components:
- `OnboardingCubit` already has `completeOnboarding()` — just needs to be called and provided
- `AiAssistantSheet` already exists — just needs to be shown from dashboard button
- `SettingsCubit` already has `saveCurrency()` and `saveLanguage()` — just need wiring
- `EmptyState` widget exists — used in spec 013

## Data Flow Fixes

### Onboarding Flow (T11.1)
```text
SplashScreen → AuthAuthenticated
  → SettingsCubit.onboardingCompleted? → /home (skip onboarding)
  → else → /onboarding/language
    → LanguageScreen: OnboardingCubit.setLanguage(en|ar) → /onboarding/currency
      → BaseCurrencyScreen: OnboardingCubit.setCurrency(code) → /onboarding/notifications
        → NotificationsScreen: OnboardingCubit.setNotifications(settings)
          → OnboardingCubit.completeOnboarding()
            → SettingsRepository.saveSettings(onboardingCompleted: true, ...)
          → /home
```

### Dashboard Refresh Flow (T11.2)
```text
AddExpenseQuickScreen: CreateExpenseBloc.add(CreateExpense(expense))
  → FirebaseExpenseRepo.createExpense() → Firestore write
  → GetExpensesBloc.watchExpenses() stream emits updated list
  → CreateExpenseBloc emits CreateExpenseSuccess
    → BlocListener in app.dart or dashboard:
      → ReportCubit.load() → recomputes totals
      → HomeDashboardScreen._HeroCard rebuilds with new totalSpent
```

### AI Assistant Flow (T11.3)
```text
HomeDashboardScreen: sparkle button tapped
  → showModalBottomSheet(AiAssistantSheet())  // no route needed
  → user types message → AiAssistantCubit.sendMessage()
  → AiService.parseExpense() via gateway
```

## Possible Bugs And Fix Strategy

| Bug | Likelihood | Fix |
|-----|-----------|-----|
| OnboardingCubit not available in context | Medium | Provide in `app.dart` MultiBlocProvider under `if (_bundle != null)` |
| SettingsRepository.saveSettings fails silently | Low | OnboardingCubit already has try/catch — verify error state handling |
| ReportCubit.load() called too frequently | Medium | Add guard: only reload on CreateExpenseSuccess, debounce if needed |
| AiAssistantSheet can't access BLoCs | Low | Provide via BlocProvider.value pattern or pass via constructor |
| BudgetBloc stream emits null after delete | Low | Guard with `if (budget != null)` — already implemented pattern |
| AppRadii.sheet used by GlassBottomSheet | High | Change `BorderRadius.vertical(top:)` to `BorderRadiusDirectional.vertical(top:)`. Needs `topStart`/`topEnd` |
| RecurringExpenseBloc file may not compile after edit | Low | Verify part files and imports before building |
| Wallets/Subscriptions mock data structure changes | Medium | Use proper `WalletAccount`/`Subscription` models, with fallback for missing fields |

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter build apk --release
```

### Manual verification checklist:
1. **Fresh sign-up**: Complete onboarding → verify settings in Firestore → restart app → goes to home
2. **Add expense**: Quick Add 15 KWD → return to dashboard → hero card shows updated total + progress
3. **AI sparkle**: Tap sparkle on dashboard → AI Assistant bottom sheet opens
4. **Null safety**: Delete all budgets from Firestore → open budgets screen → no crash (shows 0.00)
5. **RTL**: Switch to Arabic → open any bottom sheet → corners on correct side in RTL
6. **Recurring**: Try creating recurring expense offline → shows error, not silent fail
7. **Wallets**: Open wallets screen → renders without crash (mock or real data)
8. **Subscriptions**: Open subscriptions → renders without crash

## Phase 0: Research

All issues identified in full audit (2026-05-29). Key decisions:

- **OnboardingCubit provider**: Add to `app.dart` under authenticated BLoCs, using `_bundle!.settingsRepository`
- **Dashboard refresh**: Use `BlocListener<CreateExpenseBloc>` in `app.dart` that calls `ReportCubit.load()` on success
- **AI route fix**: Use `showModalBottomSheet` instead of route — simpler, matches design intent
- **RTL radii**: `BorderRadiusDirectional.vertical(top: Radius.circular(AppRadii.lg))` with `topStart`/`topEnd`
- **Type safety**: Use null-safe accessors instead of `as` casts on mock data

## Phase 1: Design

No new data models, routes, or APIs. All changes are modifications to existing infrastructure. The `OnboardingCubit` already has `setLanguage`, `setCurrency`, `setNotifications`, and `completeOnboarding` methods. The `AiAssistantSheet` already exists as a functional component.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| BlocListener in app.dart | Dashboard stale data only fixable with cross-BLoC listener | Would require every screen to listen individually — more complex |
| OnboardingCubit injection per-auth | Auth-scoped preference writing | Global availability causes issues on logout |
