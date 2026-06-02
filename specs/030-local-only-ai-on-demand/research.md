# Research: Local Only With AI On Demand

## Decision 1: App-owned data is local-only

**Decision**: Use on-device persistent storage as the only production data store for expenses, categories, budgets, wallets, goals, subscriptions, settings, and AI history.

**Rationale**: Mohamed wants to avoid monthly backend operations and keep the product small. Local-only reduces server cost, sync complexity, privacy risk, and maintenance.

**Alternatives considered**:

- Firestore primary: rejected because it keeps cloud database dependency and ongoing rules/index maintenance.
- PostgreSQL primary: rejected for now because it adds VPS uptime, migrations, monitoring, backups, and sync support.
- Local-first with server sync: useful later, but more complexity than needed for the current product size.

## Decision 2: Server/AI is called only by explicit user action

**Decision**: No background upload or sync. Network calls for AI happen only when the user explicitly asks for AI advice or another AI action.

**Rationale**: This matches the privacy and simplicity goal while still allowing premium AI features.

**Alternatives considered**:

- Background AI recommendations: rejected because it would upload data without a direct user action and create waiting/cost issues.
- Server-generated monthly stories: rejected for now; local monthly stories can be generated from local summaries.

## Decision 3: AI advice receives a compact summary, not raw transactions

**Decision**: Build a small financial summary locally and send only aggregate numbers, trend flags, top categories, budget status, subscriptions totals, and non-sensitive labels where needed.

**Rationale**: This makes requests faster, cheaper, and more private. It also keeps payloads predictable even when the user has years of expenses.

**Alternatives considered**:

- Send all transactions: rejected because it is slow and privacy-heavy.
- Send only current month total: too weak for good advice.

## Decision 4: Precompute and cache the AI summary

**Decision**: Maintain a local `AdviceSummary` that updates after expense/budget/subscription changes. The AI button sends the cached summary immediately.

**Rationale**: The slow part should not happen after the user taps Ask AI. If the summary is already prepared, request creation is near-instant.

**Alternatives considered**:

- Compute summary on every AI tap: acceptable for tiny datasets, but poor for heavy users and violates the "very fast" requirement.

## Decision 5: Local advice appears before AI advice

**Decision**: Advice screen renders deterministic local tips first, then optionally upgrades/adds AI advice after the AI response.

**Rationale**: The user always sees value instantly and is not blocked by network, quota, or provider issues.

**Alternatives considered**:

- Empty loading screen until AI returns: rejected because it makes the app feel slow.

## Decision 6: Premium and ads do not require an app data backend

**Decision**: Use app-store purchase state and local entitlement cache for premium gating. Ads use local ad policy and SDK state. AI gateway may enforce operational quotas but must not store full financial data.

**Rationale**: This supports monetization without making PostgreSQL/Firestore a product dependency.

**Alternatives considered**:

- Server-owned subscription database: stronger fraud protection, but not needed for the initial small-app approach.

## Decision 7: Firestore/PostgreSQL code becomes disabled for production app data

**Decision**: Keep legacy repositories only as code that can be removed or guarded later, but production default must not instantiate cloud financial repositories.

**Rationale**: This avoids accidental writes and makes the architecture clear for future agents.

**Alternatives considered**:

- Delete all Firestore/VPS code immediately: possible but risky and larger than the first migration step. Better to switch default and add guardrails/tests first.
