# Feature Specification: Local Only With AI On Demand

**Feature Branch**: `030-local-only-ai-on-demand`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Mohamed wants the app data to be local-only to avoid monthly backend maintenance for a small app. The app may contact the server/AI only when the user explicitly asks for AI advice or an AI action. Advice requests must be very fast and must not make the user wait for large data upload.

## Mandatory Agent Prerequisites *(mandatory)*

Completed before drafting this specification:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Loaded relevant Spec Kit skills.

**Skills used**:

- `speckit-specify`: define the local-only product architecture and user-facing behavior.
- `speckit-plan`: produce implementation planning artifacts.
- `speckit-tasks`: produce dependency-ordered execution tasks.

**Scope guard**: This feature changes the product data architecture. App-owned financial data must stay on the device. Server communication is allowed only for explicit AI actions, ads, purchase/entitlement SDKs, and operational quota/abuse checks that do not store full financial data.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Track Money Locally Without Account Or Cloud (Priority: P1)

As a user, I want to add and view my expenses without signing in or depending on a cloud database, so the app feels fast and private.

**Why this priority**: This is the core architectural decision. If app data still depends on Firestore or PostgreSQL, the product does not match Mohamed's requested direction.

**Independent Test**: Install the app, skip login if available, add expenses, close/reopen the app, and confirm data remains on the same device without Firestore/PostgreSQL writes.

**Acceptance Scenarios**:

1. **Given** a fresh app install, **When** the user adds an expense, **Then** the expense is saved locally on the device.
2. **Given** the app has no internet, **When** the user adds, edits, filters, or reviews expenses, **Then** core tracking still works.
3. **Given** no cloud account is connected, **When** the app restarts, **Then** local expenses, categories, settings, budgets, wallets, and goals remain available.

---

### User Story 2 - Get Instant Local Advice (Priority: P1)

As a user, I want useful advice to appear immediately from local data, so I get value without waiting for AI.

**Why this priority**: Local-only apps should not feel blocked by the network. Local advice also works for free users and offline users.

**Independent Test**: Create local expenses and budgets, open advice, and confirm local tips appear instantly without network.

**Acceptance Scenarios**:

1. **Given** the user has spending data, **When** the advice screen opens, **Then** local tips appear without a server request.
2. **Given** the user is offline, **When** the user opens advice, **Then** the app shows local tips and an honest offline state for AI advice.
3. **Given** the user changes expenses or budgets, **When** the advice screen refreshes, **Then** local tips reflect the latest local data.

---

### User Story 3 - Ask AI Only On Demand With Tiny Payload (Priority: P1)

As a user, I want AI advice only when I press a button, and I do not want the app uploading all my transactions.

**Why this priority**: This protects privacy, reduces cost, and makes the AI request fast.

**Independent Test**: Tap "Ask AI" and inspect the outgoing request shape in tests to confirm it contains a compact summary only, not raw transaction lists or descriptions.

**Acceptance Scenarios**:

1. **Given** the user taps Ask AI, **When** the app sends a request, **Then** it sends a compact spending summary only.
2. **Given** the user has many expenses, **When** the AI request is created, **Then** payload size stays below the agreed budget.
3. **Given** the AI request is slow, **When** the timeout is reached, **Then** the app keeps local advice visible and shows a retry option.

---

### User Story 4 - Keep Premium And Ads Without App Database (Priority: P2)

As the app owner, I want subscriptions and ads to work without a full backend database, so the app can stay simple and cheap to maintain.

**Why this priority**: Mohamed plans AI-driven premium features and ads, but does not want a monthly backend maintenance burden.

**Independent Test**: Simulate free and premium entitlement states and confirm ads show/hide and AI limits apply without Firestore/PostgreSQL data storage.

**Acceptance Scenarios**:

1. **Given** a free user, **When** they use the app, **Then** ads may show in non-blocking placements.
2. **Given** a premium user, **When** premium entitlement is active, **Then** ads are hidden and premium AI limits apply.
3. **Given** purchase state cannot be checked, **When** the app opens, **Then** it uses the last known local entitlement with a clear restore path.

---

### User Story 5 - Preserve User Trust About Data Loss (Priority: P2)

As a user, I want the app to clearly explain local-only storage, so I understand that deleting the app or losing the phone can remove my data.

**Why this priority**: Local-only is simpler and private, but the app must be honest about data durability.

**Independent Test**: Open settings/onboarding and confirm local-only data wording is visible where appropriate.

**Acceptance Scenarios**:

1. **Given** the app uses local-only storage, **When** the user opens settings, **Then** the app explains that financial data is stored on this device.
2. **Given** backup/export has been removed or disabled, **When** the user looks for cloud sync, **Then** the app does not imply cloud backup exists.

### Edge Cases

- Device storage is full.
- Local database migration fails.
- User has thousands of expenses.
- AI advice request times out.
- AI gateway rejects quota or auth.
- User is offline.
- User changes locale between Arabic and English.
- Premium status is unknown.
- Ads SDK fails to load.
- User deletes the app and expects restored data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: App-owned financial data MUST be stored locally on the device as the primary and only production data store.
- **FR-002**: The app MUST NOT write expenses, budgets, wallets, categories, settings, goals, subscriptions, or AI history to Firestore or PostgreSQL in this local-only mode.
- **FR-003**: The app MUST work for core tracking without login and without internet.
- **FR-004**: The app MUST keep Firebase/Auth/cloud identity out of the core tracking requirement; if identity is used for AI gateway protection, it must not become a financial data store.
- **FR-005**: The advice screen MUST show local deterministic tips before any AI call.
- **FR-006**: AI advice MUST be requested only after explicit user action.
- **FR-007**: AI advice requests MUST send a compact aggregated summary, not raw transactions, merchant names, descriptions, receipt text, or full history by default.
- **FR-008**: The AI advice payload MUST stay below 10 KB for normal accounts and below 25 KB for very large local datasets.
- **FR-009**: The local summary used for AI MUST be precomputed or cached so request preparation usually completes under 150 ms on a mid-range phone.
- **FR-010**: The app MUST keep local advice visible if the AI request fails, times out, or is blocked by quota.
- **FR-011**: Ads MUST be non-blocking for core expense entry.
- **FR-012**: Premium entitlement MUST hide ads and unlock premium AI limits/features without requiring app financial data to be stored on the app server.
- **FR-013**: AI provider keys MUST remain server-side only.
- **FR-014**: The app MUST clearly communicate local-only storage and data-loss risk.

### Key Entities *(include if feature involves data)*

- **Local Financial Store**: On-device storage for all app-owned financial records.
- **Local Advice Summary**: Aggregated metrics computed locally from financial data.
- **AI Advice Request**: Small on-demand payload sent to the AI gateway.
- **Local Advice Cache**: Last local/AI advice shown without re-uploading data.
- **Premium Entitlement Snapshot**: Local view of app-store purchase state.
- **Ad Policy State**: Local state that controls when ads may appear.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Core add/edit/list/report flows work with airplane mode enabled.
- **SC-002**: No app-owned financial data write goes to Firestore/PostgreSQL in local-only mode.
- **SC-003**: Local advice renders in under 300 ms after opening the advice screen for a typical user.
- **SC-004**: AI request body is below 10 KB for typical users and below 25 KB for heavy users.
- **SC-005**: AI request preparation completes under 150 ms for typical users because the summary is precomputed/cached.
- **SC-006**: AI timeout/failure leaves the user with useful local advice and a retry option.
- **SC-007**: Premium users see no ads in app screens covered by the ad policy.

## Assumptions

- Local storage uses the existing Drift/SQLite direction or an equivalent persistent local store.
- Cloudflare AI Gateway remains the server-side AI boundary.
- Firebase/Auth may remain only for optional AI quota protection or existing login screens until separately removed, but it must not own financial data.
- App Store / Google Play purchase APIs remain the source of truth for premium entitlement.
- Export/import/cloud backup is out of scope unless Mohamed re-adds it later.
