# UI Small-Screen Review: Arabic RTL and English LTR

**Date**: 2026-05-31

**Scope**: T039 from `specs/027-product-restructure-master-plan/tasks.md`.

## Status

T039 is not fully closed yet.

The automated small-screen and RTL/LTR checks passed, and an Android device is
available for manual review. A full manual walkthrough across every listed
screen still needs an interactive app session with a signed-in account and real
test data, because several screens are behind authentication and real backend
state.

## Device Availability

`flutter devices` detected:

- Android phone: `RMX3760`, Android 15, device id `0H74425I251015CB`
- Windows desktop
- Chrome
- Edge

## Automated Review Completed

Command:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\core\rtl_responsive_test.dart test\core\layout_test.dart test\features\auth\auth_panel_test.dart test\features\auth\login_screen_test.dart test\features\auth\sign_up_screen_test.dart test\features\onboarding test\features\dashboard\smart_add_sheet_test.dart test\features\ai\ai_no_mock_screens_test.dart
```

Result:

- 59 tests passed.
- Covered key 360, 375, and 390 width checks where existing tests define them.
- Covered shared responsive components, core layout helpers, auth, onboarding,
  dashboard smart add sheet, and AI no-mock states.

## Automated Coverage Notes

Confirmed by tests:

- Splash renders at key viewport widths.
- Language onboarding renders Arabic RTL at 360 width and required widths.
- Base currency and notifications onboarding render localized content.
- Login and sign-up render Arabic without broken/mixed text.
- Shared cards and progress UI render in RTL without overflow.
- Dashboard smart add sheet renders Arabic RTL without overflow.
- AI advice/history/assistant show honest unavailable/empty states instead of
  fake data.

Not fully proven by automated small-screen tests:

- Every authenticated financial screen at 360x800, 375x812, and 390x844.
- Every bottom sheet height and scroll interaction on a physical Android phone.
- Real signed-in navigation through all backend-backed screens.
- Real data edge cases with long Arabic category, wallet, merchant, and note
  names.

## Manual Screen Checklist

Use this checklist on the Android device after signing in with a test account
that has real non-production data.

For each screen, check:

- Arabic RTL and English LTR direction.
- No critical overflow or clipped text at 360x800, 375x812, and 390x844.
- Primary buttons are visible and tappable.
- Empty, loading, error, and unavailable states are honest.
- No mock/demo/sample financial data appears as real.

Screens to review:

- SplashScreen
- OnboardingLanguageScreen
- BaseCurrencyScreen
- NotificationsScreen
- LoginScreen
- SignUpScreen
- HomeDashboardScreen
- ExpensesListScreen
- AddExpenseQuickScreen
- AddExpenseAiTextScreen
- AddExpenseReceiptScreen
- AiExpenseScreen redirect behavior
- EditExpenseScreen
- ExpenseFiltersSheet
- ReportsMainScreen
- ReportDrilldownScreen
- MonthlyFinancialStoryScreen
- BudgetsOverviewScreen
- CategoryBudgetsListScreen
- EditMonthlyBudgetScreen
- SavingGoalsScreen
- WalletsAccountsScreen
- SubscriptionsCenterScreen
- AiAdviceScreen
- AiAdvisorScreen
- AiChatScreen
- AiHistoryScreen
- AiAssistantSheet
- SettingsScreen
- CategoriesScreen
- CategoryFormDialog
- UnlockScreen
- CreatePinScreen
- AccountProfileScreen
- FreePremiumScreen
- NotFoundScreen

## Recommended Manual Flow

1. Open the app on the Android device.
2. Create or sign in to a test account.
3. Complete language, currency, and notifications setup.
4. Switch between Arabic and English from settings.
5. Add a quick expense with a real category and wallet.
6. Add an AI text expense and review the parsed draft before saving.
7. Open receipt add and confirm it is real or clearly unavailable.
8. Filter and edit expenses.
9. Open categories and manage aliases.
10. Open wallets and create a transfer.
11. Review dashboard, reports, budgets, goals, and subscriptions.
12. Review AI advice, assistant, chat, and history states.
13. Review settings, profile, app lock, PIN, biometric, and premium screens.

## Closure Rule

Only mark T039 complete after the manual checklist above has been walked on the
Android device or an equivalent scripted visual review exists for all listed
screens.
