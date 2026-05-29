---
description: Mandatory development workflow for Codex/Antigravity in this repo.
---

# Development Workflow

## Phase 0: First Read And Skill Gate

This phase is mandatory before planning, task generation, coding, dependency
changes, or broad commands.

1. Read `AGENTS.md`.
2. Read `.specify/memory/constitution.md`.
3. Read `.agents/MANDATORY_RULES.md`.
4. Read `.agents/skill-matcher.json`.
5. Search `.agents/skills/` and `.agent/skills/` for relevant skills.
6. Load only relevant `SKILL.md` files.
7. Announce the skills being used. If none apply, say so.

Recommended search:

```powershell
rg -n "flutter|dart|speckit|ui|rtl|responsive|test|plan|tasks|design" .agents/skills .agent/skills
```

## Phase 1: Specify

- For meaningful features or ambiguous work, create/update Spec Kit artifacts.
- Use `speckit-specify` when turning user intent into a feature spec.
- Specs must preserve the UI-only scope unless the user explicitly changes it.
- Tiny mechanical fixes may use a short change note, but still require Phase 0.

## Phase 2: Plan

- Use `speckit-plan` for meaningful implementation planning.
- Plans must include a Constitution Check.
- Plans must identify affected files, dependencies, risks, verification
  commands, and acceptance criteria.
- Every task must include why, expected result, possible bugs, fix strategy,
  verification, and stop condition.

## Phase 3: Implement

- Follow the approved plan and keep changes scoped.
- Preserve user changes.
- For UI-only work: no backend, Firebase, real auth, database, API calls,
  persistence, WebView, or HTML rendering.
- Rebuild screens as native Flutter widgets.
- Reuse components and design tokens instead of duplicating UI.
- Keep Arabic RTL and English LTR ready.

## Phase 4: Verify

- Flutter: run `flutter analyze` and `flutter test` when a Flutter project
  exists.
- UI: check 360x800, 375x812, and 390x844.
- Report commands and outcomes.
- Report any check that could not run and why.

## Phase 5: Update Project Memory

- Update specs, AGENTS.md, or the constitution only when architecture,
  dependencies, routes, design tokens, or long-lived rules changed.
