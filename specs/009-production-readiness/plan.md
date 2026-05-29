# Implementation Plan: Production Readiness — Expense Recording & Feature Fixes

**Branch**: `009-production-readiness` | **Date**: 2026-05-28 | **Spec**: `specs/009-production-readiness/spec.md`

**Input**: Feature specification from `/specs/009-production-readiness/spec.md` and 2026-05-28 comprehensive audit.

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `flutter-build-responsive-layout`, `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`.

## Summary

Fix 13 blocking issues across expense recording, AI features, budgets, goals, onboarding, and localization discovered in the May 28 production audit. The app builds and authenticates via Firebase but users cannot add, view, or manage expenses through the UI. This plan covers navigation wiring, BLoC fixes, model migration from mocks, Firestore integration, AI gateway connection, and UI polish.

## Why

The audit revealed that expense recording is broken at every layer:
- **Navigation**: No FAB/+ button to reach add screens
- **Data**: Empty `expenseId` causes all expenses to overwrite the same Firestore document
- **Screens**: Two of three add screens are stubs (save buttons do nothing)
- **Widgets**: `TransactionTile`/`TransactionSection` typed to `MockExpense` crash on real data
- **Categories**: No `CategoryBloc`, no loading, no seeding
- **AI**: Gateway client/service defined but all screens use hardcoded mock data
- **Budgets/Goals**: Progress stuck at 0%, type mismatches, edit doesn't persist
- **Onboarding**: Bypassed entirely by SplashScreen
- **Localization**: Full Arabic translation exists but zero screens use it

## Expected Result

- `/expenses/new/quick` saves expenses with UUIDs to Firestore
- `/expenses/new/text` parses AI input via Cloudflare Worker gateway
- `/expenses/new/receipt` uploads receipt image and extracts via AI gateway
- `/expenses` list renders real `Expense` model without type errors
- Category selector uses `CategoryBloc` with Firestore data + default seeding
- Dashboard has FAB navigating to Quick Add
- Budget progress calculates from actual expenses
- Saving goals render with correct `SavingGoal` model type
- Onboarding flow triggers for new users
- All screens use `AppLocalizations` for text

## Source References

- Audit report: `specs/009-production-readiness/spec.md`
- `specs/003-dashboard-expenses/spec.md` — dashboard FAB design
- `specs/004-add-edit-expense/spec.md` — add/edit screen specs
- `specs/005-reports-budgets-goals/spec.md` — budget/goal specs
- `specs/007-ai-settings-final-qa/spec.md` — AI and settings specs
- `specs/002-launch-onboarding-auth/spec.md` — onboarding specs
- `specs/design-system.md` — design token reference
- `specs/component-map.md` — component inventory

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: `flutter_bloc`, `go_router`, `firebase_auth`, `cloud_firestore`, `http`, `uuid`, `image_picker`, `google_sign_in`

**Storage**: Firebase Firestore (primary) at `users/{userId}/expenses`, `users/{userId}/categories`, etc.

**Testing**: Manual device testing on Realme RMX3760 (Android 15). Widget tests for BLoCs, screens. `flutter analyze` for static analysis.

**Target Platform**: Android (release APK). iOS deferred.

**Constraints**: No WebView or HTML rendering. No direct AI provider keys in Flutter (route through Cloudflare Worker gateway). No secrets in source code.

**Runtime Mode**: `firebaseLegacy` (default) — Firebase Auth + Firestore.

## Constitution Check

| Rule | Status | Notes |
|------|--------|-------|
| Project law read (AGENTS.md, constitution, workflows) | PASS | All prerequisites complete |
| Skills before plans or code | PASS | Speckit + Flutter skills loaded |
| Production Flutter App Scope | PASS | Firebase/Firestore allowed, no WebView |
| Spec-driven full-stack implementation | PASS | Spec + plan + tasks created |
| flutter_bloc + go_router architecture | PASS | Existing architecture preserved |
| Component reuse over duplication | PASS | Fix existing widgets, don't create new ones |
| RTL/LTR support | PASS | Localization infrastructure ready, being applied |
| No secrets in source | PASS | firebase_options not tracked, API URL via dart-define |
| Responsive verified at 360x800, 375x812, 390x844 | PASS | Checked as part of verification |

## Project Structure

```text
Existing files to modify:
  lib/main.dart                                  — (no changes needed, already fixed)
  lib/app/app.dart                              — (no changes needed, already correct)
  lib/app/router.dart                            — (no changes needed)
  lib/app/routes.dart                            — (no changes needed)
  lib/features/dashboard/presentation/
    home_dashboard_screen.dart                   — ADD: FAB button, ADD: navigation to /expenses/new/quick
  lib/features/expenses/presentation/
    expenses_list_screen.dart                    — ADD: FAB/button to /expenses/new/quick
    add_expense_quick_screen.dart                — FIX: generate UUID, wire CreateExpenseBloc
    add_expense_ai_text_screen.dart              — FIX: wire AiAssistantCubit, wire CreateExpenseBloc
    add_expense_receipt_screen.dart              — FIX: wire AiService.extractReceipt(), wire CreateExpenseBloc
    widgets/
      transaction_tile.dart                      — FIX: use Expense model, not MockExpense
      transaction_section.dart                   — FIX: use List<Expense>, not List<MockExpense>
      category_icon_badge.dart                   — FIX: accept Category model, not MockCategory
  lib/features/budgets/presentation/
    budgets_overview_screen.dart                 — FIX: compute progress from ReportCubit
    edit_monthly_budget_screen.dart              — FIX: wire BudgetBloc for persistence
    category_budgets_list_screen.dart            — FIX: wire CategoryBudgetRepository
  lib/features/goals/presentation/
    widgets/goal_card.dart                       — FIX: accept SavingGoal, not MockGoal
  lib/features/onboarding/presentation/
    splash_screen.dart                           — FIX: route to onboarding for new users
    language_screen.dart                         — FIX: wire OnboardingCubit, use AppRoutes
    base_currency_screen.dart                    — FIX: wire OnboardingCubit, use AppRoutes
    notifications_screen.dart                    — FIX: wire OnboardingCubit, use AppRoutes
  lib/features/reports/presentation/
    report_drilldown_screen.dart                 — IMPLEMENT: real data from ReportCubit
    monthly_financial_story_screen.dart          — IMPLEMENT: real data from ReportCubit
  lib/ai/cubit/
    ai_assistant_cubit.dart                      — FIX: call AiService instead of placeholder
  lib/features/ai/presentation/
    ai_assistant_sheet.dart                      — FIX: wire AiAssistantCubit
    ai_advice_screen.dart                        — FIX: wire AiAssistantCubit.getAdvice()
  lib/screens/auth/blocs/
    auth_bloc/auth_bloc.dart                     — (already fixed in prior work)
  lib/screens/home/blocs/
    get_expenses_bloc/get_expenses_bloc.dart     — (already fixed in prior work)
  lib/screens/add_expense/blocs/
    create_expense_bloc/create_expense_bloc.dart — (no changes needed, already correct)
  lib/screens/settings/blocs/
    onboarding_cubit.dart                        — (no changes needed, already correct)

New files to create:
  lib/features/categories/
    category_bloc/category_bloc.dart             — NEW: load/watch categories from Firestore
    category_bloc/category_event.dart            — NEW
    category_bloc/category_state.dart            — NEW
  lib/core/services/
    default_category_seeder.dart                 — NEW: seed default categories for new users

New dependencies:
  uuid: ^4.5.1                                   — ADD to pubspec.yaml
  image_picker: ^1.1.2                           — already in pubspec.yaml

Files to delete/consolidate:
  lib/core/mock/                                 — (keep for now, remove references from production)
  lib/screens/home/views/home_screen.dart        — already dead code (AuthGate never used)
```

**Structure Decision**: No new feature directories. Work is distributed across existing features. The only new feature is `categories/` for the `CategoryBloc`.

## Reuse Strategy

Fix existing widgets rather than creating new ones:
- `TransactionTile` — change `MockExpense expense` to `Expense expense`
- `TransactionSection` — change `List<MockExpense>` to `List<Expense>`
- `CategoryIconBadge` — accept `Category` model instead of looking up `MockData`
- `GoalCard` — change `MockGoal goal` to `SavingGoal goal`
- `AiAssistantCubit` — replace hardcoded response with `AiService.parseExpense()`
- `AiService` — already wraps `AiGatewayClient`, just needs to be called
- `OnboardingCubit` — already implemented, just needs to be called from screens

## Data Flow for Expense Creation (Target State)

```text
User taps FAB on dashboard
  → go_router navigates to /expenses/new/quick
  → User fills amount, selects category from CategoryBloc, enters merchant
  → User taps Save
  → CreateExpenseBloc.add(CreateExpense(expenseWithUuid))
  → FirebaseExpenseRepo.createExpense(expense)
    → _col.doc(expenseId).set(expense.toEntity().toJson())
  → Firestore triggers watchExpenses() stream
  → GetExpensesBloc receives updated list
  → ExpensesListScreen re-renders with new expense
  → HomeDashboardScreen re-renders updated metrics
```

## Possible Bugs And Fix Strategy

| Bug | Likelihood | Fix Strategy |
|-----|-----------|--------------|
| UUID collision | Very low | Use `uuid` v4, which has 2^122 collision space |
| CategoryBloc not initialized before Quick Add opens | Medium | Provide CategoryBloc at App level (MultiBlocProvider) for authenticated users |
| AI gateway timeout (Cloudflare Worker cold start) | High | Set 15s timeout, show "AI is warming up, try manual entry" fallback |
| Image picker permission denied | Medium | Wrap in try-catch, show permission rationale dialog |
| Firestore write fails (offline) | Medium | Show snackbar error with retry button, don't pop screen |
| Budget progress NaN (no expenses) | Medium | Guard division: `spent > 0 && budget > 0 ? spent/budget : 0.0` |
| Onboarding loops for existing Firebase users | Medium | Check `onboardingCompleted` flag in settings before routing |
| RTL layout breaks after Arabic switch | Medium | Test each screen in both LTR and RTL after localization changes |
| Category seeding adds duplicates | Low | Check `getCategories()` count before seeding |
| `ember` in BLoC used via stream listener | Low | All BLoCs already fixed to use `await for` pattern |

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Device verification checklist:
1. Install APK via `adb install -r`
2. Sign in with existing Firebase account
3. Verify expenses load in dashboard recent transactions
4. Verify expenses list shows real data grouped by date
5. Tap FAB → verify Quick Add opens
6. Add expense → verify it appears in list
7. Add expense via AI text → verify parse + save
8. Open budgets → verify progress bar shows real percentage
9. Open goals → verify render without crash
10. Sign out → Sign up as new user → verify onboarding flow triggers
11. Switch language to Arabic → verify Arabic text renders
12. Verify no app crashes throughout flow

## Phase 0: Research

Audit completed 2026-05-28. All findings documented in spec. Key decisions:
- **UUID package**: `uuid: ^4.5.1` is the standard Dart UUID package
- **Category seeding**: Seed on first `getCategories()` call returning empty list
- **Image picker**: Already in pubspec.yaml (`image_picker: ^0.8.9`)
- **AI gateway**: Reachable at `ai-expenses-gateway.mohamedsaied-m20.workers.dev`
- **Firebase project**: `ai-expenses-tracker-studio` (ID: `216033590804`)

## Phase 1: Design

Data model: No new models. Use existing `Expense`, `Category`, `SavingGoal`, `Budget`, `UserSettings` from `packages/expense_repository/lib/src/models/`.

Contracts: No new API contracts. AI gateway endpoints already defined in `AiGatewayClient`:
- `POST /aiParse` — text expense parsing
- `POST /aiReceipt` — receipt extraction
- `POST /aiAdvice` — financial advice

Tasks: See `tasks.md` for detailed implementation breakdown.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New `CategoryBloc` | No existing BLoC loads categories from Firestore | Would require passing category data through every screen manually |
| `uuid` dependency | Expenses need unique Firestore document IDs | Firestore auto-ID not accessible from BLoC layer before write |
| New `DefaultCategorySeeder` | No other code creates initial categories for new users | Manual category creation per user is impractical |

## AGENTS.md Update

Add `specs/009-production-readiness/plan.md` to the Spec Kit plan set in AGENTS.md.
