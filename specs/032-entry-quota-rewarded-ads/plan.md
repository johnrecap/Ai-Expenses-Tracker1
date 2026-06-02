# Implementation Plan: Entry Quota And Rewarded Ads

**Branch**: `032-entry-quota-rewarded-ads` | **Date**: 2026-06-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/032-entry-quota-rewarded-ads/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Loaded matching Spec Kit and second-agent review skills.

**Skills used**:

- `second-agent-solution-review`: read-only critique loop for the quota/ad plan.
- `speckit-specify`: specification.
- `speckit-plan`: implementation plan and design artifacts.
- `speckit-tasks`: execution tasks.

## Summary

Add a real local quota and ad reward system for free users:

- 5 daily normal manual entries.
- 3 daily complete AI entries.
- Rewarded manual ad grants 5 more normal entries for today.
- Rewarded AI ad grants 2 more complete AI entries for today.
- Premium hides ads and bypasses free-tier quota.
- Banner and inline ads appear only in safe non-blocking placements.

The feature keeps financial data local-only. Server calls are limited to explicit AI gateway requests, ad SDK requests, purchase/restore checks, and AI quota/abuse protection.

## Why

Mohamed wants monetization based on AI and ads while keeping the app small and local-only. The current code has only placeholder monetization:

- `FeatureGateService.canUseAI()` is a stub and does not enforce real quota.
- `AdService` has no rewarded-ad API.
- `MonetizationCubit` has no reward flow.
- Ads are already blocked during core expense entry, which must remain true.

This plan adds a trustworthy quota layer without fake ad success or cloud financial storage.

## Expected Result

When implementation is complete:

- Manual add shows remaining normal entries and blocks only when the free daily normal quota is exhausted.
- AI add shows remaining AI entries and blocks only when the free daily AI quota is exhausted.
- Failed saves do not consume quota.
- Rewarded ads grant credits only after verified completion.
- Duplicate taps/callbacks cannot double-consume or double-grant.
- Home and Expenses list can show safe banner/inline ads for free users.
- Premium users see no ads and are not blocked by free quotas.
- AI gateway quota remains separate from local AI save quota.

## Source References

- `specs/032-entry-quota-rewarded-ads/spec.md`
- `specs/032-entry-quota-rewarded-ads/research.md`
- `specs/032-entry-quota-rewarded-ads/data-model.md`
- `specs/032-entry-quota-rewarded-ads/contracts/quota-contract.md`
- `specs/032-entry-quota-rewarded-ads/contracts/rewarded-ads-contract.md`
- `specs/032-entry-quota-rewarded-ads/contracts/ad-placement-contract.md`
- `specs/032-entry-quota-rewarded-ads/contracts/ai-gateway-quota-contract.md`
- `lib/monetization/services/ad_service.dart`
- `lib/monetization/cubit/monetization_cubit.dart`
- `lib/monetization/models/entitlement_snapshot.dart`
- `lib/feature_flags/feature_gate_service.dart`
- `lib/features/expenses/presentation/add_expense_quick_screen.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`
- `lib/features/expenses/presentation/expenses_list_screen.dart`
- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `workers/ai-gateway/src/quota/quotaService.ts`
- `workers/ai-gateway/test/quota.test.ts`
- `test/monetization/local_entitlement_ads_test.dart`
- `test/monetization/monetization_honesty_test.dart`

## Technical Context

**Language/Version**: Flutter / Dart app, TypeScript Cloudflare Worker for AI gateway.

**Primary Dependencies**: Flutter SDK, BLoC/Cubit, GoRouter, Drift/SQLite local persistence, path_provider, current monetization abstractions, optional AdMob SDK when Android build alignment is completed.

**Storage**: Quota and reward records are local-only. App-owned financial data remains in Drift/SQLite local storage. Firestore/PostgreSQL/VPS sync are not used for this feature.

**Testing**: Focused Flutter tests for quota policy, local quota persistence, manual save integration, AI save integration, rewarded ad results, ad placement policy, premium bypass, and focused worker quota tests when gateway alignment is touched.

**Target Platform**: Android-first Flutter app with Arabic/English and RTL/LTR.

**Project Type**: Production Flutter app with local-only financial data and explicit AI/ad/purchase server actions.

**Performance Goals**:

- Quota read before Save completes from local storage without visible delay.
- Save flow remains responsive and does not wait on ad network.
- Reward sheet opens immediately after a local quota block.
- Expenses list scroll remains smooth with inline ad slots.

**Constraints**:

- No fake ad success.
- No API keys or ad secrets in Flutter code.
- No financial cloud writes.
- Ads must not interrupt entry, save, typing, or AI parsing.
- Arabic RTL and English LTR must fit on narrow screens.
- Do not run broad repo analysis or full-project tests during normal task execution.

**Scale/Scope**:

- Owned Flutter areas: `lib/monetization/`, `lib/feature_flags/`, manual and AI add screens, Home, Expenses list.
- Owned test areas: `test/monetization/`, focused expense/dashboard tests.
- Owned worker area only if AI gateway quota limits must be aligned: `workers/ai-gateway/src/quota/` and `workers/ai-gateway/test/quota.test.ts`.

## Constitution Check

**Gate status**: PASS for planning.

- `AGENTS.md` and constitution were read.
- `.agents/skill-matcher.json` was checked.
- Relevant Spec Kit and second-agent review skills were used.
- Production Flutter app scope is preserved.
- Native Flutter UI is planned.
- No WebView or HTML rendering is planned.
- App-owned financial data remains local-only.
- Remote calls are limited to explicit AI, ads, purchase/restore, and quota/abuse protection.
- No mock/demo financial data is presented as real.
- No fake ad rewards are allowed.
- Responsive and RTL/LTR checks are planned.

## Project Structure

### Documentation

```text
specs/032-entry-quota-rewarded-ads/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    quota-contract.md
    rewarded-ads-contract.md
    ad-placement-contract.md
    ai-gateway-quota-contract.md
  tasks.md
```

### Source Code Areas

```text
lib/
  monetization/
    cubit/
    models/
    services/
    widgets/
  feature_flags/
  features/
    expenses/
    dashboard/

test/
  monetization/
  features/
    expenses/
    dashboard/

workers/ai-gateway/
  src/quota/
  test/quota.test.ts
```

**Structure Decision**: Create quota-specific monetization files instead of putting quota logic inside each screen. Screens should ask a quota service/cubit whether the save can continue, then consume after durable save success.

## Reuse Strategy

- Reuse `AdPolicy`, `AdPlacement`, and `MonetizationCubit` instead of adding screen-local ad logic.
- Reuse existing `showAppToast`, `GradientButton`, theme tokens, spacing, and sheet/card patterns.
- Add shared monetization widgets for quota chips and reward sheets under `lib/monetization/widgets/`.
- Keep manual and AI screens visually aligned with existing app theme.

## Data Strategy

- Store quota snapshots, consumption records, and reward grants locally.
- Use stable local account/device scope when no Firebase user exists.
- Do not write quota state to Firestore/PostgreSQL/VPS.
- Do not use fake test data in production UI.
- Tests may use fake ad services and fake local quota stores, but production unavailable ad provider must return no reward.

## Possible Bugs And Fix Strategy

- **Double quota consumption from double tap**: use operation IDs and disable save while saving; add tests.
- **Duplicate reward grants**: store reward event IDs and reject duplicates.
- **Reward granted by placeholder service**: keep unavailable service returning no reward and test it.
- **AI blocked twice**: AI save consumes AI credit only; test no normal quota block in AI flow.
- **Failed save consumes quota**: consume after success state only; test failure path.
- **Date rollover bugs**: normalize by local date and reload snapshot when date changes.
- **Ad SDK breaks Android build**: enable SDK in a separate owned task with focused build verification.
- **Ad overlaps FAB/nav**: visual checks on Home and Expenses list at required viewports.
- **RTL overflow in reward sheet**: widget tests and manual viewport checks.
- **Gateway local quota confusion**: local quota gates saves; gateway quota gates provider calls.

## Verification Plan

Focused Flutter tests:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\entry_quota_policy_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entry_quota_store_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\rewarded_ad_quota_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_quota_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_quota_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\dashboard\home_ads_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\expenses_inline_ads_test.dart
```

Scoped analyzer:

```powershell
& 'C:\flutter\bin\flutter.bat' analyze <touched lib files> <touched test files>
```

Worker tests if quota alignment is touched:

```powershell
cmd /c npm --prefix workers/ai-gateway test -- quota
```

Guardrail searches:

```powershell
rg -n "FirebaseFirestore|PostgreSQL|vpsLocalFirst|grant.*unavailable|reward.*fake|WebView|webview" lib test workers
rg -n "expenseEntry|expenseSave|aiTyping|aiParsing" lib\monetization test\monetization
```

Visual checks:

```text
360x800 English LTR
360x800 Arabic RTL
375x812 English LTR
375x812 Arabic RTL
390x844 English LTR
390x844 Arabic RTL
```

## Phase 0: Research

Completed in [research.md](./research.md).

Key decisions:

- Daily quotas.
- Local account/device scope.
- AI credits are complete AI entries.
- Quota consumed only after successful save.
- Rewarded grants require verified completion.
- Banner and inline ads are non-blocking only.
- Ad SDK activation must not create fake rewards.

## Phase 1: Design

Completed in:

- [data-model.md](./data-model.md)
- [contracts/quota-contract.md](./contracts/quota-contract.md)
- [contracts/rewarded-ads-contract.md](./contracts/rewarded-ads-contract.md)
- [contracts/ad-placement-contract.md](./contracts/ad-placement-contract.md)
- [contracts/ai-gateway-quota-contract.md](./contracts/ai-gateway-quota-contract.md)
- [quickstart.md](./quickstart.md)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Real rewarded ad provider is required for actual grants | Mohamed requested rewarded ads that add entries | Placeholder rewards would be fake success and violate project rules |
| Local quota and gateway quota both exist | Local quota controls saved entries, gateway quota protects AI provider cost | Using only one quota would either fail local-only mode or leave AI cost unprotected |

## Stop Condition

Stop implementation when:

- Manual quota, AI quota, and rewarded grants pass focused tests.
- Placeholder ad services cannot grant credits.
- Premium hides ads and bypasses free quota.
- Banner/inline placements are safe on required viewports.
- AI gateway quota remains separate from local save quota.
- No financial cloud storage is introduced.
