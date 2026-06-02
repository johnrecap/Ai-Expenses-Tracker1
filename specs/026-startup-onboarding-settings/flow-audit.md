# Flow Audit: Startup Onboarding Settings

Date: 2026-05-31

## Startup Routing

Status: broken.

- `App` creates `AuthBloc` and `GoRouter` before authenticated repositories are available.
- `AppRouter` only redirects protected routes based on auth. It does not know settings/onboarding state.
- `SplashScreen` waits for a minimum timer, then checks `AuthBloc`.
- If authenticated, `SplashScreen` tries to read `SettingsCubit`. If settings are loaded and `onboardingCompleted == false`, it routes to onboarding.
- If `SettingsCubit` is missing, loading, initial, failed, or settings are not loaded yet, splash falls through to home.

Fix direction: create/load `SettingsCubit` for authenticated users, make splash wait for `SettingsSuccess`, and route by `settings.requiresOnboarding`.

## Onboarding Provider Availability

Status: partial.

- Authenticated `App` tree provides `OnboardingCubit`.
- Unauthenticated/no-bundle `App` tree does not provide `OnboardingCubit`.
- `AppRouter._publicRoutes` allows onboarding language/currency/notifications while unauthenticated.
- Onboarding screens call `context.read<OnboardingCubit>()`, so direct public access can crash.

Fix direction: remove onboarding routes from public access for unauthenticated users or redirect them safely to login.

## Language Save And Locale

Status: broken.

- `OnboardingLanguageScreen` stores the selected code in `OnboardingCubit`.
- `OnboardingCubit.completeOnboarding()` maps `ar` to Arabic and all other values to English.
- `AppLanguageCubit` exists but is not connected to saved settings.
- Both authenticated and unauthenticated `MaterialApp.router` instances hardcode `locale: Locale('ar')`.
- Generated app localization delegate exists in `lib/l10n/app_localizations.dart`, but `App` only registers global Flutter delegates.

Fix direction: update app locale from saved settings and use `AppLocalizations.localizationsDelegates` / `supportedLocales`.

## Currency Save

Status: partial.

- `BaseCurrencyScreen` stores the selected code in `OnboardingCubit`.
- `UserSettings` normalizes base currency and supported currencies in the constructor.
- `OnboardingCubit.completeOnboarding()` writes `baseCurrency`, but final save relies on current settings and does not expose errors beyond a boolean.
- Repository default creation can overwrite existing settings before onboarding fields are applied.

Fix direction: preserve existing settings in `ensureDefaultSettings()`, normalize selected currency, and surface save errors.

## Notification Save

Status: broken.

- `NotificationsScreen` has daily and weekly toggles plus a time picker.
- It passes only `notificationsEnabled` to `OnboardingCubit`.
- `OnboardingCubit.completeOnboarding()` writes back existing notification settings unchanged.
- UI navigates home immediately, before the settings save completes.

Fix direction: pass actual daily/weekly/time choices into the cubit, await save completion through state, and navigate only on success.

## Settings Repository Path

Status: partial.

- Firebase settings path is `users/{userId}/settings/profile`.
- `getSettings()` creates defaults when missing.
- `ensureDefaultSettings()` writes defaults unconditionally in Firebase and local implementations.
- Firestore settings rules require strict settings shape.

Fix direction: make default ensure idempotent and align notification settings serialization with rules.

## Notification Model, Entity, And Rules

Status: broken.

- `NotificationSettings` model has `budgetAlerts`, `recurringReminders`, `subscriptionRenewals`, `weeklyDigest`, and `aiQuotaWarnings`.
- `UserSettingsEntity.toDocument()` serializes only `budgetAlerts` and `recurringReminders`.
- `UserSettingsEntity.fromDocument()` parses only `budgetAlerts` and `recurringReminders`.
- `firestore.rules` accepts only `budgetAlerts` and `recurringReminders`.
- Data model requires optional `dailyReminder` and `dailyReminderTime`.

Fix direction: add daily reminder fields to the model, serialize/parse all supported fields, and update rules strictly.

## Device Notification Service

Status: partial.

- `NotificationService.initialize()` exists but is not called from startup.
- `showNotification()` and `scheduleNotification()` silently return when uninitialized.
- Scheduling uses `tz.local` but timezone data is not initialized.
- Android 13+ notification permission is not declared in `AndroidManifest.xml`.

Fix direction: initialize safely in `main`, request/check permission before scheduling, and initialize timezone data.
