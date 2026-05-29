# Wallets And Subscriptions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild wallet/account and subscriptions center screens as native Flutter UI.

**Architecture:** Use static mock account and subscription data, shared glass
cards, metric cards, AI insight cards, and responsive one-column mobile grids.
No bank, billing, payment, or subscription APIs are implemented.

**Tech Stack:** Flutter, shared foundation widgets, mock wallets/subscriptions.

---

## Depends On

- `specs/plans/00-foundation-plan.md`
- `specs/plans/04-reports-budgets-goals-plan.md` for progress/metric patterns, though this plan can start after foundation if shared widgets exist.

## Screens Covered

- `wallets_accounts`
- `subscriptions_center`

## Why

These screens are financially sensitive visually because they imply bank
accounts, balances, recurring payments, and subscription changes. The plan keeps
them static and local while still looking complete.

## Expected Result

Wallet/account cards, transfer preview rows, subscription summary cards, active
subscription cards, and AI subscription insight render from mock data.

## Source References

- `stitch_ai_expenses_tracker_pro/wallets_accounts/*`
- `stitch_ai_expenses_tracker_pro/subscriptions_center/*`
- `specs/component-map.md`
- `specs/design-system.md`

## Files And Ownership

- Create: `lib/features/wallets/presentation/wallets_accounts_screen.dart`
- Create: `lib/features/wallets/presentation/widgets/wallet_card.dart`
- Create: `lib/features/wallets/presentation/widgets/transfer_preview_tile.dart`
- Create: `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`
- Create: `lib/features/subscriptions/presentation/widgets/subscription_card.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/core/mock/mock_data.dart`
- Test: `test/features/wallets/wallets_test.dart`
- Test: `test/features/subscriptions/subscriptions_test.dart`

## Tasks

- [ ] T501 [Wallets] Build wallet card and transfer preview components.
  - Why: Wallet cards and transfer rows are repeated account-specific surfaces.
  - Expected result: `WalletCard` and `TransferPreviewTile` render balance, account type, trend, and transfer metadata from mock data.
  - Inputs: `wallets_accounts/screen.png`, `wallets_accounts/code.html`.
  - Implementation notes: Use icons/initials instead of remote bank logos; one-column layout at 360px.
  - Possible bugs: account grid too wide, remote images used, bank API dependency added.
  - Fix strategy: use responsive grid constraints, local icons, remove integration dependencies.
  - Verification: wallet widget test renders at 360x800 with no overflow.

- [ ] T502 [Wallets] Build `WalletsAccountsScreen`.
  - Why: The screen validates account cards, add-wallet CTA, and transfer preview inside the main shell.
  - Expected result: `/wallets` renders wallet cards, add wallet visual card, and recent transfer preview.
  - Inputs: wallet export and mock wallet data.
  - Implementation notes: Add wallet action is inert or placeholder-only.
  - Possible bugs: add wallet implies persistence, bottom nav highlights wrong tab, total balances overflow.
  - Fix strategy: show local snackbar, update nav route mapping, constrain balance text.
  - Verification: route and viewport tests pass.

- [ ] T503 [Subscriptions] Build subscription card components.
  - Why: Subscription cards repeat vendor, amount, next bill, and status visuals.
  - Expected result: `SubscriptionCard` renders active subscriptions from mock data.
  - Inputs: `subscriptions_center/screen.png`, `subscriptions_center/code.html`.
  - Implementation notes: Use local initials/icons for Netflix/Spotify/Amazon-style cards unless approved local assets exist.
  - Possible bugs: brand logos pulled remotely, recurring billing API implied, card actions do too much.
  - Fix strategy: replace logos with styled initials, keep actions visual-only.
  - Verification: subscription card tests render all mock statuses.

- [ ] T504 [Subscriptions] Build `SubscriptionsCenterScreen`.
  - Why: This screen combines recurring expense summary, AI insight, and subscription grid.
  - Expected result: `/subscriptions` renders summary and active subscription cards with local controls.
  - Inputs: subscriptions export and mock subscriptions/AI insight.
  - Implementation notes: Review changes, add, and filter actions are local-only or placeholders.
  - Possible bugs: desktop side nav copied poorly to mobile, cards overflow, action implies remote changes.
  - Fix strategy: prioritize mobile bottom nav/shell, use one-column or two-column constrained grid, show visual-only feedback.
  - Verification: subscriptions screen test passes at required widths.

## Possible Bugs And Fix Strategy

- Bank/payment integration creep: remove dependency and use mock data.
- Remote logo usage: replace with local assets, initials, or Material icons.
- Grid overflow: use responsive constraints and one-column mobile layout.
- Wrong nav state: centralize tab-to-route mapping.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden dependency search should include billing/bank keywords when reviewing:

```powershell
rg -n "plaid|stripe|paypal|bank|billing|firebase|http|dio|WebView|api" lib pubspec.yaml test
```

## Acceptance Criteria

- Both covered screens render natively.
- Wallet and subscription data is static mock data.
- No bank, billing, payment, backend, API, persistence, WebView, or remote image dependency exists.
- Required viewport and RTL checks pass.

## Stop Condition

Do not move to AI/settings/final QA until wallet and subscription screens pass
compile and viewport checks.
