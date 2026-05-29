# Quickstart: Foundation Verification

## Read First

1. `AGENTS.md`
2. `.specify/memory/constitution.md`
3. `.agents/workflows/development.md`
4. `.agents/skill-matcher.json`
5. Relevant skills in `.agents/skills/` and `.agent/skills/`

## Implementation Order

1. Create or confirm Flutter project in the workspace root.
2. Add analysis/lint setup.
3. Add theme tokens.
4. Add responsive and directionality helpers.
5. Add shared widgets.
6. Add route constants and placeholder router.
7. Add mock models/data.
8. Add local asset registration.
9. Add smoke tests.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Fallback if Android build tooling is unavailable:

```powershell
flutter build web
```

Forbidden dependency search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api" lib pubspec.yaml test
```

## Manual Viewport Checks

- 360x800 LTR and RTL
- 375x812 LTR and RTL
- 390x844 LTR and RTL

## Stop Condition

Stop after foundation passes compile, route, mock data, asset, LTR/RTL, and forbidden-dependency checks. Do not implement Stitch screens in this feature.
