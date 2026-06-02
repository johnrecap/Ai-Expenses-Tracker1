# Feature Specification: Core Stability Repairs

**Feature Branch**: `031-core-stability-repairs`

**Created**: 2026-06-01

**Status**: Draft

**Input**: User description: "Make full Spec Kit plans for all agreed repairs: local storage reliability, monthly budget correctness, wallet behavior, AI privacy cleanup, worker guardrails, notifications, settings language/currency, honest Home data, AI expense UI, and release readiness."

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent MUST:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Search `.agents/skills/` and `.agent/skills/` for relevant skills.
- Load matching `SKILL.md` files and follow them.

**Skills used**:

- `speckit-specify`: create the product-facing repair specification.
- `speckit-plan`: create the implementation plan and design artifacts.
- `speckit-tasks`: create ordered, executable tasks.
- `production-flutter-app-guardrails`: enforce full production app scope, local-only financial data, explicit AI, and responsive RTL/LTR rules.
- `dart-add-unit-test`: shape focused repository and service tests.
- `flutter-add-widget-test`: shape focused UI/widget verification.
- `dart-run-static-analysis`: define touched-file analyzer checks.

**Scope guard**: This is a production Flutter app covering the full product surface. Production app-owned financial data remains local-only by default. Firestore, PostgreSQL, and VPS sync remain legacy or future infrastructure unless Mohamed approves a separate backend plan.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Trust Local Saves (Priority: P1)

As a user, when I add or edit financial data, the app must only show success after the data is really saved locally and ready to appear again after restart.

**Why this priority**: This protects user money records. UI polish or AI features cannot be trusted if saved expenses, settings, or budgets can disappear or load as empty.

**Independent Test**: Save an expense/settings record, restart the local store immediately, and confirm the saved data is still returned. Simulate a failed local save and confirm the app shows failure instead of success.

**Acceptance Scenarios**:

1. **Given** existing local records, **When** the app opens, **Then** screens read the existing records instead of temporary empty defaults.
2. **Given** local saving fails, **When** the user saves an expense, **Then** the app shows a clear failure and does not claim the expense was saved.
3. **Given** local settings already exist, **When** the app starts, **Then** default settings are not written over the existing settings before loading completes.

---

### User Story 2 - Correct Monthly Money Numbers (Priority: P1)

As a user, I must see the correct monthly budget and wallet balance so I can trust the financial numbers shown in Home, budgets, reports, and wallet screens.

**Why this priority**: A finance app with wrong monthly budget or wallet balance gives harmful guidance, even if the UI looks good.

**Independent Test**: Store budgets for multiple months and verify each month returns only its own budget. Create, edit, and delete wallet-linked expenses and verify wallet behavior follows the chosen rule.

**Acceptance Scenarios**:

1. **Given** May and June budgets exist, **When** the user views June, **Then** only June's budget is used.
2. **Given** an expense is linked to a wallet and wallet balance is automatic, **When** the expense is created, edited, or deleted, **Then** the wallet balance updates consistently.
3. **Given** wallet balance is intentionally manual, **When** a user adds a wallet-linked expense, **Then** the app clearly avoids implying the balance was automatically changed.

---

### User Story 3 - Keep AI Private And Explicit (Priority: P1)

As a user, AI must only contact the server when I deliberately ask it to, and advice must send a compact summary rather than raw expense details.

**Why this priority**: Privacy and trust boundaries matter before feature polish. Legacy AI paths must not accidentally upload data or use broad prompt-based advice.

**Independent Test**: Open AI advice without pressing the request button and confirm no remote request happens. Press the request button and confirm the payload is compact and does not contain raw expense lists, merchant names, descriptions, or receipt text.

**Acceptance Scenarios**:

1. **Given** the user opens an AI advice screen, **When** they do not press the AI action, **Then** no server request is made.
2. **Given** the user presses the advice button, **When** the request is prepared, **Then** only a compact summary is sent.
3. **Given** legacy AI services still exist in the codebase, **When** production screens are used, **Then** those services are not reachable for remote advice.

---

### User Story 4 - Reliable Settings And Notifications (Priority: P2)

As a user, changing language, currency, and notification settings should do exactly what I asked without restarting onboarding or leaving old reminders active.

**Why this priority**: Settings are high-frequency trust features. They must be predictable and should not accidentally reset other choices.

**Independent Test**: Change language while keeping currency unchanged, change currency while keeping language unchanged, and disable notifications while verifying scheduled reminders are cancelled.

**Acceptance Scenarios**:

1. **Given** the app is Arabic and uses USD, **When** the user changes language, **Then** the currency remains USD.
2. **Given** the user changes currency from Settings, **When** the change is saved, **Then** the onboarding flow does not reopen.
3. **Given** a daily reminder is scheduled, **When** the user disables notifications, **Then** the reminder is cancelled and does not fire again.

---

### User Story 5 - Honest Home And Clear AI Expense Entry (Priority: P2)

As a user, Home must not show fake financial insights, and AI expense entry must guide me to review the parsed expense before saving.

**Why this priority**: Fake financial cards damage trust. AI entry is a core workflow and must be easy for beginners.

**Independent Test**: Open Home with no data and confirm no fake spending trend or fake bills appear. Enter a long AI expense sentence and confirm the input and Save flow remain usable on small Arabic and English screens.

**Acceptance Scenarios**:

1. **Given** the user has no spending trend data, **When** Home opens, **Then** static claims like "Spending is down 12%" do not appear.
2. **Given** the AI parser produces missing fields, **When** the user tries to save, **Then** Save is disabled or a clear field-level message explains what is missing.
3. **Given** Arabic text and a narrow phone width, **When** the AI expense entry is used, **Then** text stays inside its field and actions remain reachable.

---

### User Story 6 - Prepare For Release Without Blocking Core Repairs (Priority: P3)

As the product owner, I need release blockers tracked separately so stability work is not delayed by ads, purchases, signing, or legal readiness.

**Why this priority**: Release readiness matters, but core financial correctness and privacy must come first.

**Independent Test**: Review the release checklist and confirm ads, purchases, signing, analytics consent, and privacy policy cannot be marked production-ready without explicit verification.

**Acceptance Scenarios**:

1. **Given** ads or purchases are not connected, **When** the app displays premium messaging, **Then** it does not claim a successful production purchase flow.
2. **Given** a release build is requested, **When** signing is not configured, **Then** the release checklist blocks the release.
3. **Given** analytics or ads are enabled, **When** the release checklist is run, **Then** consent and privacy policy checks are required.

### Edge Cases

- Local database loading is slow or fails on app start.
- A save succeeds in memory but fails on disk.
- Multiple budgets exist for different months.
- A wallet-linked expense is edited to a different wallet or deleted.
- Legacy AI code remains in the repo but should not be reachable from production screens.
- AI parse and receipt actions receive very large input.
- Notification permission is denied after the user tries to enable reminders.
- Long Arabic category names, wallet names, or AI text run on a 360px-wide screen.
- Release work is attempted before core local data and AI privacy checks pass.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST wait for local financial data loading before treating missing records as empty/default state.
- **FR-002**: The app MUST report local save failures to the user instead of showing success before durable save completion.
- **FR-003**: The app MUST prevent default settings from overwriting existing settings during startup loading.
- **FR-004**: The app MUST return monthly budgets by requested month and year.
- **FR-005**: The app MUST define one wallet balance rule for expenses and apply it consistently across create, edit, and delete.
- **FR-006**: AI advice MUST only make remote requests after an explicit user action.
- **FR-007**: AI advice MUST send compact summaries only; raw expense lists, merchant names, descriptions, receipt text, and full histories are forbidden by default.
- **FR-008**: Legacy AI prompt-based advice paths MUST be isolated from production screens or converted to the compact on-demand flow.
- **FR-009**: AI gateway validation MUST reject unsafe or excessive request payloads and avoid logging raw user AI inputs or receipt images.
- **FR-010**: Disabling notifications MUST cancel app-managed scheduled reminders.
- **FR-011**: Language and currency changes from Settings MUST be handled inside Settings without reopening onboarding.
- **FR-012**: Home MUST not display fake/static financial insight cards as real data.
- **FR-013**: AI expense entry MUST keep text inside input boundaries and keep Save reachable and clear on narrow Arabic and English screens.
- **FR-014**: The plan MUST keep release readiness work separate from core stability work.
- **FR-015**: All implementation work MUST use focused tests and touched-file analysis before broader checks.

### Key Entities *(include if feature involves data)*

- **Local Store Readiness**: Whether saved local data has loaded and can be safely read.
- **Durable Save Result**: Success or failure after a local write is actually persisted.
- **Monthly Budget**: Budget scoped to a specific month and year.
- **Wallet Balance Policy**: Product rule describing whether expenses automatically affect wallet balances.
- **AI Advice Request**: Explicit user-triggered request using compact summary only.
- **Notification Schedule State**: Whether app-managed reminders are scheduled or cancelled.
- **Settings Preference**: Language, currency, payment method, and notification choices changed outside onboarding.
- **Home Insight Card**: A user-facing financial card that must be backed by real data or hidden.
- **Release Readiness Item**: Non-core production blocker such as signing, purchases, ads, consent, or privacy policy.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In focused startup tests, existing local settings and expenses are returned on first read 100% of the time after store creation.
- **SC-002**: In focused save-failure tests, failed local writes show failure 100% of the time and never emit a false success state.
- **SC-003**: Budget tests with at least two different months return the requested month correctly in 100% of cases.
- **SC-004**: Wallet behavior tests cover create, edit, delete, and wallet-change cases with no balance drift.
- **SC-005**: AI advice screen tests prove no remote request occurs before explicit user action.
- **SC-006**: AI advice payload tests prove no raw expense descriptions, merchant names, receipt text, or transaction lists are sent by default.
- **SC-007**: Settings tests prove language and currency can each change independently without resetting the other.
- **SC-008**: Notification tests prove disabling reminders cancels app-managed scheduled reminders.
- **SC-009**: Home tests prove fake financial claims are absent when no real data supports them.
- **SC-010**: AI expense entry widget tests pass on 360px-wide Arabic and English layouts without overflow.

## Assumptions

- The app remains local-only for financial app data.
- The preferred wallet behavior is automatic balance adjustment when an expense is linked to a wallet, unless implementation risk forces a temporary manual-balance label.
- AI parse text and receipt scan remain explicit AI actions; the guardrail is preventing unexpected history upload, excessive payloads, and raw logging.
- Export/import remains removed/out of scope.
- Release readiness items are planned here but executed only after core stability and privacy checks pass.
