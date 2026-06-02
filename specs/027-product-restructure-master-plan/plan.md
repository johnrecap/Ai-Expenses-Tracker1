# Implementation Plan: Product Restructure Master Plan

**Branch**: `027-product-restructure-master-plan` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/027-product-restructure-master-plan/spec.md`

## Mandatory First Read And Skill Gate

Read before writing this plan:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/skill-matcher.json`

**Skills used**:

- `speckit-specify`
- `speckit-plan`
- `speckit-tasks`

## Summary

This plan restructures the existing production Flutter finance app without starting over. The work is split into phases that make the user journey truthful end to end: setup, real data, one add expense entry, expense management, financial insight, wallets/subscriptions, AI, settings/security/premium, backend services, and release readiness.

## Why

The review found a recurring pattern: many screens exist, but some use mock data, partial wiring, wrong monthly calculations, old AI paths, no-op settings, and incomplete backend contracts. The goal is not a visual refresh first; the goal is to make every visible button and screen honest and working.

## Expected Result

When complete:

- First-run flow cannot be skipped incorrectly.
- Language/currency/notifications are saved and applied.
- Home has one Add entry and no confusing duplicate AI expense button.
- Quick Add and AI Text save real expenses after review.
- Receipt is real or visibly unavailable.
- Expense list filters work.
- Edit preserves hidden fields.
- Categories include aliases.
- Wallet transfers update balances.
- Dashboard, reports, budgets, goals, story, recurring, and subscriptions use real period data.
- AI advice/chat/history are real or honest empty/unavailable states.
- Settings, profile, delete account, app lock, PIN/biometric, premium, and ads are not fake.
- Notifications/export/analytics/exchange rates/Firestore/sync contracts are safe and truthful.

## Source References

- `specs/024-real-ai-expense-refactor/`
- `specs/025-smart-add-entry/`
- `specs/026-startup-onboarding-settings/`
- `lib/app/`
- `lib/features/onboarding/`
- `lib/features/auth/`
- `lib/features/dashboard/`
- `lib/features/expenses/`
- `lib/features/categories/`
- `lib/features/wallets/`
- `lib/features/reports/`
- `lib/features/budgets/`
- `lib/features/goals/`
- `lib/features/recurring_expenses/`
- `lib/features/subscriptions/`
- `lib/features/ai/`
- `lib/features/settings/`
- `lib/features/security/`
- `lib/features/account/`
- `lib/monetization/`
- `lib/services/notifications/`
- `lib/services/export/`
- `lib/services/analytics/`
- `lib/services/exchange_rates/`
- `packages/expense_repository/lib/`
- `firestore.rules`
- `server/`
- `workers/ai-gateway/`

## Technical Context

**Language/Version**: Flutter / Dart, existing project version.

**Primary Dependencies**: Flutter, Dart, Firebase Auth, Firestore, flutter_bloc, go_router, Cloudflare Worker AI Gateway, local/Drift package, server package where applicable.

**Storage**: Firestore primary, local/Drift where implemented, VPS sync planned for parity.

**Testing**: Scoped `flutter analyze`, focused `flutter test`, package/server/worker focused tests.

**Target Platform**: Mobile Flutter app for Egypt/MENA users with Arabic/English and RTL/LTR.

**Project Type**: Production Flutter finance app with backend services.

**Performance Goals**: Fast startup decision, stable forms, no duplicate save, responsive lists, no layout overflow on small devices.

**Constraints**:

- No API keys in Flutter/mobile code.
- AI through gateway only.
- No production mock financial data.
- No fake success for save/delete/purchase/AI.
- Respect current design language.
- Keep edits scoped per phase.

## Constitution Check

Required gates:

- `AGENTS.md` read: yes.
- `.specify/memory/constitution.md` read: yes.
- `.agents/skill-matcher.json` checked: yes.
- Relevant skills loaded: yes.
- Production scope preserved: yes.
- No mobile secrets planned: yes.
- No direct AI provider calls planned: yes.
- No mock production data planned: yes.
- Arabic RTL and English LTR checks planned: yes.
- Scoped verification planned: yes.

**Template conflict note**: Some older templates/rules still mention UI-only prototype. The constitution is newer and explicitly allows production backend integration. This plan follows the constitution and Mohamed's no-mock-data requirement.

## Project Structure

### Documentation

```text
specs/027-product-restructure-master-plan/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
  tasks.md
```

### Implementation Ownership

```text
lib/app/
lib/features/onboarding/
lib/features/auth/
lib/features/dashboard/
lib/features/expenses/
lib/features/categories/
lib/features/wallets/
lib/features/reports/
lib/features/budgets/
lib/features/goals/
lib/features/recurring_expenses/
lib/features/subscriptions/
lib/features/ai/
lib/features/settings/
lib/features/security/
lib/features/account/
lib/monetization/
lib/services/
packages/expense_repository/lib/
firestore.rules
server/
workers/ai-gateway/
test/
```

## Phase Plan

### Phase 0: Control Tower And Baseline

Create a single baseline and no-mock audit so every agent knows what is already fixed, what is in progress, and what failures are pre-existing.

**Stop condition**: Baseline exists and phase ownership is clear.

### Phase 1: Startup, Onboarding, Settings, Language

Implement or finish `specs/026-startup-onboarding-settings/`. Fix setup routing, settings preservation, notification choice save, language delegate, and hardcoded locale.

**Stop condition**: New and returning user routing is correct, saved language/currency applies, and focused onboarding tests pass.

### Phase 2: Real Data And Backend Contract Foundation

Align Firestore rules and app models for expense source, notification settings, user settings, and default data creation. Add no-mock production search gate.

**Stop condition**: Valid app writes are accepted by rules/tests and fake data is not reachable in production flows.

### Phase 3: Unified Expense Entry

Continue `024` and `025`: one Add entry, Quick Add real save, AI Text via new gateway cubit, Receipt real endpoint or unavailable, old AI screen redirected/removed.

**Stop condition**: Quick Add and AI Text create real expenses; Receipt is honest; old duplicate AI flow is gone.

### Phase 4: Expense Management, Categories, Wallets

Make filters real, edit safe, category aliases manageable, wallet selection required where needed, and transfers update balances.

**Stop condition**: User can find, edit, categorize, and account for expenses without metadata loss.

### Phase 5: Financial Insight

Fix dashboard, reports, drilldown, monthly story, monthly budgets, category budgets, saving goals, recurring expenses, and subscriptions with real period data.

**Stop condition**: "This Month" and selected periods match across screens.

### Phase 6: AI Experiences Beyond Entry

Replace fake advice/history/assistant data with real gateway-backed results or honest empty/unavailable states. Add quota/auth/network states.

**Stop condition**: No production AI screen uses `MockAiService` as real output.

### Phase 7: Settings, Account, Security, Premium

Wire settings actions, profile, delete account with reauth, app lock enforcement, PIN/biometric flow, and premium/ads honesty.

**Stop condition**: Security actually protects the app and premium is real or disabled.

### Phase 8: Services And Sync

Fix notifications, export, analytics privacy, exchange-rate failure, Firestore rule tests, local/Drift persistence, and VPS sync contract.

**Stop condition**: Services are truthful, private, and safe on failure.

### Phase 9: Release Readiness

Run scoped and then broader checks only after phase owners have cleaned their areas. Perform manual Arabic/English and small-screen review.

**Stop condition**: Product is ready for Mohamed to review screen by screen.

## Reuse Strategy

- Reuse existing theme files and shared components before adding UI.
- Keep Smart Add sheet from `025` as home add entry foundation.
- Keep AI gateway client/models/cubit foundation from `024`.
- Keep onboarding plan from `026`.
- Prefer existing repositories and blocs over new parallel services.
- Add new abstractions only when they remove duplication or enforce a real contract.

## Mock Data Strategy

Production app must not show mock data. Existing fake data must be replaced with:

- real repository data,
- loading state,
- empty state,
- error state,
- unavailable state.

Test fakes stay under `test/`.

## Possible Bugs And Fix Strategy

- **Route loops after onboarding**: add route/startup tests and avoid navigating before settings save completes.
- **Localization crashes**: ensure generated delegates are registered and tests pump localized app.
- **Firestore rejects writes**: add model/rules contract tests and align enum values.
- **AI quota swallowed**: map gateway errors to user-visible states.
- **Edit wipes fields**: use copy/update behavior and regression tests.
- **Monthly totals wrong**: centralize period filtering and add fixture tests across screens.
- **Wallet transfers wrong**: update both wallets in one safe operation or clearly define balance strategy.
- **App lock not enforced**: add app-level lock gate and resume observer.
- **Exchange rates wrong**: never fallback to `1.0` unless currencies are the same.
- **Full analyzer noisy**: run scoped checks during phases; document unrelated failures.

## Verification Plan

Each phase lists focused commands in `tasks.md`. General preferred commands:

```powershell
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze <touched paths>
& 'C:\flutter\bin\flutter.bat' test <focused tests>
```

Manual checks:

```text
360x800 Arabic RTL
360x800 English LTR
375x812 Arabic RTL
375x812 English LTR
390x844 Arabic RTL
390x844 English LTR
```

No-mock search:

```powershell
rg -n "MockAiService|mock|demo|sample|placeholder|not available yet|Future.delayed" lib packages/expense_repository/lib
```

Security search:

```powershell
rg -n "PROXY_API_KEY|X-API-Key|OPENAI|ANTHROPIC|apiKey|secret|dotenv" lib pubspec.yaml packages/expense_repository/lib
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Production backend work in a template that mentions UI-only | Constitution and user request require real backend and no mock data | UI-only plan would preserve fake/non-working behavior |
