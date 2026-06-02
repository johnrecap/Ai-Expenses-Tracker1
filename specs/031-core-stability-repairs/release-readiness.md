# Release Readiness: Core Stability Repairs

## Current Release Decision

Status: **BLOCKED**

The app must not be treated as production-release ready until the items below
are completed and verified. Core local storage and AI privacy repairs can
continue independently, but store release is blocked by signing, privacy,
consent, purchases, and ads readiness.

## Required Evidence

| Area | Status | Owner | Evidence | Required Check |
| --- | --- | --- | --- | --- |
| Android release signing | BLOCKED | Release owner | `android/app/build.gradle.kts` currently uses debug signing for `release` | Replace debug signing with a real release keystore and verify release build signing before upload |
| Privacy policy | BLOCKED | Product/Legal | Settings currently says Privacy Policy is not available yet | Publish a real privacy policy and link it inside the app before release |
| Terms of service | BLOCKED | Product/Legal | Settings currently says Terms of Service is not available yet | Publish real terms or remove any store copy that implies terms are available |
| Analytics consent | BLOCKED | Product/Legal/Engineering | `lib/services/analytics/analytics_service.dart` can initialize Firebase Analytics, but no user-facing consent gate is release-approved yet | Add consent decision, document allowed events, and verify no raw financial data is logged |
| Ads consent | BLOCKED | Product/Legal/Engineering | Ads are disabled through `UnavailableAdService` and no consent UI is release-approved yet | Add ad provider, consent flow, privacy review, and non-blocking placement verification before showing ads |
| Purchases | BLOCKED | Engineering | `PurchaseService` returns unavailable for purchase and restore | Connect store billing/restore and verify entitlement state before enabling upgrade buttons |
| Premium claims | PASS FOR PLACEHOLDER | Engineering | `FreePremiumScreen` disables upgrade and restore and states premium is unavailable | Keep placeholder copy until real billing and entitlement verification exist |
| Local-only financial data | PASS FOR THIS FEATURE | Engineering | Spec and guardrails require local-only financial data by default | Re-run local-only search before release and do not enable Firestore/VPS financial sync without a separate approved plan |
| AI privacy | PASS FOR THIS FEATURE | Engineering | AI advice uses compact explicit requests; worker rejects unsafe payloads | Re-run focused AI privacy and worker tests before release |

## Release Gate

Release can move from **BLOCKED** to **READY FOR STORE REVIEW** only after:

1. Release signing no longer uses debug signing.
2. Privacy policy and terms are available from the app.
3. Analytics and ads have explicit consent and privacy review.
4. Purchase and restore flows verify real entitlement state.
5. Focused local data, AI privacy, Settings/notifications, Home, and AI expense
   checks pass for the release candidate.

## Commands And Checks

Focused checks used by this repair feature:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\free_premium_readiness_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\free_premium_screen_test.dart test\monetization\monetization_honesty_test.dart
& 'C:\flutter\bin\flutter.bat' analyze test\monetization\free_premium_readiness_test.dart lib\monetization
```

Manual release review:

- Confirm `android/app/build.gradle.kts` release signing is not debug.
- Confirm Settings links open real privacy policy and terms.
- Confirm analytics/ad consent is present before any analytics/ad provider is
  enabled for production users.
