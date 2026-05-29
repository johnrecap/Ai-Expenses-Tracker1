# Quickstart: Dashboard And Expenses

## Implementation Order

1. Confirm foundation widgets, routes, and mock data exist.
2. Build transaction row and section widgets.
3. Build dashboard screen.
4. Build expenses list screen.
5. Build filter bottom sheet.
6. Wire routes and filter trigger.
7. Add widget/route tests.
8. Run compile, viewport, RTL, and forbidden dependency checks.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Manual Checks

- Dashboard amount values at 360px.
- Expenses list scroll bottom with bottom nav visible.
- Filter sheet content scroll and safe-area footer.
- LTR and RTL for every route.

## Stop Condition

Stop when dashboard, expenses, and filter sheet render natively, use mock data only, and pass compile and viewport checks.
