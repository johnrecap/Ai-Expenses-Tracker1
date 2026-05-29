# Feature Specification: Polish — Phase 3

**Feature Branch**: `013-polish`

**Created**: 2026-05-29

**Status**: Draft pending approval

**Input**: Full code review (2026-05-29) — 8 low-severity polish issues.

## User Stories

### US-1 — Shared Empty State Widget (P2)

As a user, I want consistent empty-state screens across the app with icons and messaging that match the design system.

**Why**: 5 screens have ad-hoc inline `Text('No data')` empty states. A shared `EmptyState` widget exists but is never used.

**Acceptance**: All empty states use `EmptyState` widget. Consistent icon, message, and optional action button pattern.

---

### US-2 — Report Arrow Direction (P3)

As a user, I want the comparison arrow in the report summary to point up when spending increased and down when decreased.

**Why**: `report_summary_card.dart` always shows `Icons.arrow_downward` regardless of comparison direction.

**Acceptance**: `+X%` → up arrow (green). `-X%` → down arrow (red or green). Not always down.

---

### US-3 — Currency Consistency (P3)

As a user, I want currency labels (`KWD`, `EGP`, etc.) to match my selected base currency, not be hardcoded.

**Why**: 7+ screens hardcode `'KWD'` as currency suffix. User selects EGP but sees KWD everywhere.

**Acceptance**: Currency label reads from `SettingsCubit` or `expense.currency` field.

---

### US-4 — AppLocalizations Integration (P3)

As a user switching to Arabic, I want screen text to appear in Arabic.

**Why**: Full Arabic translation exists (125 strings) but zero screens use `AppLocalizations.of(context)`. ~120+ strings hardcoded in English.

**Acceptance**: High-traffic screens (auth, dashboard, expenses) use `AppLocalizations`. Arabic mode shows Arabic text.

---

### US-5 — Category Name Matching (P3)

As a user selecting a category from dropdown, I want robust matching that handles slight name differences.

**Why**: `add_expense_quick_screen.dart:158` uses `.firstWhere((c) => c?.name == v)` — exact name match. If category name changes or has whitespace, selection fails silently.

**Acceptance**: Case-insensitive and trimmed matching. Fallback to first category if no match.

---

### US-6 — Future-Dated Transaction Labels (P3)

As a user with scheduled transactions, I want clear date labels for future expenses.

**Why**: `TransactionTile._formatDate()` shows "Today" for today, "Yesterday" for yesterday, but falls through to month-day format for future dates with no indicator.

**Acceptance**: Future dates show with "Scheduled" prefix or date with future indicator.

---

### US-7 — Fallback Character Fix (P3)

As a user viewing the home dashboard with no categories, I want a meaningful fallback instead of a broken Unicode character.

**Why**: `home_dashboard_screen.dart:218` uses `'�'` (U+FFFD) as fallback — shows broken glyph.

**Acceptance**: Fallback shows '—' (em dash) or meaningful text like 'None'.

---

### US-8 — ExpenseFormCard Dropdown Safety (P3)

As a user selecting a value from a dropdown, I want the form not to crash if selection returns null.

**Why**: `expense_form_card.dart:129` has `(v) => onChanged!(v!)` — `v!` null assertion on `String?`. If dropdown selection is null, crashes.

**Acceptance**: Null value handled with null check before calling callback.

---

## Non-Functional Requirements

- `flutter analyze` zero errors
- `flutter build apk --release` succeeds
- Arabic RTL verified on device
- No regression in add/delete/view expense flows

## Success Criteria

- [ ] Empty states use shared `EmptyState` widget
- [ ] Report arrow direction is dynamic
- [ ] Currency labels match user preference
- [ ] Auth, dashboard, expenses screens localized (EN+AR)
- [ ] Category matching is case-insensitive
- [ ] Future dates labeled properly
- [ ] No `'�'` fallback character
- [ ] Dropdown null safety handled
