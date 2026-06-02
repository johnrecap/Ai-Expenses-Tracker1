# Contract: Localization And Directionality

## Locale Behavior

- App supports Arabic and English.
- User language choice must affect visible app text.
- User language choice must survive app restart.
- System language can be supported as a preference if existing settings allow it.

## Required App Wiring

- App localization delegate is included in the app.
- Supported locales include Arabic and English.
- App locale is not hardcoded to Arabic.
- Arabic uses RTL direction.
- English uses LTR direction.

## Text Rules

- No mixed labels like `Email / البريد الإلكتروني` in production UI.
- User-facing strings on primary screens should come from localization resources.
- Dynamic values such as money, dates, quota, and validation messages should be formatted for the current locale where practical.

## Directional UI Rules

- Back/forward/chevron icons mirror correctly.
- Row alignment uses directional padding where possible.
- Bottom navigation labels fit in Arabic and English.
- Bottom sheets and forms remain usable at narrow widths.

## Acceptance Tests

- Arabic launch shows Arabic text and RTL direction.
- English launch shows English text and LTR direction.
- Primary screens at 360x800 do not clip required buttons.
- Directional icons point correctly in both languages.

