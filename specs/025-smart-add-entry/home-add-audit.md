# Home Add Entry Audit

## Scope

Audited `lib/features/dashboard/presentation/home_dashboard_screen.dart`,
`lib/app/routes.dart`, and `lib/app/router.dart` for home-screen add and AI
entry points.

## Current Home Entry Points

### Stacked AI floating action button

- Location: `HomeDashboardScreen.floatingActionButton`
- Widget: `FloatingActionButton.small`
- Icon: `Icons.auto_awesome`
- Color: `AppColors.secondary`
- Hero tag: `ai_fab`
- Current action: `context.go(AppRoutes.expensesNewAi)`
- Router target: `AiExpenseScreen`
- Classification: Duplicated expense-entry AI action. This is the old AI
  expense route and should not remain as a separate home FAB.

### Stacked add floating action button

- Location: `HomeDashboardScreen.floatingActionButton`
- Widget: `FloatingActionButton`
- Icon: `Icons.add`
- Color: `AppColors.primary`
- Hero tag: `add_fab`
- Current action: `context.go(AppRoutes.expensesNewQuick)`
- Router target: `AddExpenseQuickScreen`
- Classification: Current primary add expense action. This should become the
  single smart add entry button that opens the choice sheet.

### Top-bar AI assistant action

- Location: `AppTopBar.trailing`
- Widget: `IconButton`
- Icon: `Icons.auto_awesome`
- Color: `AppColors.secondaryContainer`
- Current action: `showModalBottomSheet(... AiAssistantSheet())`
- Classification: Assistant/help action, not expense entry. This must remain
  separate from smart add.

## Canonical Routes

- `AppRoutes.expensesNewText` exists and maps to `AddExpenseAiTextScreen`.
- `AppRoutes.expensesNewQuick` exists and maps to `AddExpenseQuickScreen`.
- `AppRoutes.expensesNewReceipt` exists and maps to `AddExpenseReceiptScreen`,
  but receipt behavior is not clearly ready for this feature because the wider
  AI gateway refactor is still in progress. Smart add should present receipt as
  unavailable/disabled for now.
- `AppRoutes.expensesNewAi` exists and maps to `AiExpenseScreen`. New smart add
  navigation must not use this older duplicate route.

## Required Change

Replace the stacked `ai_fab` + `add_fab` pattern with one primary add FAB. The
new FAB opens `SmartAddSheet`. Inside the sheet, AI text navigates to
`AppRoutes.expensesNewText`, quick add navigates to
`AppRoutes.expensesNewQuick`, and receipt stays disabled with a visible
unavailable reason.
