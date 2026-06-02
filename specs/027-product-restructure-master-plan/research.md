# Research: Product Restructure Master Plan

## Decision 1: Continue Existing App, Do Not Restart

**Decision**: Restructure the current Flutter app in phases rather than rebuilding from zero.

**Rationale**: The app already has useful foundations: Firebase Auth, repositories, Firestore, Cloudflare AI Gateway, local data package, BLoC/Cubit, routing, many screens, and recent Smart Add work. Restarting would lose working pieces and delay product review.

**Alternatives considered**:

- Full rewrite: rejected because the main risk is inconsistent wiring and partial flows, not absence of a codebase.
- UI-only prototype: rejected because Mohamed requires every visible feature to work without mock data.

## Decision 2: Fix First-Run And Real Data Before UI Polish

**Decision**: The first phase after planning must stabilize startup, onboarding, localization, settings persistence, and no-mock-data guardrails.

**Rationale**: If users can skip onboarding or the app uses fake data, every later screen becomes misleading.

**Alternatives considered**:

- Start with visual redesign: rejected because it would make broken flows look nicer without making them true.
- Start with AI: rejected because AI depends on categories, wallets, settings, and expense save behavior.

## Decision 3: One Add Entry, Multiple Honest Methods

**Decision**: Home should keep one Add button that opens Quick Add, AI Text, and Receipt only when receipt is real.

**Rationale**: Recent Smart Add work already removed stacked buttons. The next step is making each choice fully honest and connected.

**Alternatives considered**:

- Separate buttons for every add method: rejected because it confused users and duplicated AI meanings.
- Hide AI until perfect: rejected because AI text is a core differentiator and already has a secure gateway foundation.

## Decision 4: AI Gateway Is The Only Production AI Path

**Decision**: All production AI screens must use Cloudflare AI Gateway or show an empty/unavailable state.

**Rationale**: Mobile code must not carry AI secrets. The gateway already supports authenticated requests and quota. Mock AI service must not be visible as real AI.

**Alternatives considered**:

- Keep `MockAiService` as fallback: rejected for production user-facing screens because it creates false financial advice.
- Direct provider calls from Flutter: rejected by security rules.

## Decision 5: Monthly Means Current Or Selected Period Everywhere

**Decision**: Home, reports, budgets, category budgets, and monthly story must share the same period model.

**Rationale**: The review found "This Month" screens using all-time totals. Finance apps must make period meaning consistent.

**Alternatives considered**:

- Screen-local date filters: rejected because totals would drift between screens.
- All-time dashboard: allowed only if explicitly labeled as all-time.

## Decision 6: Subscription Is Not The Same As Recurring Expense

**Decision**: Subscription must have its own meaning or a clear type flag; recurring expense remains a broader concept.

**Rationale**: Rent, installments, and subscriptions have different user expectations and alerts.

**Alternatives considered**:

- Show all active recurring items as subscriptions: rejected because it mislabels financial commitments.

## Decision 7: Scoped Verification Only For Each Phase

**Decision**: Each phase should run scoped analyzer/tests for touched `lib`, `packages/expense_repository/lib`, server/worker paths, and focused tests. Full-project failures should be documented separately unless the phase owns them.

**Rationale**: The repo has pre-existing unrelated analyzer/test failures. Broad cleanup would block focused progress and mix responsibilities.

**Alternatives considered**:

- Full `flutter analyze` every phase: rejected for this restructuring plan because current unrelated failures are known and already documented.

## Decision 8: Backend Contracts Must Match App Serialization Before New UI Claims

**Decision**: Firestore rules, repository serialization, server sync contracts, and AI gateway contracts must be aligned before screens claim the behavior is production-ready.

**Rationale**: Valid app writes can currently be rejected by rules, and VPS sync has push/pull contract mismatch.

**Alternatives considered**:

- Patch UI first and backend later: rejected because users would still hit save/sync failures.
