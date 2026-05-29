---
name: ui-only-prototype-guardrails
description: Use before implementing or reviewing this project's Flutter prototype. Enforces UI-only, native widgets, responsive mobile sizes, and RTL/LTR readiness.
---
# UI-only Flutter Prototype Guardrails

## Hard rules
- No backend implementation.
- No Firebase.
- No real authentication.
- No database.
- No API calls.
- No WebView.
- Rebuild screens as native Flutter widgets.
- Reuse components instead of duplicating UI.
- Validate 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR ready.

## Review checks
1. Search for network/database/auth/WebView imports before finalizing.
2. Check common widgets are extracted into shared components.
3. Check text direction and localization readiness.
4. Run compile/static checks required by the plan.