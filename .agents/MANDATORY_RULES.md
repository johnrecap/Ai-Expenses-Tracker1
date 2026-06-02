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

## Production Flutter App Rules

- This is a production Flutter expense tracker, not a UI-only prototype.
- Firebase Auth, Firestore, Cloudflare AI Gateway, local/Drift storage, VPS
  sync, notifications, exports, analytics, app lock, and monetization may be in
  scope when a Spec Kit plan explicitly owns them.
- Never put API keys or AI provider secrets in Flutter/mobile code.
- AI APIs must go through the server-side gateway/proxy.
- Do not show mock/demo/sample financial data as real production data.
- If a feature is not connected, show an empty/error/unavailable state instead
  of fake success.
- Do not use WebView or render exported HTML directly.
- Reuse shared components and design tokens.
- Keep layouts responsive for 360x800, 375x812, and 390x844.
- Keep Arabic RTL and English LTR ready.

## Delegated Agent Runtime Rules

- Delegate exact task ids and exact file ownership.
- Do not allow broad repo analysis unless the task explicitly owns it.
- Do not run full-project `flutter analyze` or full `flutter test` during
  feature work.
- Verify with a ladder: single focused test, touched-file analyzer, then wider
  folder tests only if owned by the task.
- Stop after the first unrelated failure and report it as unrelated.
- Do not retry the same failing/hanging command more than twice.
- If blocked, return `BLOCKED` with the exact command, failure, changed files,
  and smallest next action.
- Follow `docs/agent-playbooks/subagent-execution-rules.md` for Flutter hangs,
  stale lock files, stuck Git processes, and widget test scroll issues.
- In this workspace, Flutter commands may require running outside the sandbox
  because Flutter writes to `C:\flutter\bin\cache\lockfile`. Do not keep
  retrying inside the sandbox when the lockfile is blocked.

## Spec Kit Rules

- Meaningful features MUST use Spec Kit artifacts.
- Plans MUST include a Constitution Check.
- Tasks MUST include why, expected result, scope, inputs, possible bugs, fix
  strategy, verification, and stop condition.
- Do not implement screens when the user has asked for planning approval first.
