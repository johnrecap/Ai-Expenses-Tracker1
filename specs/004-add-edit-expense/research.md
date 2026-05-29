# Research: Add And Edit Expense

## Decision: Use local form state and controllers only

**Rationale**: Add/edit screens need realistic interaction without persistence.

**Alternatives considered**:

- Persist drafts: rejected as persistence.
- Mutate global mock arrays: rejected because mock data should remain deterministic.

## Decision: Mock AI and receipt parsing visually

**Rationale**: The UI should demonstrate AI/receipt concepts without service calls, camera, OCR, or uploads.

**Alternatives considered**:

- Integrate AI/OCR/camera packages: rejected by UI-only scope.
- Remove AI/receipt modes: rejected because they are detected Stitch screens.

## Decision: Shared add/edit components

**Rationale**: Four screens share segmented modes, amount presentation, fields, and CTAs.

**Alternatives considered**:

- Per-screen forms: rejected due to duplication and inconsistent fixes.
