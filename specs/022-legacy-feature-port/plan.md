# Implementation Plan: Legacy Feature Port

**Branch**: `022-legacy-feature-port` | **Date**: 2026-05-29 | **Spec**: `specs/022-legacy-feature-port/spec.md`

## Strategy

**Method:** Hermes orchestrator wrote files directly using `write_file` after sub-agents timed out on large tasks. Lesson learned: sub-agents work best with 1-2 file tasks, not full feature porting.

**Design system adaptation:** All old app screens were rewritten to use the new design system (AppColors, AppTextStyles, AppSpacing, AppBackground, GlassCard, GradientButton). Zero screens use the old `Colors.grey[100]` / white card design.

## Implementation Batches

### Batch 1: Security (Done)
### Batch 2: Account (Done)
### Batch 3: Settings Rewrite (Done)
### Batch 4: Monetization (Done)
### Batch 5: AI Services (Done)
### Batch 6: Backup (Done)
### Batch 7: Wallet + Subscriptions Mock→Real (Done)
### Batch 8: Routes + Wiring (Done)

## Constitution Check
- [x] Native Flutter widgets only
- [x] Reused shared components (GlassCard, AppBackground, AppTopBar, etc.)
- [x] RTL ready (EdgeInsetsDirectional used where applicable)
- [x] No secrets in code
- [x] No WebView or HTML rendering

## Verification
```bash
flutter analyze --no-pub
flutter test
```
