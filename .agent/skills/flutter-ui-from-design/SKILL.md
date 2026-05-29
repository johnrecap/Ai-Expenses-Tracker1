---
name: flutter-ui-from-design
description: Use when converting screenshots, Figma/Stitch screens, UI kits, or visual references into Flutter UI. Focuses on pixel structure, responsive layout, design tokens, assets, and no-backend MVP screens.
---
# Flutter UI From Design References

## Workflow
1. Inventory all screens/assets before coding.
2. Define design tokens first: colors, spacing, typography, radii, shadows.
3. Build shared widgets before screens.
4. Use Material 3 by default unless the project chooses another design system.
5. Keep backend/API calls out of UI-only work unless explicitly requested.
6. Run `flutter analyze`, widget tests for reusable widgets, and manual screenshot comparison.

## Required output for tasks
- Why this task exists.
- Expected result.
- Possible bugs.
- Fix strategy.
- Verification command or manual check.
- Stop condition.