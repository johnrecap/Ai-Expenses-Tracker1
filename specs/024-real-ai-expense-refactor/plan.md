# Production Flutter Implementation Plan: Real AI Expense Refactor

**Branch**: `main` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/024-real-ai-expense-refactor/spec.md`

**Scope Note**: The older Spec Kit templates in this repo still contain UI-only/mock-data wording. The current constitution, AGENTS.md, and Mohamed's explicit request define this feature as production work: real user data, secure AI gateway usage, no mock financial data, no mobile secrets.

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched `.agents/skills/` and `.agent/skills/` for matching skills.
- Loaded relevant skills.

**Skills used**:

- `speckit-specify`: produced the feature specification.
- `speckit-plan`: produced this implementation plan and supporting design artifacts.
- `speckit-tasks`: will produce the executable task list.
- `flutter-apply-architecture-best-practices`: guides separation of UI, state, services, and repositories.
- `flutter-setup-localization`: guides Arabic/English, ARB, and app locale wiring.
- `flutter-use-http-package`: guides safe typed gateway requests.
- `flutter-fix-layout-issues`: guides narrow-phone and RTL layout checks.
- `dart-run-static-analysis`: guides analyzer/test verification.

## Summary

Refactor the app so the visible product is real rather than prototype-like:

- Remove production dependency on mock financial data.
- Move AI text expense parsing to the secure AI gateway path.
- Require authenticated AI requests and user review before saving.
- Unify manual, quick, AI text, receipt, and edit expense entry behavior.
- Connect localization and RTL/LTR behavior across the app.
- Fix visible UI inconsistencies without changing the approved design language.
- Ensure every visible action works or clearly explains why it is unavailable.

## Why

The app currently has strong foundations, but several flows still behave like a prototype: mock data appears, AI entry can use a mobile-shipped proxy key, localization is partially disconnected, and some visible actions are placeholders. This plan reduces the biggest product risks first: security exposure, fake data, incorrect AI saves, and confusing UI.

## Expected Result

When implementation is complete:

- `.env` is not bundled into Flutter assets.
- Flutter no longer reads or sends `PROXY_API_KEY`.
- AI text parsing uses the existing Worker endpoints with the signed-in user's identity.
- AI-generated expenses always show a review screen/state before saving.
- All dashboard, expenses, reports, budgets, wallets, goals, subscriptions, AI, account, and settings screens show real data, empty states, or intentional unavailable states.
- Arabic and English use the app localization layer, not mixed hardcoded text.
- RTL/LTR direction and directional icons work consistently.
- Main tests and analyzer are brought back to a known baseline.

## Source References

Primary project references:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `APP_DOCUMENTATION.md` at `C:/Users/SOUQ/Downloads/APP_DOCUMENTATION.md`
- `pubspec.yaml`
- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/routes.dart`
- `lib/core/theme/`
- `lib/core/widgets/`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- `lib/features/expenses/`
- `lib/features/ai/`
- `lib/core/mock/`
- `packages/expense_repository/lib/`
- `workers/ai-gateway/src/index.ts`
- `workers/ai-gateway/src/handlers/parseExpense.ts`
- `workers/ai-gateway/src/handlers/receiptExtraction.ts`
- `workers/ai-gateway/src/handlers/financialAdvice.ts`
- `firestore.rules`
- Existing tests under `test/`

## Technical Context

**Language/Version**: Flutter app with Dart SDK constraint `^3.12.0`.

**Primary Dependencies**: Flutter, `flutter_bloc`, `go_router`, Firebase Auth/Core/Firestore, `http`, `flutter_localizations`, `intl`, existing `expense_repository` package, Cloudflare Worker AI Gateway.

**Storage**: Existing repository package with Firebase legacy mode and local-first/VPS work in progress. This feature must preserve existing saved user data and remove UI reliance on mock financial data.

**Testing**: `flutter analyze`, `flutter test`, focused widget/unit tests for AI expense entry, no-mock states, localization, routes, and existing failing tests.

**Target Platform**: Mobile-first Flutter app, verified at 360x800, 375x812, and 390x844 in English LTR and Arabic RTL.

**Project Type**: Production Flutter finance app with secure backend/AI integration.

**Performance Goals**:

- AI parse result appears with a visible loading state and no frozen UI.
- Expense lists and dashboard rebuild from real streams without visible jank.
- Empty states and bottom sheets fit narrow phone screens.

**Constraints**:

- No API keys or shared gateway secrets in Flutter/mobile code.
- No raw AI prompts, financial text, secrets, or full AI response bodies in logs.
- No fake financial data in production flows.
- No new design language without Mohamed approval.
- No WebView or HTML rendering shortcuts.
- Preserve existing user data.

## Required Plan Detail

Every implementation batch must include:

- Why the change exists.
- Exact files to edit.
- Existing components/tokens to reuse.
- How mock data is removed or quarantined.
- Likely bugs and repair strategy.
- Verification commands and manual checks.
- Stop condition before moving to the next batch.

## Constitution Check

**Gate result**: PASS with documented template override.

- `AGENTS.md` and `.specify/memory/constitution.md` were read.
- `.agents/skill-matcher.json` was checked.
- Relevant installed skills were searched before this plan was written.
- Matching skills are listed in the Mandatory First Read And Skill Gate.
- Current constitution production scope is followed.
- Older UI-only/mock-data template wording is not followed for this feature because Mohamed explicitly requested real working behavior and no mock data.
- No WebView or HTML rendering is planned.
- Native Flutter widgets remain the UI approach.
- Shared components and design tokens are planned before screen redesign work.
- Mock financial data is planned for removal from production flows.
- Responsive checks include 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR checks are planned.
- Compile/analyzer/test checks are listed for every implementation batch.
- Security rules from AGENTS.md are followed: AI through server-side gateway/proxy, no mobile secrets.

## Project Structure

### Documentation (this feature)

```text
specs/024-real-ai-expense-refactor/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    ai-gateway-contract.md
    ui-state-contract.md
    localization-contract.md
  tasks.md
```

### Source Code Ownership

```text
pubspec.yaml
lib/
  main.dart
  app/
    app.dart
    app_providers.dart             # proposed extraction
    authenticated_scope.dart       # proposed extraction
    router.dart
    routes.dart
  core/
    config/app_config.dart
    layout/
    theme/
    widgets/
    mock/                          # production usage removed/quarantined
  l10n/
    app_en.arb
    app_ar.arb
  features/
    ai/
      data/                        # proposed gateway client/service boundary
      domain/                      # proposed parse/advice use cases
      presentation/
    expenses/
      domain/                      # proposed AI-to-expense mapping/use case
      presentation/
        cubit/                     # proposed AI expense entry state
        widgets/
    dashboard/
    reports/
    budgets/
    wallets/
    goals/
    subscriptions/
    settings/
packages/
  expense_repository/lib/
workers/
  ai-gateway/src/
test/
```

**Structure Decision**: Keep the existing feature-based Flutter structure, but move AI network behavior out of widgets and into one gateway boundary. Keep repositories in `packages/expense_repository`. Do not create another parallel design system.

## Reuse Strategy

Reuse these existing design pieces before building new UI:

- Theme tokens: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`, `AppTheme`.
- Layout helpers: `ResponsiveConstraints`, `DirectionalityUtils`.
- Shared widgets: `AppBackground`, `AppTopBar`, `AppBottomNav`, `GlassCard`, `GradientButton`, `EmptyState`, `SearchField`, `SectionHeader`, `ProgressBar`, `IconCircleButton`.
- Existing localization ARB files and generated `AppLocalizations`.

New shared pieces should be created only if they remove repeated behavior:

- `AppEmptyStateAction` or equivalent if empty states repeatedly need a title, body, icon, and action.
- `DirectionalIcon` helper if directional icon fixes repeat across screens.
- One reusable expense review panel for manual, quick, AI, receipt, and edit flows.

## Real Data Strategy

Mock financial data must not be used in production UI flows.

Planned handling:

- `lib/core/mock/` can remain only for tests, previews, or explicit development-only fixtures.
- Dashboard, reports, budgets, wallets, goals, subscriptions, AI history, and settings must read from repositories/cubits/services tied to the signed-in user.
- If data does not exist, screens must show empty states and setup actions.
- Any existing screen that currently imports `MockData`, `MockAiService`, or placeholder services must be migrated or explicitly marked unavailable.

## AI Expense Strategy

The AI text expense flow must behave as:

1. User types free-form Arabic or English text.
2. App sends an authenticated request to the AI gateway with locale, default currency, current timestamp, categories, and optional recent context.
3. Gateway returns structured expense data or a structured error.
4. App displays a reviewable draft.
5. User edits missing or incorrect fields.
6. App validates required fields.
7. User confirms save.
8. Saved expense appears in expenses list, dashboard totals, reports, and related budget calculations.

Receipt mode must either use the gateway's receipt endpoint or clearly show an unavailable state. It must not return fake receipt data.

## Possible Bugs And Fix Strategy

- **AI returns incomplete data**: keep the draft visible, mark missing fields, and require manual completion.
- **AI returns category text not matching user categories**: suggest closest known category or require selection.
- **User has no wallet/category**: block save with setup guidance.
- **Gateway auth fails**: refresh identity token once, then show sign-in/session message.
- **Quota exceeded**: show remaining/limit message if available and keep typed text.
- **Network failure**: keep input and offer retry/manual entry.
- **Old proxy path still used**: search for `PROXY_API_KEY`, `/parseExpense`, `/getAdvice`, and `flutter_dotenv`.
- **Mock data leaks**: search for `MockData`, `MockAiService`, placeholder, and fake fixtures in `lib/`.
- **Localization compiles but app does not use it**: verify `AppLocalizations.delegate` is in `MaterialApp.router` and locale comes from settings/language state.
- **RTL icon direction wrong**: replace fixed directional icons with directional helpers.
- **Bottom sheet/input overflow**: test 360x800 and wrap text/fields with bounded constraints.
- **Tests fail because providers are missing**: add shared test harnesses with required blocs/repositories.

## Verification Plan

Run after relevant implementation batches:

```powershell
& 'C:\flutter\bin\flutter.bat' pub get
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test
```

Run backend/worker tests when AI gateway behavior is touched:

```powershell
cmd /c npm --prefix workers/ai-gateway test
cmd /c npm --prefix server test
```

Security searches:

```powershell
rg -n "PROXY_API_KEY|X-API-Key|flutter_dotenv|dotenv\.env|/parseExpense|/getAdvice|AIza|GEMINI_API_KEY|GROQ_API_KEY" lib pubspec.yaml packages workers server --glob "!**/.env"
rg -n "MockData|MockAiService|placeholder|fake|stub" lib packages/expense_repository/lib
```

Visual checks:

```text
360x800 English LTR
360x800 Arabic RTL
375x812 English LTR
375x812 Arabic RTL
390x844 English LTR
390x844 Arabic RTL
```

## Phase 0: Research

Research decisions are captured in [research.md](research.md).

Key resolved decisions:

- Keep current app and refactor, not rebuild from scratch.
- Use secure AI gateway with authenticated user identity.
- Remove mobile-shipped shared proxy secret.
- Keep current theme and shared component style.
- Replace production mock data with real data plus empty states.
- Wire localization before migrating hardcoded strings.

## Phase 1: Design

Design artifacts:

- [data-model.md](data-model.md)
- [contracts/ai-gateway-contract.md](contracts/ai-gateway-contract.md)
- [contracts/ui-state-contract.md](contracts/ui-state-contract.md)
- [contracts/localization-contract.md](contracts/localization-contract.md)
- [quickstart.md](quickstart.md)

## Implementation Phases

### Phase 1 - Security And AI Gateway Foundation

Stop condition:

- `.env` is not bundled.
- Flutter no longer sends `X-API-Key`.
- AI gateway client uses authenticated user identity.
- Existing AI gateway tests still pass or failures are documented.

### Phase 2 - Real Data And Empty States

Stop condition:

- No production screen imports `MockData` or `MockAiService`.
- New account shows empty states.
- Existing account shows real user data.

### Phase 3 - AI Expense Entry UX

Stop condition:

- Arabic and English AI text input produce a reviewable draft.
- Missing fields block save with clear messages.
- Confirmed save updates expenses list and dependent summaries.

### Phase 4 - Localization And RTL/LTR

Stop condition:

- Locale is controlled by user setting/language state.
- Primary screens use localized strings.
- Directional icons and layouts mirror correctly.

### Phase 5 - UI Polish And Action Audit

Stop condition:

- Main actions work or are intentionally unavailable.
- Narrow viewport checks pass.
- Existing design language is preserved.

### Phase 6 - Test Baseline And Regression Fixes

Stop condition:

- `flutter analyze` has no important warnings/errors caused by this work.
- `flutter test` failures are fixed or documented with exact reasons.
- Security searches show no mobile secrets or production mock-data usage.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Older UI-only/mock-data template rules are not followed | Mohamed explicitly requested no mock data and full working behavior; constitution v2.1.0 defines production backend scope | Keeping UI-only/mock behavior would preserve the exact product risk this feature is meant to remove |

