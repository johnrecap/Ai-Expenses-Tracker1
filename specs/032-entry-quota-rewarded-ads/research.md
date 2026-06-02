# Research: Entry Quota And Rewarded Ads

## Decision 1: Quota Period

**Decision**: Use daily quotas.

**Rationale**: Daily quotas are easier for users to understand, reduce frustration, and avoid making the app feel permanently locked after a few saves. This matches existing AI quota wording in the gateway model that already talks about daily limits.

**Alternatives considered**:

- Lifetime quota: rejected because it would make the app unusable quickly.
- Monthly quota: viable later, but harder to explain and balance for a small free tier.

## Decision 2: Local Account Scope

**Decision**: Store quotas per stable local account/device profile.

**Rationale**: The app is local-only for financial data. Manual saves can happen with no Firebase user, so quota storage cannot depend on a cloud user ID. Firebase identity can remain for AI gateway quota and abuse protection when present.

**Alternatives considered**:

- Firebase UID for all quota: rejected because login is not required for local tracking.
- Server-side manual quota: rejected because manual entries do not need a backend in the local-only product direction.

## Decision 3: Avoid AI Double-Wall

**Decision**: AI saves consume AI entry credit only. Rewarded AI ads grant complete AI entries.

**Rationale**: If an AI save consumes both AI credit and normal-entry credit, users can watch an AI ad and still be blocked by normal quota. The second-agent review identified that as the highest UX risk. AI gateway quota still protects provider cost at parse time.

**Alternatives considered**:

- AI saves consume both normal and AI balances: rejected because it creates confusing double blocking.
- Rewarded AI grants both AI and normal credits: viable, but more complex than making AI credits complete entries.

## Decision 4: Consume Quota Only After Successful Save

**Decision**: Consume normal or AI entry quota only after the expense is saved successfully.

**Rationale**: A failed local save should not cost the user a daily entry. This follows the app's honesty rule: no false success and no hidden data loss.

**Alternatives considered**:

- Consume before save: rejected because failed local persistence would unfairly reduce quota.
- Consume at screen open or parse: rejected because browsing or retrying should not count as a saved expense.

## Decision 5: Rewarded Ads Require Verified Completion

**Decision**: Credits are granted only after the ad service reports a verified rewarded completion for the requested placement and event ID.

**Rationale**: Current `UnavailableAdService` must not grant fake success. Google AdMob rewarded guidance uses a reward callback such as `onUserEarnedReward`, and rewarded inventory requires clear opt-in and promised reward delivery.

**Alternatives considered**:

- Grant immediately before showing the ad: rejected because users could receive credits without completing the ad.
- Grant from placeholder services: rejected because project rules forbid fake success.

## Decision 6: Banner And Inline Placement

**Decision**: Banner and inline ads are non-blocking, hidden for premium users, and excluded from expense entry/save/AI typing/parsing flows. Inline ads start conservatively after every 6 expense rows and do not appear in short lists.

**Rationale**: Current `AdPolicy` already blocks ads for core flow placements. Ad placement guidance warns against banners near interactive controls or text input because accidental clicks are a risk.

**Alternatives considered**:

- Interstitial ads after save: rejected because it interrupts a core money-tracking flow.
- Banner on add expense screens: rejected because it is near inputs and save controls.

## Decision 7: Ad SDK Activation

**Decision**: The plan includes real rewarded/banner provider work, but no reward is granted until the provider is actually connected and returns verified callbacks.

**Rationale**: `pubspec.yaml` currently notes that `google_mobile_ads` is disabled for the prototype build because Android Gradle needs alignment. Implementation must not pretend ads work before SDK readiness.

**Alternatives considered**:

- Keep placeholder only: rejected because Mohamed requested functional ads.
- Add SDK without Android verification: rejected because it can break device builds.

## Official Policy References

- Google AdMob rewarded ads policy and guidance: `https://support.google.com/admob/answer/7313578`
- Google Mobile Ads Flutter rewarded guide: `https://developers.google.com/admob/flutter/rewarded`
- Google AdMob banner placement guidance: `https://support.google.com/admob/answer/6128877`
