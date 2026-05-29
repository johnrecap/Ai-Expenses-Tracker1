# Tasks: Wallets And Subscriptions

**Input**: Design documents from `/specs/006-wallets-subscriptions/`

**Prerequisites**: `specs/001-foundation/` approved and implemented

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Non-Negotiable Rules

- UI only. No bank, billing, payment, backend, API, database, persistence, remote runtime logos, WebView, or HTML rendering.
- Native Flutter widgets only.
- Static mock data only.
- Reuse shared components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Wallets

- [ ] T501 [P] [US1] Create `WalletCard` in `lib/features/wallets/presentation/widgets/wallet_card.dart`
  - Why: Wallet account cards are repeated and balance-heavy.
  - Expected result: Wallet card renders name, type, balance, trend, and local identity mark.
  - Inputs: `wallets_accounts/screen.png`, `code.html`, mock wallets.
  - Implementation notes: Use local icons/initials; one-column layout at 360px.
  - Possible bugs: Remote bank logo used; balance overflow; card grid too wide.
  - Fix strategy: Replace remote image with local mark, constrain amount text, use mobile constraints.
  - Verification: Wallet card widget test at 360px.

- [ ] T502 [P] [US1] Create `TransferPreviewTile` in `lib/features/wallets/presentation/widgets/transfer_preview_tile.dart`
  - Why: Transfer preview rows need consistent styling and directionality.
  - Expected result: Transfer rows render source, destination, amount, date, and status.
  - Inputs: `wallets_accounts` export, mock transfer data.
  - Implementation notes: Use directional alignment and constrained amount text.
  - Possible bugs: Amount column clips; source/destination order wrong in RTL.
  - Fix strategy: Use `Expanded` and directional row layout; add RTL test.
  - Verification: Transfer tile test in LTR and RTL.

- [ ] T503 [US1] Build `WalletsAccountsScreen` in `lib/features/wallets/presentation/wallets_accounts_screen.dart`
  - Why: Wallets screen is a detected main shell surface.
  - Expected result: `/wallets` renders account cards, add wallet visual CTA, and transfer preview from mock data.
  - Inputs: `wallets_accounts/screen.png`, `code.html`, wallet widgets.
  - Implementation notes: Add wallet action is inert or placeholder-only.
  - Possible bugs: Add wallet implies persistence; bottom nav active state wrong; total balance overflows.
  - Fix strategy: Local snackbar/placeholder, centralize nav mapping, constrain balance text.
  - Verification: Wallets route and viewport tests pass.

## Phase 2: Subscriptions

- [ ] T504 [P] [US2] Create `SubscriptionCard` in `lib/features/subscriptions/presentation/widgets/subscription_card.dart`
  - Why: Subscription cards repeat vendor, recurring amount, next bill, and status.
  - Expected result: Cards render all mock subscription statuses.
  - Inputs: `subscriptions_center/screen.png`, `code.html`, mock subscriptions.
  - Implementation notes: Use local initials/icons for vendor identity; no remote images.
  - Possible bugs: Brand logos loaded remotely; card action implies billing API.
  - Fix strategy: Replace logos with styled initials and keep actions visual-only.
  - Verification: Card tests render active, warning, and inactive statuses.

- [ ] T505 [US2] Build `SubscriptionsCenterScreen` in `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`
  - Why: Subscriptions center completes recurring-money UI.
  - Expected result: `/subscriptions` renders summary, AI insight, subscription cards, and local actions.
  - Inputs: `subscriptions_center/screen.png`, `code.html`, subscription widgets.
  - Implementation notes: Review/add/filter actions are local-only or placeholders.
  - Possible bugs: Billing/payment package added; cards overflow; remote vendor image used.
  - Fix strategy: Remove integration packages, use one-column cards, and use local identities.
  - Verification: Subscriptions viewport and forbidden dependency tests pass.

## Phase 3: Routes And Verification

- [ ] T506 [Routes] Wire wallet and subscription routes in `lib/app/router.dart`
  - Why: Screens need stable central navigation and bottom nav mapping.
  - Expected result: `/wallets` and `/subscriptions` resolve correctly.
  - Inputs: `contracts/ui-contract.md`.
  - Implementation notes: No bank/billing guards or service hooks.
  - Possible bugs: Route stays placeholder; nav active state wrong.
  - Fix strategy: Add route smoke tests and central tab mapping.
  - Verification: Route tests pass.

- [ ] T507 [Polish] Run compile, viewport, RTL, remote-image, and forbidden dependency checks
  - Why: These screens are financially sensitive and must remain static UI.
  - Expected result: Commands pass or blockers documented; search is clean.
  - Inputs: Completed wallet/subscription files.
  - Implementation notes: Include `Image.network` and financial integration keywords in search.
  - Possible bugs: False positives; hidden network image; bank/billing package in `pubspec.yaml`.
  - Fix strategy: Inspect and remove every implementation violation.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, debug build, viewport checks, forbidden search.

## Dependencies And Execution Order

T501-T502 block T503. T504 blocks T505. T506 depends on screens. T507 is final.

## Acceptance Criteria

- Wallets and subscriptions render natively.
- Data is static mock data.
- No bank/billing/payment/backend/API/database/persistence/remote image/WebView/HTML rendering.
- Required viewport and RTL/LTR checks pass.
