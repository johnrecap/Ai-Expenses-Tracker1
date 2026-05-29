# Research: Wallets And Subscriptions

## Decision: Use local initials/icons instead of remote brand or bank logos

**Rationale**: Remote runtime images are not allowed and exported HTML may reference external assets.

**Alternatives considered**:

- Use `Image.network`: rejected as remote runtime dependency.
- Embed exported logos from the web: rejected unless explicitly approved local assets exist.

## Decision: Add/review actions are placeholders

**Rationale**: The prototype needs interaction affordances without persistence or integrations.

**Alternatives considered**:

- Add wallet or subscription forms now: deferred as missing secondary screens.
- Implement bank/billing APIs: rejected by UI-only scope.

## Decision: Mobile one-column layout is primary

**Rationale**: Required target widths are narrow, and account/subscription cards are content-heavy.

**Alternatives considered**:

- Preserve desktop-style grids from HTML: rejected for 360px responsiveness.
