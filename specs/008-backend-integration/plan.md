# Implementation Plan: Backend Integration & Production Architecture

**Branch**: `008-backend-integration` | **Date**: 2026-05-28 | **Spec**: `specs/008-backend-integration/spec.md`

**Input**: Feature specification from `specs/008-backend-integration/spec.md`

## Mandatory First Read And Skill Gate

Before writing this plan, the agent MUST:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Search `.agents/skills/` and `.agent/skills/` for relevant skills.
- Load matching `SKILL.md` files and follow them.
- List the skills used for this plan, or state that no relevant skill exists.

**Skills used**: speckit-specify, speckit-plan, speckit-tasks, flutter-ui-from-design, flutter-build-responsive-layout.

## Summary

Transform the UI-only Flutter prototype (`ai_expenses_tracker`) into a full production expense tracker (`expenses_tracker`) by integrating the backend architecture, state management, and AI infrastructure from the existing production app (`Expense-Tracker-main`). Preserve all 25 screens and the design system from the new UI project. The result is a production-grade app with Firebase Auth, Firestore/VPS dual-backend support, flutter_bloc + go_router architecture, AI via Cloudflare Worker, monetization, notifications, and full localization.

## Why

The existing production app (`Expense-Tracker-main`) has 91 specs, a mature backend, and 290 passing tests, but its UI was built incrementally without a unified design system. The new app (`new app`) has a polished 25-screen UI with a consistent design system, glass effects, and responsive RTL layouts, but is UI-only with no backend. This plan bridges both: the production backend and logic from the old app are ported into the new app's clean UI architecture, creating a best-of-both-worlds production release candidate.

## Expected Result

When complete, the app will have:

**Screens (25 total, all functional with real data):**
- Splash, Onboarding (language, currency, notifications)
- Auth (login, sign-up, account profile)
- Home dashboard with live data
- Expenses list with real-time filters
- Add expense (quick, AI text, receipt)
- Edit expense
- Reports main, drilldown, monthly story
- Budgets overview, category budgets, edit monthly budget
- Saving goals
- Wallets/accounts
- Subscriptions center
- AI advice, AI history, AI assistant sheet
- Settings
- Free/Premium screen
- Guided tour overlay
- Export screen
- Recurring expenses
- Categories management
- App lock (PIN/biometric)

**Backend:**
- Firebase Auth (email/password + Google)
- Firestore repositories for all entities
- VPS PostgreSQL sync with local-first Drift storage
- Runtime mode toggle (`firebaseLegacy`, `vpsLocalFirst`, `migrationComparison`)

**AI:**
- Cloudflare Worker gateway for text parse, receipt, advice
- Firebase Functions fallback
- Gemini integration with structured JSON schemas
- Quota enforcement per user per day

**Infrastructure:**
- `flutter_bloc` for all feature state
- `go_router` for declarative navigation
- `flutter_localizations` + `intl` for EN/AR
- `flutter_secure_storage` for tokens/PIN
- `local_auth` for biometrics
- `flutter_local_notifications` for alerts
- `google_mobile_ads` for monetization
- `in_app_purchase` for premium
- `image_picker` + `image` for receipts
- `speech_to_text` for voice input
- `http` for AI gateway API
- `drift` for local SQLite

**Tests:**
- Unit tests for repositories, services, blocs
- Widget tests for all screens
- Integration tests for critical flows

## Source References

- `Expense-Tracker-main/lib/` - existing production Flutter code (reference for bloc patterns, service logic, repository interfaces)
- `Expense-Tracker-main/packages/expense_repository/` - repository package
- `Expense-Tracker-main/server/` - VPS Fastify backend
- `Expense-Tracker-main/functions/` - Firebase Cloud Functions
- `Expense-Tracker-main/workers/ai-gateway/` - Cloudflare Worker
- `new app/lib/` - new UI screens and design system (preserve)
- `new app/lib/core/theme/` - design tokens (preserve)
- `new app/lib/core/widgets/` - shared widgets (preserve)
- `stitch_ai_expenses_tracker_pro/` - Stitch exports (UI reference only)

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**:
- `flutter_bloc: ^8.1.6`, `bloc: ^8.1.4`, `equatable: ^2.0.5`
- `go_router: ^10.2.0`
- `firebase_core: ^2.32.0`, `firebase_auth: ^4.16.0`, `cloud_firestore: ^4.17.5`, `firebase_messaging` (if needed)
- `flutter_localizations` (sdk), `intl: ^0.20.2`
- `drift: ^2.18.0`, `sqlite3_flutter_libs: ^2.4.0`
- `http: ^1.2.2`
- `flutter_secure_storage: ^9.2.4`
- `local_auth: ^2.3.0`
- `flutter_local_notifications: ^18.0.1`, `timezone: ^0.9.4`
- `google_mobile_ads: ^5.3.1`
- `in_app_purchase: ^3.2.0`
- `image_picker: ^1.1.2`, `image: ^4.3.0`
- `speech_to_text: ^7.3.0`
- `fl_chart: ^0.68.0`
- `csv: ^6.0.0`, `excel: ^4.0.6`, `pdf: ^3.11.1`, `path_provider: ^2.1.4`, `share_plus: ^10.0.2`
- `uuid: ^4.4.0`
- `crypto: ^3.0.3`
- `flutter_colorpicker: ^1.1.0`
- `font_awesome_flutter: ^11.0.0`

**Storage**:
- **Firebase mode**: Firestore collections under `users/{userId}/`
- **VPS mode**: Local Drift SQLite + sync queue + VPS PostgreSQL backend
- **Local secure**: `flutter_secure_storage` for auth tokens, PIN
- **Shared preferences**: Lightweight settings cache

**Testing**: `flutter test`, widget tests, bloc tests, integration tests

**Target Platform**: Android primary, iOS later

**Project Type**: Production Flutter mobile app with full backend

**Performance Goals**: <3s app launch, <500ms list filter, <3s AI response, <2s sync batch

**Constraints**:
- No AI provider keys in Flutter (route through gateway)
- No secrets in source code (use dart-define)
- Firebase Auth tokens must refresh silently
- Offline-first writes must queue and sync transparently
- RTL/LTR must work for all screens
- Responsive at 360x800, 375x812, 390x844

**Scale/Scope**: Full rebuild of 25 screens with real data, plus backend services, repositories, AI gateway, and sync protocol.

## Constitution Check

*GATE: Must pass before Phase 0. Re-check after each phase design.*

- `AGENTS.md` and `.specify/memory/constitution.md` were read. ✅ (v2.0.0)
- `.agents/skill-matcher.json` was checked. ✅
- Relevant installed skills were searched before this plan was written. ✅
- Matching skills are listed in the Mandatory First Read And Skill Gate. ✅
- Backend scope is explicitly allowed by constitution v2.0.0. ✅
- Native Flutter widgets are planned for all screens. ✅
- Shared components and design tokens are preserved from new app. ✅
- Responsive checks include 360x800, 375x812, and 390x844. ✅
- Arabic RTL and English LTR checks are planned. ✅
- Compile checks are listed for every implementation phase. ✅
- No WebView or HTML rendering is planned. ✅
- AI provider keys stay in Cloudflare Worker, not Flutter. ✅

## Project Structure

### Documentation

```text
specs/008-backend-integration/
  spec.md
  plan.md
  tasks.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    ai-gateway-contract.md
    sync-protocol-contract.md
    auth-contract.md
  checklists/
    requirements.md
```

### Source Code (repository root)

```text
lib/
  main.dart                          # Entry point: Firebase init, Bloc observer
  app.dart                           # MyApp widget
  app_view.dart                      # MaterialApp with go_router, localization
  simple_bloc_observer.dart          # Bloc observer for debugging

  app/
    router.dart                      # go_router route definitions (25 routes)
    routes.dart                      # Route path constants

  l10n/
    app_en.arb                       # English strings
    app_ar.arb                       # Arabic strings
    app_localizations.dart           # Localization delegate
    app_language_cubit.dart          # Language switching cubit

  core/
    theme/
      app_theme.dart                 # Design tokens, light/dark themes
      app_colors.dart                # Color palette
      app_spacing.dart               # Spacing constants
      app_text_styles.dart           # Typography
      app_radii.dart                 # Border radii
    layout/
      responsive_layout.dart         # Responsive helpers
      app_scaffold.dart              # Common scaffold with background
    widgets/
      app_background.dart            # Gradient background
      app_top_bar.dart               # Consistent app bar
      app_bottom_nav.dart            # Bottom navigation
      glass_card.dart                # Glassmorphism card
      metric_card.dart               # Stat metric card
      progress_ring.dart             # Circular progress
      ai_insight_card.dart           # AI insight display
      # ... (all existing shared widgets preserved)
    mock/
      mock_data.dart                 # Temporary mock data until backend wired

  packages/
    expense_repository/              # Local package (moved from Expense-Tracker-main)
      lib/
        src/
          expense_repo.dart          # Repository interface
          category_repo.dart
          budget_repo.dart
          # ... all repository interfaces
          firebase/                  # Firebase implementations
          local/                     # Local Drift implementations
          sync/                      # Sync coordinator, queue, change model
          api/                       # VPS API client
          models/                    # Domain models
          entities/                  # Firestore serialization entities
          repository_factory.dart    # AuthenticatedRepositoryFactory
          repository_runtime_mode.dart
      pubspec.yaml

  ai/
    cubit/
      ai_assistant_cubit.dart        # AI assistant state
    models/
      ai_action.dart                 # AI action model
    services/
      ai_service.dart                # Main AI service facade
      gateway_ai_service.dart        # Cloudflare Worker client
      remote_ai_service.dart         # Firebase Functions client
      mock_ai_service.dart           # Mock for testing
      ai_gateway_client.dart         # HTTP client for Worker
      ai_advice_service.dart         # Advice-specific logic
      receipt_ai_service.dart        # Receipt-specific logic
      ai_usage_fallback_service.dart # Quota/fallback handling
      ai_service_factory.dart        # Service factory by mode
      ai_provider_config.dart        # Provider configuration
      ai_response_parser.dart        # JSON parser
      ai_action_mapper.dart          # Action mapping
      ai_category_resolver.dart      # Category resolution
      spending_prediction_service.dart
      repeated_expense_detector.dart
    voice/
      voice_input_handler.dart       # Speech-to-text integration

  services/
    notifications/
      notification_service.dart      # Local notification setup
      notification_scheduler.dart    # Budget/recurring alerts
    exchange_rates/
      exchange_rate_service.dart     # Rate fetching
      exchange_rate_refresh_service.dart
    export/
      export_service.dart            # CSV/Excel/PDF export
    finance/
      financial_calculation_service.dart
      budget_recommendation_service.dart
      money_snapshot_service.dart
    backup/
      backup_service.dart            # Data backup/restore
    recurring_expense_scheduler.dart
    sync_retry_service.dart

  security/
    app_lock_service.dart            # PIN storage/validation
    biometric_service.dart           # Fingerprint/face
    pin_service.dart                 # PIN hashing

  monetization/
    cubit/
      monetization_cubit.dart        # Premium state
    models/
      premium_entitlement.dart
    services/
      ad_service.dart                # Ad display logic
      google_mobile_ads_service.dart # AdMob wrapper
      purchase_service.dart          # In-app purchase
      feature_gate_service.dart      # Feature availability

  feature_flags/
    feature_flag_service.dart        # Remote/local feature flags

  observability/
    observability_service.dart       # Privacy-safe logging

  screens/
    onboarding/
      views/
        splash_screen.dart           # Splash
        first_run_onboarding_gate.dart
        first_run_setup_screen.dart  # Language, currency, notifications
      blocs/
        onboarding_cubit.dart
    auth/
      views/
        auth_gate.dart               # Auth state router
        login_screen.dart            # Email/password login
        register_screen.dart         # Email/password register
      blocs/
        auth_bloc/
          auth_bloc.dart
          auth_event.dart
          auth_state.dart
    home/
      views/
        home_screen.dart             # Bottom nav shell
        main_screen.dart             # Dashboard content
      blocs/
        get_expenses_bloc/
      services/
        home_summary_calculator.dart
    expenses/
      views/
        expenses_screen.dart         # List with filters
        expense_filters_sheet.dart   # Filter bottom sheet
      blocs/
        expense_filter_cubit.dart
    add_expense/
      views/
        add_expense_screen.dart      # Quick add
        category_creation.dart       # Create category inline
        ai_text_add_screen.dart      # AI natural language
        receipt_add_screen.dart      # AI receipt scan
      blocs/
        create_expense_bloc/
        create_category_bloc/
        get_categories_bloc/
    budgets/
      views/
        budget_screen.dart           # Budget overview
        category_budgets_screen.dart # Per-category budgets
      blocs/
        budget_bloc/
        category_budget_cubit/
    reports/
      views/
        reports_screen.dart          # Charts and stats
        drilldown_screen.dart        # Category drilldown
        monthly_story_screen.dart    # Narrative
      cubits/
        report_cubit.dart
      services/
        monthly_financial_story_service.dart
    categories/
      views/
        categories_screen.dart       # Manage categories
      blocs/
        categories_bloc/
    goals/
      views/
        saving_goals_screen.dart     # Goals list
      blocs/
        saving_goal_bloc/
    wallets/
      views/
        wallets_screen.dart          # Wallets list
      # blocs as needed
    subscriptions/
      views/
        subscription_center_screen.dart
      services/
        subscription_summary_service.dart
    recurring_expenses/
      views/
        recurring_expenses_screen.dart
      blocs/
        recurring_expense_bloc/
    ai_assistant/
      views/
        ai_assistant_sheet.dart      # Bottom sheet
    ai/
      views/
        ai_advice_screen.dart        # Advice screen
        ai_history_screen.dart       # History screen
    settings/
      views/
        settings_screen.dart         # Settings list
      blocs/
        settings_cubit.dart
    account/
      views/
        account_profile_screen.dart  # Profile/edit/delete
      cubits/
        account_profile_cubit.dart
    app_lock/
      views/
        create_pin_screen.dart
        unlock_screen.dart
      cubits/
        app_lock_cubit.dart
    monetization/
      views/
        free_premium_screen.dart
    export/
      views/
        export_screen.dart
      cubits/
        export_cubit.dart
    stats/
      views/
        stat_screen.dart

  widgets/                           # Cross-screen widgets
    sync_status_banner.dart
    # ... other shared widgets

  guided_tour/
    cubit/
      guided_tour_cubit.dart
    models/
      tour_step.dart
    widgets/
      tour_overlay.dart
      tour_spotlight.dart
      tour_connector.dart

  engagement/
    models/
    services/
    widgets/
      weekly_digest_screen.dart

test/
  # Unit tests for repositories, services
  # Widget tests for screens
  # Bloc tests

android/                           # Android config
ios/                               # iOS config
assets/
  images/                          # App images
  fonts/                           # Noto Sans Arabic, etc.

pubspec.yaml
analysis_options.yaml
```

## Reuse Strategy

**Preserve from new app UI:**
- `lib/core/theme/` - All design tokens, colors, spacing, typography
- `lib/core/widgets/` - All shared widgets (glass_card, app_top_bar, app_bottom_nav, etc.)
- `lib/core/layout/` - Responsive helpers
- All 25 screen file structures and visual layouts

**Port from Expense-Tracker-main:**
- Bloc/Cubit patterns and state classes
- Repository interfaces and implementations
- Service logic (AI, notifications, export, finance, exchange rates)
- Firebase Auth integration patterns
- Sync coordinator and queue logic
- Security services (app lock, biometric)
- Monetization services
- Localization ARB files and patterns

**Create new:**
- go_router route definitions (replace imperative nav)
- Bloc-to-UI wiring for each screen
- go_router deep link support for auth callbacks

## Mock Data Strategy

During development phases before backend is fully wired:
- Use static mock data in `lib/core/mock/mock_data.dart` for UI testing
- Mock repositories implement the same interfaces as Firebase/Local repos
- Switch repository implementations via `RepositoryRuntimeMode` enum
- Remove or deprecate mock repositories once Firebase/Local repos are functional

## Possible Bugs And Fix Strategy

| Bug | Fix Strategy |
|-----|-------------|
| Import path errors after package rename (`ai_expenses_tracker` -> `expenses_tracker`) | Global find/replace all import statements; run `flutter analyze` to catch misses |
| go_router route conflicts with existing `MaterialPageRoute` patterns | Audit all `Navigator.push` calls and convert to `context.go()` or `context.push()` |
| Bloc provider scope issues (screen can't find bloc) | Ensure `BlocProvider` is above `GoRoute` in widget tree or use `BlocProvider.value` |
| Firebase initialization fails (missing config) | Verify `google-services.json` and `GoogleService-Info.plist` are present and correct |
| RTL layout breaks after adding real text | Test every screen in Arabic; check `Directionality` and `TextDirection` |
| Drift database migration errors | Version schema correctly; test on clean install and upgrade paths |
| AI gateway 403/401 due to Firebase token expiry | Implement token refresh before API calls; cache tokens with expiry check |
| AdMob test ads in production | Use `kDebugMode` to conditionally show test ads; verify ad unit IDs |
| Bottom nav state lost during navigation | Use `StatefulShellRoute` in go_router or maintain nav state in a cubit |
| Offline sync queue grows unbounded | Implement max queue size; compress batches; evict old pending changes |

## Verification Plan

### Compile checks (every phase)
```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
```

### Build checks
```powershell
flutter build apk --debug
# or if Android tooling unavailable:
flutter build web
```

### Visual checks
```text
360x800 LTR
360x800 RTL
375x812 LTR
375x812 RTL
390x844 LTR
390x844 RTL
```

### Backend checks
```powershell
# Server typecheck and tests
cd server
npm run typecheck
npm test

# Functions tests
cd functions
npm test

# Worker typecheck
cd workers/ai-gateway
npm run typecheck
```

## Phase 0: Foundation & Project Restructure

**Goal**: Rename package, add dependencies, set up architecture, verify compilation.

**Why**: The project must transition from `ai_expenses_tracker` to `expenses_tracker` and gain all production dependencies before any feature work can begin.

**Scope**:
1. Rename package in `pubspec.yaml` from `ai_expenses_tracker` to `expenses_tracker`
2. Update all import statements across `lib/` and `test/`
3. Add all production dependencies to `pubspec.yaml`
4. Create `packages/expense_repository/` package structure
5. Set up `main.dart` with Firebase initialization and Bloc observer
6. Set up `app_view.dart` with `MaterialApp`, `go_router`, localization
7. Configure Android (`google-services.json`) and iOS (`GoogleService-Info.plist`) Firebase configs
8. Add `.env` or dart-define configuration for AI gateway URL, VPS URL
9. Run `flutter pub get` and verify zero analysis errors

**Stop condition**: `flutter analyze` passes with zero errors; app compiles and launches to splash screen.

## Phase 1: Auth & Core Infrastructure

**Goal**: Working authentication flow with Firebase Auth, onboarding, app lock, and account management.

**Why**: Auth is the foundation for all user-scoped data. Without it, expenses, budgets, and AI cannot be persisted or personalized.

**Scope**:
1. Implement `AuthBloc` with Firebase Auth integration (login, register, logout, auth state changes)
2. Implement Google Sign-In via Firebase
3. Create `AuthGate` that routes based on auth state (splash -> onboarding -> login -> home)
4. Wire onboarding screens (language, currency, notifications) with real persistence to Settings repository
5. Implement `AppLockCubit` with PIN creation, validation, and biometric fallback
6. Implement `AccountProfileCubit` with display name editing and account deletion with reauth
7. Add `flutter_secure_storage` for PIN and token caching
8. Create `SettingsCubit` for language, currency, theme, notifications preferences
9. Wire `AppLanguageCubit` to trigger app-wide rebuild on language change
10. Add auth-scoped repositories via `AuthenticatedRepositoryFactory`

**Stop condition**: User can complete onboarding, register, login, logout, set PIN, and view/edit profile. `flutter test` passes for auth bloc and settings cubit.

## Phase 2: Expenses & Categories

**Goal**: Full expense CRUD with categories, real persistence, and filtering.

**Why**: Expenses are the core data model. All other features (budgets, reports, AI) depend on expenses existing.

**Scope**:
1. Implement `ExpenseRepository` interface with Firebase and Local implementations
2. Implement `CategoryRepository` with CRUD operations
3. Create `GetExpensesBloc` for expense list with pagination/filtering
4. Create `CreateExpenseBloc` for add expense (quick, AI, receipt)
5. Wire Add Expense screens to blocs with real form validation
6. Implement `ExpenseFilterCubit` for date range, category, payment method, search
7. Add expense edit and delete with confirmation dialogs
8. Implement category creation inline in Add Expense
9. Wire Expenses List screen with real data and filter bottom sheet
10. Add duplicate expense detection in `CreateExpenseBloc`
11. Create `MoneyConversionService` for display currency conversion

**Stop condition**: User can add, edit, delete, filter expenses. Categories can be created and assigned. Data persists to Firestore. `flutter test` passes for expense bloc and repository.

## Phase 3: Budgets & Goals

**Goal**: Monthly budgets, category budgets, and saving goals with real-time progress.

**Why**: Budgets provide financial control and are a key retention feature.

**Scope**:
1. Implement `BudgetRepository` for monthly budgets
2. Implement `CategoryBudgetRepository` for per-category budgets
3. Create `BudgetBloc` for budget CRUD and progress calculation
4. Create `CategoryBudgetCubit` for category budget management
5. Wire Budgets Overview screen with progress indicators
6. Wire Category Budgets List screen
7. Wire Edit Monthly Budget screen
8. Implement `SavingGoalRepository`
9. Create `SavingGoalBloc` for goal CRUD and progress
10. Wire Saving Goals screen
11. Integrate budget alerts into `NotificationScheduler`

**Stop condition**: User can set budgets, see progress update as expenses are added, and manage saving goals. `flutter test` passes.

## Phase 4: Reports & Analytics

**Goal**: Spending reports, drilldowns, and monthly financial stories.

**Why**: Reports give users insight into their spending patterns.

**Scope**:
1. Create `ReportCubit` for report data aggregation
2. Implement `ReportCalculator` for category totals, trends, comparisons
3. Wire Reports Main screen with charts (`fl_chart`)
4. Wire Report Drilldown screen with expense list per category
5. Implement `MonthlyFinancialStoryService` for narrative generation
6. Wire Monthly Financial Story screen
7. Add multi-currency conversion in reports using cached exchange rates
8. Support date range selection in reports

**Stop condition**: Reports display accurate data. Drilldown works. Monthly story generates. `flutter test` passes.

## Phase 5: AI Integration

**Goal**: AI text parsing, receipt extraction, advice, and history assistant.

**Why**: AI is the primary product differentiator and reduces expense entry friction.

**Scope**:
1. Implement `AiGatewayClient` for Cloudflare Worker HTTP calls
2. Implement `FirebaseFunctionsAiClient` for Functions fallback
3. Create `AiService` facade with provider selection and fallback
4. Implement `GatewayAiService` for text parsing, receipt extraction, advice
5. Implement `AiAdviceService` and `FinancialAdviceAiService`
6. Implement `ReceiptAiService` with image preprocessing
7. Create `AiAssistantCubit` for assistant sheet state
8. Implement `AiActionLogRepository` for AI usage logging
9. Add quota enforcement using `AiUsageFallbackService`
10. Wire AI Text Add screen with real parsing and preview
11. Wire Receipt Add screen with real extraction
12. Wire AI Advice screen
13. Wire AI History screen with queryable logs
14. Wire AI Assistant Sheet with voice input (`speech_to_text`)
15. Integrate AI quota display into Settings

**Stop condition**: All AI features work end-to-end. Quotas enforce correctly. Fallbacks handle errors gracefully. `flutter test` passes for AI service and cubit.

## Phase 6: Wallets, Subscriptions & Recurring

**Goal**: Wallets, transfers, subscription tracking, and recurring expenses.

**Why**: Advanced financial management features increase engagement and app value.

**Scope**:
1. Implement `WalletAccountRepository`
2. Wire Wallets/Accounts screen with balance calculation
3. Implement `TransferRepository` for wallet-to-wallet transfers
4. Implement `SubscriptionSummaryService` for subscription analytics
5. Wire Subscription Center screen with renewal tracking
6. Implement `RecurringExpenseRepository`
7. Create `RecurringExpenseBloc` for recurring rule CRUD
8. Implement `RecurringExpenseScheduler` for generating instances
9. Wire Recurring Expenses screen
10. Add subscription renewal to `NotificationScheduler`

**Stop condition**: Wallets show balances. Subscriptions track renewals. Recurring expenses generate on schedule. `flutter test` passes.

## Phase 7: Settings, Onboarding & Guided Tour

**Goal**: Complete settings with live data, onboarding flow, and guided tour.

**Why**: Settings control UX. Onboarding and tour improve activation and retention.

**Scope**:
1. Wire Settings screen with all sections (profile, currency, language, notifications, security, AI, monetization, support)
2. Implement settings live refresh (changes apply immediately without restart)
3. Implement `GuidedTourCubit` with step management
4. Create `TourOverlay`, `TourSpotlight`, `TourConnector` widgets
5. Integrate guided tour into Home dashboard for first-time users
6. Add "Replay Tour" option in Settings
7. Implement onboarding completion persistence
8. Add export data option in Settings (CSV, Excel, PDF)
9. Implement data backup/restore UI (backup preview, restore confirmation)

**Stop condition**: Settings work with live data. Tour highlights all key elements. RTL works. `flutter test` passes.

## Phase 8: Monetization

**Goal**: Ads for free users, premium upgrade with in-app purchase.

**Why**: Monetization is required for sustainability.

**Scope**:
1. Integrate `google_mobile_ads` with test ad units
2. Implement `AdService` and `GoogleMobileAdsService`
3. Add banner ads to appropriate screens (expenses list, reports)
4. Implement `PurchaseService` with `in_app_purchase`
5. Create `MonetizationCubit` for premium state
6. Wire Free/Premium screen with purchase flow
7. Implement `FeatureGateService` for premium-gated features
8. Add premium entitlement backend validation
9. Integrate AI quota increases for premium users
10. Implement ad consent via `AdConsentService`

**Stop condition**: Free users see ads. Purchase flow completes. Premium unlocks features. `flutter test` passes.

## Phase 9: Notifications & Exchange Rates

**Goal**: Smart notifications and daily exchange rate fetching.

**Why**: Notifications drive engagement. Exchange rates enable multi-currency accuracy.

**Scope**:
1. Implement `NotificationService` with `flutter_local_notifications`
2. Implement `NotificationScheduler` for budget alerts, recurring reminders, subscription renewals
3. Add notification permission request during onboarding
4. Implement `ExchangeRateService` for fetching live rates
5. Implement `ExchangeRateRefreshService` for daily background refresh
6. Add exchange rate display in Settings
7. Integrate exchange rates into Reports and Budgets for multi-currency
8. Implement `MoneyConversionService` using cached rates
9. Add stale rate warnings in UI

**Stop condition**: Notifications trigger correctly. Exchange rates cache and refresh. Multi-currency conversion works. `flutter test` passes.

## Phase 10: VPS Sync & Migration

**Goal**: Local-first sync with VPS PostgreSQL backend and migration comparison.

**Why**: VPS provides data independence, lower costs at scale, and full ownership.

**Scope**:
1. Set up Drift database schema in `packages/expense_repository/`
2. Implement `LocalRepositoryStore` for in-memory caching
3. Implement `LocalSyncQueue` for pending changes
4. Create `VpsApiClient` with Firebase token authentication
5. Implement `SyncCoordinator` for push/pull cycles
6. Wire `AuthenticatedRepositoryFactory` for `vpsLocalFirst` mode
7. Implement `migrationComparison` mode with dual repository comparison
8. Add sync status banner UI widget
9. Implement sync retry logic with exponential backoff
10. Test sync with server endpoints (`/v1/bootstrap`, `/v1/sync/push`, `/v1/sync/pull`)
11. Document migration rollback procedures

**Stop condition**: VPS mode syncs data bidirectionally. Migration comparison shows parity. Offline queue syncs on reconnect. Server tests pass.

## Phase 11: Polish, Testing & Release

**Goal**: Full test suite, RTL QA, performance optimization, and release build.

**Why**: Production release requires comprehensive verification.

**Scope**:
1. Write widget tests for all 25 screens
2. Write bloc tests for all blocs/cubits
3. Write repository unit tests for Firebase and Local implementations
4. Write integration tests for critical flows (onboarding -> add expense -> view report)
5. Run Arabic RTL QA on all screens at all viewports
6. Optimize list scrolling performance (pagination, lazy loading)
7. Optimize image loading and caching for receipts
8. Add Firebase Crashlytics and Analytics
9. Configure release signing keystore
10. Build signed release APK
11. Run production device QA checklist
12. Update all documentation (AGENTS.md, README, runbooks)

**Stop condition**: All tests pass. RTL QA complete. Release APK builds successfully. Device QA checklist complete.

## Rollback

- If any phase introduces breaking changes, keep the previous phase's git branch as fallback.
- Firebase Auth and Firestore remain the default (`firebaseLegacy`) until VPS pilot is approved.
- If VPS sync fails, users can switch back to `firebaseLegacy` via runtime configuration.
- Keep mock repositories as a last-resort fallback for development/testing.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Dual backend (Firebase + VPS) | Strategic requirement for data independence | Single backend would lock us into Firebase forever |
| AI gateway + Functions fallback | Free tier quotas and reliability | Single provider would risk downtime and cost |
| go_router + flutter_bloc | User explicitly requested this architecture | Old imperative nav + bloc would not match new app structure |
| 25 screens in one plan | User wants full integration in new app | Splitting into multiple specs would fragment the migration |
