# Research: Foundation

## Decision: Build a native Flutter foundation before feature screens

**Rationale**: The Stitch exports repeat visual structures. Building shared theme, layout, widgets, routes, and mock data first reduces drift.

**Alternatives considered**:

- Implement screens directly: rejected because it duplicates UI and makes RTL/responsive fixes expensive.
- Render exported HTML: rejected by constitution and no-WebView rule.

## Decision: Use static in-memory mock data only

**Rationale**: The prototype is UI-only. Static data supports realistic lists and cards without implying backend behavior.

**Alternatives considered**:

- Local database or preferences: rejected as persistence.
- Remote fixtures: rejected as API/runtime dependency.

## Decision: Centralize route strings and screen placeholders

**Rationale**: Later batches can replace placeholders without route drift.

**Alternatives considered**:

- Hardcode route strings in buttons: rejected because it makes navigation brittle.

## Decision: Use directional Flutter layout APIs from the start

**Rationale**: Arabic RTL readiness is a hard requirement, and retrofitting directionality is costly.

**Alternatives considered**:

- Add RTL at the end: rejected due to high overflow and alignment risk.

## Decision: Keep charts and complex visuals out of foundation

**Rationale**: Foundation should define primitives and tokens. Chart implementation is decided in the reports plan.

**Alternatives considered**:

- Add chart package immediately: rejected until report needs prove it is worth the dependency.
