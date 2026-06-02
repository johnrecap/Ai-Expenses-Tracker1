# Quickstart: Local Only With AI On Demand

## Implementation Order

1. Add a new local-only runtime mode or make local-only the production default.
2. Ensure authenticated repository factory does not instantiate Firestore/VPS app-data repositories in local-only mode.
3. Confirm Drift/SQLite persistence covers all app-owned financial entities.
4. Disable or hide cloud sync/VPS/Firestore settings and user-facing wording.
5. Build `AdviceSummary` from local data.
6. Cache/precompute `AdviceSummary` after relevant local data changes.
7. Build local deterministic tips from `AdviceSummary`.
8. Change AI advice flow so the button sends only the compact summary.
9. Add timeout, retry, local fallback, and last-advice cache behavior.
10. Gate premium AI features and ad visibility from local entitlement/ad policy.
11. Add tests that prove no Firestore/PostgreSQL app-data writes happen in local-only mode.
12. Add payload-size and speed-budget tests for advice summary.

## Focused Verification

Use focused checks only during implementation:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\local_only_repository_factory_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\advice_summary_builder_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_payload_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart
```

Analyzer should be scoped to touched files only.

## Manual Checks

- Turn on airplane mode.
- Add expense.
- Edit expense.
- Open dashboard/reports/budget.
- Confirm all work offline.
- Open advice screen.
- Confirm local advice appears immediately.
- Tap Ask AI while online.
- Confirm only summary is sent.
- Confirm failure keeps local advice visible.
- Confirm premium hides ads.

## Stop Condition

Stop when local-only app data mode is the default, no financial app data goes to Firestore/PostgreSQL, local advice is instant, AI advice sends a compact summary only, and premium/ads behavior works without a financial-data backend.
