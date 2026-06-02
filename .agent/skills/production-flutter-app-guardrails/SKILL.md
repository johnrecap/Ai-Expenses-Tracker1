---
name: production-flutter-app-guardrails
description: Use before implementing or reviewing this project's production Flutter app. Enforces local-only financial data, explicit AI/server actions, native Flutter UI, responsive mobile sizes, and RTL/LTR readiness.
---
# Production Flutter App Guardrails

## Current scope

This project is a production Flutter expense tracker. Planning and implementation
may include Flutter screens, local data, app services, AI gateway work,
notifications, monetization, analytics, security, and release readiness when
the active Spec Kit task owns that area.

## Hard rules

- Production app-owned financial data is local-only by default.
- Expenses, categories, wallets, budgets, goals, subscriptions, settings, and
  local AI history must not be written to Firestore, PostgreSQL, or VPS sync
  unless Mohamed approves a separate backend/sync plan.
- Drift/SQLite local storage, BLoC/Cubit, GoRouter, local notifications, app
  lock, monetization, analytics, and Cloudflare Worker AI Gateway are allowed
  when the active Spec Kit task owns that area.
- Firebase Auth may be used only when needed for AI gateway identity/quota or
  legacy auth flows; it must not own financial app data by default.
- AI provider keys must never be placed in Flutter/mobile code.
- AI calls must go through the server-side gateway/proxy.
- AI advice must be explicit user action only and send compact summaries by
  default, not raw expense lists, merchant names, descriptions, or receipt text.
- Do not show mock/demo/sample financial data as real production data.
- No WebView or rendered HTML UI shortcuts.
- Rebuild screens as native Flutter widgets.
- Reuse components and design tokens instead of duplicating UI.
- Validate 360x800, 375x812, and 390x844.
- Keep Arabic RTL and English LTR ready.

## Review checks

1. Check production runtime paths do not instantiate Firestore/VPS for
   app-owned financial data in local-only mode.
2. Check AI requests are explicit, gateway-backed, and do not include raw
   financial histories by default.
3. Check common widgets and theme tokens are reused.
4. Check text direction, localization, and narrow mobile layouts.
5. Run focused tests and touched-file analysis required by the active plan.
