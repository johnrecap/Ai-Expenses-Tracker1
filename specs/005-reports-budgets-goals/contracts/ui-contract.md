# UI Contract: Reports, Budgets, And Goals

## Routes

- `/reports`
- `/reports/category/:categoryId`
- `/story/monthly`
- `/budgets`
- `/budgets/categories`
- `/budgets/monthly/edit`
- `/goals`

## Component Contracts

### ChartCard

- Accepts title, trend points, optional labels, and visual variant.
- Renders native Flutter chart visuals.
- Must not use exported screenshots as the chart.

### CategoryBudgetTile

- Accepts category, spent, limit, and progress.
- Clamps progress between 0 and 1.
- Supports RTL/LTR and 360px width.

### GoalCard

- Accepts goal progress and optional insight.
- Uses native progress ring.
- Must not overflow large currency values.

### StoryPagePanel

- Accepts story title, metric, body, and accent token.
- Scrollable parent handles long content.

## Interaction Contracts

- Edit budget controls change local draft state only.
- Drilldown unknown IDs show not-found or fallback.
- Add budget/goal actions are inert or placeholder-only unless later approved.
