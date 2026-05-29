# Tasks: Code Review Cleanup

**Branch**: `010-code-review-cleanup` | **Date**: 2026-05-29 | **Plan**: `specs/010-code-review-cleanup/plan.md`

## Batch 8: Architecture & Resilience (P1)

### Task 8.1 — Migrate BLoC files from `screens/` → `features/`

**Why**: 13 consumer files import from legacy `screens/` path. AGENTS.md prescribes `features/` structure.

**Expected result**: All BLoC/cubit files moved. All 13 consumers updated. `flutter analyze` clean.

**Scope**: 
- MOVE source directories to new feature paths
- UPDATE all import statements in 13 consumer files

**Implementation**:
```
Move files (keep part files together):
  lib/screens/auth/blocs/auth_bloc/auth_bloc.dart       → lib/features/auth/auth_bloc/
  lib/screens/auth/blocs/auth_bloc/auth_event.dart      → lib/features/auth/auth_bloc/
  lib/screens/auth/blocs/auth_bloc/auth_state.dart      → lib/features/auth/auth_bloc/
  lib/screens/home/blocs/get_expenses_bloc/             → lib/features/expenses/get_expenses_bloc/
  lib/screens/add_expense/blocs/create_expense_bloc/     → lib/features/expenses/create_expense_bloc/
  lib/screens/expenses/blocs/expense_filter_cubit/       → lib/features/expenses/expense_filter_cubit/
  lib/screens/reports/cubit/report_cubit.dart            → lib/features/reports/report_cubit/
  lib/screens/budget/blocs/budget_bloc/                  → lib/features/budgets/budget_bloc/
  lib/screens/saving_goals/blocs/saving_goal_bloc/       → lib/features/goals/saving_goal_bloc/

Update imports in these consumer files:
  lib/app/app.dart                                   (7 imports)
  lib/features/dashboard/presentation/home_dashboard_screen.dart  (1 import)
  lib/features/expenses/presentation/expenses_list_screen.dart   (2 imports)
  lib/features/expenses/presentation/add_expense_quick_screen.dart (2 imports)
  lib/features/expenses/presentation/add_expense_ai_text_screen.dart (2 imports)
  lib/features/expenses/presentation/add_expense_receipt_screen.dart (2 imports)
  lib/features/budgets/presentation/budgets_overview_screen.dart (2 imports)
  lib/features/budgets/presentation/edit_monthly_budget_screen.dart (1 import)
  lib/features/goals/presentation/saving_goals_screen.dart (1 import)
  lib/features/onboarding/presentation/splash_screen.dart (2 imports)
  lib/features/reports/presentation/report_drilldown_screen.dart (1 import)
  lib/features/reports/presentation/monthly_financial_story_screen.dart (1 import)
  lib/features/auth/presentation/login_screen.dart (if imports old path)
  lib/features/auth/presentation/sign_up_screen.dart (if imports old path)
```

**Possible bugs**: Missed import → `flutter analyze` catches. Part file `part of` paths may break — update if using absolute paths.

**Verification**: `flutter analyze` with zero errors.

**Stop condition**: All imports resolve, zero references to `package:expenses_tracker/screens/` in lib/features/ files.

---

### Task 8.2 — Firebase init failure fallback

**Why**: App launches even when Firebase fails. User sees broken auth with no feedback.

**Expected result**: `FirebaseInitErrorScreen` with error message + retry button on init failure.

**Scope**: `lib/main.dart`

**Implementation**:
- Extract `runApp(const App())` into success path of try-catch
- On catch, run `MaterialApp` with `_FirebaseInitErrorScreen`:
  - Shows error message from exception
  - Retry button calls `Firebase.initializeApp()` again
  - On success → `Navigator.pushReplacement` to `App()`

**Verification**: Disable network, launch app → error screen. Re-enable → tap retry → app loads.

**Stop condition**: Firebase init failure shows retry screen, not broken app.

---

### Task 8.3 — Extract AI gateway URL to environment config

**Why**: Hardcoded URL violates AGENTS.md rule. Multi-environment deployment needs configurability.

**Expected result**: Single config constant. Both consumers read from it.

**Scope**: 
- NEW or UPDATE: `lib/core/config/app_config.dart` — define `AiGatewayConfig`
- UPDATE: `lib/app/app.dart:103` — use config
- UPDATE: `lib/features/expenses/presentation/add_expense_receipt_screen.dart:35` — read from cubit or provider

**Implementation**:
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const aiGatewayUrl = String.fromEnvironment(
    'AI_GATEWAY_URL',
    defaultValue: 'https://ai-expenses-gateway.mohamedsaied-m20.workers.dev',
  );
}
```
Receipt screen: instead of creating its own `AiService`, access `AiAssistantCubit` which already has one. Or make `AiAssistantCubit.aiService` a named getter.

**Possible bugs**: Receipt screen creates separate `AiService` → needs refactor to share. Fix: expose `aiService` from cubit as getter.

**Verification**: Build with `--dart-define=AI_GATEWAY_URL=https://test-url` → app uses test URL.

**Stop condition**: No hardcoded gateway URL strings. All consumers read from single config.

---

## Batch 9: UX Polish (P2)

### Task 9.1 — Currency-aware amount formatting

**Why**: `toStringAsFixed(3)` hardcoded. KWD=3 decimals, EGP=2.

**Expected result**: Precision derived from currency code.

**Scope**: `lib/features/expenses/presentation/widgets/transaction_tile.dart`

**Implementation**:
```dart
int _decimalPlaces(String currency) {
  switch (currency.toUpperCase()) {
    case 'KWD': case 'BHD': case 'OMR': return 3;
    default: return 2;
  }
}
```
Use: `expense.amount.toStringAsFixed(_decimalPlaces(expense.currency))`

Also apply in: `budgets_overview_screen.dart`, `reports_main_screen.dart` if they format amounts.

**Verification**: KWD expense shows 3 decimals. EGP shows 2.

**Stop condition**: Currency precision matches currency code everywhere amounts are displayed.

---

### Task 9.2 — Add category selector to AI Text screen

**Why**: User can't override AI-parsed category in AI Text mode.

**Expected result**: Category chips from `CategoryBloc` render below the parsed result. User can tap to select.

**Scope**: `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`

**Implementation**:
- Add `Category? _selectedCategory` state field
- Add `BlocBuilder<CategoryBloc, CategoryState>` with `Wrap` of chip widgets (reuse pattern from Quick Add)
- On AI parse success, auto-select the matching category if found
- On save, use `_selectedCategory` or fall back to parsed category

**Possible bugs**: Category name from AI may not exactly match Firestore category name. Fix: use case-insensitive matching.

**Verification**: Open AI Text → parse input → category chips appear → tap different category → save uses selected category.

**Stop condition**: AI Text screen has functional category selector.

---

### Task 9.3 — AI confirmation message on successful parse

**Why**: Chat only gets messages on errors. Success should also confirm.

**Expected result**: On successful `parseExpense()`, append message like "I found: Lunch — 15.000 KWD in Food" to chat.

**Scope**: `lib/ai/cubit/ai_assistant_cubit.dart`

**Implementation**:
```dart
final msg = 'Found: ${draft.description} — ${draft.amount.toStringAsFixed(3)} in ${draft.categoryName}';
messages.add(AiMessage(role: 'assistant', content: msg));
```

**Verification**: Parse "lunch 15 at restaurant" → chat shows user message, then "Found: ..." assistant message, then parsed form.

**Stop condition**: Chat is symmetrical — both success and error produce assistant messages.

---

### Task 9.4 — Image size validation before encoding

**Why**: `readAsBytes()` + `base64Encode()` on large images causes OOM.

**Expected result**: Images >5MB resized to max 2048px before base64 encoding.

**Scope**: `lib/features/expenses/presentation/add_expense_receipt_screen.dart`

**Implementation**:
```dart
final bytes = await file.readAsBytes();
if (bytes.length > 5 * 1024 * 1024) {
  final decoded = decodeImage(bytes);
  if (decoded != null) {
    final resized = copyResize(decoded, width: 2048);
    final resizedBytes = encodeJpg(resized, quality: 80);
    // use resizedBytes
  }
}
```
Import `package:image/image.dart` (already in pubspec.yaml `image: ^4.3.0`).

**Possible bugs**: `encodeJpg` function name may differ in v4.3.0. Fix: check API — likely `encodeJpg` or `encodePng`.

**Verification**: Select 10MB image → app resizes → no OOM → AI extraction runs.

**Stop condition**: Large images are resized without crashing.

---

## Batch 10: Cleanup & Robustness (P3)

### Task 10.1 — Remove dead code

**Why**: Dead code wastes maintenance effort.

**Expected result**: Dead code removed, no compilation errors.

**Scope**:
```
DELETE or CLEANUP:
  lib/features/onboarding/presentation/splash_screen.dart — remove AnimationController + forward() + dispose
  lib/features/goals/presentation/saving_goals_screen.dart — remove redundant SizedBox(height: AppSpacing.md) on line 53
  lib/screens/home/views/home_screen.dart — DELETE entire file
  lib/screens/home/views/auth_gate.dart — DELETE if only references home_screen
```

**Possible bugs**: `AuthGate` imported elsewhere. Fix: search before deleting.

**Verification**: `flutter analyze` — no dead code, no import errors for deleted files.

**Stop condition**: Dead code removed, no references remain.

---

### Task 10.2 — Add default cases to all switch statements

**Why**: Unexpected index values silently do nothing. Must handle gracefully.

**Expected result**: Every switch statement in the codebase has a default handler.

**Scope**: Add `default: break;` or `_ => {}` to:
```
  lib/features/expenses/presentation/add_expense_ai_text_screen.dart      — _navigateMode
  lib/features/expenses/presentation/add_expense_receipt_screen.dart       — _navigateMode
  lib/features/expenses/presentation/expenses_list_screen.dart             — bottom nav
  lib/features/dashboard/presentation/home_dashboard_screen.dart           — bottom nav
  lib/features/budgets/presentation/budgets_overview_screen.dart           — bottom nav
  lib/features/goals/presentation/saving_goals_screen.dart                 — bottom nav
```

**Verification**: All switch blocks compile without analyzer warnings.

**Stop condition**: Zero switch blocks without default case.

---

## Dependency Order

```
Task 8.1 (BLoC migration) → all other tasks (import paths change)
Task 8.2 (Firebase fallback) — independent
Task 8.3 (Gateway URL config) — independent
Tasks 9.1-9.4 (UX polish) — parallel after Task 8.1
Tasks 10.1-10.2 (Cleanup) — last (safe to delete after migration)
```

## Verification (all tasks)

```powershell
flutter pub get
flutter analyze
flutter build apk --release
```
