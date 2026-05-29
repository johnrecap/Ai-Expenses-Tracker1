# Research: Reports, Budgets, And Goals

## Decision: Prefer native lightweight chart drawing for prototype charts

**Rationale**: The prototype needs visual chart fidelity without heavy dependencies or screenshot UI.

**Alternatives considered**:

- Use exported chart screenshots: rejected because all screens must be native widgets.
- Add chart dependency immediately: deferred until implementation proves native drawing is insufficient.

## Decision: Clamp progress values in components

**Rationale**: Budget and goal values may exceed targets and must not break progress visuals.

**Alternatives considered**:

- Trust mock data only: rejected because future mock changes could break layout.

## Decision: Use local draft state for edit budget

**Rationale**: Budget editing is visual-only and must not persist.

**Alternatives considered**:

- Store edited budgets: rejected as persistence.

## Decision: Keep reports, budgets, and goals in one batch

**Rationale**: They share summary, chart, and progress components.

**Alternatives considered**:

- Separate each screen group: rejected because it increases duplicate chart/progress decisions.
