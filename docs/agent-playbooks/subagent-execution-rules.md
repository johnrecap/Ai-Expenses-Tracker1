# Subagent Execution Rules

Purpose: prevent delegated agents from wasting time in broad analysis, broad
verification, or repeated tool hangs.

## What Went Wrong

In the onboarding/settings worker, the implementation was mostly complete, but
the agent lost time because:

- It ran an analyzer scope that was still too broad and surfaced unrelated
  legacy issues.
- It kept investigating after the actionable blocker was already small.
- A widget test failed because `Continue` was offscreen in the default test
  viewport.
- Retried Flutter commands left stale Flutter lock files and hanging Git
  child processes, causing later `flutter` commands to hang.

Other workers finished faster because they:

- Kept verification to touched files and focused tests.
- Reported unrelated full-project failures as pre-existing instead of chasing
  them.
- Returned a concise completion summary with files changed and exact remaining
  blocker.

## Required Delegation Prompt Rules

Every implementation subagent prompt MUST include:

1. Exact task ids and exact files/folders owned by the agent.
2. A hard ban on broad repo analysis unless the task explicitly owns it.
3. A hard ban on full-project `flutter analyze` and full `flutter test` unless
   the task is a final release-readiness task.
4. Verification ladder:
   - Run the single focused test first.
   - Run analyzer only on touched files and directly touched tests.
   - Run wider folder tests only if the task owns that folder.
   - Stop at the first unrelated failure and report it as unrelated.
5. A maximum of two attempts for the same failing command.
6. If stuck after two attempts, return `BLOCKED` with:
   - exact command,
   - exact failure,
   - smallest next action,
   - files changed so far.
7. Task checkboxes must be updated immediately after each verified task, not at
   the end of a large batch.

## Flutter Command Hang Protocol

If a Flutter command times out or produces no output:

1. Do not keep rerunning the same command.
2. In this workspace, Flutter commands often need to run outside the sandbox
   because Flutter writes to `C:\flutter\bin\cache\lockfile`. Use the approved
   escaped command path/prefix when available:

   ```powershell
   & 'C:\flutter\bin\flutter.bat' test <focused-test>
   & 'C:\flutter\bin\flutter.bat' analyze <touched-files>
   ```

   If the sandbox blocks the lockfile, report that instead of treating it as a
   test failure.
3. Check whether `dart --version` works:

   ```powershell
   & 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' --version
   ```

4. Check for stale Flutter lock files:

   ```powershell
   Get-ChildItem 'C:\flutter\bin\cache' -Force |
     Where-Object { $_.Name -match '^lockfile$|flutter\.bat\.lock' }
   ```

5. Check for visible hanging processes:

   ```powershell
   Get-Process |
     Where-Object { $_.ProcessName -match 'flutter|dart|git|java|gradle' } |
     Select-Object Id,ProcessName,CPU,StartTime,Path
   ```

6. If stale locks or hanging processes exist, report `BLOCKED: Flutter tool
   hang` to the controller. Do not repeatedly run Flutter.
7. The controller may remove stale Flutter lock files or stop specific known
   stale PIDs after approval. Do not force-stop all Git processes system-wide
   without explicit user approval.

## Widget Test Rules

For screens with scrolling content:

- Use `tester.ensureVisible(...)` before tapping controls below the fold.
- Prefer `tester.pump(const Duration(...))` over `pumpAndSettle()` when the app
  contains animated backgrounds or repeating animations.
- If a tap misses because a widget is offscreen, fix the test viewport/scroll
  once and rerun only that test.
- Do not broaden to a whole folder test until the single failing test passes.

## Required Final Status Format

Agents must end with one of:

- `DONE`: task complete, focused verification passed.
- `DONE_WITH_CONCERNS`: task complete, but unrelated failures or risk remain.
- `BLOCKED`: task cannot continue without controller/user action.

The final status must include:

- tasks completed,
- files changed,
- commands run and results,
- exact unrelated failures,
- smallest next action.
