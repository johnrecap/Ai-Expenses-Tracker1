# QC-01: Remove MockData from 3 AI Screens

## Metadata
- **ID:** QC-01
- **Priority:** High
- **Assignee:** flutter-master
- **Status:** Ready
- **Created:** 2026-05-29
- **Due:** Before v1.0 release

## Goal
Remove all MockData usage from 3 AI screens and replace with real AiService calls.

## Context
The app currently uses MockData in AI presentation screens for development/testing. Before production release, all mock data must be replaced with real service calls.

## Files to Modify
1. `lib/features/ai/presentation/ai_advice_screen.dart`
2. `lib/features/ai/presentation/ai_assistant_sheet.dart`
3. `lib/features/ai/presentation/ai_history_screen.dart`

## Acceptance Criteria
- [ ] No MockData imports remain in the 3 files
- [ ] All MockData calls replaced with AiService calls
- [ ] Screens work with real data
- [ ] Error handling for failed service calls
- [ ] Loading states during service calls
- [ ] flutter analyze passes with 0 errors

## Technical Notes
- AiService location: `lib/features/ai/services/ai_service.dart`
- Check if AiService has required methods
- If AiService is incomplete, document what's missing

## Verification Steps
1. Run `flutter analyze` → 0 errors
2. Test each screen loads real data
3. Test error handling (offline, server error)
4. Code review by hamza

## Related
- Depends on: AiService implementation completeness
- Blocks: v1.0 release
