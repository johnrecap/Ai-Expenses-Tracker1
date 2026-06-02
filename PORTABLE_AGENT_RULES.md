# Portable Agent Rules

Copy this file into any new project as `AGENTS.md`, `.agents/MANDATORY_RULES.md`,
or `docs/agent-playbooks/subagent-execution-rules.md`.

Purpose: prevent agents from wasting time in broad analysis, broad verification,
repeated command hangs, and unclear delegation.

## 1. First Read Gate

Before planning, editing, adding dependencies, running broad commands, or
delegating work, the agent must read:

- `AGENTS.md` if present.
- Project README or main documentation.
- Active spec/plan/tasks file if present.
- Existing architecture/design/test rules if present.

If instructions conflict, the newest explicit project rule wins. If still
unclear, stop and ask for clarification before editing.

## 2. Scope Rules

Every task must have:

- Exact objective.
- Exact files/folders owned by the task.
- Exact files/folders that must not be touched.
- Expected output.
- Verification commands.
- Stop condition.

Do not perform broad repo analysis unless the task explicitly asks for it.
Do not refactor unrelated files.
Do not fix unrelated failures unless the task explicitly owns cleanup.

## 3. Subagent Delegation Rules

Use subagents only for independent work.

Every subagent prompt must include:

```text
Task:
[exact task id and goal]

Owned files/folders:
[exact paths]

Do not touch:
[exact paths or "anything outside owned files"]

Forbidden:
- No broad repo analysis.
- No full-project analyze/test unless this task is final release readiness.
- Do not retry the same failing or hanging command more than twice.
- Do not chase unrelated failures.

Verification ladder:
1. Run the single focused test first.
2. Run analyzer/linter only on touched files and directly touched tests.
3. Run wider folder tests only if this task owns that folder.
4. Stop at first unrelated failure and report it separately.

If blocked:
Return BLOCKED with:
- exact command,
- exact error/failure,
- files changed,
- smallest next action.

Final report must include:
- DONE / DONE_WITH_CONCERNS / BLOCKED,
- tasks completed,
- files changed,
- commands run and results,
- unrelated failures,
- smallest next action.
```

## 4. Verification Ladder

Do verification from smallest to largest:

1. Single focused test for the changed behavior.
2. Analyzer/linter on exact changed files and exact changed tests.
3. Feature folder tests only if owned by the task.
4. Full project checks only for release-readiness tasks.

Do not run full-project `flutter analyze`, full `flutter test`, `npm test`,
`pytest`, or similar broad commands during normal feature work unless the task
explicitly owns full verification.

If a broad command is required, document existing failures first so old failures
are not confused with new regressions.

## 5. Command Retry Limit

Never retry the same failing or hanging command more than twice.

After two failed attempts:

- Stop running that command.
- Identify whether the failure is code, environment, dependency, or unrelated.
- Return `BLOCKED` if the next action needs controller/user action.

## 6. Flutter Rules

For Flutter projects:

- Prefer focused commands:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub path\to\focused_test.dart
& 'C:\flutter\bin\flutter.bat' analyze path\to\changed_file.dart path\to\changed_test.dart
```

- Replace `C:\flutter\bin\flutter.bat` with the project's Flutter path if
  different.
- Do not run full `flutter analyze` during feature work unless explicitly asked.
- Do not run full `flutter test` during feature work unless explicitly asked.
- Use `--no-pub` for focused tests when dependencies are already fetched.

## 7. Flutter Hang Protocol

If a Flutter command hangs, times out, or produces no output:

1. Stop rerunning it.
2. Check whether Dart works:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' --version
```

3. Check for Flutter lock files:

```powershell
Get-ChildItem 'C:\flutter\bin\cache' -Force |
  Where-Object { $_.Name -match '^lockfile$|flutter\.bat\.lock' }
```

4. Check visible related processes:

```powershell
Get-Process |
  Where-Object { $_.ProcessName -match 'flutter|dart|git|java|gradle' } |
  Select-Object Id,ProcessName,CPU,StartTime,Path
```

5. If Flutter cannot access `C:\flutter\bin\cache\lockfile`, treat it as an
   environment/sandbox issue, not a code failure.
6. Ask the controller/user before deleting lock files or stopping processes.
7. Do not force-stop all Git processes system-wide unless explicitly approved.

## 8. Widget Test Rules

For scrollable screens:

- Use `tester.ensureVisible(...)` before tapping controls below the fold.
- Prefer a fixed pump duration over `pumpAndSettle()` if the app has repeating
  animations or animated backgrounds.

Example:

```dart
await tester.ensureVisible(find.text('Continue'));
await tester.pump(const Duration(milliseconds: 300));
await tester.tap(find.text('Continue'));
await tester.pump();
await tester.pump(const Duration(seconds: 1));
```

For router tests:

- Do not wrap `MaterialApp.router` inside another `MaterialApp`.
- Provide a test harness that wraps only providers around `MaterialApp.router`.
- Keep router tests focused on navigation behavior, not full app setup.

## 9. Mock Data Rule

Production user flows must not show fake data as real data.

Allowed mock data:

- tests,
- previews,
- explicit demo mode,
- documentation examples.

Production screens should show one of:

- real data,
- loading,
- empty,
- error,
- unavailable.

Do not show fake financial, AI, purchase, account, or analytics data as if it
is real.

## 10. Security Rules

- Never put API keys, tokens, secrets, or private provider keys in mobile/client
  code.
- Do not print secrets in logs.
- AI provider calls must go through a server-side gateway/proxy.
- If screenshots/logs may expose secrets, warn before sharing.

## 11. Task Checkbox Rule

When using a task list:

- Mark each task complete immediately after its own verification passes.
- Do not wait until the end of a large batch.
- If a task is implemented but not verified, leave it unchecked or mark it in
  notes as implemented-not-verified.

## 12. Final Status Format

Every agent must finish with:

```text
Status: DONE | DONE_WITH_CONCERNS | BLOCKED

Completed:
- ...

Files changed:
- ...

Verification:
- command: result

Unrelated failures:
- ...

Remaining blocker / smallest next action:
- ...
```

## 13. Controller Rules

The main/controller agent must:

- Give subagents exact scope and exact files.
- Interrupt subagents that drift into broad analysis.
- Stop waiting if a subagent is stuck and ask for a concise status report.
- Integrate results only after reading changed files and focused verification.
- Keep a small issue log of unrelated failures instead of making every worker
  rediscover them.

## 14. Good Delegation Example

```text
Implement T012 only.

Owned files:
- test/features/onboarding/base_currency_screen_test.dart
- test/helpers/app_test_harness.dart only if needed

Goal:
Fix the currency onboarding test so selecting USD and tapping Continue reaches
the notifications route.

Rules:
- Do not inspect unrelated onboarding files unless needed for this test.
- Do not run full flutter analyze.
- Do not run all tests.
- Run only:
  & 'C:\flutter\bin\flutter.bat' test --no-pub test\features\onboarding\base_currency_screen_test.dart
- If Flutter hangs twice, stop and return BLOCKED.

Return:
DONE/BLOCKED, files changed, command result, smallest next action.
```

