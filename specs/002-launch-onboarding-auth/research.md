# Research: Launch, Onboarding, And Auth Mock

## Decision: Treat auth screens as visual forms only

**Rationale**: Real authentication is explicitly forbidden, while the exported screens still need native UI counterparts.

**Alternatives considered**:

- Add auth package: rejected by constitution.
- Leave buttons disabled: rejected because the prototype should be navigable.

## Decision: Keep onboarding preferences in local state only

**Rationale**: Language, currency, and notification screens need selected states, not persistence.

**Alternatives considered**:

- Use shared preferences: rejected as persistence.
- Use OS notification permission APIs: rejected because the feature is UI-only.

## Decision: Use reusable panels and option cards

**Rationale**: Login/sign-up and onboarding screens share visual structures.

**Alternatives considered**:

- Create screen-local cards: rejected because it violates reuse rules.

## Decision: Manually clean Arabic strings

**Rationale**: Exported HTML may contain encoding issues. Arabic readiness should be deliberate.

**Alternatives considered**:

- Copy HTML text exactly: rejected due to mojibake risk.
