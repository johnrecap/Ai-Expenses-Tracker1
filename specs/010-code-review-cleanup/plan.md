# Implementation Plan: Code Review Cleanup

**Branch**: `010-code-review-cleanup` | **Date**: 2026-05-29 | **Spec**: `specs/010-code-review-cleanup/spec.md`

**Input**: Comprehensive code review (2026-05-28) of all 19 modified files across batches 1-7. 27 issues identified; 12 fixed immediately. 15 remaining issues in this plan.

## Mandatory Skills

`speckit-plan`, `speckit-tasks`, `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`.

## Summary

Address 15 remaining medium/low issues from the code review: BLoC import path migration, environment configuration, currency formatting, offline resilience, dead code removal, switch statement hardening, and AI UX polish.

## Constitution Check

| Rule | Status |
|------|--------|
| Read project law | PASS |
| Skills before code | PASS |
| Production app scope | PASS |
| Component reuse over duplication | PASS |
| RTL/LTR support | PASS (already fixed localization delegates in prior fix) |
| No secrets in source | PASS (dart-define implemented) |
| flutter_bloc + go_router | PASS (preserved) |

## Batch Plan

### Batch 8: Architecture & Resilience (P1-P2)

#### Task 8.1 — Migrate BLoC files from `lib/screens/` → `lib/features/`

**Why**: 13 files import from old `screens/` path. AGENTS.md prescribes `features/` structure.

**Expected result**: BLoC/cubit files moved to feature directories. All imports updated.

**Scope**:
```
MOVE:  lib/screens/auth/blocs/auth_bloc/        → lib/features/auth/auth_bloc/
MOVE:  lib/screens/home/blocs/get_expenses_bloc/ → lib/features/expenses/get_expenses_bloc/
MOVE:  lib/screens/add_expense/blocs/            → lib/features/expenses/create_expense_bloc/
MOVE:  lib/screens/expenses/blocs/               → lib/features/expenses/expense_filter_cubit/
MOVE:  lib/screens/reports/cubit/                → lib/features/reports/report_cubit/
MOVE:  lib/screens/budget/blocs/                 → lib/features/budgets/budget_bloc/
MOVE:  lib/screens/saving_goals/blocs/           → lib/features/goals/saving_goal_bloc/
MOVE:  lib/screens/settings/blocs/               → lib/screens/settings/blocs/ (keep, settings not migrated)
UPDATE: 13 consumer files — all imports pointing to old screens/ path
```

**Possible bugs**: Missed import update causes compilation failure. Fix: run `flutter analyze` after each move batch.

**Verification**: `flutter analyze` passes with zero errors.

---

#### Task 8.2 — Add Firebase init failure fallback

**Why**: `main.dart` catches init error but still launches app. User sees broken auth with no feedback.

**Expected result**: On Firebase init failure, show a MaterialApp with a retry screen (ErrorWidget with retry button) instead of launching the full App.

**Scope**: `lib/main.dart`

**Implementation**: 
```dart
try {
  await Firebase.initializeApp();
  runApp(const App());
} catch (e) {
  runApp(_FirebaseInitErrorApp(error: e));
}
```

---

#### Task 8.3 — Make AI gateway URL configurable

**Why**: Hardcoded URL in `app.dart:103` and `add_expense_receipt_screen.dart:35`. AGENTS.md requires configuration via dart-define.

**Expected result**: Single source of truth for gateway URL. Both files read from the same config.

**Scope**: 
- `lib/app/app.dart` — pass URL from dart-define or constant
- `lib/features/expenses/presentation/add_expense_receipt_screen.dart` — read from BlocProvider

**Implementation**: Extract to `const _aiGatewayUrl = String.fromEnvironment('AI_GATEWAY_URL', defaultValue: 'https://ai-expenses-gateway.mohamedsaied-m20.workers.dev')`. Receipt screen reads `AiService` from `AiAssistantCubit` state or passes via provider.

---

### Batch 9: UX Polish (P2-P3)

#### Task 9.1 — Currency-aware amount formatting

**Why**: `toStringAsFixed(3)` is hardcoded. KWD uses 3 decimals, EGP uses 2.

**Expected result**: Precision determined by currency code.

**Scope**: `lib/features/expenses/presentation/widgets/transaction_tile.dart`

**Implementation**: Helper `_decimalPlaces(String currency) => currency == 'KWD' ? 3 : 2`.

---

#### Task 9.2 — Add category chips to AI Text screen

**Why**: Quick Add has category selector. AI Text doesn't. User can't override AI-inferred category.

**Expected result**: AI Text screen shows `CategoryBloc`-backed category chips below the parsed result. User can tap to select/change.

**Scope**: `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`

---

#### Task 9.3 — AI chat confirmation message on successful parse

**Why**: Error messages are appended to chat but success produces no confirmation. Asymmetrical UX.

**Expected result**: On successful parse, append assistant message "Found: {description} — {amount} KWD in {category}" before showing parsed form.

**Scope**: `lib/ai/cubit/ai_assistant_cubit.dart`

---

#### Task 9.4 — Image size guard in receipt screen

**Why**: No size validation before base64 encoding. Large images cause OOM.

**Expected result**: Images >5MB are resized to max 2048px before encoding. Fails gracefully on resize error.

**Scope**: `lib/features/expenses/presentation/add_expense_receipt_screen.dart`

**Implementation**: Use `image` package's `decodeImage` + `copyResize`. Already in pubspec.yaml (`image: ^4.3.0`).

---

### Batch 10: Cleanup & Robustness (P3)

#### Task 10.1 — Remove dead code

**Why**: Dead code wastes maintenance effort and confuses navigation analysis.

**Expected result**: Removed:
- `splash_screen.dart`: dead `AnimationController` + `_controller.forward()` call
- `saving_goals_screen.dart`: redundant spacer on line 53
- `lib/screens/home/views/home_screen.dart`: dead file (referenced by `AuthGate`, never used)
- `lib/screens/home/views/auth_gate.dart`: if only references `home_screen.dart`

---

#### Task 10.2 — Add default cases to switch statements

**Why**: 6 files have switch without default — unexpected indices silently do nothing.

**Scope**: Files with switch on bottom nav index or segmented mode index:
- `add_expense_ai_text_screen.dart`
- `add_expense_receipt_screen.dart`
- `expenses_list_screen.dart`
- `home_dashboard_screen.dart`
- `budgets_overview_screen.dart`
- `saving_goals_screen.dart`

**Implementation**: Add `default: break;` or convert to `=>` syntax with `_ => {}`.

---

## Verification

```powershell
flutter pub get
flutter analyze
flutter build apk --release
```

Manual checks:
- Firebase offline → retry screen appears
- Build with `--dart-define=AI_GATEWAY_URL=https://other-url` → URL changes
- All BLoC imports resolve correctly after path migration
- KWD amounts show 3 decimals, EGP shows 2
- AI text screen shows category chips
- AI successful parse shows confirmation message
- Upload 10MB image → no crash, image resized
- SplashScreen no longer has unused AnimationController
- Switch with unexpected index → no crash, no error
