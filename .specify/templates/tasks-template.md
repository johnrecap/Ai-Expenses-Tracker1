---

description: "UI-only Flutter task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required), research.md,
data-model.md, quickstart.md, contracts/ if present

**Project Type**: UI-only Flutter prototype

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

- UI only: no backend, Firebase, real auth, database, API calls, OCR, AI calls,
  payment SDKs, notification APIs, or persistence.
- No WebView and no HTML rendering.
- Use native Flutter widgets.
- Use static in-memory mock data.
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
  - Inputs: List the specs, screenshots, HTML references, mock data, or design
    docs needed before editing.
  - Implementation notes: Mention component reuse, route impact, responsive
    behavior, RTL/LTR behavior, and forbidden shortcuts.
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
    mock/
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
assets/images/
pubspec.yaml
analysis_options.yaml
```

Do not create `backend/`, `api/`, `services/` for remote calls, database
migrations, auth middleware, repository layers, or environment configs unless
the user explicitly changes the UI-only scope.

## Phase 1: Setup And Guardrails

**Purpose**: Create a compiling Flutter baseline and make forbidden work visible
before screen implementation starts.

Example task shape:

- [ ] T001 [Scaffold] Create Flutter project structure in `lib/`, `test/`, and
  `pubspec.yaml`
  - Why: Later UI work needs a real Flutter target for compile checks.
  - Expected result: The app launches to a placeholder screen.
  - Inputs: plan.md project structure, AGENTS.md hard rules.
  - Implementation notes: Do not overwrite Stitch exports or spec files.
  - Possible bugs: Project created in a nested folder; generated files overwrite
    planning docs.
  - Fix strategy: Move generated Flutter files to the intended root and keep
    `stitch_ai_expenses_tracker_pro/` unchanged.
  - Verification: `flutter pub get` succeeds from the workspace root.

## Phase 2: Foundation

**Purpose**: Build shared theme, layout, routes, widgets, mock data, and assets
that all user stories depend on.

Recommended task areas:

- Theme tokens in `lib/core/theme/`.
- Responsive and directionality helpers in `lib/core/layout/`.
- Shared widgets in `lib/core/widgets/`.
- Mock models and mock data in `lib/core/mock/`.
- Central routes in `lib/app/routes.dart` and `lib/app/router.dart`.
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
- **Common bugs and fixes**: batch-level layout, routing, mock data, and RTL
  risks.
- **Independent test**: how to prove this batch works without later batches.
- **Acceptance criteria**: compile, UI-only, responsive, and RTL/LTR checks.
- **Stop condition**: what must pass before moving on.

## Final Phase: Verification And Polish

Required final tasks:

- [ ] TXXX [Polish] Search for forbidden dependencies and APIs in
  `lib`, `pubspec.yaml`, and `test`
  - Why: Ensures the prototype stayed UI-only.
  - Expected result: No forbidden package/import/use remains.
  - Inputs: AGENTS.md hard rules.
  - Implementation notes: The search can match documentation outside source;
    verify only implementation files.
  - Possible bugs: false positives in comments or specs; missed capitalized
    variants.
  - Fix strategy: inspect each hit and remove implementation dependencies.
  - Verification:
    `rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api" lib pubspec.yaml test`

- [ ] TXXX [Polish] Run compile and test commands
  - Why: Confirms the app is shippable as a prototype.
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
    `flutter pub get`, `flutter analyze`, `flutter test`,
    `flutter build apk --debug`.

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
