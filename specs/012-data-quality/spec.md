# Feature Specification: Data Quality — Phase 2

**Feature Branch**: `012-data-quality`

**Created**: 2026-05-29

**Status**: Draft pending approval

**Input**: Full code review (2026-05-29) — 12 medium-severity architectural and data integrity issues.

## User Stories

### US-1 — CategoryBloc Integration (P1)

As a user, I want category filters and category budgets to show my actual categories from Firestore, not hardcoded lists.

**Why**: `expense_filters_sheet.dart` hardcodes 5 categories. `category_budgets_list_screen.dart` hardcodes 6 category budgets. `reports_main_screen.dart` has a hardcoded color map. If user has different categories, filters break.

**Acceptance**: Filter sheet loads categories from `CategoryBloc`. Category budgets load from `CategoryBudgetRepository`. Report colors derive from category data.

---

### US-2 — Settings Persistence (P1)

As a user, I want my notification preferences, dark mode, and biometric lock settings to survive app restarts.

**Why**: Settings screen toggles use local `setState` only. `SettingsCubit.saveBaseCurrency()` and `saveLanguagePreference()` exist but are never called by the UI.

**Acceptance**: Toggle notifications off → restart app → toggle remains off. Language changes persist.

---

### US-3 — Dead Code Cleanup (P2)

As a developer, I want to remove all 18+ duplicate BLoC files and 3 unused BLoCs from `screens/` so the codebase is maintainable.

**Why**: 18 files in `screens/` are byte-identical copies of `features/` versions. 3 BLoCs (`GuidedTourCubit`, `AppLockCubit`, `RecurringExpenseBloc`) are defined but never provided or used.

**Acceptance**: Zero duplicate files. Zero referenced dead code in `screens/`. `flutter analyze` clean after deletion.

---

### US-4 — AI Feature Consolidation (P2)

As a developer, I want all AI code in `lib/features/ai/` instead of split across `lib/ai/` and `lib/features/ai/`.

**Why**: `AiAssistantCubit` at `lib/ai/cubit/`, screens at `lib/features/ai/presentation/`. Split confuses feature ownership and dependency analysis.

**Acceptance**: All AI code in `lib/features/ai/` with `ai_cubit/`, `services/`, `presentation/` subdirectories.

---

### US-5 — Empty Directories (P3)

As a developer, I want 7 empty directories removed to prevent confusion.

**Why**: Empty `widgets/` dirs under budgets, settings, subscriptions, wallets plus `ai/models/`, `screens/account/views/`, `screens/account/cubit/`.

**Acceptance**: All 7 empty directories removed.

---

### US-6 — Router Import Consistency (P3)

As a developer, I want `router.dart` to use `package:` imports like the rest of the codebase.

**Why**: `router.dart` uses relative `../features/...` imports while every other file uses `package:expenses_tracker/features/...`.

**Acceptance**: All imports in `router.dart` converted to `package:` style.

---

### US-7 — Money Snapshot Serialization (P3)

As a user recording expenses in a foreign currency, I want the exchange rate snapshot saved with the expense record.

**Why**: `ExpenseEntity.moneySnapshot` is declared but never serialized in `toDocument()`. Lost on Firestore write.

**Acceptance**: `moneySnapshot` included in `toDocument()` and `fromDocument()`.

---

### US-8 — GetExpensesFailure Error Message (P3)

As a user seeing a failed expense load, I want to know what went wrong.

**Why**: `GetExpensesFailure` has no message field. UI can only show generic "Failed to load" with no details.

**Acceptance**: `GetExpensesFailure` has `message` field populated by BLoC on error.

---

### US-9 — Subscription Vendor Crash Fix (P3)

As a user viewing subscriptions, I want the vendor avatar to render without crashing on short names.

**Why**: `subscription.vendor.substring(0, 2)` crashes if vendor name is 1 character.

**Acceptance**: Short names handled gracefully with fallback character.

---

## Non-Functional Requirements

- `flutter analyze` zero errors after dead code removal
- `flutter build apk --release` succeeds
- No regression in existing functionality

## Success Criteria

- [ ] Category filter sheet loads from `CategoryBloc`
- [ ] Category budget list loads from `CategoryBudgetRepository`
- [ ] Settings toggles persist via `SettingsCubit`
- [ ] 18+ dead files removed from `screens/`
- [ ] 7 empty directories removed
- [ ] AI code consolidated in `features/ai/`
- [ ] Router imports use `package:` style
- [ ] `moneySnapshot` serialized
- [ ] `GetExpensesFailure` has message
- [ ] Subscription vendor crash fixed
