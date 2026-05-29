# Tasks: Production Readiness — Expense Recording & Feature Fixes

**Branch**: `009-production-readiness` | **Date**: 2026-05-28 | **Plan**: `specs/009-production-readiness/plan.md`

## Implementation Batches

Each batch must pass `flutter analyze` before continuing. Batches are ordered by dependency. Critical-path batches (P0) must complete before P1, and P1 before P2.

---

## Batch 1: Foundation Fixes (P0 — Critical Path)

### Task 1.1 — Add `uuid` dependency

**Why**: Every new expense needs a unique Firestore document ID. Currently `expenseId: ''` causes all expenses to overwrite the same document.

**Expected result**: `uuid: ^4.5.1` added to root `pubspec.yaml` and available for import.

**Scope**: `pubspec.yaml`

**Verification**: `flutter pub get` succeeds. `import 'package:uuid/uuid.dart';` resolves.

**Stop condition**: UUID package available in project.

---

### Task 1.2 — Fix `TransactionTile` to accept `Expense` model

**Why**: Widget is typed to `MockExpense`. When `GetExpensesBloc` emits real `Expense` objects from Firestore, the `ExpensesListScreen` passes them to this widget, causing a type mismatch crash.

**Expected result**: `TransactionTile` accepts `Expense expense` and renders amount, category name, category icon, merchant, and formatted date from the real model.

**Scope**: `lib/features/expenses/presentation/widgets/transaction_tile.dart`

**Implementation notes**:
- Change parameter type from `MockExpense expense` to `Expense expense`
- Use `expense.amount`, `expense.categoryName`, `expense.categoryIcon`, `expense.description`, `expense.date`
- Keep existing layout and styling unchanged
- Remove any `MockData` or `MockCategory` references

**Possible bugs**: `Expense` model fields may differ from `MockExpense`. Check: `amount` is `double`, `categoryName` is `String`, `date` is `DateTime`.

**Fix strategy**: Map fields 1:1 where possible. Use `expense.description ?? ''` for optional fields.

**Verification**: Screen renders real expenses from Firestore without crash.

**Stop condition**: Widget compiles and renders with `Expense` type.

---

### Task 1.3 — Fix `TransactionSection` to accept `List<Expense>`

**Why**: Same type mismatch as Task 1.2 — this section widget groups expenses by date and passes them to `TransactionTile`.

**Expected result**: `TransactionSection` accepts `List<Expense> transactions` and renders rows using the fixed `TransactionTile`.

**Scope**: `lib/features/expenses/presentation/widgets/transaction_section.dart`

**Implementation notes**:
- Change `List<MockExpense>` to `List<Expense>`
- Group by `expense.date` (use `DateTime(expense.date.year, expense.date.month, expense.date.day)` for grouping key)
- Section header shows formatted date

**Verification**: Expenses grouped correctly by date in the list.

**Stop condition**: Grouping logic works with real `Expense` model.

---

### Task 1.4 — Fix `CategoryIconBadge` to accept `Category` model

**Why**: Widget references `MockData.categories` instead of accepting a category parameter. When real categories load from Firestore, this won't work.

**Expected result**: Widget accepts a `Category category` parameter and renders its icon + color.

**Scope**: `lib/features/expenses/presentation/widgets/category_icon_badge.dart`

**Implementation notes**:
- Add `final Category category;` constructor parameter
- Use `category.icon` and `category.color` instead of `MockData.categories` lookup
- Remove `MockCategory`/`MockData` imports

**Verification**: Badge renders different icons/colors based on category data.

**Stop condition**: No mock references, compiles with real `Category` model.

---

### Task 1.5 — Fix `ExpensesListScreen` type casts

**Why**: Screen has `.cast()` calls on lines that pass `List<Expense>` to widgets expecting `List<MockExpense>`. After Tasks 1.2-1.4, remove these casts.

**Expected result**: `ExpensesListScreen` passes `List<Expense>` directly to `TransactionSection` and `TransactionTile` without casts.

**Scope**: `lib/features/expenses/presentation/expenses_list_screen.dart`

**Implementation notes**:
- Remove all `.cast<MockExpense>()` calls
- Pass `state.expenses` directly to `TransactionSection`
- Update any local variables typed to `MockExpense` to `Expense`
- ADD a FAB button (`FloatingActionButton`) or app bar action to navigate to `/expenses/new/quick`

**Possible bugs**: Search/filter logic may reference `MockExpense` fields. Update to `Expense` field names.

**Verification**: List renders without type errors, FAB navigates to Quick Add.

**Stop condition**: No type casts, no mock references, FAB works.

---

## Batch 2: Dashboard Navigation & Quick Add (P0 — Critical Path)

### Task 2.1 — Add FAB to `HomeDashboardScreen`

**Why**: Users have no way to reach the add-expense screens. The dashboard is the primary entry point.

**Expected result**: A gradient FAB with a "+" icon is visible on the dashboard. Tapping it navigates to `/expenses/new/quick`.

**Scope**: `lib/features/dashboard/presentation/home_dashboard_screen.dart`

**Implementation notes**:
- Add `FloatingActionButton` to the `Scaffold`
- Use `AppColors.primaryGradientStart` / `AppColors.primaryGradientEnd` for the gradient
- `onPressed: () => context.go(AppRoutes.expensesNewQuick)`
- Position: `floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked` (if using BottomNav) or standard end position
- Import `go_router` and `AppRoutes`

**Possible bugs**: FAB overlaps with BottomNav. Fix: use `centerDocked` with a notch, or position above the nav.

**Verification**: Tap FAB, Quick Add screen opens. Back button returns to dashboard.

**Stop condition**: FAB visible and functional on dashboard.

---

### Task 2.2 — Fix `AddExpenseQuickScreen` to generate UUID and save

**Why**: Currently creates expense with `expenseId: ''`, which causes all expenses to overwrite the same Firestore document. Must generate UUID and call `CreateExpenseBloc`.

**Expected result**: On save, the screen generates a UUID, constructs a full `Expense` with the UUID as `expenseId`, dispatches `CreateExpense` to `CreateExpenseBloc`, listens for success/failure, and pops on success.

**Scope**: `lib/features/expenses/presentation/add_expense_quick_screen.dart`

**Implementation notes**:
- Import `package:uuid/uuid.dart`
- In `_onSave()`:
  ```dart
  final expenseId = const Uuid().v4();
  final expense = Expense(
    expenseId: expenseId,
    userId: context.read<AuthBloc>().state.user?.userId ?? '',
    categoryId: selectedCategory.categoryId,
    categoryName: selectedCategory.name,
    categoryIcon: selectedCategory.icon,
    categoryColor: selectedCategory.color,
    amount: double.tryParse(_amountController.text) ?? 0,
    description: _merchantController.text,
    date: DateTime.now(),
    source: ExpenseSource.manual,
    paymentMethod: PaymentMethod.cash,
  );
  context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  ```
- Listen to `CreateExpenseBloc` state with `BlocListener`:
  - `CreateExpenseSuccess` → show SnackBar, pop screen
  - `CreateExpenseFailure` → show error SnackBar
- Replace hardcoded category strings with `CategoryBloc` state (see Task 3.1)

**Possible bugs**: `AuthBloc.state.user` might be null if state is loading. Fix: guard with null check or access `AuthBloc.state` as `AuthAuthenticated`.

**Fix strategy**: Cast auth state: `final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;`

**Verification**: Tap save, verify expense appears in Firestore with UUID document ID, verify expense appears in list after navigating back.

**Stop condition**: Expense saves with UUID, persists across restarts.

---

## Batch 3: Categories (P0 — Critical Path)

### Task 3.1 — Create `CategoryBloc`

**Why**: No BLoC loads categories from Firestore. Every screen hardcodes its own category list. New users have zero categories.

**Expected result**: A BLoC that loads categories from `CategoryRepository.watchCategories()` and exposes them via stream. Supports watch mode for reactive updates.

**Scope**:
- NEW: `lib/features/categories/category_bloc/category_bloc.dart`
- NEW: `lib/features/categories/category_bloc/category_event.dart`
- NEW: `lib/features/categories/category_bloc/category_state.dart`

**Implementation notes**:
```dart
// CategoryEvent
class CategoriesWatched extends CategoryEvent {}

// CategoryState
class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}
class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
}
class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}

// CategoryBloc
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repo;
  CategoryBloc(this._repo) : super(CategoryInitial()) {
    on<CategoriesWatched>(_onWatch);
  }
  Future<void> _onWatch(CategoriesWatched event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await for (final categories in _repo.watchCategories()) {
        emit(CategoryLoaded(categories));
      }
    } catch (_) {
      emit(const CategoryError('Failed to load categories.'));
    }
  }
}
```

**Verification**: `flutter analyze` passes.

**Stop condition**: BLoC compiles and exposes category stream.

---

### Task 3.2 — Seed default categories for new users

**Why**: New users signing up have zero categories in Firestore, making the app unusable.

**Expected result**: When `CategoryBloc` detects an empty category list for the first time, it creates 10 default categories in Firestore.

**Scope**: `lib/features/categories/category_bloc/category_bloc.dart` (extend `_onWatch`) or NEW: `lib/core/services/default_category_seeder.dart`

**Implementation notes**:
- Default categories: Food (🍔, orange), Transport (🚗, blue), Shopping (🛍, purple), Housing (🏠, teal), Entertainment (🎬, pink), Healthcare (💊, red), Education (📚, indigo), Utilities (💡, amber), Personal Care (💇, brown), Other (📦, grey)
- In `CategoryBloc._onWatch()`, after first emission, check `if (categories.isEmpty)`:
  ```dart
  if (categories.isEmpty) {
    await _seedDefaults();
  }
  ```
- `_seedDefaults()` creates each default category via `_repo.createCategory()`
- Use `CategoryBloc`'s own repository (injected)

**Possible bugs**: Multiple simultaneous empty checks → create duplicates. Fix: use a `_seeded` flag that resets on dispose.

**Verification**: Sign up as new user, verify 10 categories appear in Firestore and in app.

**Stop condition**: Default categories created exactly once per new user.

---

### Task 3.3 — Wire `CategoryBloc` into `App` widget

**Why**: `CategoryBloc` must be available to all screens via `BlocProvider`.

**Expected result**: `CategoryBloc` is provided in `MultiBlocProvider` alongside authenticated BLoCs so all screens can `context.read<CategoryBloc>()`.

**Scope**: `lib/app/app.dart`

**Implementation notes**:
- In `_AppState._onAuthStateChanged()`, when user authenticates:
  - Create `CategoryBloc(_bundle!.categoryRepository)` 
  - Dispatch `CategoriesWatched()`
- Add `BlocProvider<CategoryBloc>` to `MultiBlocProvider` when `_bundle != null`

**Verification**: `BlocProvider.of<CategoryBloc>(context)` works from any authenticated screen.

**Stop condition**: CategoryBloc accessible app-wide.

---

### Task 3.4 — Wire `AddExpenseQuickScreen` to use `CategoryBloc`

**Why**: Quick Add screen has hardcoded category chips. Must load from `CategoryBloc`.

**Expected result**: Category chips render from `CategoryBloc.state`, and selected category data (ID, name, icon, color) is used when creating the expense.

**Scope**: `lib/features/expenses/presentation/add_expense_quick_screen.dart`

**Implementation notes**:
- Replace `_categories` static list with `BlocBuilder<CategoryBloc, CategoryState>`
- On `CategoryLoaded`, render chips from `state.categories`
- On tap, set selected `Category` object (not just string)
- Use `selectedCategory.categoryId`, `.name`, `.icon`, `.color` when constructing `Expense`

**Verification**: Categories load from Firestore and render as chips. Selecting a chip highlights it.

**Stop condition**: No hardcoded category strings in Quick Add screen.

---

## Batch 4: AI & Receipt Features (P1)

### Task 4.1 — Wire `AiAssistantCubit` to `AiService`

**Why**: AI cubit returns hardcoded placeholder responses. `AiGatewayClient` and `AiService` are fully defined but never called.

**Expected result**: `AiAssistantCubit.sendMessage()` parses user input via `AiService.parseExpense()` and returns structured expense data, or shows a fallback error.

**Scope**: `lib/ai/cubit/ai_assistant_cubit.dart`

**Implementation notes**:
- Inject `AiService` into `AiAssistantCubit`
- In `sendMessage()`:
  - Add user message to state
  - Set loading state
  - Call `_aiService.parseExpense(text: message)`
  - On success: emit parsed expense suggestion
  - On failure: emit error message with "Try manual entry" suggestion
- Add a 15-second timeout

**Possible bugs**: Cloudflare Worker may have cold starts (5-10s latency). Fix: use longer timeout, show "Analyzing..." progress indicator.

**Verification**: Type "lunch 15 at restaurant", verify AI returns structured expense suggestion.

**Stop condition**: AI parsing works end-to-end via gateway.

---

### Task 4.2 — Wire `AddExpenseAiTextScreen` save button

**Why**: Save button currently does nothing (shows snackbar and pops). Must call `CreateExpenseBloc`.

**Expected result**: On save, the screen dispatches `CreateExpense` with the AI-parsed expense data and navigates back on success.

**Scope**: `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`

**Implementation notes**:
- Replace `_onSave` stub with real save logic:
  - Read parsed expense from `AiAssistantCubit` state
  - Generate UUID via `const Uuid().v4()`
  - Set `source: ExpenseSource.aiText`
  - Dispatch `CreateExpense(expense)` to `CreateExpenseBloc`
- Add `BlocListener<CreateExpenseBloc>` for success/failure

**Verification**: Parse text → see structured result → tap Save → expense appears in list.

**Stop condition**: AI text expenses save to Firestore and appear in list.

---

### Task 4.3 — Wire `AddExpenseReceiptScreen` image picker + save

**Why**: Receipt upload panel is a static mock. Must use `image_picker` and `AiService.extractReceipt()`.

**Expected result**: Tap upload area → image picker opens → selected image displays → AI extracts expense data → user can edit and save.

**Scope**: `lib/features/expenses/presentation/add_expense_receipt_screen.dart`

**Implementation notes**:
- Add `image_picker` import
- On tap: `await ImagePicker().pickImage(source: ImageSource.gallery)`
- Display selected image in upload panel
- Call `_aiService.extractReceipt(imageBytes: await file.readAsBytes())`
- Show parsed result in form card
- On Save: same flow as Task 4.2 but with `source: ExpenseSource.receipt`

**Possible bugs**: Image picker permissions. Fix: wrap in try-catch, show permission dialog.

**Verification**: Upload receipt photo → AI extracts data → tap Save → expense appears in list.

**Stop condition**: Receipt expenses save to Firestore via AI extraction.

---

## Batch 5: Budgets & Goals (P2)

### Task 5.1 — Fix budget progress calculation

**Why**: Budget progress bar is hardcoded to 0% with a TODO comment. Must calculate from actual expenses.

**Expected result**: Budget screen shows `(totalSpent / budgetAmount) * 100` as the progress percentage.

**Scope**: `lib/features/budgets/presentation/budgets_overview_screen.dart`

**Implementation notes**:
- Read `BudgetBloc` state for budget amount
- Read `ReportCubit` state for `totalSpent`
- Compute: `final progress = totalSpent > 0 && budgetAmount > 0 ? (totalSpent / budgetAmount).clamp(0.0, 1.0) : 0.0;`
- Guard against division by zero

**Possible bugs**: `ReportCubit` may not have loaded when Budget screen opens. Fix: show loading until both BLoCs have data.

**Verification**: Add an expense, navigate to budgets, verify progress bar updates.

**Stop condition**: Progress reflects actual spending.

---

### Task 5.2 — Wire `EditMonthlyBudgetScreen` to `BudgetBloc`

**Why**: Edit screen uses local state only. Save button shows snackbar and pops without persistence.

**Expected result**: On save, `BudgetBloc` dispatches `BudgetSave` with the new budget. Progress persists across app restarts.

**Scope**: `lib/features/budgets/presentation/edit_monthly_budget_screen.dart`

**Implementation notes**:
- Remove local `_totalBudget` state
- Read current budget from `BudgetBloc` state
- On save, construct `Budget` with updated amount and dispatch `BudgetSave(budget)`
- Listen for `BudgetSaved` → show success and pop

**Verification**: Edit budget → save → navigate away → come back → budget is updated.

**Stop condition**: Budget edits persist to Firestore.

---

### Task 5.3 — Fix `GoalCard` type from `MockGoal` to `SavingGoal`

**Why**: `SavingGoalBloc` provides `SavingGoal` objects but `GoalCard` expects `MockGoal`. This is a type mismatch that will crash at runtime.

**Expected result**: `GoalCard` accepts `SavingGoal` and renders goal name, target amount, current amount, progress bar, and deadline.

**Scope**: `lib/features/goals/presentation/widgets/goal_card.dart`

**Implementation notes**:
- Change constructor: `final SavingGoal goal;`
- Map fields: `goal.name`, `goal.targetAmount`, `goal.currentAmount`, `goal.targetDate`
- Compute progress: `(goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)`
- Remove `MockGoal`/`MockData` imports

**Verification**: Goals list renders without crash. Progress bar shows correct percentage.

**Stop condition**: Goals screen renders real data without type errors.

---

### Task 5.4 — Wire `CategoryBudgetsListScreen` to `CategoryBudgetRepository`

**Why**: Screen uses 6 hardcoded category budget entries. Must load from Firestore.

**Expected result**: Screen loads category budgets from `CategoryBudgetRepository` and renders them in the list.

**Scope**: `lib/features/budgets/presentation/category_budgets_list_screen.dart`

**Implementation notes**:
- Create or extend `CategoryBudgetBloc` or use repository directly
- Load via `watchCategoryBudgets()` or `getCategoryBudgets()`
- Replace hardcoded list with `BlocBuilder` or `FutureBuilder`

**Verification**: Category budgets load from Firestore. Editing a category amount persists.

**Stop condition**: No hardcoded category budget data.

---

## Batch 6: Onboarding & Localization (P2)

### Task 6.1 — Fix `SplashScreen` to route to onboarding for new users

**Why**: SplashScreen routes to `/home` or `/login` but never to onboarding. OnboardingCubit has `completeOnboarding()` but nothing calls it.

**Expected result**: SplashScreen checks `SettingsRepository` for `onboardingCompleted` flag. If false (new user), routes to `/onboarding/language`. If true (returning user), routes to `/home`.

**Scope**: `lib/features/onboarding/presentation/splash_screen.dart`

**Implementation notes**:
- Inject `SettingsRepository` (via `SettingsCubit` or direct)
- After auth resolves, check if onboarding is completed
- Route accordingly: `/onboarding/language` or `/home`

**Possible bugs**: Settings may not have loaded yet. Fix: wait for `SettingsCubit` state before routing.

**Verification**: New user → onboarding screens appear. Returning user → home screen appears.

**Stop condition**: Onboarding flow triggers correctly for new vs returning users.

---

### Task 6.2 — Wire onboarding screens to `OnboardingCubit`

**Why**: All 3 onboarding screens use local state only. No selections are persisted. `OnboardingCubit` is dead code.

**Expected result**: Each screen calls the appropriate `OnboardingCubit` method. Language selection → `setLanguage()`, Currency → `setCurrency()`, Notifications → `setNotifications()`. Final "Get Started" calls `completeOnboarding()`.

**Scope**:
- `lib/features/onboarding/presentation/language_screen.dart`
- `lib/features/onboarding/presentation/base_currency_screen.dart`
- `lib/features/onboarding/presentation/notifications_screen.dart`

**Implementation notes**:
- Add `OnboardingCubit` as dependency (inject via `BlocProvider` or constructor)
- Language screen: call `cubit.setLanguagePreference(en/ar)` on selection
- Currency screen: call `cubit.setBaseCurrency(code)` on selection
- Notifications screen: call `cubit.setNotificationPreferences(...)` then `cubit.completeOnboarding()`
- Replace hardcoded route strings with `AppRoutes` constants
- Use `context.go(AppRoutes.onboardingCurrency)` instead of `context.go('/onboarding/currency')`

**Verification**: Complete onboarding flow → check Firestore `users/{userId}/settings` → verify `onboardingCompleted: true`, `languagePreference: ar`, `baseCurrency: EGP`.

**Stop condition**: Onboarding preferences persist to Firestore.

---

### Task 6.3 — Apply `AppLocalizations` to all screens (Phase 1 — Dashboard + Expenses)

**Why**: Full Arabic translation exists (125 strings). Infrastructure is wired. But zero screens use it. All text is hardcoded English.

**Expected result**: Dashboard, expense list, and add expense screens use `AppLocalizations.of(context)` for all visible text.

**Scope**:
- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `lib/features/expenses/presentation/expenses_list_screen.dart`
- `lib/features/expenses/presentation/add_expense_quick_screen.dart`

**Implementation notes**:
- Import `package:expenses_tracker/l10n/app_localizations.dart`
- Replace all hardcoded strings with `AppLocalizations.of(context)!.xxx`
- Common replacements: `'Home'` → `l10n.homeTitle`, `'Expenses'` → `l10n.expensesTitle`, `'Save'` → `l10n.save`, `'Cancel'` → `l10n.cancel`, `'Amount'` → `l10n.amount`, `'Category'` → `l10n.category`
- Check `app_localizations.dart` for exact getter names

**Possible bugs**: Some strings may not exist in ARB. Fix: add missing strings to `app_en.arb` and `app_ar.arb`.

**Verification**: Switch language to Arabic → dashboard and expense screens display Arabic text.

**Stop condition**: Dashboard and expense screens are fully localized.

---

### Task 6.4 — Apply `AppLocalizations` to remaining screens

**Why**: Phase 2 of localization — apply to all remaining screens.

**Scope**:
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/sign_up_screen.dart`
- `lib/features/budgets/presentation/budgets_overview_screen.dart`
- `lib/features/goals/presentation/saving_goals_screen.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/onboarding/presentation/language_screen.dart`
- `lib/features/onboarding/presentation/base_currency_screen.dart`
- `lib/features/onboarding/presentation/notifications_screen.dart`
- `lib/features/reports/presentation/reports_main_screen.dart`

**Implementation notes**: Same pattern as Task 6.3.

**Verification**: Switch language to Arabic → all screens display Arabic text.

**Stop condition**: Zero hardcoded English strings remain in UI code.

---

## Batch 7: Reports & Remaining Fixes (P3)

### Task 7.1 — Implement `ReportDrilldownScreen` with real data

**Why**: Screen is a stub showing placeholder text. Must show real expenses for the selected category.

**Expected result**: Screen accepts a `categoryId` parameter, reads `ReportCubit` data, filters expenses by that category, and renders a chart + expense list.

**Scope**: `lib/features/reports/presentation/report_drilldown_screen.dart`

**Implementation notes**:
- Read `categoryId` from route parameters (already passed)
- Access `ReportCubit` via `context.read<ReportCubit>()`
- Filter `state.expenses` by `categoryId`
- Render a simple bar chart or list of matching expenses
- Show category name and total amount

**Verification**: Tap a category from reports → drilldown shows expenses for that category.

**Stop condition**: Drilldown shows real filtered expense data.

---

### Task 7.2 — Implement `MonthlyFinancialStoryScreen` with real data

**Why**: Screen uses 4 hardcoded narrative panels with fake KWD values.

**Expected result**: Screen reads `ReportCubit` state and generates a narrative summary based on real data (month-over-month comparison, top category, biggest single expense, savings rate).

**Scope**: `lib/features/reports/presentation/monthly_financial_story_screen.dart`

**Implementation notes**:
- Read `ReportCubit` state for `monthComparison` and `categoryTotals`
- Generate narrative from data:
  - "You spent X this month, Y% vs last month"
  - "Your top category was [name] at X% of total"
  - "Your biggest single expense was [name] for X"
- Replace hardcoded panels with computed data

**Verification**: Open monthly story → see narrative generated from real expense data.

**Stop condition**: Story uses real computed data, not hardcoded values.

---

### Task 7.3 — Fix Firestore security rules

**Why**: Current rules deny all reads to `expenses` and `categories` collections. Must allow authenticated users to read/write their own data.

**Expected result**: Firestore rules updated in Firebase Console to allow authenticated access.

**Implementation notes**: Update rules to:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Verification**: Add expense → verify it persists to Firestore and can be read back.

**Stop condition**: All Firestore CRUD operations work for authenticated users.

---

## Dependency Order

```
Batch 1 (Foundation: uuid, widget fixes) 
  → Batch 2 (Dashboard FAB + Quick Add fix) 
    → Batch 3 (Categories: BLoC + seeding + wiring) 
      → Batch 4 (AI: cubit + text + receipt screens) 
      → Batch 5 (Budgets + Goals fixes) 
      → Batch 6 (Onboarding + Localization) 
      → Batch 7 (Reports + Security rules)
```

Batches 5 and 6 can run in parallel after Batch 3. Batch 7 can start after Batch 5.

## Verification After All Batches

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am start -n com.saeeddevstudio.ai_expenses_tracker/.MainActivity
```

Full manual test:
1. Sign out (if signed in) → Sign in with email
2. Verify categories load in Quick Add
3. Add an expense via Quick Add → verify in list
4. Add expense via AI Text → verify parse + save
5. View reports → verify totals
6. View budgets → verify progress
7. View goals → verify render
8. Sign out → Sign up as new user → verify onboarding flow
9. Switch language → verify Arabic
10. No crashes throughout
