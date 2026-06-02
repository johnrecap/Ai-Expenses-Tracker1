# Quickstart: Smart Add Entry

## Manual Review

1. Open the home screen.
2. Confirm there is one primary add button.
3. Tap the add button.
4. Confirm the add sheet opens.
5. Tap AI text and confirm it opens the AI expense text flow.
6. Return home.
7. Tap quick add and confirm it opens quick add.
8. Confirm receipt is honest: working only if real, otherwise disabled/unavailable.
9. Confirm top-bar AI opens assistant/help, not expense add.
10. Repeat in Arabic RTL and English LTR.

## Files To Inspect Before Editing

1. `lib/core/theme/app_colors.dart`
2. `lib/core/theme/app_spacing.dart`
3. `lib/core/theme/app_text_styles.dart`
4. `lib/core/widgets/glass_bottom_sheet.dart`
5. `lib/core/widgets/glass_card.dart`
6. `lib/core/widgets/gradient_button.dart`
7. `lib/features/dashboard/presentation/home_dashboard_screen.dart`
8. `lib/app/routes.dart`
9. `lib/app/router.dart`

## Commands

```powershell
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/home_dashboard_test.dart
& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/smart_add_sheet_test.dart
```

## Viewports

```text
360x800 Arabic RTL
360x800 English LTR
375x812 Arabic RTL
375x812 English LTR
390x844 Arabic RTL
390x844 English LTR
```
