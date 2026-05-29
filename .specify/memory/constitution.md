<!--
Sync Impact Report
Version change: 2.0.0 -> 2.1.0
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
Last Amended: 2026-05-29
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

### III. Production Flutter App Scope

The current product is a **production-grade Flutter expense tracker** with full
backend integration, AI capabilities, and multi-backend sync support.

Allowed architecture:
- Firebase Authentication and Firestore as legacy/primary backend.
- VPS PostgreSQL backend with local-first sync as secondary/cutover target.
- Cloudflare Worker AI gateway and Firebase Functions for AI services.
- `flutter_bloc` for state management with `go_router` for navigation.
- Real API calls, local database (Drift/SQLite), persistent storage.
- Push notifications, local auth/biometrics, camera/image picker.
- In-app purchases, ads (AdMob), premium entitlements.
- Localization (EN+AR), RTL/LTR support, export (CSV/Excel/PDF).

Forbidden by default:
- WebView or HTML rendering packages for UI shortcuts.
- Hardcoded secrets in source code (use dart-define or secure storage).
- Direct AI provider keys in Flutter (must route through gateway).

Rationale: The app has graduated from UI prototype to full production
architecture. Backend integration is now required, not forbidden.

### IV. Spec-driven Full-Stack Implementation

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

### V. Verification, RTL/LTR, And Responsive Quality

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
- `packages/expense_repository/`: Repository package with local/remote implementations.
- `server/`: VPS backend (Fastify + PostgreSQL + Drizzle ORM).
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

- Firebase Auth remains the identity provider even when app data moves to VPS.
- **VPS Architecture**: See `specs/023-vps-architecture-fix/spec.md` for 4 documented blockers preventing `vpsLocalFirst` from working. Key issues: in-memory storage, stub repos, VPS not connected, sync pull not applied.
- **Legacy Feature Port**: See `specs/022-legacy-feature-port/spec.md` for complete list of features ported from old app (security, account, settings, monetization, AI, backup).

**Version**: 2.1.0 | **Ratified**: 2026-05-28 | **Last Amended**: 2026-05-29
