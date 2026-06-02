# Contract: Entry Quota

## Purpose

Define how manual and AI expense saves interact with free quotas, rewarded credits, and premium entitlement.

## Normal Manual Entry

**Before save**:

- App reads the local quota snapshot for the current local date.
- If premium, the save can continue.
- If free and normal remaining is greater than 0, the save can continue.
- If free and normal remaining is 0, show the normal rewarded-entry sheet.

**After save success**:

- Consume 1 normal entry using a unique operation ID.
- Refresh the visible quota count.

**After save failure**:

- Consume 0 entries.
- Show the normal save error.

## AI Entry

**Before save**:

- App reads the local quota snapshot for the current local date.
- If premium, the save can continue.
- If free and AI remaining is greater than 0, the save can continue.
- If free and AI remaining is 0, show the AI rewarded-entry sheet.

**After save success**:

- Consume 1 AI entry using a unique operation ID.
- Refresh the visible quota count.

**After save failure**:

- Consume 0 AI entries.
- Show the normal AI save error.

## Non-Goals

- Do not block AI saves with an additional normal-entry quota.
- Do not upload expenses to Firestore, PostgreSQL, or VPS for quota tracking.
- Do not grant credits from placeholder ads.

## Error States

- If quota cannot load: show "Entry limits are unavailable right now" and do not pretend the save was allowed by quota.
- If quota cannot be updated after a save: show a clear error and do not mark the operation as completed twice.
- If date rollover happens: reload today's snapshot before saving.
