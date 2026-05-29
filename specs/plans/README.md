# UI Prototype Plan Index

> Status: legacy planning index. The canonical Spec Kit plans now live in
> `specs/001-foundation/` through `specs/007-ai-settings-final-qa/`. Use those
> feature directories for implementation approval and task execution.

These plans split the native Flutter rebuild into reviewable, compile-checked
increments. Execute them in order unless a later plan explicitly says it can run
in parallel after the foundation is complete.

| Order | Plan | Coverage |
| --- | --- | --- |
| 00 | `00-foundation-plan.md` | Flutter scaffold, theme, layout, routes, mock data, assets, shared widgets |
| 01 | `01-launch-onboarding-auth-plan.md` | Splash, onboarding, login, sign up |
| 02 | `02-dashboard-expenses-plan.md` | Home dashboard, expenses list, filters bottom sheet |
| 03 | `03-add-edit-expense-plan.md` | Add expense quick/text/receipt modes, edit expense |
| 04 | `04-reports-budgets-goals-plan.md` | Reports, drilldown, monthly story, budgets, category budgets, edit budget, saving goals |
| 05 | `05-wallets-subscriptions-plan.md` | Wallets/accounts, subscriptions center |
| 06 | `06-ai-settings-final-qa-plan.md` | AI advice, AI history, AI assistant sheet, settings, empty states, not-found, final QA |

Global rules for every plan:

- UI only: no backend, Firebase, real authentication, database, API calls, OCR,
  AI calls, payment SDKs, notification APIs, or persistence.
- No WebView and no HTML rendering.
- Rebuild Stitch exports as native Flutter widgets.
- Reuse shared components and theme tokens.
- Keep mock data static and in-memory.
- Verify 360x800, 375x812, and 390x844 in English LTR and Arabic RTL.
- Every plan must compile before the next plan starts.
