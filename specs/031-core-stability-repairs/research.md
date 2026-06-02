# Research: Core Stability Repairs

## Decision 1: Fix Local Data Reliability Before UI Polish

**Decision**: The first implementation slice must fix local store readiness and durable write results.

**Rationale**: If the app can read before local data finishes loading or report success before SQLite persistence completes, every screen can show false empty states or lose records after restart. This risk affects expenses, settings, reports, budgets, wallets, and AI summaries.

**Alternatives considered**:

- Fix Home and AI entry UI first: rejected because it improves the surface while leaving data trust broken.
- Run a full repo refactor first: rejected because focused local-store tasks are safer and match project agent rules.

## Decision 2: Budget Must Be Month-Year Scoped

**Decision**: Monthly budget reads and watches must filter by requested month/year.

**Rationale**: Returning the first available budget makes Home, reports, budget warnings, and AI advice use the wrong month. This is a direct financial correctness bug.

**Alternatives considered**:

- Keep a single global budget: rejected because the app already models monthly budgets.
- Fix only the UI display: rejected because services and reports would still use wrong data.

## Decision 3: Wallet Balance Behavior Must Be Explicit

**Decision**: Preferred behavior is automatic balance adjustment when an expense is linked to a wallet. If implementation risk is too high for the first patch, wallet balances must be clearly treated as manual/metadata until automatic adjustment is complete.

**Rationale**: Current behavior can attach a wallet to an expense without changing wallet balance. That makes wallet totals untrustworthy. A partial automatic implementation is worse because edits/deletes could create balance drift.

**Alternatives considered**:

- Keep current silent metadata behavior: rejected because users interpret wallet balances as real balances.
- Adjust only on create: rejected because edits and deletes would create inconsistent totals.

## Decision 4: AI Privacy Cleanup Comes Before UI Improvements

**Decision**: Production AI advice must use the new explicit on-demand compact-summary flow only. Legacy prompt-based advice paths must be isolated or converted before AI UI polish.

**Rationale**: AI privacy is a trust-boundary issue. A legacy path that can send prompt-style advice or auto-call remote AI undermines the local-only decision even if not currently routed.

**Alternatives considered**:

- Leave legacy code because it is not routed today: rejected because future wiring could reintroduce it silently.
- Remove all AI server calls: rejected because explicit AI actions remain part of the product.

## Decision 5: Worker Validation Should Guard Boundaries, Not Block Explicit AI Actions

**Decision**: Advice payloads must reject raw histories and oversized data. Parse text and receipt scan may accept the user's current text/image because those are explicit AI actions, but they need request size, MIME, and logging guardrails.

**Rationale**: The product needs AI text and receipt parsing. The risk is unexpected stored history upload or raw content leakage in logs, not the explicit current input itself.

**Alternatives considered**:

- Ban receipt/text upload entirely: rejected because it removes a requested feature.
- Trust Flutter clients only: rejected because server contracts should protect against bad or future clients.

## Decision 6: Settings Must Own Language And Currency Changes

**Decision**: Settings should use direct pickers/sheets for language and currency instead of reusing onboarding routes.

**Rationale**: Onboarding has defaults and a completion flow. Re-entering it for a single setting can reset unrelated preferences.

**Alternatives considered**:

- Keep onboarding routes and patch defaults: rejected because onboarding still carries first-run semantics and navigation risks.
- Add separate full screens: acceptable later, but a sheet/dialog is the smallest safe product change.

## Decision 7: Notification Disable Must Cancel Scheduled Reminders

**Decision**: Turning off notifications must cancel app-managed scheduled reminders, not just save a disabled preference.

**Rationale**: Users expect the setting to control real behavior. Leaving existing schedules active violates that expectation.

**Alternatives considered**:

- Only save settings and let future scheduler skip reminders: rejected because already scheduled notifications may still fire.

## Decision 8: Home Must Prefer Empty/Unavailable States Over Static Financial Claims

**Decision**: Static financial cards must be removed or backed by real data.

**Rationale**: Claims like "spending is down" or "bills due" are financial guidance. If they are not real, they are misleading.

**Alternatives considered**:

- Rename them as examples: rejected because production Home should not show demo finance claims.
- Hide only in Arabic: rejected because the issue is product truth, not localization.

## Decision 9: AI Expense Save Should Follow Review

**Decision**: AI expense entry should make the review step clear before save. Save should appear after validated fields or be disabled until required fields are ready.

**Rationale**: Beginners can parse an expense and press Save before understanding missing fields. Better ordering reduces confusion and support issues.

**Alternatives considered**:

- Keep current order because validation exists: rejected because snackbar-only validation is not enough for a primary workflow.

## Decision 10: Release Readiness Is Separate From Core Stability

**Decision**: Ads, purchases, signing, analytics consent, and privacy policy are tracked but executed after core data and AI trust repairs.

**Rationale**: Release readiness matters, but it should not block or distract from correcting financial data and privacy behavior.

**Alternatives considered**:

- Connect monetization now: rejected because core product trust is not yet stable.
- Ignore release items: rejected because they are future blockers and should be explicit.
