<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan.
Spec Kit was initialized for Codex skills in `.agents/skills`.

Current canonical Spec Kit plan set:

- `specs/001-foundation/plan.md`
- `specs/002-launch-onboarding-auth/plan.md`
- `specs/003-dashboard-expenses/plan.md`
- `specs/004-add-edit-expense/plan.md`
- `specs/005-reports-budgets-goals/plan.md`
- `specs/006-wallets-subscriptions/plan.md`
- `specs/007-ai-settings-final-qa/plan.md`
- `specs/008-backend-integration/plan.md`
- `specs/009-production-readiness/plan.md`
- `specs/010-code-review-cleanup/plan.md`
- `specs/011-critical-fixes/plan.md`
- `specs/012-data-quality/plan.md`
- `specs/013-polish/plan.md`
- `specs/014-production-backend-ops/plan.md`
- `specs/015-local-first-sync-parity/plan.md`
- `specs/016-ai-gateway-hardening/plan.md`
- `specs/017-account-security-lock/plan.md`
- `specs/018-finance-feature-completion/plan.md`
- `specs/019-engagement-guided-tour/plan.md`
- `specs/020-monetization-observability/plan.md`
- `specs/021-localization-routing-ci/plan.md`
<!-- SPECKIT END -->

# AI Expenses Tracker Agent Guide

## Mandatory First Steps

Before any plan, task generation, file edit, code generation, dependency
change, or broad command, the agent MUST:

1. Read this `AGENTS.md`.
2. Read `.specify/memory/constitution.md`.
3. Read `.agents/workflows/development.md`.
4. Read `.agents/skill-matcher.json`.
5. Search `.agents/skills/` and `.agent/skills/` for relevant skills.
6. Load the relevant `SKILL.md` files and follow them.
7. State which skills are being used before planning or coding. If no relevant
   skill exists, state that explicitly.

Minimum local skill search command:

```powershell
rg -n "flutter|dart|speckit|ui|rtl|responsive|test|plan|tasks|design" .agents/skills .agent/skills
```

This requirement is project law. Do not skip it for Flutter code, Spec Kit
plans, UI tasks, package changes, test work, or tooling changes.

## Mission

Build a production-grade Flutter expense tracker app (`expenses_tracker`) by
integrating the full backend architecture from `Expense-Tracker-main` into the
redesigned UI from the new app.

The app preserves all 25 screens and the design system from the Stitch exports
while adding real backend support: Firebase Auth + Firestore, VPS PostgreSQL
sync, AI via Cloudflare Worker, monetization, notifications, and full
localization.

## Hard Rules

- The constitution in `.specify/memory/constitution.md` is authoritative (v2.0.0).
- Skills are mandatory project knowledge. Search and use matching skills before
  plans or code.
- Use `flutter_bloc` for state management and `go_router` for navigation.
- Use native Flutter widgets for every screen and component.
- Reuse shared widgets and tokens instead of duplicating UI per screen.
- Support English LTR and Arabic RTL from the first implementation batch.
- Verify layouts at 360x800, 375x812, and 390x844.
- Every implementation batch must compile before being marked complete.
- No AI provider keys in Flutter source (route through gateway only).
- No secrets in Git (use dart-define or secure storage).
- Do not use WebView or HTML rendering packages.

## Task Documentation Standard

Every Spec Kit plan/task file for this project must explain the work enough for
a new engineer or agent to execute it without guessing.

Each batch and non-trivial task must include:

- Why: the reason this work exists and what risk it removes.
- Expected result: the concrete visible or technical outcome.
- Scope: exact files or folders to create/modify, using project-relative paths.
- Inputs: Stitch screenshots, HTML references, specs, or mock data required.
- Implementation notes: important constraints, component reuse, RTL/LTR and
  responsive behavior.
- Possible bugs: likely failures such as overflow, wrong directionality,
  duplicated widgets, route mismatch, asset failures, or accidental backend
  dependencies.
- Fix strategy: how to diagnose and repair each likely failure.
- Verification: commands, widget tests, visual viewport checks, and acceptance
  criteria.
- Stop condition: what must be true before moving to the next batch.

## Current Source Assets

- Stitch export folder:
  `stitch_ai_expenses_tracker_pro/`
- Design system reference:
  `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`
- Planning docs:
  `specs/ui-only-flutter-prototype.md`
  `specs/screens-inventory.md`
  `specs/design-system.md`
  `specs/component-map.md`
  `specs/tasks.md`

## Current Scope Overrides

- Firebase Functions references in older plans are superseded by the VPS
  `server/` plus Cloudflare Worker AI gateway. Do not add or port
  `functions/` unless the user explicitly reopens that scope.
- The full Export screen is currently out of scope by user decision. Keep
  existing export services only if needed by other code, but do not plan or
  implement a dedicated Export screen until the user asks for it.

## Installed Tooling

- Spec Kit CLI: `specify 0.8.15`
- Spec Kit Codex skills: `.agents/skills/speckit-*`
- Flutter SDK: `3.44.0`
- Dart SDK: `3.12.0`
- FlutterGen: `5.14.1`

FlutterGen was installed globally and Dart Pub's global executable directory was
added to the user PATH. If the current terminal has not picked up the PATH
change yet, run it with:

```powershell
dart pub global run flutter_gen:flutter_gen_command -v
```

## Planned Flutter Shape

The future implementation should use a feature-first Flutter structure:

```text
lib/
  app/
  core/
    layout/
    theme/
    widgets/
    mock/
  features/
    onboarding/
    auth/
    dashboard/
    expenses/
    reports/
    budgets/
    goals/
    wallets/
    subscriptions/
    ai/
    settings/
```

Do not start building screens until the user approves the spec plan.

<!-- BEGIN AGENT-TOOLING-V3 -->
# Agent Tooling v3

This repository uses project-local Agent Skills and Spec Kit.

## Before changing code
1. Read `.agents/workflows/development.md`.
2. Check `.agents/skill-matcher.json` and load only relevant skills.
3. Inspect existing project structure and conventions before generating files.
4. For Flutter/Dart work, run `flutter analyze` and `flutter test` when available.

## Production Flutter app rules
- Backend, Firebase, real auth, database, and API calls are explicitly allowed.
- Use `flutter_bloc` + `go_router` architecture.
- Package name is `expenses_tracker`.
- Support three runtime modes: `firebaseLegacy`, `vpsLocalFirst`, `migrationComparison`.
- Do not use WebView or HTML rendering packages.
- Rebuild all screens as native Flutter widgets.
- Reuse shared components instead of duplicating UI.
- Keep layouts responsive for 360x800, 375x812, and 390x844.
- Keep Arabic RTL and English LTR ready.
<!-- END AGENT-TOOLING-V3 -->
