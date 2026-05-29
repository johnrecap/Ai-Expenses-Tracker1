# Tasks: Localization Routing CI

**Input**: `specs/021-localization-routing-ci/spec.md`, `specs/021-localization-routing-ci/plan.md`

## Phase 1: Localization

- [ ] T021-001 [US1] Expand localization keys in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
  - Why: `new app` has far fewer keys than the reference and many hardcoded strings.
  - Expected result: App-owned strings for auth, dashboard, expenses, categories, budgets, reports, wallets, subscriptions, AI, settings, account, security, monetization, tour, and notifications have EN/AR keys.
  - Inputs: reference ARB files, current screens, `docs/localization.md`.
  - Implementation notes: Do not translate user-generated values such as category names, merchant names, or descriptions.
  - Possible bugs: duplicate or unstable key names.
  - Fix strategy: group keys by feature and prefer descriptive stable names.
  - Verification: `flutter gen-l10n` succeeds.

- [ ] T021-002 [US1] Replace hardcoded app-owned strings across `lib/features/`
  - Why: Users need complete EN/AR experience.
  - Expected result: Screens read `AppLocalizations` instead of inline English strings.
  - Inputs: localization keys, current feature screens.
  - Implementation notes: Keep formatting placeholders for amounts, dates, and counts.
  - Possible bugs: localizations unavailable in widgets outside context.
  - Fix strategy: pass localized labels from parent or use context in build methods only.
  - Verification: source search for hardcoded English reviewed to approved allowlist.

- [ ] T021-003 [P] [US1] Add localization tests in `test/localization/`
  - Why: Missing keys or stale generated files can break runtime strings.
  - Expected result: Tests verify supported locales, key coverage, and selected Arabic strings.
  - Inputs: current l10n generated files.
  - Implementation notes: Include RTL directionality smoke tests.
  - Possible bugs: generated files not committed after ARB changes.
  - Fix strategy: rerun `flutter gen-l10n` and update tests.
  - Verification: `flutter test --no-pub test/localization`.

## Phase 2: Routes

- [ ] T021-004 [US2] Create route contract in `specs/021-localization-routing-ci/contracts/route-contract.md`
  - Why: Every route needs an owner, auth rule, and screen mapping.
  - Expected result: Contract lists all paths in `AppRoutes`, screen widget, feature owner, and status.
  - Inputs: `lib/app/routes.dart`, `lib/app/router.dart`, specs 014-020.
  - Implementation notes: Mark Export as intentionally excluded/deferred.
  - Possible bugs: contract drifts from code.
  - Fix strategy: route test fails when constants and GoRoutes diverge.
  - Verification: contract reviewed against route test.

- [ ] T021-005 [US2] Align route constants and router definitions in `lib/app/`
  - Why: Constants such as `/ai/assistant` or filter routes must be mapped or removed.
  - Expected result: Every active route constant has a `GoRoute`; deferred routes are documented and not exposed.
  - Inputs: route contract and current router.
  - Implementation notes: Protected routes redirect unauthenticated users; public routes remain limited to auth/onboarding.
  - Possible bugs: deep links bypass auth.
  - Fix strategy: route redirect tests for public/protected paths.
  - Verification: `test/app/routes_test.dart`.

- [ ] T021-006 [P] [US2] Add navigation smoke tests in `test/app/`
  - Why: Route regressions break feature discoverability.
  - Expected result: Tests cover route existence, auth redirects, and not-found behavior.
  - Inputs: router and fake auth bloc.
  - Implementation notes: Avoid Firebase initialization in route tests by using fakes.
  - Possible bugs: tests hang due to stream not closing.
  - Fix strategy: dispose blocs and use controlled streams.
  - Verification: `flutter test --no-pub test/app`.

## Phase 3: CI And Tools

- [ ] T021-007 [US3] Add GitHub CI workflow in `.github/workflows/ci.yml`
  - Why: Regression checks should run before merge.
  - Expected result: CI runs Flutter pub get, analyze, tests, server checks, and Worker checks when folders exist.
  - Inputs: reference `.github/workflows/ci.yml`, current project structure.
  - Implementation notes: Use Node 20 for server/Worker; keep Flutter stable action cache.
  - Possible bugs: CI fails when server/Worker folders not yet implemented.
  - Fix strategy: add path existence guards or make this depend on specs 014/016 completion.
  - Verification: workflow syntax review and local equivalent commands.

- [ ] T021-008 [P] [US3] Add CodeQL workflow in `.github/workflows/codeql.yml`
  - Why: TypeScript backend/Worker code needs security scanning.
  - Expected result: CodeQL scans JavaScript/TypeScript on push/PR and weekly schedule.
  - Inputs: reference CodeQL workflow.
  - Implementation notes: Minimal permissions; no secrets required.
  - Possible bugs: CodeQL scans huge reference repos under docs if present.
  - Fix strategy: ensure reference repos are intentionally handled or excluded if needed.
  - Verification: workflow syntax review.

- [ ] T021-009 [P] [US3] Add verification scripts in `tools/verification/`
  - Why: Local agents need repeatable diagnostics and safe format commands.
  - Expected result: Toolchain diagnose and safe Dart format scripts exist.
  - Inputs: reference `tools/verification/`.
  - Implementation notes: Scripts must not delete or reset user changes.
  - Possible bugs: PowerShell execution policy blocks scripts.
  - Fix strategy: document `-ExecutionPolicy Bypass` usage in README.
  - Verification: run scripts in dry/safe mode.

## Phase 4: Release And QA Docs

- [ ] T021-010 [US3] Add QA runbooks under `docs/qa/`
  - Why: RTL, device, Firebase, Worker, ads, and sync checks need repeatable manual coverage.
  - Expected result: Production device QA, Arabic RTL checklist, QA run template, and Flutter verification runbook exist.
  - Inputs: reference `Expense-Tracker-main/docs/qa/`.
  - Implementation notes: Remove Export screen checks or mark them out of scope.
  - Possible bugs: docs instruct agents to run Firebase Functions checks.
  - Fix strategy: replace Functions references with server/Worker checks.
  - Verification: docs search for forbidden scope.

- [ ] T021-011 [P] [US3] Add release signing docs under `release-signing/`
  - Why: Release builds need signing instructions without storing keys.
  - Expected result: Placeholder signing README and ignored key locations are documented.
  - Inputs: reference `release-signing/`, Android build files.
  - Implementation notes: No keystore, passwords, or service account files in Git.
  - Possible bugs: docs accidentally encourage committing keystore.
  - Fix strategy: include explicit "never commit" warning and `.gitignore` patterns if needed.
  - Verification: `rg -n "storePassword|keyPassword|BEGIN PRIVATE KEY|AIza" .`.

## Final Verification

- [ ] T021-012 [Polish] Run localization, route, and CI-readiness verification
  - Why: These guardrails protect every later feature.
  - Expected result: Gen-l10n, analyze, app/localization tests pass; workflow files reviewed.
  - Inputs: completed localization/routing/CI work.
  - Implementation notes: Export and Firebase Functions remain out of scope.
  - Possible bugs: analyzer timeout due to generated files or large docs references.
  - Fix strategy: scope commands to `lib`/`test` first, then full repo when stable.
  - Verification: `flutter gen-l10n`; `flutter analyze --no-pub`; `flutter test --no-pub test/localization test/app`; hardcoded string source search; required viewport matrix.
