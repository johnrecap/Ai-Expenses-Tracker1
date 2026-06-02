# AGENTS.md — AI Expenses Tracker

## Project

Flutter app: AI Expenses Tracker.

Target users:
- Egypt / MENA users
- Arabic and English
- RTL and LTR support

Main stack:
- Flutter / Dart
- Drift / SQLite local storage for app-owned financial data
- Firebase Auth only when needed for AI gateway identity/quota protection
- BLoC / Cubit
- GoRouter
- Cloudflare Worker AI Gateway

## Architecture Decision: Local-Only App Data

- Production app-owned financial data is local-only by default.
- Expenses, categories, wallets, budgets, goals, subscriptions, settings, and
  AI history must stay on the device unless Mohamed explicitly approves a new
  sync/backend plan.
- Do not write app-owned financial data to Firestore, PostgreSQL, or VPS sync
  in local-only mode.
- Firestore/VPS code may exist as legacy or future migration code, but it must
  not be instantiated by the production local-only runtime.
- Server calls are allowed for explicit AI actions, ads, purchase/restore
  checks, and AI quota/abuse protection.
- AI advice must send a compact summary only when the user asks for it; do not
  upload raw expense lists, merchant names, descriptions, or receipt text by
  default.

## Mohamed Preferences

- Reply to Mohamed in Egyptian Arabic.
- Mohamed is a beginner programmer.
- Explain practical cause and fix.
- Give commands and file paths clearly.
- Do not ask many questions unless necessary.

## Mandatory Discussion And Second Review

Before planning, editing, or running project commands for non-trivial work,
Codex must read `AGENTS.md` and `.specify/memory/constitution.md`.

For non-trivial changes, Codex must discuss the request with Mohamed in
Egyptian Arabic before implementation. The discussion must cover the practical
goal, the expected screens/files, the main risks, and the short execution plan.

Non-trivial changes include UI redesigns, navigation changes, storage/database
changes, security/account changes, AI gateway or AI behavior changes, Spec Kit
features, migrations, and changes that touch multiple important files.

Before implementing a non-trivial change, Codex must use the
`second-agent-solution-review` skill as a read-only critique loop. The second
agent must challenge the proposed solution without editing files. Codex must
summarize accepted objections, rejected objections, and the final plan for
Mohamed.

Codex must not implement if the second review changes the plan, expands scope,
or exposes a new material risk until Mohamed approves the revised plan.

Tiny direct commands, simple answers, and clearly scoped one-line fixes may
proceed without the full second-review loop, but they still must obey the
project rules. This rule is not permission to run broad repo analysis unless
Mohamed explicitly asks for it.

## Critical Design Rules

Before editing UI:
1. Inspect existing theme files.
2. Inspect shared components.
3. Inspect docs/design.md if present.
4. Match current colors, typography, spacing, shadows, and component style.
5. Do not add new colors/styles without Mohamed approval.

Never create a new design language.

## Critical Security Rules

- Never put API keys in Flutter/mobile code.
- AI APIs must go through server-side gateway/proxy.
- Use `.env`, server env vars, Cloudflare Worker secrets, or aaPanel secure settings.
- Do not print secrets in logs.
- Warn if screenshots or files expose tokens.

## Commands

Use these checks when relevant:

```bash
flutter pub get
flutter analyze
flutter test
```

## Delegated Agent Rules

When using agents, keep each agent scoped to exact tasks and exact files. Do not
ask agents to perform broad repo analysis unless the task explicitly owns a
repo-wide audit.

For normal feature work:
- Do not run full-project `flutter analyze` or full `flutter test`.
- Run the single focused test first.
- Run analyzer only on touched files and directly touched tests.
- Stop at the first unrelated failure and report it as unrelated.
- Do not retry the same failing/hanging command more than twice.
- If blocked, return `BLOCKED` with the exact command, failure, changed files,
  and smallest next action.
- Update task checkboxes immediately after each verified task.

Flutter hang rule: if `flutter` times out or hangs with no output, stop
rerunning it. Check Dart, Flutter lock files, and visible Git/Flutter processes,
then report the blocker to the controller. Follow
`docs/agent-playbooks/subagent-execution-rules.md`.

In this workspace, Flutter may need to run outside the sandbox because it writes
to `C:\flutter\bin\cache\lockfile`. Treat sandbox lockfile failures as an
execution-environment issue, not as a code failure.
