# Implementation Plan: Monetization Observability

**Branch**: `020-monetization-observability` | **Date**: 2026-05-29 | **Spec**: `specs/020-monetization-observability/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Complete monetization and observability layers by porting plan/policy/entitlement models, ad services/widgets, purchase abstraction, feature gates, feature flags, and privacy-safe logging.

## Why

`new app` has only four monetization files and no observability module. The reference app has mature models, services, widgets, and tests. Production readiness requires graceful monetization and safe debugging signals.

## Expected Result

- Complete `lib/monetization/` model/service/widget structure.
- Premium screen and settings integration.
- Ad widgets/gates that respect consent and premium state.
- `lib/observability/` and feature flag service.
- Tests for policy, cubit, widgets, gates, and redaction.

## Source References

- `Expense-Tracker-main/lib/monetization/`
- `Expense-Tracker-main/lib/screens/monetization/`
- `Expense-Tracker-main/lib/observability/`
- `Expense-Tracker-main/test/monetization/`
- `new app/lib/monetization/`
- `new app/lib/features/settings/presentation/settings_screen.dart`

## Technical Context

**Primary Dependencies**: `google_mobile_ads`, potential `in_app_purchase`, `flutter_bloc`, existing server API for future verification.

**Storage**: Entitlement repository, local feature flags, server-backed purchase validation later.

**Testing**: Unit tests for policies/services, widget tests for ads/premium screen, observability redaction tests.

**Constraints**: No secrets in source; no blocking free tracking; no raw finance data in logs.

## Constitution Check

- Monetization is allowed by constitution.
- No Export screen work.
- No Firebase Functions work.
- Native Flutter UI and localization required.

## Project Structure

```text
lib/monetization/
lib/features/monetization/ or lib/screens/monetization/
lib/observability/
lib/feature_flags/
lib/features/settings/
test/monetization/
test/observability/
```

## Implementation Batches

### Batch 1 - Monetization Domain

**Expected result**: Models, repositories, policies, and cubit represent free/premium state.

### Batch 2 - Ads And Purchase UI

**Expected result**: Ad slots and premium screen work with test/dummy services.

### Batch 3 - Feature Gates And Observability

**Expected result**: Gates and privacy-safe events wrap risky features.

### Batch 4 - QA And Policy Checks

**Expected result**: Tests and source searches verify no secrets/sensitive logs.

## Possible Bugs And Fix Strategy

- **Ad SDK breaks Android build**: align Gradle plugin/Android SDK before enabling dependency.
- **Premium state not refreshed after purchase**: refresh entitlement after purchase/restore callback.
- **Free users blocked from core tracking**: gate only advanced AI/ads/report features, not add expense.
- **Sensitive logs leak descriptions**: event model should accept semantic codes, not raw text.
- **Test ads shipped to release**: require dart-define ad unit ids and debug guards.

## Verification Plan

```powershell
flutter analyze --no-pub
flutter test --no-pub test/monetization test/observability
rg -n "description|receipt|pin|password|token|API_KEY" lib/observability lib/monetization
```

## Stop Condition

Monetization is complete enough for controlled testing, premium removes ads, free tracking remains usable, and observability is privacy-safe.
