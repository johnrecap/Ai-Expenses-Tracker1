# Data Model: Reports, Budgets, And Goals

## ReportSummary

- `periodLabel`
- `totalSpent`
- `comparisonLabel`
- `trendPoints`

## CategoryBreakdown

- `categoryId`
- `amount`
- `percent`
- `trendLabel`

## StoryPanel

- `id`
- `title`
- `metricText`
- `body`
- `accentToken`

## BudgetDraft

- `monthlyCapText`
- `categoryAllocations`
- `selectedMonthLabel`

## GoalProgress

- `goalId`
- `targetAmount`
- `savedAmount`
- `deadlineLabel`
- `progress`: derived and clamped

## Validation Rules

- Chart input lists must not be empty; use fallback empty state if needed.
- Unknown category IDs must not crash.
- Progress values are clamped between 0 and 1.
- Edit budget state stays local to the screen.
