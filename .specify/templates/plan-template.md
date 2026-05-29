# UI-Only Flutter Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. This
workspace is a UI-only Flutter prototype. Plans must not introduce backend,
Firebase, real auth, database, API calls, OCR, AI-service calls, persistence,
WebView, or HTML-rendering work.

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

[Extract from feature spec: primary UI requirement + technical approach from
research]

## Why

[Explain why this feature or batch exists, what user/product problem it solves,
and what implementation risk it removes.]

## Expected Result

[List the concrete screens, routes, widgets, mock data, assets, and tests that
will exist when this plan is complete.]

## Source References

[List exact Stitch folders, screenshots, HTML files, design-system docs, and
spec files that workers must read before editing.]

## Technical Context

**Language/Version**: Flutter [version] / Dart [version]

**Primary Dependencies**: Flutter SDK, Material widgets, optional `go_router`,
optional `intl`, optional FlutterGen-generated assets

**Storage**: N/A. Static in-memory mock data only.

**Testing**: `flutter test`, widget tests for LTR/RTL and required viewports

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and
390x844

**Project Type**: UI-only Flutter mobile app prototype

**Performance Goals**: smooth scrolling lists, stable bottom sheets, no layout
jank from repeated widgets, restrained glass effects

**Constraints**: native Flutter widgets only, no WebView, no backend, no remote
runtime assets, responsive mobile layout, Arabic RTL and English LTR ready

**Scale/Scope**: native rebuild of detected Stitch export screens plus
documented missing/deferred screens

## Required Plan Detail

Every plan generated for this project must include:

- Why: reason the feature/batch exists and what risk it removes.
- Expected result: concrete screens, routes, widgets, mock data, assets, or
  tests produced.
- Files and ownership: exact Flutter folders/files to create or modify.
- Reuse strategy: shared components and tokens to use instead of duplicating UI.
- Mock data strategy: static models/lists and route IDs required.
- Possible bugs: likely Flutter layout, asset, routing, RTL, and dependency
  failures.
- Fix strategy: how a worker should diagnose and repair each likely failure.
- Verification: compile commands, widget tests, viewport checks, and acceptance
  criteria.
- Stop condition: what must pass before moving to the next batch.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Required gates for this project:

- `AGENTS.md` and `.specify/memory/constitution.md` were read.
- `.agents/skill-matcher.json` was checked.
- Relevant installed skills were searched before this plan was written.
- Matching skills are listed in the Mandatory First Read And Skill Gate.
- UI-only scope is preserved.
- No WebView or HTML rendering is planned.
- Native Flutter widgets are planned for all screens.
- Shared components and design tokens are planned before feature screens.
- Mock data is static and in-memory.
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

**Structure Decision**: [Document which folders are used by this feature and
why. Do not add backend/api/database/auth service folders.]

## Reuse Strategy

[Name the shared widgets/tokens this feature must use, and identify any new
shared widget that should be created before screen work. Prefer
`lib/core/widgets/` and `lib/core/theme/` over screen-local duplicated UI.]

## Mock Data Strategy

[Name the static mock models, lists, IDs, and state objects required. Confirm no
network, database, persistence, or auth services are needed.]

## Possible Bugs And Fix Strategy

[List likely failures and repair steps. Include layout overflow, RTL mirroring,
route mismatches, missing assets, raw duplicated styles, accidental backend
dependencies, bottom nav overlap, and bottom sheet height issues when relevant.]

## Verification Plan

Every implementation batch must run or document why it cannot run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If Android build tooling is unavailable, record the exact failure and run:

```powershell
flutter build web
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

Forbidden dependency search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api" lib pubspec.yaml test
```

## Phase 0: Research

[Resolve unknowns about Flutter package choices, chart approach, asset handling,
fonts, RTL/LTR testing, and responsive verification. Each decision must include
Decision, Rationale, Alternatives considered.]

## Phase 1: Design

[Define mock models, route contracts, component contracts, screen ownership, and
quickstart verification steps. Contracts for this UI-only app should describe
routes, widget APIs, mock data shapes, and visual acceptance criteria, not HTTP
endpoints.]

## Complexity Tracking

> Fill only if a plan violates one of the gates above.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [Violation] | [Reason] | [Alternative] |
