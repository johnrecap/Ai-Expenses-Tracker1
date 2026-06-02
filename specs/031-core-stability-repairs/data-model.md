# Data Model: Core Stability Repairs

## Local Store Readiness

**Purpose**: Represents whether local financial data has finished loading and can safely be read.

**Fields / Concepts**:

- `ready`: loading is complete.
- `failed`: loading failed and the UI should not write defaults as if data is empty.
- `loadError`: user-safe failure details for diagnostics and retry.

**Rules**:

- Reads that can create defaults must not run before readiness.
- Watch streams must either wait for readiness or expose a clear loading state.
- Startup must not overwrite existing settings because loading has not completed.

## Durable Save Result

**Purpose**: Represents whether local write persistence actually succeeded.

**Fields / Concepts**:

- `operation`: create, update, delete, or settings save.
- `entityType`: expense, category, budget, wallet, settings, etc.
- `success`: write completed durably.
- `failure`: write failed and must be shown to the user.

**Rules**:

- UI success states must depend on durable write success.
- Failed writes must not leave the user believing data is saved.
- In-memory updates must not hide persistence failures.

## Monthly Budget

**Purpose**: A budget scoped to a month and year.

**Fields / Concepts**:

- `month`
- `year`
- `amount`
- `currency`
- `warningThresholdPercent`

**Rules**:

- Reads and watches must filter by month/year.
- Multiple months can exist at the same time.
- Home, reports, budget alerts, and AI summaries must use the requested month.

## Wallet Balance Policy

**Purpose**: Defines whether wallet balance is automatic or manual.

**Preferred Policy**: Automatic when an expense is linked to a wallet.

**Automatic Rules**:

- Creating a wallet-linked expense reduces wallet balance by expense amount.
- Editing amount adjusts only the difference.
- Moving expense from wallet A to wallet B reverses A and applies B.
- Deleting a wallet-linked expense restores the amount.
- Currency mismatch must be rejected or handled explicitly; do not silently adjust different currencies.

**Manual Fallback Rules**:

- If automatic behavior is deferred, wallet balance must be labeled as manually maintained.
- The UI must not imply expenses affect wallet balance.

## AI Advice Request

**Purpose**: User-triggered request for richer AI advice.

**Fields / Concepts**:

- `userAction`: explicit button/action that starts the request.
- `summary`: compact financial summary only.
- `period`: the summarized period.
- `locale`: requested response language.
- `defaultCurrency`: display currency.

**Forbidden By Default**:

- raw expense rows;
- merchant names;
- expense descriptions;
- receipt text;
- full history;
- prompt-only advice payloads from legacy services.

## AI Parse/Receipt Request

**Purpose**: Explicit user action to parse current input or current receipt image.

**Fields / Concepts**:

- `input`: current text typed by the user for parsing.
- `image`: current receipt image selected by the user.
- `locale`
- `defaultCurrency`
- `categories` where needed for classification.

**Rules**:

- Must not upload stored expense history by default.
- Must validate request size and allowed image types.
- Must not log raw text/image content.

## Notification Schedule State

**Purpose**: Tracks whether app-managed reminders are active.

**Fields / Concepts**:

- `enabled`
- `dailyReminder`
- `dailyReminderTime`
- `scheduledIds`

**Rules**:

- Disabling notifications cancels app-managed reminders.
- Enabling notifications requests permission before scheduling.
- Permission denial leaves notifications disabled.

## Settings Preference

**Purpose**: User preferences changed after onboarding.

**Fields / Concepts**:

- language
- base currency
- default payment method
- notifications

**Rules**:

- Changing one preference must not reset another.
- Settings changes should not reopen onboarding.
- Arabic and English labels must be localized.

## Home Insight Card

**Purpose**: User-facing financial card on Home.

**Allowed States**:

- real calculated insight;
- empty state;
- unavailable state;
- loading state.

**Forbidden State**:

- static/fake financial claim presented as real user data.

## Release Readiness Item

**Purpose**: Tracks non-core blockers for store release.

**Items**:

- Android signing.
- Ads readiness.
- Purchase/restore readiness.
- Analytics consent.
- Privacy policy.
- Release build verification.

**Rules**:

- These do not block core stability implementation.
- They do block production release.
