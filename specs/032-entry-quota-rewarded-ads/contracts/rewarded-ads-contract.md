# Contract: Rewarded Ads

## Purpose

Define the only acceptable way to grant extra entries from ads.

## Rewarded Normal Entries

**User-facing promise**: Watch one ad to get 5 extra entries today.

**Grant**:

- Placement: `rewardedNormalEntries`.
- Amount: 5 normal entries.
- Validity: current local date.
- Grant trigger: verified rewarded completion only.

## Rewarded AI Entries

**User-facing promise**: Watch one ad to get 2 AI entries today.

**Grant**:

- Placement: `rewardedAiEntries`.
- Amount: 2 complete AI entries.
- Validity: current local date.
- Grant trigger: verified rewarded completion only.

## Required Result States

- `granted`: ad completed and reward event was accepted once.
- `dismissed`: user closed or skipped the ad; no credit.
- `unavailable`: provider, consent, or network unavailable; no credit.
- `failed`: provider failed; no credit.
- `duplicate`: callback already processed; no extra credit.

## Rules

- The reward sheet must show the exact reward before the ad starts.
- No ad starts automatically after a failed save.
- User must explicitly tap the reward action.
- The same reward event ID cannot grant more than once.
- Premium users should not need rewarded ads.
- The placeholder `UnavailableAdService` must always return no reward.
