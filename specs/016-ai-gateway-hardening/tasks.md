# Tasks: AI Gateway Hardening

**Input**: `specs/016-ai-gateway-hardening/spec.md`, `specs/016-ai-gateway-hardening/plan.md`

## Phase 1: Worker Boundary

- [ ] T016-001 [US2] Port Cloudflare Worker gateway into `workers/ai-gateway/`
  - Why: `new app` lacks the production AI gateway implementation.
  - Expected result: Worker source, migrations, tests, `package.json`, lockfile, and `wrangler.toml` exist.
  - Inputs: `Expense-Tracker-main/workers/ai-gateway/`.
  - Implementation notes: Do not port Firebase Functions. Keep provider secrets in Worker environment only.
  - Possible bugs: Wrangler config references old account/resource names.
  - Fix strategy: use placeholders and document required secrets; never commit real values.
  - Verification: `cd workers/ai-gateway; npm ci; npm run typecheck; npm test`.

- [ ] T016-002 [P] [US2] Document Worker API contract in `specs/016-ai-gateway-hardening/contracts/worker-api.md`
  - Why: Flutter and Worker must agree on request/response shapes.
  - Expected result: Contract covers `aiParse`, `aiReceipt`, `aiAdvice`, quota metadata, and error payloads.
  - Inputs: Worker handlers and reference specs.
  - Implementation notes: Include auth header requirement and no-auto-write rule.
  - Possible bugs: response field names differ from Flutter parser expectations.
  - Fix strategy: add table of exact JSON keys and update client tests.
  - Verification: contract reviewed against Worker tests.

## Phase 2: Flutter AI Client

- [ ] T016-003 [US1] Replace simplified AI client in `lib/features/ai/services/ai_gateway_client.dart`
  - Why: Current client loses metadata, quota, and typed error behavior.
  - Expected result: Client supports parse, receipt, advice, token provider, timeout, and typed exceptions.
  - Inputs: `Expense-Tracker-main/lib/ai/services/ai_gateway_client.dart`, Worker contract.
  - Implementation notes: Attach Firebase token lazily; no provider keys in Flutter.
  - Possible bugs: unauthenticated state treated as generic network failure.
  - Fix strategy: add explicit auth error code mapping and tests.
  - Verification: `test/ai/ai_gateway_client_test.dart`.

- [ ] T016-004 [P] [US1] Add AI models in `lib/features/ai/models/`
  - Why: Screens need typed drafts, provider metadata, usage status, and action previews.
  - Expected result: Models represent AI draft, receipt payload, advice payload, target match, provider metadata, and quota status.
  - Inputs: Reference `Expense-Tracker-main/lib/ai/models/`.
  - Implementation notes: Keep model conversion deterministic and null-safe for ambiguous AI output.
  - Possible bugs: unknown AI fields crash parsing.
  - Fix strategy: ignore unknown fields and validate required fields before preview.
  - Verification: model parser unit tests.

- [ ] T016-005 [US1] Implement AI service facade in `lib/features/ai/services/ai_service.dart`
  - Why: UI screens should not directly know Worker details.
  - Expected result: Service accepts app context and returns editable drafts/advice/receipt results.
  - Inputs: Current `AiService`, reference AI service classes.
  - Implementation notes: Manual entry must remain usable when AI fails.
  - Possible bugs: service saves expenses automatically.
  - Fix strategy: service returns draft only; persistence stays in create expense bloc after confirmation.
  - Verification: service tests prove no repository write happens during parse.

## Phase 3: UI Integration

- [ ] T016-006 [US1] Wire AI text add screen in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: AI text currently needs production parsing and preview behavior.
  - Expected result: User enters Arabic/English text, gets editable preview, then confirms save.
  - Inputs: AI service, create expense bloc, l10n.
  - Implementation notes: Missing fields stay editable; use existing `ExpenseFormCard`.
  - Possible bugs: Arabic text overflows preview card.
  - Fix strategy: wrap long text, test 360x800 RTL.
  - Verification: widget test and manual Arabic input check.

- [ ] T016-007 [US2] Wire receipt add screen in `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
  - Why: Receipt extraction should use gateway and not create automatic expenses.
  - Expected result: Selected image is validated, sent to gateway, parsed into editable draft, then saved only on confirmation.
  - Inputs: `image_picker`, `image`, AI receipt contract.
  - Implementation notes: Add image size limit and progress/error states.
  - Possible bugs: base64 image causes memory spike.
  - Fix strategy: resize/compress before encoding and reject very large files.
  - Verification: receipt widget/service tests with mock image bytes.

- [ ] T016-008 [US3] Wire AI quota and action logs into settings/history screens
  - Why: Users need transparency and quota feedback.
  - Expected result: AI history screen reads `AiActionLogRepository`; settings shows usage/quota state.
  - Inputs: repository package AI action log files, settings screen.
  - Implementation notes: Localize messages and keep user-generated text unmodified.
  - Possible bugs: history leaks sensitive raw provider payloads.
  - Fix strategy: store only app-safe summaries and action metadata.
  - Verification: AI history tests and source review.

## Final Verification

- [ ] T016-009 [Polish] Run AI gateway, Flutter tests, and secret search
  - Why: AI touches privacy, cost, auth, and trust.
  - Expected result: Worker and Flutter tests pass; no provider secrets in source.
  - Inputs: Completed Worker and Flutter AI code.
  - Implementation notes: Firebase Functions fallback must not be added.
  - Possible bugs: tests require network/provider access.
  - Fix strategy: mock provider and HTTP responses for tests.
  - Verification: `npm test` under Worker, `flutter test --no-pub test/ai`, `rg -n "API_KEY|GEMINI|OPENAI|ANTHROPIC" lib workers`.
