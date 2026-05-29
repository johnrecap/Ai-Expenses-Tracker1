# Quickstart: Add And Edit Expense

## Implementation Order

1. Confirm foundation and expense list components exist.
2. Build shared segmented mode, amount, form, AI parse, and receipt panel widgets.
3. Build quick add screen.
4. Build AI text add screen.
5. Build receipt add screen.
6. Build edit expense screen.
7. Wire routes.
8. Add tests for local-only interactions and route IDs.
9. Run compile, viewport, RTL, and forbidden dependency checks.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Stop Condition

Stop when all four screens render natively, all service-like controls are local-only, and forbidden dependency search is clean.
