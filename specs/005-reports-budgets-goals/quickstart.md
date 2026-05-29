# Quickstart: Reports, Budgets, And Goals

## Implementation Order

1. Confirm foundation widgets and expense/category mock data exist.
2. Build report summary and chart components.
3. Build reports main, drilldown, and monthly story.
4. Build budget overview, category budget tile, and edit budget screen.
5. Build goal card and saving goals screen.
6. Wire routes.
7. Add tests for progress clamping, route IDs, and viewport/RTL behavior.
8. Run compile and forbidden dependency checks.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Stop Condition

Stop when all seven screens render natively, charts/progress are native widgets, edit budget is local-only, and checks pass.
