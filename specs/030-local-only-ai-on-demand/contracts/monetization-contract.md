# Contract: Premium And Ads Without App Data Backend

## Premium

Premium unlocks:

- No ads.
- Higher AI request limits.
- Advanced AI advice/features.
- Future premium-only widgets or tools.

Premium state source:

- Google Play Billing / App Store purchase APIs.
- Local cached entitlement snapshot.

No financial app data backend is required for premium state.

## Ads

Ads apply to free users only.

Rules:

- Ads must not block adding expenses.
- Ads must not cover active typing or AI parsing.
- Ads must not show for premium users.
- Ads respect user consent state and platform policy.

Allowed placements:

- Non-intrusive banner on non-critical screens.
- Optional rewarded ad for extra AI credits if implemented later.
- Interstitial only after non-critical navigation, not during save.

## AI Limits

Free users:

- Limited AI advice/actions per day.
- Local advice remains unlimited.

Premium users:

- Higher AI quota or unlimited within gateway policy.

Quota source:

- Local counters for UX gating.
- AI gateway operational quota for abuse protection.

The gateway must not store full financial data.
