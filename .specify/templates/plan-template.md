# Production Flutter Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. This
workspace is a production Flutter expense tracker. Plans may include Flutter UI,
local Drift/SQLite persistence, state management, routing, local notifications,
security/app lock, monetization, analytics, and server-side AI gateway work
when owned by the active feature. Production financial app data remains
local-only by default; Firestore/PostgreSQL/VPS sync must not be used for
app-owned financial data unless a separate approved plan changes that decision.
WebView/HTML rendering and hardcoded secrets remain forbidden.

## Mandatory First Read And Skill Gate

Before writing this plan, the agent MUST:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Search `.agents/skills/` and `.agent/skills/` for relevant skills.
- Load matching `SKILL.md` files and follow them.
- List the skills used for this plan, or state that no relevant skill exists.

**Skills used**: [List exact skill names and why they apply]

## Summary

[Extract from feature spec: primary product requirement + technical approach
from research]

## Why

[Explain why this feature or batch exists, what user/product problem it solves,
and what implementation risk it removes.]

## Expected Result

[List the concrete screens, routes, widgets, data behavior, services, worker
contracts, assets, and tests that will exist when this plan is complete.]

## Source References

[List exact app files, package files, worker files, design-system docs, specs,
screenshots, and test files that workers must read before editing.]

## Technical Context

**Language/Version**: Flutter [version] / Dart [version]

**Primary Dependencies**: Flutter SDK, BLoC/Cubit, GoRouter, Drift/SQLite,
local notifications, Firebase Auth only when needed for AI gateway
identity/quota, Cloudflare Worker AI Gateway, purchase/ad SDKs only when owned
by the feature

**Storage**: Drift/SQLite is the production financial-data store. Firestore,
PostgreSQL, and VPS sync are legacy/future infrastructure and not default
runtime storage for app-owned financial data.

**Testing**: focused `flutter test` suites, package-level tests, worker tests,
widget tests for LTR/RTL and required viewports, touched-file analyzer checks

**Target Platform**: Flutter mobile app verified on narrow mobile viewports
360x800, 375x812, and 390x844, plus connected Android device checks when
available

**Project Type**: Production Flutter mobile app with local-only financial data
and explicit server-side AI actions

**Performance Goals**: reliable startup reads, durable local saves, fast list
updates, compact AI requests, smooth scrolling lists, stable bottom sheets, no
layout jank, and no false success states

**Constraints**: native Flutter widgets, no WebView/HTML rendering, no mobile
secrets, app-owned financial data local-only, explicit AI server calls only,
responsive mobile layout, Arabic RTL and English LTR ready

**Scale/Scope**: the active feature's owned app, package, worker, docs, and
test files only; avoid broad repo analysis unless the task explicitly owns it

## Required Plan Detail

Every plan generated for this project must include:

- Why: reason the feature/batch exists and what risk it removes.
- Expected result: concrete screens, routes, widgets, data behavior, services,
  worker contracts, assets, or tests produced.
- Files and ownership: exact Flutter folders/files to create or modify.
- Reuse strategy: shared components and tokens to use instead of duplicating UI.
- Data strategy: real local data behavior, allowed fixture/test data, and any
  unavailable states required. Do not present mock/demo financial data as real.
- Possible bugs: likely Flutter layout, asset, routing, RTL, and dependency
  failures.
- Fix strategy: how a worker should diagnose and repair each likely failure.
- Verification: focused tests, touched-file analyzer commands, worker checks,
  compile commands where owned, widget tests, viewport checks, and acceptance
  criteria.
- Stop condition: what must pass before moving to the next batch.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Required gates for this project:

- `AGENTS.md` and `.specify/memory/constitution.md` were read.
- `.agents/skill-matcher.json` was checked.
- Relevant installed skills were searched before this plan was written.
- Matching skills are listed in the Mandatory First Read And Skill Gate.
- Production Flutter app scope is preserved.
- No WebView or HTML rendering is planned.
- Native Flutter widgets are planned for all screens.
- Shared components and design tokens are planned before feature screens.
- Production app-owned financial data remains local-only by default.
- Any network calls are explicit and limited to AI gateway, ads, purchases,
  analytics, or quota/abuse protection owned by this feature.
- No mock/demo financial data is presented as real production data.
- Responsive checks include 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR checks are planned.
- Compile checks are listed for every implementation batch.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
  tasks.md
```

### Source Code (repository root)

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    routes.dart
  core/
    layout/
    theme/
    widgets/
  features/
    onboarding/presentation/
    auth/presentation/
    dashboard/presentation/
    expenses/presentation/
    reports/presentation/
    budgets/presentation/
    goals/presentation/
    wallets/presentation/
    subscriptions/presentation/
    ai/presentation/
    settings/presentation/
test/
packages/expense_repository/
workers/ai-gateway/
assets/images/
pubspec.yaml
analysis_options.yaml
```

**Structure Decision**: [Document which folders are used by this feature and
why. Do not add new backend/sync runtime ownership unless the active feature
explicitly owns it.]

## Reuse Strategy

[Name the shared widgets/tokens this feature must use, and identify any new
shared widget that should be created before screen work. Prefer
`lib/core/widgets/` and `lib/core/theme/` over screen-local duplicated UI.]

## Data Strategy

[Name the production local data behavior, fixture/test data, unavailable states,
and remote calls allowed by the feature. Confirm app-owned financial data stays
local-only unless the spec explicitly changes that.]

## Possible Bugs And Fix Strategy

[List likely failures and repair steps. Include local data loss, false save
success, route mismatches, AI privacy leaks, accidental cloud financial-data
writes, layout overflow, RTL mirroring, missing assets, raw duplicated styles,
bottom nav overlap, and bottom sheet height issues when relevant.]

## Verification Plan

Every implementation batch must run focused checks or document why it cannot
run:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub <focused-test-file>
& 'C:\flutter\bin\flutter.bat' analyze <touched-files-and-tests>
```

Run wider checks only for final release-readiness tasks or when explicitly
owned:

```powershell
& 'C:\flutter\bin\flutter.bat' test
& 'C:\flutter\bin\flutter.bat' build apk --debug
```

Visual checks:

```text
360x800 LTR
360x800 RTL
375x812 LTR
375x812 RTL
390x844 LTR
390x844 RTL
```

Forbidden-pattern search for local-only/AI privacy tasks:

```powershell
rg -n "FirebaseFirestore|firebaseLegacy|migrationComparison|merchant|receiptText|description" lib packages workers test
```

## Phase 0: Research

[Resolve unknowns about local data behavior, AI privacy boundaries, feature
ownership, Flutter package choices, worker validation, RTL/LTR testing, and
responsive verification. Each decision must include Decision, Rationale,
Alternatives considered.]

## Phase 1: Design

[Define data models, route contracts, service/repository contracts, worker
contracts, component contracts, screen ownership, and quickstart verification
steps. Contracts should describe the interfaces owned by the active feature:
local data behavior, AI gateway payloads, route/UI behavior, and visual
acceptance criteria.]

## Complexity Tracking

> Fill only if a plan violates one of the gates above.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [Violation] | [Reason] | [Alternative] |
