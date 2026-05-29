# Implementation Plan: Localization Routing CI

**Branch**: `021-localization-routing-ci` | **Date**: 2026-05-29 | **Spec**: `specs/021-localization-routing-ci/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Finish cross-cutting production hardening: full EN/AR localization, RTL viewport QA, route coverage, CI workflows, CodeQL, release tooling, and QA documentation.

## Why

The comparison showed `new app` has far fewer localization keys, hardcoded English screens, missing route mappings, no `.github` workflows, and missing verification/release tools from the reference project.

## Expected Result

- Expanded `lib/l10n/app_en.arb` and `app_ar.arb`.
- Generated localization files updated.
- Route coverage tests for all `AppRoutes`.
- CI workflows for Flutter/server/Worker and CodeQL.
- Release signing and verification scripts/docs.
- QA runbooks for RTL and production device checks.

## Source References

- `Expense-Tracker-main/lib/l10n/`
- `Expense-Tracker-main/docs/localization.md`
- `Expense-Tracker-main/docs/qa/`
- `Expense-Tracker-main/.github/workflows/`
- `Expense-Tracker-main/tools/verification/`
- `new app/lib/app/routes.dart`
- `new app/lib/app/router.dart`

## Technical Context

**Primary Dependencies**: Flutter localization tooling, GitHub Actions, CodeQL.

**Testing**: `flutter gen-l10n`, analyzer, widget tests, route tests, workflow syntax review.

**Constraints**: No secrets in CI. No Export screen or Firebase Functions work.

## Constitution Check

- RTL/LTR is mandatory.
- Compile checks are mandatory.
- CI and security hardening are production scope.
- Native Flutter UI remains required.

## Project Structure

```text
lib/l10n/
lib/app/
test/localization/
test/app/
.github/workflows/
tools/verification/
docs/localization.md
docs/qa/
release-signing/
```

## Implementation Batches

### Batch 1 - Localization Expansion

**Expected result**: All app-owned strings are keyed and regenerated for EN/AR.

### Batch 2 - Route Contract

**Expected result**: Route constants, router definitions, tests, and docs are aligned.

### Batch 3 - CI And Security Automation

**Expected result**: GitHub Actions run Flutter/server/Worker checks and CodeQL.

### Batch 4 - Release And QA Runbooks

**Expected result**: Toolchain scripts and QA docs cover release, RTL, and device checks.

## Possible Bugs And Fix Strategy

- **Generated l10n files stale**: run `flutter gen-l10n` after ARB edits.
- **Arabic values translated incorrectly**: translate app-owned labels only, not user data/category names.
- **Route redirects loop**: add route tests for authenticated and unauthenticated states.
- **CI assumes missing folders**: make jobs depend on specs 014/016 or add existence checks.
- **Secrets accidentally documented**: use placeholders and `.env.example` only.

## Verification Plan

```powershell
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub test/localization test/app
rg -n "'[A-Za-z][^']{2,}'|\"[A-Za-z][^\"]{2,}\"" lib/features lib/core/widgets
```

Manual visual matrix: 360x800, 375x812, 390x844 in English LTR and Arabic RTL.

## Stop Condition

Localization, routes, CI, and QA docs are complete enough that future feature work has automated guardrails.
