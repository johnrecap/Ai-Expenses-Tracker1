# Contract: Release Readiness Tracking

## Scope

Owned files:

- `lib/monetization/`
- `lib/services/analytics/`
- `android/app/build.gradle.kts`
- docs/spec notes for release readiness
- focused monetization/analytics tests only when this phase is active

## Guarantees

1. Ads and purchases are not described as production-ready unless connected and verified.
2. Feature gating does not rely on fake always-zero usage counts in production.
3. Release signing is required before production release.
4. Analytics and ads require consent/privacy policy review before production release.
5. Release readiness work does not block core local-data and AI privacy repairs.

## Acceptance Tests

- Free/Premium screen does not show fake purchase success.
- Purchase restore unavailable state is honest.
- Release checklist blocks release when signing/privacy/consent are incomplete.
