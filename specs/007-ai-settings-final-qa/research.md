# Research: AI, Settings, Empty States, And Final QA

## Decision: AI interactions are local mock interactions only

**Rationale**: The product promise is AI-heavy, but the current prototype scope forbids real AI/API calls.

**Alternatives considered**:

- Add OpenAI/Anthropic or chat API client: rejected by UI-only scope.
- Disable inputs entirely: rejected because the UI should demonstrate interaction states.

## Decision: Arabic chat text is manually curated

**Rationale**: Exported HTML can contain mojibake and RTL mistakes. Clean Arabic text is required for credible RTL testing.

**Alternatives considered**:

- Copy HTML text directly: rejected due to encoding risk.

## Decision: Settings toggles are local state only

**Rationale**: Settings must look interactive without persistence or account services.

**Alternatives considered**:

- Store settings in preferences: rejected as persistence.

## Decision: Final QA belongs in this feature

**Rationale**: This batch completes the screen set and must validate cross-feature compliance.

**Alternatives considered**:

- Leave QA outside Spec Kit: rejected because compile and UI-only gates are constitution requirements.
