# Quickstart: AI, Settings, Empty States, And Final QA

## Implementation Order

1. Confirm previous batches are implemented and compile.
2. Build chat bubble and prompt chip components.
3. Build AI advice screen.
4. Build AI history screen with clean Arabic RTL strings.
5. Build AI assistant bottom sheet.
6. Build settings row and settings screen.
7. Add empty/no-results/not-found states.
8. Wire routes.
9. Run final compile, dependency, viewport, and RTL checks.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Fallback:

```powershell
flutter build web
```

Forbidden search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api|openai|anthropic|camera|image_picker|file_picker|speech|microphone|plaid|stripe|paypal|billing|payment|Image.network|NetworkImage" lib pubspec.yaml test
```

## Stop Condition

Stop when AI, settings, states, routes, final dependency search, compile checks, and viewport/RTL checks pass or exact environment blockers are documented.
