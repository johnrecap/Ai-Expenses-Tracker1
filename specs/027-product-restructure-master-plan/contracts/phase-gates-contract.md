# Contract: Phase Gates

Each implementation phase must pass these gates before the next phase starts.

## Gate 1: Scope

- The phase owns a clear set of screens/services.
- The phase does not refactor unrelated files.
- Existing user changes are preserved.

## Gate 2: Truthfulness

- No visible mock data is introduced.
- Disabled features are clearly marked unavailable.
- Save/navigation success is shown only after real completion.

## Gate 3: Localization And Layout

- Arabic and English strings are considered.
- RTL/LTR direction is considered.
- 360x800 overflow risk is checked for touched screens.

## Gate 4: Security And Privacy

- No API keys or secrets in Flutter/mobile code.
- AI uses gateway only.
- Analytics/export/account/security flows avoid sensitive leaks.

## Gate 5: Verification

Run scoped checks for the phase. Prefer:

```powershell
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze <touched lib paths> <touched package paths> <focused tests>
& 'C:\flutter\bin\flutter.bat' test <focused tests>
```

Backend/worker/server phases must use their focused package checks when available.

Do not require full-project `flutter analyze` unless the phase is explicitly a full cleanup phase.
