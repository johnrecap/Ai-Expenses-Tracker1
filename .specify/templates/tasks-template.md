---

description: "Production Flutter task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required), research.md,
data-model.md, quickstart.md, contracts/ if present

**Project Type**: Production Flutter app with local-only financial data and explicit AI/server actions when owned by the feature

## Mandatory First Read And Skill Gate

Before generating or executing tasks, the agent MUST:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Search `.agents/skills/` and `.agent/skills/` for relevant skills.
- Load matching `SKILL.md` files and follow them.
- List the skills used for task generation/execution.

If this gate has not happened, stop and complete it before writing tasks or
code.

## Non-Negotiable Rules

- Production app scope: tasks may touch Flutter UI, Drift/SQLite local
  persistence, BLoC/Cubit, GoRouter, notifications, app lock, monetization,
  analytics, tests, and Cloudflare Worker AI Gateway when the feature owns that
  area.
- App-owned financial data stays local-only by default; do not write expenses,
  categories, wallets, budgets, goals, subscriptions, settings, or AI history
  to Firestore, PostgreSQL, or VPS sync without a separate approved plan.
- Remote calls are allowed only for explicit AI actions, ads, purchase/restore
  checks, analytics, and AI quota/abuse protection owned by the task.
- No WebView and no HTML rendering.
- Use native Flutter widgets.
- Do not show mock/demo/sample financial data as real production data.
- Reuse shared components and theme tokens.
- Responsive for 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR ready.

## Required Task Card Format

Every non-trivial generated task must include the complete detail block below.
Do not generate vague one-line tasks.

```text
- [ ] T000 [P?] [Story? or Area] Short action with exact file path
  - Why: Explain the reason this task exists and what risk it removes.
  - Expected result: State the concrete visible or technical outcome.
  - Inputs: List the specs, app files, package files, worker files, screenshots,
    fixtures, or design docs needed before editing.
  - Implementation notes: Mention component reuse, route impact, responsive
    behavior, RTL/LTR behavior, local-only data rules, AI/privacy boundaries,
    and forbidden shortcuts.
  - Possible bugs: List likely failures for this task.
  - Fix strategy: Explain how to diagnose and repair those failures.
  - Verification: Name the command, widget test, visual viewport check, or
    manual check that proves the task is complete.
```

Format components:

- `T000`: sequential task ID in execution order.
- `[P]`: include only when task can be done in parallel with no file conflict.
- `[Story]`: use `[US1]`, `[US2]`, etc. for user-story phases.
- `[Area]`: use labels such as `[Theme]`, `[Routes]`, `[Mock]`, `[Screen]`,
  `[Widgets]`, `[Tests]`, or `[Polish]` for non-story phases.

## Path Conventions

Use these paths unless the plan says otherwise:

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

Do not create new backend/sync/runtime ownership unless the active Spec Kit
plan explicitly owns that area. Prefer existing `packages/expense_repository/`
for local financial data and `workers/ai-gateway/` for AI server calls.

## Phase 1: Setup And Guardrails

**Purpose**: Establish the feature's owned files, focused checks, and guardrails
before implementation starts.

Example task shape:

- [ ] T001 [Guardrail] Confirm active Spec Kit scope and focused verification commands in `specs/[###-feature]/tasks.md`
  - Why: Later work needs exact ownership and must avoid broad repo analysis.
  - Expected result: The task list names owned app/package/worker files and
    focused checks.
  - Inputs: plan.md project structure, AGENTS.md hard rules.
  - Implementation notes: Do not broaden ownership beyond the feature.
  - Possible bugs: Tasks become too broad or run full-project checks too early.
  - Fix strategy: split broad tasks into owned file groups and use focused
    tests first.
  - Verification: Read the generated task list and confirm every task has exact
    paths and focused checks.

## Phase 2: Foundation

**Purpose**: Build shared app foundations that all user stories depend on.

Recommended task areas:

- Theme tokens in `lib/core/theme/`.
- Responsive and directionality helpers in `lib/core/layout/`.
- Shared widgets in `lib/core/widgets/`.
- Central routes in `lib/app/routes.dart` and `lib/app/router.dart`.
- Local data contracts in `packages/expense_repository/`.
- Worker contracts in `workers/ai-gateway/` when AI is owned.
- Local assets in `assets/images/` and `pubspec.yaml`.
- Foundational widget/unit tests in `test/core/`.

Every task in this phase must explain:

- why the foundation is blocking,
- which later screens depend on it,
- what bugs it prevents,
- how to repair expected Flutter layout/theme/asset failures.

**Checkpoint**: no feature screen work starts until foundation compile and smoke
tests pass.

## Phase 3+: User Story Screen Batches

Create one phase per user story or cohesive screen batch. For this project,
recommended batches are:

- Launch/onboarding/auth.
- Dashboard/expenses/add/edit/filter flow.
- Reports/budgets/goals/wallets/subscriptions.
- AI/settings/polish.

Each phase must include:

- **Goal**: user-visible outcome.
- **Why**: reason this batch exists and risk removed.
- **Expected result**: specific screens/routes completed.
- **Screens**: Stitch folder names used as source references.
- **Work areas**: exact Flutter feature folders and tests.
- **Tasks**: detailed task cards in the required format.
- **Common bugs and fixes**: batch-level data, routing, privacy, layout, and
  RTL risks.
- **Independent test**: how to prove this batch works without later batches.
- **Acceptance criteria**: focused tests, touched-file analysis, responsive
  checks, and RTL/LTR checks.
- **Stop condition**: what must pass before moving on.

## Final Phase: Verification And Polish

Required final tasks:

- [ ] TXXX [Polish] Search for forbidden dependencies and APIs in
  `lib`, `pubspec.yaml`, and `test`
  - Why: Ensures the app preserved local-only financial data and AI privacy
    boundaries.
  - Expected result: No forbidden financial cloud write path or raw AI upload
    remains in owned production paths.
  - Inputs: AGENTS.md hard rules.
  - Implementation notes: The search can match documentation outside source;
    verify only implementation files.
  - Possible bugs: false positives in comments or specs; missed capitalized
    variants.
  - Fix strategy: inspect each hit and remove implementation dependencies.
  - Verification:
    `rg -n "FirebaseFirestore|firebaseLegacy|migrationComparison|merchant|receiptText|description|WebView|webview" lib packages workers test`

- [ ] TXXX [Polish] Run compile and test commands
  - Why: Confirms the owned feature is stable enough to merge.
  - Expected result: Flutter dependency, analyze, test, and debug build checks
    pass or exact environment failures are documented.
  - Inputs: completed Flutter implementation.
  - Implementation notes: If Android tooling is unavailable, run web build and
    record Android failure.
  - Possible bugs: analyzer warnings, missing assets, platform build setup
    missing.
  - Fix strategy: fix analyzer findings first, then asset paths, then platform
    setup issues.
  - Verification:
    focused `flutter test`, touched-file `flutter analyze`, and wider checks
    only when owned by the task.

- [ ] TXXX [Polish] Verify visual behavior at required viewports and directions
  - Why: Narrow mobile and RTL issues are the highest UI risk.
  - Expected result: no overflow, clipped controls, hidden bottom actions, or
    incorrect RTL mirroring.
  - Inputs: all built screens and `screen.png` references.
  - Implementation notes: Prefer fixing shared components/tokens over
    screen-local hacks.
  - Possible bugs: text overflow, nav overlap, wrong icon direction, bottom
    sheet too tall.
  - Fix strategy: apply the global debug playbook from `specs/tasks.md`.
  - Verification: 360x800, 375x812, 390x844 in English LTR and Arabic RTL.

## Dependencies And Execution Order

- Setup blocks everything.
- Foundation blocks all feature screen batches.
- Feature screen batches can run in parallel only if they do not edit the same
  shared widgets/routes/mock files.
- Polish depends on all selected feature batches being complete.
- Tests for a task should be written before implementation when practical.
- Commit or checkpoint after each batch or logical task group.

## Notes

- Replace sample tasks with real tasks generated from the spec.
- Keep exact file paths in each task.
- Do not leave placeholders such as "TBD", "implement later", or "add proper
  handling".
- Each task must be independently understandable by someone with no prior
  context beyond the referenced files.
