# Feature Specification: Entry Quota And Rewarded Ads

**Feature Branch**: `032-entry-quota-rewarded-ads`

**Created**: 2026-06-02

**Status**: Draft

**Input**: User description: "Each account should get 3 AI expense entries, 5 normal entries, rewarded ads for more manual or AI entries, and remaining ads as banners or inline ads between expenses."

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/skill-matcher.json`
- Relevant monetization, AI entry, and expense save files in `lib/`

**Skills used**:

- `second-agent-solution-review`: reviewed the quota and ads plan with a read-only second agent before this Spec Kit plan.
- `speckit-specify`: turned Mohamed's monetization request into a product specification.
- `speckit-plan`: produced implementation structure, contracts, data strategy, and verification plan.
- `speckit-tasks`: produced dependency-ordered implementation tasks.

**Scope guard**: This is a production Flutter expense tracker. Production app-owned financial data stays local-only. This feature may use local quota storage, ads, purchase/premium state, and AI gateway quota protection. It must not write expenses, categories, wallets, budgets, goals, subscriptions, settings, or AI history to Firestore, PostgreSQL, or VPS sync.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Free Daily Entry Balances (Priority: P1)

As a free user, I want to see how many expense entries I still have today so I can add expenses without being surprised by a blocked save.

**Why this priority**: The app is an expense tracker. A quota must be clear before it blocks a core action.

**Independent Test**: Open manual and AI add screens as a free user, confirm remaining daily entries are visible, save within the daily allowance, then confirm the balance updates only after successful saves.

**Acceptance Scenarios**:

1. **Given** a free local account with 5 normal entries remaining, **When** the user saves one manual expense successfully, **Then** the normal entry balance becomes 4.
2. **Given** a free local account with 3 AI entries remaining, **When** the user saves one expense from the AI text screen successfully, **Then** the AI entry balance becomes 2.
3. **Given** a save fails because local persistence failed, **When** the app shows an error, **Then** no quota balance is consumed.
4. **Given** the app is premium, **When** the user saves manual or AI expenses, **Then** quota does not block the save.

---

### User Story 2 - Rewarded Ads For Extra Entries (Priority: P1)

As a free user who reached today's limit, I want to choose a rewarded ad and receive more entries only after the ad completes.

**Why this priority**: The requested monetization model depends on rewarded ads. Fake rewards or unclear rewards would break trust and policy compliance.

**Independent Test**: Exhaust a quota, open the reward sheet, complete a fake verified rewarded-ad callback in a focused test, and confirm the correct balance is added once.

**Acceptance Scenarios**:

1. **Given** normal entries are exhausted, **When** the user completes a rewarded manual-entry ad, **Then** 5 extra normal entries are added for today.
2. **Given** AI entries are exhausted, **When** the user completes a rewarded AI-entry ad, **Then** 2 complete AI entries are added for today.
3. **Given** the ad provider is unavailable, skipped, failed, or dismissed before reward, **When** the user returns to the app, **Then** no entries are added.
4. **Given** the same rewarded-ad callback is delivered twice, **When** the app processes it, **Then** credit is granted only once.

---

### User Story 3 - Non-Blocking Banner And Inline Ads (Priority: P2)

As a free user, I can see non-blocking ads without ads interfering with typing, saving, navigation, or the add button.

**Why this priority**: Banner revenue is useful, but accidental clicks and blocked expense entry damage the app experience.

**Independent Test**: Open Home and Expenses list with ads available and unavailable. Confirm ad slots appear only in safe positions and disappear for premium users.

**Acceptance Scenarios**:

1. **Given** a free user with an available ad provider and consent, **When** the user opens Home, **Then** a safe non-interactive banner area can appear without covering navigation or the add button.
2. **Given** the Expenses list has at least 6 expenses, **When** inline ads are enabled, **Then** an inline ad can appear after a safe row interval and never replace an expense row.
3. **Given** the user is typing, parsing AI text, or saving an expense, **When** ads are evaluated, **Then** no ad interrupts that flow.
4. **Given** the user is premium, **When** any ad placement is evaluated, **Then** no ad is shown.

---

### User Story 4 - Premium Removes Ads And Limits (Priority: P3)

As a premium user, I want no ads and no free-tier quota interruption.

**Why this priority**: Premium must have a clear value and must not accidentally show ads.

**Independent Test**: Set local entitlement to premium in tests, open affected screens, and confirm no ad or quota-blocking sheet appears.

**Acceptance Scenarios**:

1. **Given** premium entitlement is active, **When** the user saves manual or AI expenses, **Then** quota does not block the flow.
2. **Given** premium entitlement is active, **When** Home or Expenses list is opened, **Then** banner and inline ads are hidden.
3. **Given** premium entitlement becomes inactive, **When** the app reloads monetization state, **Then** free-tier quotas and ads apply again.

### Edge Cases

- The user taps Save multiple times quickly.
- The user completes an ad, then the app is killed before the UI refreshes.
- The ad callback is repeated by the SDK.
- The local quota store cannot load or save.
- The device date changes while the app is running.
- The app runs with no Firebase user, because financial data is local-only.
- The AI gateway rejects a parse request for its own server-side quota while local AI save credits remain.
- The AI screen creates a local draft without a gateway call; saving it still counts as an AI entry because the user used AI entry.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST maintain a daily local quota for each stable local account/device profile.
- **FR-002**: Free users MUST receive 5 normal manual entries per day.
- **FR-003**: Free users MUST receive 3 complete AI expense entries per day.
- **FR-004**: A manual expense save MUST consume 1 normal entry only after the expense is saved successfully.
- **FR-005**: An AI expense save MUST consume 1 AI entry only after the expense is saved successfully.
- **FR-006**: AI entries MUST NOT be blocked by a second normal-entry quota after the user has AI credit for that save.
- **FR-007**: The app MUST show remaining entry counts before or near the relevant save action.
- **FR-008**: When normal entries are exhausted, the app MUST offer a clear rewarded-ad option that grants 5 extra normal entries for the current day after verified completion.
- **FR-009**: When AI entries are exhausted, the app MUST offer a clear rewarded-ad option that grants 2 extra complete AI entries for the current day after verified completion.
- **FR-010**: The app MUST NOT grant entries for an unavailable, failed, dismissed, skipped, or unverified ad.
- **FR-011**: The app MUST prevent duplicate quota consumption and duplicate reward grants from double taps or repeated callbacks.
- **FR-012**: Premium users MUST not see ads and MUST not be blocked by free-tier entry quotas.
- **FR-013**: Banner and inline ads MUST be disabled during expense entry, saving, AI typing, and AI parsing.
- **FR-014**: Inline ads MUST appear only in safe list positions and must not replace, hide, or reorder real expense data.
- **FR-015**: The AI gateway MAY enforce AI request quota and abuse protection, but the app MUST NOT upload financial app data to cloud storage for this feature.
- **FR-016**: If the local quota store fails, the app MUST show a safe unavailable/error state instead of pretending a save or reward succeeded.
- **FR-017**: The app MUST keep Arabic RTL and English LTR layouts usable for quota labels, reward sheets, and ad placeholders.
- **FR-018**: The app MUST keep existing rule that ads never interrupt `expenseEntry`, `expenseSave`, `aiTyping`, or `aiParsing`.

### Key Entities

- **Local Account Scope**: Stable local identity used to store quota counters when no cloud login exists.
- **Daily Entry Quota**: The daily balance for normal manual entries.
- **Daily AI Entry Quota**: The daily balance for complete AI expense saves.
- **Reward Grant**: A verified ad reward event that adds entries once.
- **Ad Placement**: A named location where an ad may be requested, such as home banner, expenses inline, rewarded normal entries, or rewarded AI entries.
- **Premium Entitlement**: Local snapshot of paid status that hides ads and bypasses free quotas.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A free user can save exactly 5 manual expenses per day before seeing a quota sheet.
- **SC-002**: A free user can save exactly 3 AI-created expenses per day before seeing an AI quota sheet.
- **SC-003**: A completed rewarded manual-entry ad adds exactly 5 normal entries and never more than once for the same reward event.
- **SC-004**: A completed rewarded AI-entry ad adds exactly 2 AI entries and never more than once for the same reward event.
- **SC-005**: Failed saves and failed ads consume or grant 0 entries.
- **SC-006**: Premium users see 0 ads and 0 quota-blocking sheets in the owned screens.
- **SC-007**: Quota checks and local balance updates complete quickly enough that Save does not feel delayed in normal local operation.
- **SC-008**: No owned screen has visible overflow at 360x800, 375x812, or 390x844 in English LTR and Arabic RTL.

## Assumptions

- Quotas are daily, resetting by local calendar day.
- "Account" means stable local account/device profile for this local-only app mode. Firebase UID can help AI gateway quota when present, but manual quotas are local.
- AI gateway request quota protects AI provider cost separately from local AI save quota.
- Rewarded ads require a real ad SDK/provider callback. Placeholder ad services must not grant entries.
- Inline ads start conservatively after every 6 expense rows and do not appear in very short lists.
- Premium purchase/restore remains an entitlement source, but this plan does not require storing financial data on a backend.
