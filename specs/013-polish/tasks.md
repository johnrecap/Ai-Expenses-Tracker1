# Tasks: Polish — Phase 3

**Branch**: `013-polish` | **Plan**: `specs/013-polish/plan.md`

## Batch 13: Empty States + Currency + Localization

### T13.1 — Apply EmptyState widget to all screens

**Why**: 5 screens have ad-hoc inline empty states. Shared `EmptyState` widget unused.

**Expected result**: All empty states use `EmptyState(icon:, title:, subtitle:, action:)`.

**Scope**:
- `lib/features/expenses/presentation/expenses_list_screen.dart`
- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `lib/features/goals/presentation/saving_goals_screen.dart`
- `lib/features/reports/presentation/reports_main_screen.dart`
- `lib/features/reports/presentation/report_drilldown_screen.dart`

**Verification**: Each screen shows empty state with icon + message, not bare Text.

**Stop condition**: Zero inline empty state texts.

---

### T13.2 — Dynamic report arrow direction

**Why**: Arrow always points down regardless of comparison direction.

**Expected result**: Arrow matches `changePercent` sign. Up for increase, down for decrease.

**Scope**: `lib/features/reports/presentation/widgets/report_summary_card.dart`

**Verification**: Compare two months with increase → see up arrow. Compare with decrease → see down arrow.

**Stop condition**: Arrow matches comparison direction.

---

### T13.3 — Currency label from settings

**Why**: 7+ screens hardcode `'KWD'`. User's selected currency ignored.

**Expected result**: Currency label reads from `SettingsCubit` or `expense.currency` field.

**Scope**:
- `add_expense_quick_screen.dart` — suffix label
- `home_dashboard_screen.dart` — hero card suffix
- `budgets_overview_screen.dart` — budget label
- `edit_monthly_budget_screen.dart` — slider label
- `category_budgets_list_screen.dart` — allocation labels
- `report_drilldown_screen.dart` — total label

**Implementation**: Read `SettingsCubit.state` or use `expense.currency`. Prefer `expense.currency` for per-transaction precision, `SettingsCubit.state.settings.baseCurrency` for display context.

**Verification**: Select EGP as base currency → all labels show EGP.

**Stop condition**: Zero hardcoded `'KWD'` where user preference should apply.

---

### T13.4 — Apply AppLocalizations to high-traffic screens

**Why**: 120+ strings hardcoded English. Arabic translation exists but unused.

**Expected result**: Auth, dashboard, expenses screens read text from `AppLocalizations.of(context)`.

**Scope** (Phase 1 localization — auth + dashboard + expenses):
- `lib/features/auth/presentation/login_screen.dart` (~15 strings)
- `lib/features/auth/presentation/sign_up_screen.dart` (~12 strings)
- `lib/features/dashboard/presentation/home_dashboard_screen.dart` (~10 strings)
- `lib/features/expenses/presentation/expenses_list_screen.dart` (~8 strings)
- `lib/features/expenses/presentation/add_expense_quick_screen.dart` (~6 strings)
- `lib/core/widgets/app_bottom_nav.dart` (5 nav labels)

**Implementation**: Import `app_localizations.dart`, replace strings with `l10n.xxx`.

**Possible bugs**: Missing keys in ARB. Fix: add to `app_en.arb` and `app_ar.arb`.

**Verification**: Arabic mode → auth/expenses screens show Arabic. Back to English → show English.

**Stop condition**: 50+ strings localized across 6 screens.

---

### T13.5 — Fix category name matching to be case-insensitive

**Why**: `.firstWhere((c) => c?.name == v)` exact match fails with whitespace or case differences.

**Expected result**: Trimmed, case-insensitive matching.

**Scope**: `lib/features/expenses/presentation/add_expense_quick_screen.dart`

**Implementation**: `c!.name.trim().toLowerCase() == v.trim().toLowerCase()`

**Verification**: Select category "Food" from dropdown → matches `Category(name: "food")`.

**Stop condition**: Category matching robust to case/whitespace variation.

---

### T13.6 — Add future-date indicator to TransactionTile

**Why**: Future expenses show day-month without indicator.

**Expected result**: Future dates show "Scheduled: Jan 15" or similar.

**Scope**: `lib/features/expenses/presentation/widgets/transaction_tile.dart`

**Verification**: Create expense with future date → label shows "Scheduled" indicator.

**Stop condition**: Future dates clearly distinguishable.

---

### T13.7 — Fix fallback character in HomeDashboard

**Why**: `'�'` renders as broken glyph when no categories exist.

**Expected result**: Fallback shows `'—'` or `'None'`.

**Scope**: `lib/features/dashboard/presentation/home_dashboard_screen.dart`

**Verification**: Fresh install with no categories → shows `'—'`, not broken glyph.

**Stop condition**: No Unicode replacement character visible.

---

### T13.8 — Fix ExpenseFormCard dropdown null safety

**Why**: `v!` assertion on `String?` crashes if null selected.

**Expected result**: Guarded callback: `if (v != null) onChanged(v)`.

**Scope**: `lib/features/expenses/presentation/widgets/expense_form_card.dart`

**Verification**: Dropdown interaction → no crash with null value.

**Stop condition**: No `!` assertion on nullable dropdown value.

---

## Dependency Order

All tasks in Batch 13 are independent and can run in parallel.

## Verification

```powershell
flutter analyze
flutter build apk --release
```

Manual: Arabic mode → text localized. EGP currency → labels match. Empty states consistent. Future dates labeled. No `'�'` glyphs. No dropdown crashes.
