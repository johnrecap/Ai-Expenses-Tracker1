# Quickstart: Entry Quota And Rewarded Ads

## Purpose

Use this quickstart to execute the quota and ads plan without broad repo analysis or fake ad success.

## Required First Read

1. `AGENTS.md`
2. `.specify/memory/constitution.md`
3. `.agents/MANDATORY_RULES.md`
4. `.agents/workflows/development.md`
5. `.agents/skill-matcher.json`
6. `specs/032-entry-quota-rewarded-ads/spec.md`
7. `specs/032-entry-quota-rewarded-ads/plan.md`
8. `specs/032-entry-quota-rewarded-ads/tasks.md`

## Execution Order

1. Build quota policy and local quota storage.
2. Add quota cubit/service and UI count widgets.
3. Wire manual save quota.
4. Wire AI save quota.
5. Extend ad service for rewarded results without fake grants.
6. Wire rewarded quota sheets.
7. Add safe banner and inline ad slots.
8. Add premium bypass and settings visibility.
9. Align AI gateway quota only if needed.
10. Run focused verification.

## Focused Verification Ladder

Use this ladder for each task:

1. Run the single focused test for the behavior.
2. Run analyzer only on touched files and directly touched tests.
3. Run wider tests only if the task owns that folder.
4. Stop at unrelated failures and report them separately.

Flutter commands may need approval/escalation because Flutter writes to `C:\flutter\bin\cache\lockfile`.

## Example Commands

Quota policy and store:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\entry_quota_policy_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entry_quota_store_test.dart
```

Manual and AI save integration:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_quota_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_quota_test.dart
```

Rewarded ads:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\rewarded_ad_quota_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart
```

Banner and inline ads:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\dashboard\home_ads_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\expenses_inline_ads_test.dart
```

Worker quota, only if touched:

```powershell
cmd /c npm --prefix workers/ai-gateway test -- quota
```

## Manual Checks

- Free user sees remaining entries on manual add screen.
- Free user sees remaining AI entries on AI add screen.
- Sixth manual save opens reward choice instead of silently failing.
- Fourth AI save opens AI reward choice instead of silently failing.
- Failed save does not reduce quota.
- Failed/skipped/unavailable ad does not add credits.
- Completed rewarded manual ad adds 5 entries once.
- Completed rewarded AI ad adds 2 AI entries once.
- Premium user sees no ads and no quota block.
- Home and Expenses ads do not overlap bottom nav or FAB.

## Stop Conditions

Stop and report `BLOCKED` if:

- Ad SDK cannot be enabled without Android build changes outside the approved task.
- Reward callback cannot be verified by a real provider.
- Quota persistence cannot be made durable without broad storage refactor.
- A focused Flutter command hangs twice.
- Visual checks show ad overlap with Save, input, nav, or FAB.
