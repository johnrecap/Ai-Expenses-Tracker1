# Mandatory Agent Rules

These rules are project law for AI Expenses Tracker.

## First Read Gate

Before any plan, task generation, file edit, code generation, dependency
change, or broad command, the agent MUST:

1. Read `AGENTS.md`.
2. Read `.specify/memory/constitution.md`.
3. Read `.agents/workflows/development.md`.
4. Read `.agents/skill-matcher.json`.
5. Search `.agents/skills/` and `.agent/skills/` for relevant skills.
6. Load the relevant `SKILL.md` files and follow them.
7. State which skills are being used before planning or coding.

If no relevant skill exists, say that explicitly and continue with the
constitution and AGENTS.md.

## UI-only Flutter Prototype Rules

- Do not implement backend.
- Do not implement Firebase.
- Do not implement real authentication.
- Do not implement database.
- Do not implement API calls.
- Do not implement persistence.
- Do not use WebView.
- Do not render exported HTML directly.
- Rebuild all screens as native Flutter widgets.
- Use static in-memory mock data only.
- Reuse shared components and design tokens.
- Keep layouts responsive for 360x800, 375x812, and 390x844.
- Keep Arabic RTL and English LTR ready.

## Spec Kit Rules

- Meaningful features MUST use Spec Kit artifacts.
- Plans MUST include a Constitution Check.
- Tasks MUST include why, expected result, scope, inputs, possible bugs, fix
  strategy, verification, and stop condition.
- Do not implement screens when the user has asked for planning approval first.
