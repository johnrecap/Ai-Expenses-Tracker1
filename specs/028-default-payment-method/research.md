# Research: Default Payment Method

## Decision 1: Payment method is required; wallet account is optional

**Decision**: Every expense must keep a valid payment method, but `walletAccountId` and `walletAccountName` remain optional.

**Rationale**: Users can accurately record how they paid without first building a wallet/account structure. This matches the requested product behavior and existing Firestore rules that already treat wallet fields as optional.

**Alternatives considered**:

- Require wallet for Wallet payment method: rejected because the user explicitly wants Wallet as a method even with no saved wallet account.
- Auto-create wallets: rejected because it creates fake account data and violates the no mock/fake financial data rule.

## Decision 2: Reuse existing `PaymentMethod`

**Decision**: Use the existing enum values: Cash, Visa, Wallet, and Bank Transfer.

**Rationale**: The repository, Firestore rules, local Drift tables, filters, and settings model already know these values. Reuse reduces migration risk.

**Alternatives considered**:

- Add separate card/mobile-wallet transfer variants: rejected for this phase because it expands scope and requires more UX decisions.
- Store raw AI strings: rejected because Firestore rules require bounded valid values.

## Decision 3: Cash is the safe fallback

**Decision**: If settings are missing, invalid, or unavailable, default to Cash.

**Rationale**: Cash is the current model default and the least surprising fallback for MENA expense tracking. It also preserves existing behavior.

**Alternatives considered**:

- Force the user to choose before saving: rejected because it slows the add flow.
- Use the most recent payment method: deferred because it needs additional product rules and state.

## Decision 4: Settings owns the default selector

**Decision**: Add the default payment method control to Settings and persist it via the existing settings repository.

**Rationale**: The field already belongs to user settings, and Settings is where users expect defaults and preferences.

**Alternatives considered**:

- Add the default selector to onboarding: deferred because the current request is settings plus expense behavior.
- Add a separate payment settings screen: rejected for now because one selector does not justify a new screen.

## Decision 5: AI payment method precedence

**Decision**: AI mapping precedence is explicit text detection first, then user default, then Cash fallback.

**Rationale**: If the user writes "cash" or "visa", that should override any default. If they say nothing, the app should avoid asking and use the default.

**Alternatives considered**:

- Always ask user to review payment method: rejected as the default behavior because it makes AI slower; review remains possible through the form.
- Trust AI provider output only: rejected because deterministic local fallback is needed when provider output is missing or inconsistent.

## Decision 6: Firestore/local persistence likely needs verification, not migration

**Decision**: Verify current rules and repositories before changing schema.

**Rationale**: Existing code already has `defaultPaymentMethod`, expense `paymentMethod`, and optional wallet fields. Most work is likely UI/flow completion and test coverage.

**Alternatives considered**:

- Add new settings field: rejected because a field already exists.
- Run a data migration: not needed unless implementation discovers incompatible stored values.
