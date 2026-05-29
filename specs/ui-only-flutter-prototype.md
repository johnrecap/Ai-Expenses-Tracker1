# UI-Only Flutter Prototype Spec

## Goal

Create a native Flutter prototype for AI Expenses Tracker using the Google
Stitch exports as visual references. This phase is planning only; no screens are
implemented yet.

## Scope

In scope:

- Native Flutter rebuild of exported screens.
- Static, in-memory mock data.
- Responsive mobile layouts for 360x800, 375x812, and 390x844.
- English LTR and Arabic RTL readiness.
- Shared design system, routes, and reusable components.
- Compile checks after every implementation batch.

Out of scope:

- Backend.
- Firebase.
- Real authentication.
- Database.
- API calls.
- WebView.
- HTML rendering.
- Payment, subscription billing, OCR, AI parsing, or notification logic.

## Source Inputs

- `stitch_ai_expenses_tracker_pro/**/screen.png`
- `stitch_ai_expenses_tracker_pro/**/code.html`
- `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`

The HTML/Tailwind files are reference material only. Flutter implementation must
translate their visual structure into widgets, not embed or render HTML.

## Detected Screen Groups

- Launch and onboarding: splash, language, base currency, notifications.
- Auth shell: login, sign up.
- Main money flow: home dashboard, expenses list, add expense quick/text/receipt,
  edit expense, filters bottom sheet.
- Reports and planning: reports, report drilldown, budgets overview, category
  budgets, edit monthly budget, saving goals, monthly financial story.
- Account and recurring money: wallets/accounts, subscriptions center.
- AI surfaces: AI advice insights, AI history assistant, AI assistant bottom
  sheet.
- Settings: settings main.
- Asset/reference: AI Expenses Tracker logo image, Lumina Finance design doc.

See `specs/screens-inventory.md` for screen-level details.

## Missing Screens To Account For

The export set is strong but not complete. The implementation plan should either
add lightweight mock-only screens or document them as deferred:

- Forgot password / reset password.
- Email verification or auth success state.
- Transaction detail read-only view.
- Empty states for expenses, reports, budgets, goals, wallets, subscriptions,
  and AI history.
- No-results state for search and filters.
- Add/edit wallet.
- Add/edit saving goal.
- Add/edit subscription.
- Category detail from budget card.
- Profile/account details.
- Language and currency settings after onboarding.
- Notification settings after onboarding.
- Permission-style states for receipt/camera and notifications.
- Generic error and maintenance placeholders.
- Not-found route.

## Routes

Use a central route registry. `go_router` is the recommended route package for
implementation because it keeps nested mobile shells, modal-style flows, and
deep links explicit. If dependencies are kept minimal, `Navigator` 2.0 can be
used, but routes must remain centralized.

Planned routes:

```text
/splash
/onboarding/language
/onboarding/currency
/onboarding/notifications
/auth/login
/auth/sign-up
/home
/expenses
/expenses/new/quick
/expenses/new/text
/expenses/new/receipt
/expenses/:expenseId/edit
/expenses/filters
/reports
/reports/category/:categoryId
/budgets
/budgets/categories
/budgets/monthly/edit
/goals
/wallets
/subscriptions
/ai/advice
/ai/history
/ai/assistant
/story/monthly
/settings
/not-found
```

Modal/bottom-sheet surfaces:

- `/expenses/filters` should be a modal bottom sheet over the expenses list.
- `/ai/assistant` should be a modal bottom sheet over the active shell screen.
- Add expense screens can be full-screen modal routes.

## Flutter Folder Structure

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    routes.dart
  core/
    layout/
      app_breakpoints.dart
      responsive_constraints.dart
      directionality_utils.dart
    theme/
      app_colors.dart
      app_gradients.dart
      app_radii.dart
      app_shadows.dart
      app_spacing.dart
      app_text_styles.dart
      app_theme.dart
    mock/
      mock_data.dart
      mock_models.dart
    widgets/
      ai_badge.dart
      app_background.dart
      app_bottom_nav.dart
      app_top_bar.dart
      glass_card.dart
      gradient_button.dart
      metric_card.dart
      section_header.dart
  features/
    onboarding/presentation/
    auth/presentation/
    dashboard/presentation/
    expenses/presentation/
    reports/presentation/
    budgets/presentation/
    goals/presentation/
    wallets/presentation/
    subscriptions/presentation/
    ai/presentation/
    settings/presentation/
```

Keep all cross-screen UI in `core/widgets/`. Feature widgets belong under their
feature only when they are not reused elsewhere.

## Mock Data Plan

Create static Dart data only:

- `MockUser`: name, avatar placeholder, locale preference, base currency.
- `MockExpense`: merchant, category, amount, currency, date, wallet, sync state,
  notes.
- `MockCategory`: label, icon, color token.
- `MockWallet`: name, institution, type, balance, trend.
- `MockBudget`: monthly cap, spent amount, category allocations.
- `MockGoal`: title, target amount, saved amount, deadline, progress.
- `MockSubscription`: vendor, price, next billing date, status, predicted
  increase flag.
- `MockReport`: month totals, category breakdown, trend points.
- `MockAiInsight`: title, summary, severity, related screen.
- `MockChatMessage`: author, text, timestamp, suggested prompts.

Rules:

- No repository classes that imply remote persistence.
- No HTTP clients.
- No Firebase packages.
- No `shared_preferences` for this prototype phase.
- UI interactions may update ephemeral widget state only.

## Dependencies Plan

Keep dependencies minimal. Candidate implementation dependencies:

- `go_router`: route registry and modal-style flows.
- `intl`: currency/date formatting and locale-aware text.
- `flutter_svg`: only if SVG assets are introduced.
- `fl_chart`: only if native chart widgets are too costly for reports.

Candidate dev dependencies:

- `flutter_lints`.
- `flutter_gen_runner` plus `build_runner` if asset generation is configured
  inside the Flutter project.

Do not add backend, Firebase, auth, database, OCR, or HTTP dependencies.

## Compile-Check Requirements

Each implementation batch must pass:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If Android build tooling is unavailable, record the failure reason and run:

```powershell
flutter build web
```

Visual checks must cover:

- 360x800
- 375x812
- 390x844
- English LTR
- Arabic RTL

## Acceptance Definition

The prototype is accepted when:

- Every planned Stitch screen has a native Flutter counterpart.
- Shared UI is componentized through `core/widgets` and theme tokens.
- Mock data drives repeated lists/cards.
- No WebView or HTML rendering exists.
- No backend/Firebase/auth/database/API code exists.
- The app compiles after every batch.
- Key screens fit without overflow at the required mobile sizes.
- Arabic RTL mode mirrors layout direction and uses Arabic-ready text styling.
