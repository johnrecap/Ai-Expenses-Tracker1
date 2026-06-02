# Research: Real AI Expense Refactor

## Decision 1: Refactor current app instead of starting over

**Decision**: Continue with the existing Flutter project and refactor high-risk areas first.

**Rationale**: The current app already has Firebase Auth, Firestore rules, repository package, Worker AI gateway, theme tokens, shared widgets, routing, and tests. Starting over would lose useful foundations and delay security fixes.

**Alternatives considered**:

- New app from scratch: rejected because it repeats already-solved setup and risks losing existing data behavior.
- UI-only rebuild: rejected because Mohamed explicitly requires real working data.

## Decision 2: AI requests must use authenticated gateway access

**Decision**: Flutter AI calls should use the existing AI gateway endpoints with the signed-in user's identity, not a shared mobile API key.

**Rationale**: Shared keys in mobile apps can be extracted. User-authenticated gateway calls allow quota, ownership, and safer failure handling.

**Alternatives considered**:

- Keep `PROXY_API_KEY` in `.env`: rejected as a mobile secret risk.
- Call AI provider directly from Flutter: rejected by project security rules.
- Keep old `server/ai-proxy` as production path: rejected unless placed behind real user authentication.

## Decision 3: `.env` must not be bundled as a Flutter asset

**Decision**: Remove `.env` from Flutter assets. Use compile-time public configuration for non-secret values and server-side secrets for private values.

**Rationale**: Flutter assets are extractable from build artifacts.

**Alternatives considered**:

- Keep `.env` and hide values by convention: rejected because packaged assets are not secret.
- Move all config to code constants: rejected for private values; acceptable only for non-secret public URLs.

## Decision 4: No production mock financial data

**Decision**: Production UI must use real user data or empty states. Mock data can exist only for tests/previews if clearly isolated.

**Rationale**: Fake financial entries make broken flows look working and confuse users.

**Alternatives considered**:

- Keep mock data as fallback: rejected because it violates the feature goal.
- Delete all mock files immediately: rejected until tests/previews are reviewed, because some tests may rely on fixtures.

## Decision 5: AI expense save requires review

**Decision**: AI parsing creates a draft, never a direct saved expense.

**Rationale**: Financial records must not be saved from uncertain AI output without user confirmation.

**Alternatives considered**:

- Auto-save high-confidence AI results: rejected because wrong money/date/category is costly for users.
- Only fill a plain form silently: rejected because users need to see what AI understood.

## Decision 6: Keep current visual language

**Decision**: Reuse current theme and shared widgets while cleaning layout and repeated components.

**Rationale**: AGENTS.md requires matching existing colors, typography, spacing, shadows, and components. The issue is consistency and function, not a new brand direction.

**Alternatives considered**:

- New design system: rejected without Mohamed approval.
- Screen-local fixes only: rejected because repeated UI bugs will return.

## Decision 7: Localization must be wired before broad text migration

**Decision**: First connect `AppLocalizations`, selected locale, and RTL/LTR theme behavior, then migrate hardcoded strings screen by screen.

**Rationale**: Migrating strings before the app consumes localization would not change user-visible behavior.

**Alternatives considered**:

- Translate every string first: rejected because it delays visible correctness.
- Keep mixed Arabic/English labels: rejected as poor MENA UX.

## Decision 8: Tests need a shared app harness

**Decision**: Widget tests for screens that require auth/blocs/repositories should use a shared test harness.

**Rationale**: Current failures show screens are tested without required providers. A harness prevents repeated setup mistakes.

**Alternatives considered**:

- Patch each failing test individually: rejected because provider setup duplication will keep growing.

