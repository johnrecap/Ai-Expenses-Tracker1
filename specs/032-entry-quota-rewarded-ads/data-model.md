# Data Model: Entry Quota And Rewarded Ads

## Local Account Scope

**Purpose**: Stable identifier for quota ownership in local-only mode.

**Fields / Concepts**:

- `scopeId`: stable local account/device profile ID.
- `firebaseUid`: optional identity used only for AI gateway quota when present.
- `createdAt`
- `updatedAt`

**Rules**:

- Must exist even when the user is not signed in.
- Must not require Firestore, PostgreSQL, or VPS sync.
- Clearing app data can reset local quotas; this is acceptable for the first local-only version.

## Entry Quota Snapshot

**Purpose**: Current daily visible quota state for the user.

**Fields / Concepts**:

- `scopeId`
- `quotaDate`: local calendar date.
- `normalDailyLimit`: 5 for free users.
- `normalConsumed`: successful manual saves consumed today.
- `normalRewardedRemaining`: extra normal credits earned today.
- `aiDailyLimit`: 3 for free users.
- `aiConsumed`: successful AI saves consumed today.
- `aiRewardedRemaining`: extra complete AI credits earned today.
- `isPremium`
- `lastResetAt`

**Rules**:

- Normal remaining = daily limit - consumed + rewarded remaining.
- AI remaining = daily limit - consumed + rewarded remaining.
- Premium bypasses blocking but the snapshot can still be displayed for debug/testing.
- A new local date starts a new snapshot.

## Quota Consumption

**Purpose**: Records a successful quota-consuming save so double taps do not consume twice.

**Fields / Concepts**:

- `operationId`: stable ID for a save attempt.
- `scopeId`
- `quotaDate`
- `kind`: normal or AI.
- `expenseId`
- `createdAt`

**Rules**:

- Same `operationId` cannot consume twice.
- Consumption happens after local expense save success.
- Failed save creates no consumption record.

## Reward Grant

**Purpose**: Records a verified rewarded ad event.

**Fields / Concepts**:

- `rewardEventId`: ad SDK reward event ID or locally generated event ID paired with SDK callback identity.
- `scopeId`
- `quotaDate`
- `placement`: rewarded normal entries or rewarded AI entries.
- `amount`: 5 normal or 2 AI.
- `status`: pending, granted, rejected.
- `createdAt`
- `grantedAt`

**Rules**:

- Same reward event grants at most once.
- Pending grants do not add credits.
- Failed, dismissed, skipped, or unavailable ads become rejected or disappear without credit.

## Ad Placement Policy

**Purpose**: Defines whether an ad may be requested in a specific app context.

**Placements**:

- `homeBanner`
- `expensesInline`
- `rewardedNormalEntries`
- `rewardedAiEntries`
- Existing blocked placements: expense entry, expense save, AI typing, AI parsing.

**Rules**:

- Premium users see no ads.
- Ads require real provider availability and consent.
- Ads do not interrupt typing, parsing, saving, or active expense entry.
- Inline ads never replace expense data.

## AI Gateway Quota Status

**Purpose**: Server-side AI request protection returned by the Cloudflare Worker.

**Fields / Concepts**:

- `requestType`
- `allowed`
- `limit`
- `used`
- `remaining`
- `resetAt`

**Rules**:

- Protects AI provider cost, not local manual quota.
- Does not store app-owned financial data.
- A gateway quota block can stop parsing even when local AI save credits remain.
