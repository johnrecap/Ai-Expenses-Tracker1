# Tasks: Monetization Observability

**Input**: `specs/020-monetization-observability/spec.md`, `specs/020-monetization-observability/plan.md`

## Phase 1: Monetization Domain

- [ ] T020-001 [US1] Port monetization models into `lib/monetization/models/`
  - Why: Current `new app` has only `PremiumEntitlement`; it lacks policies and quota models.
  - Expected result: Models cover plans, policy, entitlement snapshot, AI quota, ad frequency, placement, consent, purchase verification, and rewarded credits.
  - Inputs: `Expense-Tracker-main/lib/monetization/models/`.
  - Implementation notes: Keep models UI-independent and serializable.
  - Possible bugs: model names conflict with existing `PremiumEntitlement`.
  - Fix strategy: migrate existing class or create compatibility mapper.
  - Verification: model unit tests.

- [ ] T020-002 [P] [US1] Implement monetization repositories in `lib/monetization/repositories/`
  - Why: Entitlement and policy need testable data access boundaries.
  - Expected result: Entitlement and policy repositories can return free/premium/test states.
  - Inputs: reference repositories.
  - Implementation notes: Keep purchase receipt verification server-ready; do not fake production verification as secure.
  - Possible bugs: UI assumes premium by default when repository fails.
  - Fix strategy: default to free with non-blocking upgrade prompt.
  - Verification: repository tests.

- [ ] T020-003 [US1] Expand `MonetizationCubit` in `lib/monetization/cubit/`
  - Why: UI needs state for plan, entitlement, consent, quota, and loading/failure.
  - Expected result: Cubit exposes free/premium state, refresh, restore, ad eligibility, and feature gate data.
  - Inputs: current cubit and reference cubit.
  - Implementation notes: Avoid calling ad SDK directly from cubit.
  - Possible bugs: cubit emits loading forever after purchase failure.
  - Fix strategy: include terminal failure state with retry.
  - Verification: `test/monetization/monetization_cubit_test.dart`.

## Phase 2: Ads And Premium UI

- [ ] T020-004 [US2] Re-enable and configure `google_mobile_ads` in `pubspec.yaml`
  - Why: Ads are missing because dependency is disabled for prototype build.
  - Expected result: Dependency and Android/iOS config are compatible with current build tooling.
  - Inputs: current `pubspec.yaml`, reference `google_mobile_ads_service.dart`.
  - Implementation notes: Use debug test ids only in debug; production ids via dart-define.
  - Possible bugs: Android Gradle incompatibility.
  - Fix strategy: update Android Gradle settings minimally and rerun debug build.
  - Verification: `flutter build apk --debug` or documented platform blocker.

- [ ] T020-005 [US2] Implement ad services in `lib/monetization/services/`
  - Why: Ad loading, consent, placement, and frequency caps need central policy.
  - Expected result: Services handle banner/interstitial/rewarded ads, consent, load errors, and premium suppression.
  - Inputs: reference ad services.
  - Implementation notes: Always fail open for core tracking; no blocking ad modal before expense save.
  - Possible bugs: ad load failure crashes widget tree.
  - Fix strategy: return empty/ad-unavailable state and render nothing.
  - Verification: ad service tests with fake ad client.

- [ ] T020-006 [P] [US2] Add ad widgets in `lib/monetization/widgets/`
  - Why: Screens need reusable ad slots instead of ad logic in feature widgets.
  - Expected result: Banner slot, interstitial gate, and rewarded AI credit button widgets exist.
  - Inputs: reference ad widgets, existing design tokens.
  - Implementation notes: Stable dimensions prevent layout shifts.
  - Possible bugs: banner height pushes bottom nav off screen.
  - Fix strategy: reserve fixed height and safe-area padding.
  - Verification: widget tests for free/premium/error states.

- [ ] T020-007 [US1] Add premium screen route and settings entry
  - Why: Users need clear premium benefits and upgrade/restore entry point.
  - Expected result: `/premium` route renders Free/Premium screen and settings link opens it.
  - Inputs: reference premium screen, current settings screen.
  - Implementation notes: Use localized copy; keep core features listed as free.
  - Possible bugs: marketing copy overflows Arabic layout.
  - Fix strategy: use compact rows and wrapping text.
  - Verification: premium screen widget tests in EN/AR.

## Phase 3: Feature Gates And Observability

- [ ] T020-008 [US1] Implement feature gates in `lib/monetization/services/feature_gate_service.dart`
  - Why: Advanced features need consistent free/premium behavior.
  - Expected result: Gates return allow/upgrade-prompt/quota-exceeded outcomes.
  - Inputs: reference feature gate service and AI quota policy.
  - Implementation notes: Do not gate basic expense tracking, login, categories, or settings.
  - Possible bugs: free users blocked from add expense.
  - Fix strategy: add explicit allowlist tests for core flows.
  - Verification: feature gate service tests.

- [ ] T020-009 [US3] Add observability services in `lib/observability/`
  - Why: Production debugging needs safe signals.
  - Expected result: Observability service, feature flag wrapper, and event model omit sensitive data.
  - Inputs: reference observability files.
  - Implementation notes: Use event codes and counts, not raw descriptions or receipt text.
  - Possible bugs: logs include exception messages with tokens.
  - Fix strategy: sanitize exceptions before logging and test redaction.
  - Verification: `test/observability/observability_service_test.dart`.

- [ ] T020-010 [US3] Wire feature flags in `lib/feature_flags/feature_gate_service.dart`
  - Why: Risky AI/ads/premium surfaces need controlled rollout.
  - Expected result: Local/default flags guard AI receipt, advice, ads, premium CTA, and sync comparison.
  - Inputs: current `feature_flags` service and reference readiness docs.
  - Implementation notes: Defaults should be safe and documented.
  - Possible bugs: feature flag disables core route by mistake.
  - Fix strategy: define flag ownership matrix and tests.
  - Verification: feature flag tests.

## Final Verification

- [ ] T020-011 [Polish] Run monetization and privacy-safe observability checks
  - Why: Monetization bugs can break builds or user trust.
  - Expected result: Tests pass, debug build status known, and sensitive search reviewed.
  - Inputs: completed monetization/observability work.
  - Implementation notes: Export screen remains out of scope.
  - Possible bugs: source search false positives.
  - Fix strategy: inspect each hit and document intentional safe placeholders.
  - Verification: `flutter analyze --no-pub`; `flutter test --no-pub test/monetization test/observability`; sensitive-source `rg` search.
