# Production Flutter Implementation Plan: Default Payment Method

**Branch**: `main` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/028-default-payment-method/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills.
- Loaded relevant skills.

**Skills used**:

- `speckit-specify`: created the feature specification and quality checklist.
- `speckit-plan`: created this implementation plan and design artifacts.

## Summary

Complete the expense payment method flow so a wallet is never required to save an expense. Quick add and AI add must always save a valid payment method. If the user does not provide one, the app uses the user's default payment method from settings, with Cash as the safe fallback.

## Why

The first useful action in the app is adding an expense. Requiring users to create wallets first adds friction and makes AI entry feel broken. Separating "payment method" from "wallet/account link" lets users track spending immediately while keeping wallet tracking optional for users who want it.

## Expected Result

- Settings includes a clear "Default Payment Method" control.
- Quick add includes a direct payment method selector.
- AI text add detects payment method from text when present.
- AI text add falls back to the user's default payment method when missing.
- Expenses can be saved with Cash, Visa/Card, Wallet, or Bank Transfer without a wallet account.
- Wallet account selection stays optional and only populates wallet fields when selected or confidently matched.
- Firestore/local settings and expense contracts remain valid.
- Focused tests cover default payment behavior, no-wallet saving, AI mapping, and settings persistence.

## Source References

- `specs/028-default-payment-method/spec.md`
- `docs/firebase/firestore-schema.md`
- `firestore.rules`
- `packages/expense_repository/lib/src/models/payment_method.dart`
- `packages/expense_repository/lib/src/models/user_settings.dart`
- `packages/expense_repository/lib/src/models/expense.dart`
- `packages/expense_repository/lib/src/settings_repo.dart`
- `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`
- `packages/expense_repository/lib/src/local/local_repositories.dart`
- `lib/features/settings/settings_cubit/settings_cubit.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/expenses/presentation/add_expense_quick_screen.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/domain/ai_expense_draft_mapper.dart`
- `lib/features/ai/services/ai_service.dart`
- `lib/features/ai/services/ai_expense_service.dart`
- Existing focused tests under `test/features/expenses/`, `test/features/settings/`, and `test/packages/expense_repository/`.

## Technical Context

**Language/Version**: Flutter app with Dart SDK constraint `^3.12.0`.

**Primary Dependencies**: Existing Flutter SDK, `flutter_bloc`, `go_router`, Firebase Auth/Firestore repositories, local/Drift repository layer, current shared widgets and theme tokens.

**Storage**: Existing `UserSettings.defaultPaymentMethod` and `Expense.paymentMethod`; optional expense wallet fields remain nullable. Firestore path: `users/{userId}/settings/profile`; expenses path: `users/{userId}/expenses/{expenseId}`.

**Testing**: Focused widget tests, mapper/unit tests, repository contract tests, and analyzer on touched files.

**Target Platform**: Flutter mobile app verified for 360x800, 375x812, and 390x844 in Arabic RTL and English LTR.

**Project Type**: Production Flutter app behavior and UI refinement.

**Performance Goals**: No noticeable delay in expense save flows; no extra network call beyond existing settings state/repository behavior.

**Constraints**:

- Do not require wallet creation before expense saving.
- Do not create fake wallets or fake financial data.
- Do not put secrets or AI provider keys in Flutter.
- Do not add new design language.
- Preserve existing wallet-linked expense behavior.
- Use focused checks only; no full-project analysis/test during this feature.

## Required Plan Detail

### Files And Ownership

Own for implementation:

- `lib/features/settings/settings_cubit/settings_cubit.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/expenses/presentation/add_expense_quick_screen.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/domain/ai_expense_draft_mapper.dart`
- `lib/features/ai/services/ai_service.dart`
- `lib/features/ai/services/ai_expense_service.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- Generated localization files only if `flutter gen-l10n` is run.
- Focused tests in `test/features/settings/`, `test/features/expenses/`, and `test/packages/expense_repository/`.

Read/verify only unless a contract mismatch is found:

- `packages/expense_repository/lib/src/models/payment_method.dart`
- `packages/expense_repository/lib/src/models/user_settings.dart`
- `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
- `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`
- `packages/expense_repository/lib/src/local/local_repositories.dart`
- `firestore.rules`

### Reuse Strategy

- Use existing `PaymentMethod` enum and storage values.
- Use existing `SettingsCubit` and `SettingsRepository` rather than adding a new settings service.
- Use `AppColors`, `AppSpacing`, `AppTextStyles`, `AppRadii`, `GlassCard`, and existing list tile patterns in settings.
- Prefer a compact segmented control, chips, or bottom-sheet selector matching current component style for payment method selection.
- Keep wallet dropdown/selector visually secondary and labelled optional.

### Mock Data Strategy

No mock production data. Tests may use fake repositories/blocs only as isolated test doubles.

### Possible Bugs And Fix Strategy

- **Bug**: Expense still saves as Cash even when default is Visa.  
  **Fix**: Centralize default method reading from `SettingsCubit` and add tests for each entry flow.

- **Bug**: Wallet payment method is blocked when no wallet exists.  
  **Fix**: Keep payment method and wallet link separate; ensure wallet fields are nullable.

- **Bug**: Selecting a wallet overwrites an explicitly chosen Visa/Card method unexpectedly.  
  **Fix**: Define precedence: selected wallet account sets wallet link and should set payment method to Wallet unless the UI explicitly supports another combination.

- **Bug**: AI text parser misses Arabic payment terms.  
  **Fix**: Add deterministic keyword mapping for Arabic/English terms before fallback to default.

- **Bug**: Settings save failure silently changes UI only.  
  **Fix**: Use `SettingsCubit` save state and show an error/unavailable state if save fails.

- **Bug**: Firestore rejects an unexpected payment method string.  
  **Fix**: Use `PaymentMethod.storageValue` only and run/update repository contract tests.

- **Bug**: Arabic labels overflow in settings or add screens.  
  **Fix**: Use wrapping-friendly labels, constrained controls, and required viewport checks.

## Constitution Check

**Gate result**: PASS.

- Project law files read.
- Relevant skills loaded.
- Production app scope preserved.
- No WebView/HTML shortcut planned.
- Existing backend/storage contracts are reused.
- No mock financial data planned.
- Existing theme and shared widgets reused.
- Arabic RTL and English LTR checks planned.
- Focused compile/test checks planned.

**Template conflict note**: The bundled plan template mentions UI-only prototype constraints, but this repository constitution now defines a production Flutter app. The constitution and user request explicitly allow settings, persistence, Firestore/local contracts, and expense behavior changes for this feature.

## Project Structure

```text
specs/028-default-payment-method/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    payment-method-contract.md
  checklists/
    requirements.md

lib/
  features/settings/
    settings_cubit/settings_cubit.dart
    presentation/settings_screen.dart
  features/expenses/
    presentation/add_expense_quick_screen.dart
    presentation/add_expense_ai_text_screen.dart
    domain/ai_expense_draft_mapper.dart
  features/ai/services/
    ai_service.dart
    ai_expense_service.dart
  l10n/
    app_en.arb
    app_ar.arb

test/
  features/settings/
  features/expenses/
  packages/expense_repository/
```

**Structure Decision**: Keep the feature inside existing settings, expenses, AI, and repository contracts. Do not add a new top-level payment module unless duplication appears during implementation.

## Phase 0: Research

Research decisions are captured in [research.md](research.md).

Key decisions:

- Payment method is required; wallet account is optional.
- Use existing `PaymentMethod` enum and settings field.
- Cash is the fallback for missing/corrupt/unavailable settings.
- Settings UI owns default payment method editing.
- Quick add and AI add both consume the same default method behavior.
- Firestore schema likely needs verification, not migration, because valid payment methods and optional wallet fields already exist.

## Phase 1: Design

Design artifacts:

- [data-model.md](data-model.md)
- [contracts/payment-method-contract.md](contracts/payment-method-contract.md)
- [quickstart.md](quickstart.md)

## Agent Context Update

`.specify/feature.json` now points to `specs/028-default-payment-method`. `AGENTS.md` has no `<!-- SPECKIT START -->` / `<!-- SPECKIT END -->` block, so no inline context marker was updated.

## Verification Plan

Focused commands:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format <touched-files>
& 'C:\flutter\bin\flutter.bat' analyze <touched-files> <touched-tests>
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_screen_actions_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_draft_mapper_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\settings_wallet_budget_contract_test.dart
```

Manual checks:

```text
Settings: change default payment method to Visa/Card, Wallet, Bank Transfer, Cash
Quick add: save with no wallet and no explicit method
Quick add: save with explicit payment method and no wallet
Quick add: save with selected wallet
AI text: Arabic cash/card/wallet/transfer examples
AI text: no payment words uses default
360x800 Arabic RTL
360x800 English LTR
375x812 Arabic RTL
390x844 English LTR
```

## Stop Condition

Plan is ready for implementation when the spec, research, data model, behavior contract, and quickstart exist; requirements checklist is complete; and no unresolved clarification remains.
