# Feature Specification: Code Review Cleanup

**Feature Branch**: `010-code-review-cleanup`

**Created**: 2026-05-29

**Status**: Draft pending approval

**Input**: Full code review of all 19 modified files in batches 1-7 found 27 issues. 6 critical and 6 high issues were fixed immediately. This spec covers the 15 remaining medium/low issues for architectural consistency, resilience, and UX polish.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-setup-declarative-routing`, `flutter-fix-layout-issues`.

## User Stories

### US-1 — Offline Resilience (P1)

As a user with intermittent connectivity, I want the app to degrade gracefully when Firebase fails to initialize rather than showing a broken app that throws errors on every interaction.

**Why**: `main.dart` catches the init error but still launches the app. `FirebaseAuthRepository` then throws on every Firebase call, rendering the app unusable with no user-facing error.

**Acceptance**: When Firebase init fails, user sees an error screen with retry button. App does not launch with broken auth.

---

### US-2 — Environment Configuration (P1)

As a developer, I want the AI gateway URL configurable via `--dart-define` so it's not hardcoded in two separate files.

**Why**: AGENTS.md requires: "No AI provider keys in Flutter source (route through gateway only)". Hardcoded URL violates this principle and makes multi-environment deployment impossible.

**Acceptance**: `VPS_API_BASE_URL` or `AI_GATEWAY_URL` dart-define controls the gateway URL. Both `app.dart` and `add_expense_receipt_screen.dart` read from a single source.

---

### US-3 — Architecture Consistency (P2)

As a developer, I want all BLoC imports to follow the `features/` directory structure prescribed by AGENTS.md, not the legacy `screens/` path.

**Why**: 13 files import from `screens/` path. AGENTS.md prescribes `features/` structure. This drift causes confusion, broken imports during moves, and inconsistent conventions.

**Acceptance**: All BLoC files moved from `lib/screens/` to matching paths under `lib/features/`. All 13 consumer files updated. `flutter analyze` passes with zero import errors.

---

### US-4 — Currency-Aware Formatting (P2)

As a user mixing KWD and EGP currencies, I want amounts displayed with the correct decimal precision (3 for KWD, 2 for EGP).

**Why**: `TransactionTile` uses `toStringAsFixed(3)` fixed 3 decimals. KWD uses 3 decimals but EGP uses 2. Users see incorrectly formatted amounts.

**Acceptance**: Currency precision determined by `expense.currency`. KWD → 3 decimals, EGP/USD → 2 decimals. Consistent across all screens.

---

### US-5 — Missing Category in AI Text Screen (P2)

As a user of the AI text entry mode, I want to override the AI-parsed category, just like I can in Quick Add mode.

**Why**: Quick Add shows a category chip selector. AI Text screen has no category selector — user is stuck with whatever the AI inferred.

**Acceptance**: AI Text screen shows category chips from `CategoryBloc`. User can select a different category to override AI inference.

---

### US-6 — Image Size Guard (P3)

As a user uploading a receipt, I want the app to handle large images without crashing from memory exhaustion.

**Why**: `readAsBytes()` loads entire image into RAM, `base64Encode` creates string 33% larger. A 20MB photo can cause OOM.

**Acceptance**: Images larger than 5MB are resized before encoding. If resize fails, user sees error with manual entry suggestion.

---

### US-7 — Dead Code Cleanup (P3)

As a developer, I want dead code removed so the codebase is maintainable and navigation patterns are explicit.

**Why**: `splash_screen.dart` has a dead `AnimationController` (created, forwarded, disposed, never used). `saving_goals_screen.dart` has redundant spacer. `screens/home/views/home_screen.dart` is dead code (referenced by `AuthGate` which is never used).

**Acceptance**: Dead code removed. `flutter analyze` shows no dead code warnings for these items.

---

### US-8 — Switch Statement Robustness (P3)

As a developer, I want switch statements to handle unexpected values gracefully to prevent silent failures.

**Why**: 6 files have `switch` on bottom nav index or segmented mode control index without `default` case. If an unexpected index arrives, nothing happens.

**Acceptance**: All switch statements have `default` case or use `_ =>` syntax. Unexpected indices are logged and ignored gracefully.

---

### US-9 — AI Chat UX Consistency (P3)

As a user of the AI assistant, I want the chat to confirm successful parsing with a message like "Here's what I found..." before showing the parsed form.

**Why**: When parsing fails, an error message is appended. When parsing succeeds, no confirmation message appears. The chat is asymmetrical.

**Acceptance**: On successful parse, an assistant message like "I found this expense: ..." is appended to chat history before showing the parsed form card.

---

## Non-Functional Requirements

- `flutter analyze` passes with zero errors
- `flutter build apk --release` succeeds
- No new dependencies introduced
- All localization delegates remain correct (GlobalMaterialLocalizations)

## Success Criteria

- [ ] Firebase init failure shows retry screen instead of broken app
- [ ] AI gateway URL configurable via dart-define
- [ ] All BLoC imports use `features/` path
- [ ] Amount formatting respects currency precision
- [ ] AI Text screen has category selector
- [ ] Large images are resized before encoding
- [ ] Dead code removed
- [ ] Switch statements have default cases
- [ ] AI chat shows confirmation on successful parse
