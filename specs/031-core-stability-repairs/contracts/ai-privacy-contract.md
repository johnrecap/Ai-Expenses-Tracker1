# Contract: AI Privacy And Worker Guardrails

## Scope

Owned files:

- `lib/features/ai/presentation/ai_advice_screen.dart`
- `lib/features/ai/domain/`
- `lib/features/ai/data/`
- `lib/features/ai/services/advisor_service.dart`
- `lib/features/ai/services/ai_api_service.dart`
- `workers/ai-gateway/src/handlers/financialAdvice.ts`
- `workers/ai-gateway/src/handlers/parseExpense.ts`
- `workers/ai-gateway/src/handlers/receiptExtraction.ts`
- `workers/ai-gateway/src/ai/promptBuilder.ts`

## Advice Guarantees

1. Remote AI advice is called only after explicit user action.
2. Advice payload uses compact summary only.
3. Advice payload does not include raw expense rows, merchant names, descriptions, receipt text, or full history by default.
4. Legacy prompt-style advice is not reachable from production routes/providers.
5. Local advice/fallback remains visible if remote AI fails.

## Parse/Receipt Guarantees

1. Text parse sends only the user's current text input and allowed classification context.
2. Receipt scan sends only the selected receipt image and allowed metadata.
3. Stored expense history is not uploaded by default.
4. Request size and allowed MIME types are validated.
5. Raw text, receipt image, and sensitive financial input are not logged.

## Acceptance Tests

- Opening advice screen does not call the gateway.
- Pressing the AI action sends compact summary only.
- Legacy prompt path has no production route/provider entry point.
- Worker rejects oversized advice payloads and raw advice data.
- Worker parse/receipt tests verify boundaries and no raw logging.
