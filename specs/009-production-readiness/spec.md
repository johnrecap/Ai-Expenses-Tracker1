# Feature Specification: Production Readiness — Expense Recording & Feature Fixes

**Feature Branch**: `009-production-readiness`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Comprehensive audit (2026-05-28) revealed 13 blocking issues preventing users from recording expenses and using core features. This spec covers all fixes required to make the app production-operational with Firebase Auth + Firestore backend.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `flutter-build-responsive-layout`, `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`.

**Scope guard**: Production Flutter app with Firebase Auth + Firestore backend. Real API calls, real persistence, real state management. No WebView, no HTML rendering, no direct AI provider keys in Flutter.

## User Scenarios & Testing

### User Story 1 — Add Expense via Quick Add (Priority: P0)

As a user, I want to tap a + button from the dashboard, enter an amount/category/merchant, and save the expense to my account, then see it appear in my expense list immediately.

**Why this priority**: This is the primary money-tracking action. Without it, the app has zero value. Currently: no navigation entry point, expenses saved with empty ID (overwriting each other), transaction widgets crash on real data.

**Independent Test**: Open dashboard, tap FAB/+ button, enter amount "15.500", choose category "Food", tap save. Verify expense appears in list and persists after app restart.

**Acceptance Scenarios**:

1. **Given** user is on dashboard, **When** they tap the FAB, **Then** Quick Add screen opens at `/expenses/new/quick`.
2. **Given** amount and category are filled, **When** Save is tapped, **Then** `CreateExpenseBloc` dispatches `CreateExpense` with a valid UUID expenseId, the expense is written to Firestore under `users/{userId}/expenses/{uuid}`, and the screen pops back.
3. **Given** an expense was saved, **When** user navigates to `/expenses` list, **Then** the expense appears in the grouped-by-date list without type errors.
4. **Given** user restarts the app, **When** dashboard loads, **Then** the previously saved expense is still visible.

---

### User Story 2 — View Expenses in List (Priority: P0)

As a user, I want to see all my recorded expenses in a grouped-by-date list with correct category icons and amounts.

**Why this priority**: The expense list is the primary data view. Currently: `TransactionTile` and `TransactionSection` are typed to `MockExpense`, crash when receiving real `Expense` objects from `GetExpensesBloc`.

**Independent Test**: Navigate to `/expenses`, verify expenses render grouped by date with correct category icons, amounts, and merchant names.

**Acceptance Scenarios**:

1. **Given** expenses exist in Firestore, **When** user opens expense list, **Then** expenses render grouped by date without type errors.
2. **Given** the list renders, **When** user scrolls, **Then** sections stay persistent and performance is smooth.
3. **Given** search field is active, **When** user types, **Then** expenses filter by text matching merchant/description.

---

### User Story 3 — Categories Loaded from Firestore (Priority: P0)

As a user, I want categories to load from Firestore so I can select them when adding expenses, and new users should have default categories seeded automatically.

**Why this priority**: Every expense requires a category. Currently: no `CategoryBloc` exists, categories are never loaded, every screen hardcodes its own list, new users have zero categories.

**Independent Test**: Sign up as a new user, verify 10+ default categories appear in the Quick Add category selector. Existing users: verify their Firestore categories load and display.

**Acceptance Scenarios**:

1. **Given** a new user signs up, **When** the app loads, **Then** default categories (Food, Transport, Shopping, Housing, Entertainment, Healthcare, Education, Utilities, Personal Care, Other) are created in `users/{userId}/categories`.
2. **Given** categories exist, **When** user opens Quick Add or Expenses Filter, **Then** categories render from `CategoryBloc` state.
3. **Given** a category is selected in Quick Add, **When** the expense is saved, **Then** the category data (ID, name, icon, color) is stored with the expense.

---

### User Story 4 — AI Text Expense Entry (Priority: P1)

As a user, I want to type a phrase like "lunch 25 KWD at the mall" and have AI parse it into a structured expense that I can save.

**Why this priority**: AI text entry is a differentiated feature. Currently: screen exists but save button does nothing, AI cubit returns hardcoded placeholder, AI gateway client is fully defined but unused.

**Independent Test**: Open `/expenses/new/text`, type "dinner 30 KWD at sushi restaurant", tap Parse, verify structured expense appears (amount, merchant, category), tap Save, verify expense saved to Firestore.

**Acceptance Scenarios**:

1. **Given** AI text screen opens, **When** user types text and taps Parse, **Then** `AiAssistantCubit` calls `AiService.parseExpense()` via `AiGatewayClient`, and parsed result renders in the form.
2. **Given** parsed result shows, **When** user taps Save, **Then** `CreateExpenseBloc` saves the expense with `source: ExpenseSource.aiText`.
3. **Given** AI gateway is unreachable, **When** parse fails, **Then** a user-friendly error message displays and the manual quick mode is suggested.

---

### User Story 5 — Receipt Expense Entry (Priority: P1)

As a user, I want to upload a receipt image and have AI extract the expense details.

**Why this priority**: Receipt scanning is a premium feature. Currently: screen exists but save button does nothing, receipt panel is a static mock, AI service endpoint is defined but unused.

**Independent Test**: Open `/expenses/new/receipt`, upload a receipt photo, verify AI extraction returns structured data, tap Save, verify expense saved.

**Acceptance Scenarios**:

1. **Given** receipt screen opens, **When** user taps upload area, **Then** image picker opens and selected image displays.
2. **Given** image is selected, **When** extraction completes, **Then** parsed data (merchant, amount, date) renders in the form.
3. **Given** parsed result shows, **When** user taps Save, **Then** expense saves with `source: ExpenseSource.receipt`.

---

### User Story 6 — Budget Progress Shows Real Data (Priority: P2)

As a user, I want my budget screen to show actual spending progress calculated from my expenses.

**Why this priority**: Budget tracking is a core financial feature. Currently: progress bar is hardcoded to 0% (line has TODO comment), category budgets are hardcoded, edit screen doesn't persist to Firestore.

**Independent Test**: Open budgets screen, verify spending bar shows actual percentage based on expenses. Edit the budget amount, verify it saves and persists.

**Acceptance Scenarios**:

1. **Given** expenses exist for current month, **When** budgets screen opens, **Then** progress bar shows (totalSpent / budgetAmount) * 100%.
2. **Given** user edits the monthly budget, **When** Save is tapped, **Then** `BudgetBloc` dispatches `BudgetSave` and the new amount persists to Firestore.
3. **Given** budget is saved, **When** screen is re-opened, **Then** the saved amount displays.

---

### User Story 7 — Saving Goals With Real Data (Priority: P2)

As a user, I want to see my saving goals, create new ones, and track progress.

**Why this priority**: Goals are a core feature. Currently: `GoalCard` widget expects `MockGoal` type but `SavingGoalBloc` provides `SavingGoal` — runtime type mismatch will crash.

**Independent Test**: Open goals screen, verify existing goals render. Create a new goal with name and target, verify it persists. Delete a goal, verify it's removed.

**Acceptance Scenarios**:

1. **Given** user navigates to goals, **When** screen loads, **Then** goals from `SavingGoalBloc` render in `GoalCard` widgets without type errors.
2. **Given** user creates a new goal, **When** Save is tapped, **Then** goal saves to Firestore and appears in the list.
3. **Given** a goal exists, **When** user deletes it, **Then** goal is removed from Firestore and list.

---

### User Story 8 — Onboarding Flow Connected (Priority: P2)

As a new user, I want to complete the onboarding flow (language → currency → notifications) when I first sign up.

**Why this priority**: Proper onboarding sets user preferences. Currently: 3 onboarding screens exist visually, but `SplashScreen` bypasses them entirely (routes to login/home directly), `OnboardingCubit` is dead code, no selections are persisted.

**Independent Test**: Sign up as new user, verify onboarding screens show (language selection → currency selection → notification preferences). After completion, verify preferences are saved to `SettingsRepository` and the app starts at home.

**Acceptance Scenarios**:

1. **Given** user signs up for the first time, **When** auth completes, **Then** SplashScreen routes to `/onboarding/language` (not `/home`).
2. **Given** user completes all 3 onboarding steps, **When** "Get Started" is tapped, **Then** `OnboardingCubit.completeOnboarding()` persists language, currency, and notification settings.
3. **Given** user has already completed onboarding, **When** they sign in again, **Then** SplashScreen routes directly to `/home`.

---

### User Story 9 — Category Budgets and Reports (Priority: P3)

As a user, I want category budgets to sync with actual Firestore data, and the report drilldown to show real spending by category.

**Why this priority**: Feature completeness. Currently: category budgets are hardcoded, `ReportDrilldownScreen` is a stub, `MonthlyFinancialStoryScreen` uses hardcoded data.

**Independent Test**: Open category budgets, verify Firestore data loads. Open report drilldown for a category, verify it shows expenses for that category in the selected period.

**Acceptance Scenarios**:

1. **Given** category budgets exist in Firestore, **When** screen opens, **Then** data loads from `CategoryBudgetRepository`.
2. **Given** a category has expenses, **When** drilldown opens, **Then** `ReportCubit` filters expenses by category and period, renders chart and list.

---

### User Story 10 — Localization Applied to Screens (Priority: P3)

As a user, I want the app to display text in my selected language (English or Arabic), with all screens using localized strings.

**Why this priority**: Full Arabic translation exists (125 strings). All infrastructure is wired. But zero screens actually use `AppLocalizations.of(context)` — every string is hardcoded English.

**Independent Test**: Switch language to Arabic, verify all screen labels, buttons, and messages display in Arabic. Switch back to English, verify reversion.

**Acceptance Scenarios**:

1. **Given** language is set to Arabic, **When** any screen renders, **Then** all visible text comes from `AppLocalizations`, not hardcoded strings.
2. **Given** language is changed in Settings, **When** saved, **Then** all screens immediately re-render with the new language.

---

## Non-User-Facing Requirements

### NFR-1 — expenseId Generation

Every new expense MUST have a unique, non-empty `expenseId`. Use a UUID (package `uuid`) generated in the BLoC or repository layer before Firestore write. The current empty-string `expenseId: ''` causes all expenses to overwrite the same Firestore document.

### NFR-2 — Firestore Security Rules

Firestore rules MUST allow authenticated users to read/write their own `users/{userId}/expenses`, `users/{userId}/categories`, etc. The current "expenses deny all" rule must be updated to match the user-scoped pattern already used for `users/{userId}/{document=**}`.

### NFR-3 — Type Safety in Production Widgets

`TransactionTile`, `TransactionSection`, and `CategoryIconBadge` MUST accept the real `Expense` domain model type, not `MockExpense`. Remove mock model usage from production widget files. Update `GoalCard` to accept `SavingGoal` instead of `MockGoal`.

### NFR-4 — Error Handling

All BLoC error handlers MUST show user-friendly messages derived from actual exception types. The `_friendlyError` method in `AuthBloc` already does this; extend the pattern to `CreateExpenseBloc`, `BudgetBloc`, `SavingGoalBloc`, `ReportCubit`, and `AiAssistantCubit`.

### NFR-5 — Offline Resilience

If Firestore is unreachable, the app MUST show a retryable error state (not crash). `GetExpensesBloc` already handles this with `await for` error fallback; verify `CreateExpenseBloc` and other write operations also handle errors gracefully.

## Success Criteria

- [ ] User can add an expense via Quick Add and see it persist across app restarts
- [ ] Expense list renders real Firestore data without type errors
- [ ] Categories load from Firestore; new users receive default categories
- [ ] AI text mode parses user input and saves via `CreateExpenseBloc`
- [ ] Receipt mode uploads image and saves extracted expense data
- [ ] Budget progress shows actual spending percentage
- [ ] Saving goals render without type errors; CRUD works
- [ ] Onboarding flow triggers for new users and persists preferences
- [ ] `flutter analyze` passes with zero errors
- [ ] `flutter build apk --release` succeeds
- [ ] App installs and runs on Android device without crashes
- [ ] All Firestore security rules permit authenticated user access
