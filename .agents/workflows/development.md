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

For non-trivial work, also discuss the request with Mohamed in Egyptian Arabic
before implementation. Cover the practical goal, expected screens/files, main
risks, and short execution plan.

Before implementing a non-trivial change, use `second-agent-solution-review` as
a read-only critique loop. Summarize accepted objections, rejected objections,
and the final plan. If that review changes the plan, expands scope, or exposes
a new material risk, get Mohamed's approval before editing files.

Non-trivial work includes UI redesigns, navigation changes, storage/database
changes, security/account changes, AI gateway or AI behavior changes, Spec Kit
features, migrations, and changes that touch multiple important files.

Tiny direct commands, simple answers, and clearly scoped one-line fixes may
proceed without the full second-review loop, but still require Phase 0 and must
obey project rules. Do not use this workflow as permission for broad repo
analysis unless Mohamed explicitly asks for it.

Recommended search:

```powershell
rg -n "flutter|dart|speckit|ui|rtl|responsive|test|plan|tasks|design" .agents/skills .agent/skills
```

## Phase 1: Specify

- For meaningful features or ambiguous work, create/update Spec Kit artifacts.
- Use `speckit-specify` when turning user intent into a feature spec.
- Specs must follow the production scope in `.specify/memory/constitution.md`.
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
- For production work: backend, Firebase, persistence, AI gateway, sync, and
  services are allowed only when owned by the active Spec Kit task.
- Do not use WebView or render exported HTML directly.
- Reuse components and design tokens instead of duplicating UI.
- Keep Arabic RTL and English LTR ready.
- Do not show mock/demo/sample data as real production data.

## Phase 4: Verify

- Flutter: use focused verification for the active task. Prefer one focused
  test, then analyzer on touched files and directly touched tests.
- Do not run full-project `flutter analyze` or full `flutter test` during
  feature work unless the task is explicitly a final release-readiness task.
- Stop after the first unrelated failure and report it separately.
- Do not retry the same failing/hanging command more than twice.
- If a Flutter command hangs or leaves stale lock/process state, follow
  `docs/agent-playbooks/subagent-execution-rules.md` and return `BLOCKED` with
  the smallest next action.
- UI: check 360x800, 375x812, and 390x844.
- Report commands and outcomes.
- Report any check that could not run and why.

## Phase 5: Update Project Memory

- Update specs, AGENTS.md, or the constitution only when architecture,
  dependencies, routes, design tokens, or long-lived rules changed.
