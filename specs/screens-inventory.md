# Screens Inventory

## Detected Files

Detected from `stitch_ai_expenses_tracker_pro/`:

| Folder | Type | Notes |
| --- | --- | --- |
| `splash_loading` | Screen | Loading splash for AI Expenses Tracker. |
| `onboarding_language_selection` | Screen | Language choice entry point. |
| `onboarding_base_currency` | Screen | Base currency selection. |
| `onboarding_notifications` | Screen | Notification preference onboarding. |
| `login_authentication` | Screen | Login form, Google-style button, logo block. |
| `sign_up` | Screen | Account creation form. |
| `home_dashboard` | Screen | Main dashboard with greeting, balances, cards, list preview. |
| `expenses_list` | Screen | Search, filter chips, grouped transaction list. |
| `expense_filters_bottom_sheet` | Modal | Filter bottom sheet for expenses. |
| `add_expense_quick_mode` | Screen | Manual amount entry with category chips. |
| `add_expense_ai_text_mode` | Screen | Natural-language expense entry and AI review mock. |
| `add_expense_receipt_mode` | Screen | Receipt upload/camera mock and parsed fields. |
| `edit_expense` | Screen | Expense edit form. |
| `reports_main` | Screen | Spending summary and report cards. |
| `report_drilldown` | Screen | Category drilldown for Food & Drink. |
| `monthly_financial_story` | Screen | Narrative monthly report/story. |
| `budgets_overview` | Screen | Monthly budget overview. |
| `category_budgets_list` | Screen | Category-level budget list. |
| `edit_monthly_budget` | Screen | Monthly budget edit form. |
| `saving_goals_overview` | Screen | Saving goals, progress, AI insight. |
| `wallets_accounts` | Screen | Wallet/account cards and transfer preview. |
| `subscriptions_center` | Screen | Recurring expenses/subscriptions center. |
| `ai_advice_insights` | Screen | AI-driven advice and insights. |
| `ai_history_assistant` | Screen | Arabic-oriented AI history/chat screen. |
| `ai_assistant_bottom_sheet` | Modal | AI assistant bottom sheet. |
| `settings_main` | Screen | Main settings/profile menu. |
| `ai_expenses_tracker_logo` | Asset | Logo screenshot only, no `code.html`. |
| `lumina_finance/DESIGN.md` | Design doc | Token and style reference. |

## Image Dimensions

Screenshots vary by export scale. Flutter should target logical mobile
viewports, not copy screenshot pixel dimensions.

| Screen | Export image size |
| --- | --- |
| `add_expense_ai_text_mode` | 706x1600 |
| `add_expense_quick_mode` | 706x1600 |
| `add_expense_receipt_mode` | 706x1600 |
| `ai_advice_insights` | 545x1600 |
| `ai_assistant_bottom_sheet` | 706x1600 |
| `ai_expenses_tracker_logo` | 1024x1024 |
| `ai_history_assistant` | 706x1600 |
| `budgets_overview` | 577x1600 |
| `category_budgets_list` | 390x1195 |
| `edit_expense` | 684x1600 |
| `edit_monthly_budget` | 549x1600 |
| `expense_filters_bottom_sheet` | 706x1600 |
| `expenses_list` | 706x1600 |
| `home_dashboard` | 673x1600 |
| `login_authentication` | 706x1600 |
| `monthly_financial_story` | 390x1068 |
| `onboarding_base_currency` | 706x1600 |
| `onboarding_language_selection` | 706x1600 |
| `onboarding_notifications` | 706x1600 |
| `report_drilldown` | 390x1177 |
| `reports_main` | 527x1600 |
| `saving_goals_overview` | 706x1600 |
| `settings_main` | 416x1600 |
| `sign_up` | 706x1600 |
| `splash_loading` | 706x1600 |
| `subscriptions_center` | 423x1600 |
| `wallets_accounts` | 500x1600 |

## Navigation Classification

Bottom-tab shell candidates:

- Home: `home_dashboard`
- Reports: `reports_main`
- Add: `add_expense_quick_mode`, `add_expense_ai_text_mode`,
  `add_expense_receipt_mode`
- Wallets/Budgets: `wallets_accounts`, `budgets_overview`
- Settings: `settings_main`

Full-screen flows:

- Splash and onboarding.
- Auth screens.
- Add/edit expense screens.
- Budget edit.
- Report drilldown.
- Monthly story.

Bottom sheets:

- Expense filters.
- AI assistant.

Desktop/tablet references exist in some HTML via `md:` classes, but the required
prototype target is mobile-first. Keep layouts flexible enough to scale up
without breaking.

## Missing Or Deferred Screens

Required decision before implementation:

- Add a simple forgot-password mock screen, or keep link inert.
- Add empty/no-results states, or embed them as state variants in existing
  screens.
- Add transaction detail read-only view, or route all transaction taps to
  edit expense.
- Add settings subpages for language, currency, notifications, and profile, or
  keep settings rows inert.
- Add add/edit flows for wallet, goal, and subscription, or keep add buttons
  disabled with mock snackbar copy.

Recommended for prototype completeness:

- Implement lightweight no-data states as reusable widgets.
- Add `/not-found`.
- Keep secondary add/edit wallet, goal, subscription flows deferred until the
  main screen set compiles.
