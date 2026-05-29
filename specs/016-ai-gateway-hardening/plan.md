# Implementation Plan: AI Gateway Hardening

**Branch**: `016-ai-gateway-hardening` | **Date**: 2026-05-29 | **Spec**: `specs/016-ai-gateway-hardening/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Bring `new app` AI behavior up to production parity using Cloudflare Worker gateway contracts, rich error handling, quota metadata, action logs, and editable previews. Do not implement Firebase Functions fallback.

## Why

The current AI client in `new app` is a simplified HTTP wrapper. It does not enforce auth token expectations, rich structured response parsing, provider metadata, quota surfaces, or robust fallback behavior seen in `Expense-Tracker-main`.

## Expected Result

- `workers/ai-gateway/` present and testable.
- Flutter `AiGatewayClient` supports parse, receipt, advice, quota metadata, and typed failures.
- AI text/receipt/advice screens use gateway services with editable previews.
- AI history and quota settings are backed by repository logs.
- No Firebase Functions AI client.

## Source References

- `Expense-Tracker-main/workers/ai-gateway/`
- `Expense-Tracker-main/lib/ai/`
- `Expense-Tracker-main/lib/screens/ai_assistant/`
- `new app/lib/features/ai/`
- `new app/lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `new app/lib/features/expenses/presentation/add_expense_receipt_screen.dart`

## Technical Context

**Language/Version**: TypeScript Worker, Dart 3.12.0, Flutter 3.44.0.

**Primary Dependencies**: `http`, `firebase_auth`, `image_picker`, `image`, `speech_to_text`, repository package.

**Testing**: Worker typecheck/tests; Flutter service, cubit, and widget tests.

**Constraints**: No provider keys in Flutter. No Firebase Functions fallback. No automatic AI writes.

## Constitution Check

- AI gateway boundary matches constitution.
- User correction excludes Firebase Functions.
- Native Flutter UI remains required.
- RTL/LTR and localization are required for AI surfaces.

## Project Structure

```text
workers/ai-gateway/
lib/features/ai/
lib/features/expenses/presentation/add_expense_ai_text_screen.dart
lib/features/expenses/presentation/add_expense_receipt_screen.dart
packages/expense_repository/lib/src/*ai_action*
test/ai/
```

## Implementation Batches

### Batch 1 - Worker Parity

**Expected result**: Worker source, schema, quota, auth verification, and tests are available.

### Batch 2 - Flutter Gateway Client

**Expected result**: Typed client/service layer matches Worker contract and handles failures safely.

### Batch 3 - AI UI Integration

**Expected result**: AI text, receipt, advice, assistant, quota, and history use real services.

### Batch 4 - QA And Secret Audit

**Expected result**: Tests cover gateway cases and source search proves no provider secrets.

## Possible Bugs And Fix Strategy

- **Worker route names mismatch Flutter client**: centralize endpoint constants and add contract tests.
- **Missing auth token causes silent fallback**: fail with typed unauthenticated state and localized message.
- **Malformed provider output crashes UI**: parse defensively and keep manual entry available.
- **Large receipt image causes memory pressure**: enforce image size/mime constraints before base64 encoding.
- **Quota failure blocks manual entry**: restrict only AI action and leave manual save enabled.

## Verification Plan

```powershell
cd workers/ai-gateway
npm ci
npm run typecheck
npm test
cd ../..
flutter analyze --no-pub
flutter test --no-pub test/ai test/features/expenses
rg -n "GEMINI|OPENAI|ANTHROPIC|API_KEY|providerKey" lib pubspec.yaml
```

## Stop Condition

AI features use the Worker gateway, every AI result is previewed before persistence, quota/error states are tested, and no Firebase Functions fallback or provider keys are added.
