# No-Mock Production Audit

Date: 2026-05-31

## Rule

Normal production routes must show real data, loading, empty, error, or explicit unavailable states. They must not show fake financial, AI, purchase, account, or analytics data as if it is real.

Searches run:

```powershell
rg -n "MockAiService|MockData|mock|demo|sample|placeholder|not available yet|Future\.delayed|fake|stub|KWD|NoOp|setPremium" lib packages/expense_repository/lib -g '!**/*.g.dart'
rg -n "PROXY_API_KEY|X-API-Key|OPENAI|ANTHROPIC|apiKey|secret|dotenv|\.env|AI_GATEWAY|CLOUDFLARE" lib pubspec.yaml packages/expense_repository/lib -g '!**/*.g.dart'
rg -n "core/mock|MockData|MockAiService|NoOpAdService|setPremium|receipt_upload_panel|camera_scanner_service|local_stubs" lib packages/expense_repository/lib -g '!**/*.g.dart'
```

## Production Blockers To Remove Or Make Honest

### AI advice, assistant, and history

Status: production usage fixed; continue privacy/history work under `T026`.

Hits:

- Previous production `MockAiService` usage was removed.
- `lib/features/ai/services/ai_service.dart` no longer contains `MockAiService`.

User risk:

- The app shows generated-looking advice and chat messages based on fake KWD data.

Decision:

- Move/remove production usage.
- Tests may keep fakes under `test/`.
- Screens must use real gateway/repository state or show an explicit empty/unavailable state.

Owner task:

- `T024`, `T025`, `T026`.

### Receipt upload visual parser

Status: honest unavailable state; real OCR remains future work.

Hits:

- Receipt UI now states scanning is not available instead of showing fake receipt details.
- `lib/features/ai/services/camera_scanner_service.dart` returns no parsed data until a real server-side OCR path exists.

User risk:

- The user can believe receipt OCR worked when the shown receipt details are fake.

Decision:

- Route receipt to the real `extractReceipt` path with review, or keep the receipt route disabled/unavailable until it is real.

Owner task:

- `T012`.

### Premium, purchase, and ads

Status: honest unavailable state.

Hits:

- Purchase and restore actions return unavailable until store billing and server entitlement checks exist.
- Premium screen keeps upgrade/restore disabled.
- `MonetizationCubit.setPremium` is `@visibleForTesting` and assert-only, so it is not a production purchase path.

User risk:

- Upgrade/restore/ads can look real while no store/server entitlement is verified.

Decision:

- Either implement real verified entitlement flow or show premium/ads as unavailable/disabled. Do not allow fake purchase success.

Owner task:

- `T031`.

### Hardcoded KWD and fake/default currency assumptions

Status: addressed for normal production routes.

Hits include:

- Dashboard, wallets, budgets, reports, and story screens now read saved settings/base currency or existing record currency.
- New wallet and monthly budget creation default to `UserSettings.defaultBaseCurrency` / saved base currency.
- Remaining `KWD` hits in production source are decimal-format helpers for an already existing KWD expense/draft currency, not fake display values.

User risk:

- Mohamed's target users may select EGP/AED/SAR/USD but still see or save KWD in finance flows.

Decision:

- Replace display/save fallbacks with saved base currency, selected wallet currency, or real expense currency.
- Example text should be localized and use supported/default currency.

Owner tasks:

- `T005`, `T006`, `T011`, `T017`, `T019`, `T021`, `T027`.

### Local repository stubs

Status: contract-aligned for current local/VPS sync scope; no fake user data is shown from these classes.

Hits:

- `packages/expense_repository/lib/src/repository_factory.dart` imports `local_stubs.dart`.
- `packages/expense_repository/lib/expense_repository.dart` exports `local_stubs.dart`.
- `packages/expense_repository/lib/src/local/local_stubs.dart` defines local implementations for aliases, budgets, recurring expenses, AI logs, wallets, and transfers.

User risk:

- Lower after `T036`: push payloads now match the VPS server, pull applies remote changes locally, and the Drift pending queue persists across restarts.
- Remaining local repository limitations, such as unsupported delete actions, are action-completeness issues rather than mock financial data.

Decision:

- Keep only as explicit local/test fallback until sync is repaired.
- Do not present VPS/local-first sync as production-ready until push/pull/pending queue are contract-aligned.

Owner task:

- `T036` completed.
- Re-check action completeness under final polish/action audit.

### Account actions

Status: real auth flow connected.

Hits:

- `lib/features/account/services/account_profile_service.dart` uses `AuthRepository` for profile name, password reset, email change verification, password/Google reauth, and auth deletion.
- User data deletion removes known Firestore user subcollections before auth deletion after reauth.

User risk:

- Lower than fake success because it fails clearly, but account management is not complete.

Decision:

- Keep unavailable errors until real auth/profile/delete flow is wired.
- Settings/account UI must show clear states and not silently do nothing.

Owner tasks:

- `T027`, `T028`.

### Settings notification TODOs

Status: addressed.

Hits:

- Notification settings are wired through `SettingsCubit` and `NotificationService`; no TODO hit remains in the settings screen.

User risk:

- User toggles or settings labels may not affect saved notification behavior.

Decision:

- Wire to real settings or mark unavailable clearly.

Owner tasks:

- `T027`, `T032`.

## Allowed Or Lower-Risk Hits

### Test-only and fixture mock data

Status: addressed for production source tree.

Hits:

- Previously `lib/core/mock/mock_data.dart` contained large fake KWD fixture sets.
- It has been moved to `test/fixtures/core_mock/` with `test/core/mock_test.dart` updated.

Decision:

- Production import search does not show `MockData` or `core/mock` in `lib/` or `packages/expense_repository/lib/`.
- Mock fixtures are test-only now.

Owner task:

- Partial progress toward `T009`; not enough to close `T009` because other production blockers remain.

### Animation delays

Status: allowed if purely visual.

Hits:

- `lib/shared/animations/pulse_animation.dart`
- `lib/core/widgets/ai_expense_form.dart`
- `lib/features/ai/services/voice_input_service.dart`
- `lib/features/ai/presentation/ai_chat_screen.dart`

Decision:

- These are not automatically fake data. Re-check if a delay is used to simulate a save/API success.

Owner task:

- Relevant feature owner when touching that screen/service.

### API key fields

Status: review, not immediate secret leak from search output.

Hits:

- `lib/services/exchange_rates/exchange_rate_service.dart` accepts optional `_apiKey`.
- `lib/core/config/app_config.dart` reads `AI_GATEWAY_URL`.
- `lib/features/ai/services/ai_api_service.dart` comments state it does not read `.env` or send client API keys.

Decision:

- Public gateway URL is allowed.
- Optional exchange-rate API key must not be hardcoded or logged.
- No Flutter production hit for `PROXY_API_KEY`, `X-API-Key`, `flutter_dotenv`, or `.env` asset was found in this search.

Owner tasks:

- `T035` for exchange-rate behavior.
- `T037` final security/no-mock search.

## Phase Ownership Summary

- Phase 1: close `026 T018`, language/currency/settings visible correctness.
- Phase 2: remove/isolate mock production hits and contract drift.
- Phase 3: Quick Add, AI Text, Receipt, and old AI route.
- Phase 4: filters, edit, aliases, wallets, transfers.
- Phase 5: dashboard/reports/budgets/goals/subscriptions period and real data.
- Phase 6: AI advice/history/assistant no longer fake.
- Phase 7: settings/account/security/premium no fake success.
- Phase 8: services/sync honest and safe.
- Phase 9: final no-mock truthfulness audit.

## T037 Final Truthfulness Audit Snapshot

Date: 2026-05-31

Latest production searches were run across `lib` and `packages/expense_repository/lib`.

Classified safe/honest hits:

- `not available yet` appears only in explicit unavailable states such as Privacy Policy, Terms, Help, Feedback, Premium, Receipt scanning, AI advice, and AI assistant.
- `KWD` appears only as currency decimal formatting for a real selected/parsed currency, not as fake default data.
- `Future.delayed` hits are animation/listening timing only; no fake save/API success is generated.
- `sampleExpenseIds` is a domain field for recurring detection examples taken from real user expenses.
- `local_stubs.dart` remains a local repository implementation layer, not seeded fake user data; sync contract repairs are covered by `T036`.
- `setPremium` remains test-only/assert-guarded and is not a production purchase success path.

Security/config hits:

- `AI_GATEWAY_URL` is a public compile-time gateway URL only.
- `AiApiService` is a compatibility wrapper around `AiGatewayClient`; it does not read `.env` or send `X-API-Key`.
- `ExchangeRateService` accepts an optional API key parameter but no hardcoded key was found in production Flutter source.

Result:

- No production route currently shows fake financial records, fake AI output, fake receipt parsing, or fake purchase success as real.
- Remaining hits are either honest unavailable states, test/dev guards, or action-completeness follow-ups.
