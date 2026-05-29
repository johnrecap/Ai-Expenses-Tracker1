# Component Map

## Shared App Components

| Component | Responsibility | Used by |
| --- | --- | --- |
| `AppBackground` | Surface color, subtle gradient blobs, safe area. | Most screens. |
| `GlassCard` | Reusable glassmorphism card/panel. | Dashboard, lists, reports, budgets, goals, wallets. |
| `GlassBottomSheet` | Modal sheet container with handle, blur, safe bottom. | Filters, AI assistant. |
| `AppTopBar` | Fixed top bar with title, leading, trailing/avatar. | Main and modal screens. |
| `AppBottomNav` | Mobile tab shell with central add action. | Main shell screens. |
| `GradientButton` | Primary pill CTA. | Auth, onboarding, forms, add expense. |
| `SecondaryPillButton` | Low-emphasis action button. | Filters, cards, secondary actions. |
| `IconCircleButton` | Fixed-size icon control. | Header actions, filters, list tools. |
| `SegmentedModeControl` | Quick/Text/Receipt mode selector. | Add expense flow. |
| `SearchField` | Pill search input with icon. | Expenses, filters, AI history. |
| `FilterChipRow` | Horizontal chips with active/inactive states. | Expenses, filters, categories. |
| `SectionHeader` | Small section label and optional action. | Lists and grouped content. |
| `EmptyState` | Reusable no-data/no-results state. | Missing state coverage. |
| `MetricCard` | Label, value, trend, optional icon. | Dashboard, reports, budgets. |
| `ProgressBar` | Linear progress. | Budgets, goals, onboarding. |
| `ProgressRing` | Circular progress. | Saving goals and budget status. |
| `AiInsightCard` | Gradient-border AI advice card. | Dashboard, goals, subscriptions, AI advice. |

## Domain Components

| Component | Responsibility | Source screens |
| --- | --- | --- |
| `TransactionTile` | Merchant, category, amount, sync status, icon. | `expenses_list`, `home_dashboard`. |
| `TransactionSection` | Date-grouped transaction tile list. | `expenses_list`. |
| `CategoryIconBadge` | Colored round category icon. | Expenses, reports, budgets. |
| `AmountInputHero` | Large centered amount field. | `add_expense_quick_mode`. |
| `ExpenseFormCard` | Merchant/date/amount/category fields. | Add/edit expense screens. |
| `ReceiptUploadPanel` | Dashed upload/camera panel and parsing status. | `add_expense_receipt_mode`. |
| `AiExpenseParsePanel` | Textarea, parse button, suggestion preview. | `add_expense_ai_text_mode`. |
| `ReportSummaryCard` | Total, comparison, trend. | `reports_main`, `report_drilldown`. |
| `ChartCard` | Native chart or styled placeholder. | Reports. |
| `BudgetOverviewCard` | Monthly budget remaining/spent. | `budgets_overview`. |
| `CategoryBudgetTile` | Category budget with progress. | `category_budgets_list`. |
| `GoalCard` | Goal target, saved, progress ring. | `saving_goals_overview`. |
| `WalletCard` | Wallet/account balance and metadata. | `wallets_accounts`. |
| `TransferPreviewTile` | Recent or suggested transfer row. | `wallets_accounts`. |
| `SubscriptionCard` | Vendor, recurring amount, next bill, status. | `subscriptions_center`. |
| `StoryPagePanel` | Monthly financial story page section. | `monthly_financial_story`. |
| `ChatBubble` | AI/user chat message. | `ai_history_assistant`, `ai_assistant_bottom_sheet`. |
| `SuggestedPromptChip` | AI prompt shortcut. | AI assistant/history. |
| `SettingsRow` | Icon, label, value, chevron/toggle. | `settings_main`. |
| `OnboardingOptionCard` | Selectable language/currency/notification option. | Onboarding screens. |
| `AuthPanel` | Auth glass panel and form fields. | Login, sign up. |

## Component Reuse Rules

- Do not create screen-local copies of top bars, bottom nav, cards, chips, or
  buttons.
- Screen files should compose components and mock data, not define visual
  primitives.
- Component APIs should accept data objects and visual variants instead of
  hardcoded copy.
- Repeated rows/lists must be generated from mock arrays.
- Components must accept `TextDirection` naturally by using directional layout
  primitives.

## Asset Handling

- Copy usable local image assets into the future Flutter project under
  `assets/images/`.
- The logo screenshot can become a temporary prototype asset if no vector/source
  logo exists.
- Remote image URLs embedded in HTML must not be used at runtime. Replace with
  local placeholder assets or native icon/avatar placeholders.
- Configure FlutterGen after the Flutter project exists so asset paths are
  generated instead of handwritten strings.

## Screen-To-Component Map

| Screen | Main components |
| --- | --- |
| Splash | `AppBackground`, logo asset, loading indicator. |
| Onboarding language | `OnboardingOptionCard`, `GradientButton`. |
| Onboarding currency | `OnboardingOptionCard`, `GradientButton`. |
| Onboarding notifications | option cards/toggles, `GradientButton`. |
| Login | `AuthPanel`, text fields, `GradientButton`. |
| Sign up | `AuthPanel`, text fields, `GradientButton`. |
| Home dashboard | `AppTopBar`, `MetricCard`, `AiInsightCard`, `TransactionTile`, `AppBottomNav`. |
| Expenses list | `SearchField`, `FilterChipRow`, `TransactionSection`, `TransactionTile`. |
| Filters sheet | `GlassBottomSheet`, `SearchField`, chips, range slider, action buttons. |
| Add quick | `SegmentedModeControl`, `AmountInputHero`, chips, `ExpenseFormCard`. |
| Add AI text | `SegmentedModeControl`, `AiExpenseParsePanel`, `ExpenseFormCard`. |
| Add receipt | `SegmentedModeControl`, `ReceiptUploadPanel`, `ExpenseFormCard`. |
| Edit expense | `ExpenseFormCard`, `GradientButton`. |
| Reports | `ReportSummaryCard`, `ChartCard`, category rows. |
| Report drilldown | `ReportSummaryCard`, `ChartCard`, transaction/category list. |
| Monthly story | `StoryPagePanel`, metric cards. |
| Budgets | `BudgetOverviewCard`, `CategoryBudgetTile`. |
| Category budgets | `CategoryBudgetTile`, progress bars. |
| Edit monthly budget | form fields, sliders/steppers, `GradientButton`. |
| Saving goals | `GoalCard`, `ProgressRing`, `AiInsightCard`. |
| Wallets | `WalletCard`, `TransferPreviewTile`. |
| Subscriptions | `SubscriptionCard`, `AiInsightCard`, summary card. |
| AI advice | `AiInsightCard`, recommendation cards. |
| AI history | `ChatBubble`, `SuggestedPromptChip`, chat input. |
| AI assistant sheet | `GlassBottomSheet`, `ChatBubble`, prompt chips, chat input. |
| Settings | `SettingsRow`, profile header, toggles. |
