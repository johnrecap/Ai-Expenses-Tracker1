# UI-Only Flutter Implementation Plan: Wallets And Subscriptions

**Branch**: `006-wallets-subscriptions` | **Date**: 2026-05-28 | **Spec**: `specs/006-wallets-subscriptions/spec.md`

**Input**: Feature specification from `/specs/006-wallets-subscriptions/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Summary

Implement wallet/account and subscriptions center screens from static mock data, using reusable cards and no financial integrations.

## Why

These screens visually imply bank accounts, balances, recurring payments, and subscription changes. The plan preserves UI fidelity while blocking bank, billing, payment, API, and persistence creep.

## Expected Result

- `/wallets`
- `/subscriptions`
- `WalletCard`, `TransferPreviewTile`, `SubscriptionCard`
- Wallet and subscription tests

## Source References

- `stitch_ai_expenses_tracker_pro/wallets_accounts/`
- `stitch_ai_expenses_tracker_pro/subscriptions_center/`
- `specs/component-map.md`
- `specs/design-system.md`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets and mock data

**Storage**: N/A. Static mock data only.

**Testing**: Widget tests for account/subscription cards, viewport checks, RTL checks, forbidden dependency search

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Constraints**: No bank, billing, payment, backend, API, database, persistence, remote runtime logos, WebView, or HTML rendering

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Reuse planned: PASS
- Mock/local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/wallets/presentation/
lib/features/wallets/presentation/widgets/
lib/features/subscriptions/presentation/
lib/features/subscriptions/presentation/widgets/
test/features/wallets/
test/features/subscriptions/
```

**Structure Decision**: Wallet and subscription domain widgets stay feature-local; shared metrics/AI cards remain in core.

## Reuse Strategy

Use `GlassCard`, `MetricCard`, `AiInsightCard`, `SectionHeader`, `AppTopBar`, `AppBottomNav`, `GradientButton`, and theme tokens. Create reusable domain cards for wallets, transfers, and subscriptions.

## Mock Data Strategy

Use static `MockWallet`, `TransferPreview`, and `MockSubscription` data. Actions are local snackbars or placeholder routes only.

## Possible Bugs And Fix Strategy

- Remote logos: replace with local initials/icons or approved assets.
- Account grid overflow: use one-column mobile layout and responsive constraints.
- Bank/payment dependency added: remove package/import and replace with mock data.
- Balance text overflow: constrain amount text.
- Wrong nav active state: centralize tab mapping.

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden search:

```powershell
rg -n "plaid|stripe|paypal|bank|billing|payment|firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|api|Image.network|NetworkImage" lib pubspec.yaml test
```

Viewport checks: 360x800, 375x812, 390x844 in LTR and RTL.

## Phase 0: Research

Completed in `research.md`.

## Phase 1: Design

Completed in `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`, and `tasks.md`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
