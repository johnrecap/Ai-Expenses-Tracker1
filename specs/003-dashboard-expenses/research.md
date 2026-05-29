# Research: Dashboard And Expenses

## Decision: Transaction components live under expenses and are reused by dashboard

**Rationale**: Transactions are domain-specific but appear in both dashboard and expenses list.

**Alternatives considered**:

- Duplicate transaction rows in dashboard: rejected by reuse rule.
- Put every domain widget in core: rejected because not every screen uses transaction rows.

## Decision: Filter behavior is local-only

**Rationale**: The prototype needs interactive controls without persistence or backend queries.

**Alternatives considered**:

- Query repository or database: rejected by UI-only scope.
- Disable all controls: rejected because the prototype should demonstrate interaction states.

## Decision: Bottom sheet uses native Flutter modal surface

**Rationale**: The export is a modal sheet; native sheet gives correct mobile interaction and avoids WebView.

**Alternatives considered**:

- Full-screen route only: rejected because it loses modal behavior.
- Render HTML sheet: rejected by no-WebView/no-HTML rule.
