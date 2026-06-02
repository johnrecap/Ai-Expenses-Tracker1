<!--
Sync Impact Report
Version change: 2.2.0 -> 2.3.0
Added sections:
- Mandatory Discussion And Second Review
Updated sections:
- Mandatory Agent Workflow: Added Mohamed discussion and second-agent review gate for non-trivial work.
Previous 2.1.0 changes:
Added sections:
- Security Layer (App Lock: PIN + Biometric)
- Account Management (Profile, Deletion, Reauthentication)
- Full Settings (9 sections)
- Monetization (Free/Premium, AdMob-ready)
- AI Services (Voice, Prediction, Mock)
- Backup/Restore
- VPS Architecture Analysis (4 blockers documented)
Updated sections:
- Multi-Backend Support: Documented vpsLocalFirst blockers
- Runtime Modes: Added VPS_API_BASE_URL requirement
Constitution ratified: 2026-05-28
Last Amended: 2026-06-01
-->

# AI Expenses Tracker Constitution

## Core Principles

### I. Read Project Law First

Every agent MUST read `AGENTS.md` and this constitution before planning,
editing files, generating code, running broad installs, or changing project
structure. These files define the active project law. If a user request appears
to conflict with this constitution, the agent MUST state the conflict and ask
for explicit scope change before proceeding.

Rationale: This project now supports full production backend integration and a
large set of local skills. Starting without the project law risks architecture
mismatch, duplicated work, or plans that do not match the approved scope.

### II. Skills Before Plans Or Code

Before writing a plan or code, every agent MUST inspect `.agents/skill-matcher.json`
and search the installed skills in `.agents/skills/` and `.agent/skills/` for
relevant workflows. The agent MUST use matching skills when they apply,
especially Spec Kit, Flutter, Dart, UI-from-design, responsive layout,
localization, testing, backend architecture, and tooling-audit skills. If no
relevant skill exists, the agent MUST say that and proceed with the closest
project guidance.

Minimum skill discovery requirements:
- Read `.agents/skill-matcher.json`.
- Search skill names/descriptions using `rg` or an equivalent fast search.
- Load only the `SKILL.md` files relevant to the current task.
- Use `speckit-specify`, `speckit-plan`, and `speckit-tasks` for meaningful
  features before implementation.
- Use Flutter/Dart skills before Flutter code, tests, routing, layout,
  localization, or package changes.
- Use backend/architecture skills before API design, database schema, or sync
  protocol work.

Rationale: Skills are installed project knowledge. They prevent agents from
inventing workflows, skipping Spec Kit, or ignoring known Flutter/Dart best
practices or backend patterns.

### III. Mandatory Discussion And Second Review

Before planning, editing, or running project commands for non-trivial work,
every agent MUST read `AGENTS.md` and this constitution. For non-trivial
changes, the agent MUST discuss the request with Mohamed in Egyptian Arabic
before implementation. The discussion MUST explain the practical goal, expected
screens/files, main risks, and short execution plan.

Non-trivial changes include UI redesigns, navigation changes, storage/database
changes, security/account changes, AI gateway or AI behavior changes, Spec Kit
features, migrations, and changes that touch multiple important files.

Before implementing a non-trivial change, the agent MUST use the
`second-agent-solution-review` skill as a read-only critique loop. The second
agent MUST challenge the proposed solution without editing files. The main
agent MUST summarize accepted objections, rejected objections, and the final
plan for Mohamed.

If the second review changes the plan, expands scope, or exposes a new
material risk, the agent MUST get Mohamed's approval before implementation.
Tiny direct commands, simple answers, and clearly scoped one-line fixes may
proceed without the full second-review loop, but they still MUST obey the
project rules. This principle MUST NOT be used as permission for broad repo
analysis unless Mohamed explicitly asks for it.

Rationale: Mohamed wants fewer rushed changes and fewer hidden assumptions.
This gate forces practical discussion and an independent critique for important
work while keeping small tasks fast.

### IV. Production Flutter App Scope

The current product is a **production-grade Flutter expense tracker** with full
local persistence, AI capabilities, and optional server-side AI protection.

#### Local-Only Production Data Mode

Production app-owned financial data is local-only by default. Expenses,
categories, category aliases, wallets/accounts, transfers, budgets, saving
goals, subscriptions/recurring expenses, settings, local AI history, and local
advice cache MUST be stored on the device and MUST NOT be written to Firestore,
PostgreSQL, or VPS sync in local-only mode.

Network use is allowed for explicit AI actions, ads, purchase/restore checks,
and AI gateway quota/abuse protection. AI advice MUST send only a compact
summary when the user explicitly asks for it; raw transaction lists, merchant
names, expense descriptions, receipt OCR text, and full histories are forbidden
by default.

Allowed architecture:
- Drift/SQLite as the production financial-data store.
- Firebase Authentication only when needed for AI gateway identity/quota
  protection or legacy auth screens; it must not own financial app data.
- Firestore and VPS PostgreSQL only as legacy or future migration code unless a
  separate approved Spec Kit plan changes the local-only decision.
- Cloudflare Worker AI gateway for server-side AI calls and quota/abuse
  protection.
- `flutter_bloc` for state management with `go_router` for navigation.
- Real API calls, local database (Drift/SQLite), persistent storage.
- Push notifications, local auth/biometrics, camera/image picker.
- In-app purchases, ads (AdMob), premium entitlements.
- Localization (EN+AR), RTL/LTR support.

Forbidden by default:
- WebView or HTML rendering packages for UI shortcuts.
- Hardcoded secrets in source code (use dart-define or secure storage).
- Direct AI provider keys in Flutter (must route through gateway).

Rationale: Mohamed selected local-only storage to avoid monthly backend
maintenance for a small app while keeping AI available on demand. This reduces
sync complexity, cloud database cost, and privacy risk.

### V. Spec-driven Full-Stack Implementation

All meaningful work MUST be driven by specs. Plans and tasks MUST cite the
screen inventory, design system, component map, routes, data models, API
contracts, and expected verification. Agents MUST reuse shared components and
design tokens instead of duplicating screen-specific UI. Any proposed new
abstraction MUST remove real duplication or match an existing project pattern.

Each non-trivial task MUST include:
- Why
- Expected result
- Scope and exact file paths
- Inputs and references
- Implementation notes
- Possible bugs
- Fix strategy
- Verification
- Stop condition

Rationale: The project spans frontend, backend, AI infrastructure, and sync
protocols. A spec-driven approach keeps implementation coherent and lets
different agents work without drifting across layers.

### VI. Verification, RTL/LTR, And Responsive Quality

Every implementation batch MUST compile before it is considered complete.
Flutter work MUST be checked with `flutter analyze` and `flutter test` when a
Flutter project exists. UI work MUST be verified at 360x800, 375x812, and
390x844. Arabic RTL and English LTR readiness MUST be considered from the first
batch, including text direction, alignment, icons, navigation, and overflow.

Backend work MUST pass type checking and unit tests where available. API
contracts MUST be validated against spec. Sync protocols MUST be tested for
idempotency, conflict resolution, and offline resilience.

Agents MUST document any command they could not run and why. Visual regressions
such as overflow, clipped Arabic text, duplicated widgets, inconsistent tokens,
or broken bottom sheets block completion. Backend regressions such as data
loss, auth bypass, or sync corruption block completion.

Rationale: Mobile finance interfaces fail quickly when text direction,
viewport size, and repeated components are treated as afterthoughts. Production
backend failures can result in data loss or security issues.

## Project Scope And Source Of Truth

This repository is the planning and implementation workspace for the AI
Expenses Tracker production Flutter app.

Primary source references:
- `stitch_ai_expenses_tracker_pro/`: Google Stitch export folders, screenshots,
  HTML/Tailwind references, and possible assets.
- `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`: design reference.
- `specs/`: all Spec Kit artifacts for planned and implemented features.
- `lib/`: Flutter application source code.
- `packages/expense_repository/`: Repository package; production app-data path
  defaults to local repositories.
- `server/`: VPS backend (Fastify + PostgreSQL + Drizzle ORM), retained as
  legacy/future infrastructure and not the default product data store.
- `functions/`: Firebase Cloud Functions (AI services).
- `workers/ai-gateway/`: Cloudflare Worker AI gateway.
- `docs/`: project documentation, runbooks, and implementation plans.
- `.agents/skills/` and `.agent/skills/`: local agent skills.
- `.agents/skill-matcher.json`: skill matching map.

Detected product surface (25 UI screens):
- Splash/loading
- Onboarding language selection
- Onboarding base currency
- Onboarding notifications
- Login/authentication
- Sign-up
- Home dashboard
- Expenses list + filters
- Add expense (quick, AI text, receipt)
- Edit expense
- Reports main + drilldown + monthly story
- Budgets overview + category budgets + edit
- Saving goals
- Wallets/accounts
- Subscriptions center
- AI advice + AI history + AI assistant sheet
- Settings main

## Mandatory Agent Workflow

Before any plan, task generation, or code edit:
1. Read `AGENTS.md`.
2. Read `.specify/memory/constitution.md`.
3. Read `.agents/workflows/development.md`.
4. Read `.agents/skill-matcher.json`.
5. Search `.agents/skills/` and `.agent/skills/` for relevant skills.
6. Load only relevant `SKILL.md` files.
7. State which skills are being used, or state that no relevant skill was
   found.
8. For non-trivial work, discuss the request with Mohamed, then run the
   `second-agent-solution-review` read-only critique loop before implementation.
9. If that review changes the plan, expands scope, or exposes a new material
   risk, get Mohamed's approval before editing files.

For meaningful features:
1. Use Spec Kit artifacts under `specs/<feature>/`.
2. Produce or update `spec.md`, `plan.md`, and `tasks.md`.
3. Do not implement screens until the user approves the plan when approval is
   explicitly requested.

For implementation:
1. Keep edits scoped.
2. Preserve user changes.
3. Reuse components and tokens.
4. Verify and report results.

## Governance

This constitution supersedes informal habits, generated boilerplate, and
external reference repositories. Amendments require a documented change to this
file, a version bump, and propagation to `AGENTS.md`, mandatory rules,
workflows, and Spec Kit templates when relevant.

Versioning policy:
- MAJOR: Changes that fundamentally alter the architecture scope (e.g., adding
  or removing backend support, changing the primary state management approach).
- MINOR: New principles, required workflows, quality gates, or project scope
  sections.
- PATCH: Clarifications, typo fixes, or wording changes that do not alter
  required behavior.

Compliance review:
- Every plan MUST include a Constitution Check.
- Every task list MUST include the required task-card details.
- Every final implementation report MUST mention verification commands and any
  blocked checks.

- Firebase Auth may remain an AI gateway identity/quota mechanism, but
  app-owned financial data remains local-only unless a later approved Spec Kit
  plan changes this.
- **VPS Architecture**: See `specs/023-vps-architecture-fix/spec.md` for 4 documented blockers preventing `vpsLocalFirst` from working. Key issues: in-memory storage, stub repos, VPS not connected, sync pull not applied.
- **Legacy Feature Port**: See `specs/022-legacy-feature-port/spec.md` for complete list of features ported from old app (security, account, settings, monetization, AI, backup).

**Version**: 2.3.0 | **Ratified**: 2026-05-28 | **Last Amended**: 2026-06-01
