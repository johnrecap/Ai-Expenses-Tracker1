# AGENTS.md — AI Expenses Tracker

## Project

Flutter app: AI Expenses Tracker.

Target users:
- Egypt / MENA users
- Arabic and English
- RTL and LTR support

Main stack:
- Flutter / Dart
- Firebase Auth
- Firestore
- BLoC / Cubit
- GoRouter
- Cloudflare Worker AI Gateway

## Mohamed Preferences

- Reply to Mohamed in Egyptian Arabic.
- Mohamed is a beginner programmer.
- Explain practical cause and fix.
- Give commands and file paths clearly.
- Do not ask many questions unless necessary.

## Critical Design Rules

Before editing UI:
1. Inspect existing theme files.
2. Inspect shared components.
3. Inspect docs/design.md if present.
4. Match current colors, typography, spacing, shadows, and component style.
5. Do not add new colors/styles without Mohamed approval.

Never create a new design language.

## Critical Security Rules

- Never put API keys in Flutter/mobile code.
- AI APIs must go through server-side gateway/proxy.
- Use `.env`, server env vars, Cloudflare Worker secrets, or aaPanel secure settings.
- Do not print secrets in logs.
- Warn if screenshots or files expose tokens.

## Commands

Use these checks when relevant:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```
