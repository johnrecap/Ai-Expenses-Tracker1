# Feature Specification: Legacy Feature Port

**Feature Branch**: `022-legacy-feature-port`
**Created**: 2026-05-29
**Status**: Implemented
**Input**: Port complete features from old repo (Ai-Expenses-Tracker, 260 files) to new repo (Ai-Expenses-Tracker1, 108→134 files). Features ported using Hermes orchestration with adapted design system.

## Ported Features

### 1. Security (App Lock)
- **8 files** in `lib/security/` + `lib/features/security/`
- PIN creation & verification (SHA-256 + salt)
- Biometric unlock (fingerprint/face)
- App lock timeout settings
- Unlock screen + Create PIN screen (adapted to GlassCard/AppBackground design)
- AppLockCubit wired into root widget tree

### 2. Account Management
- **8 files** in `lib/features/account/`
- Profile screen with GlassCard design
- Edit display name, send password reset, update email
- Account deletion with confirmation dialog
- Reauthentication flow (password/Google)
- AccountProviderType capabilities (emailPassword, google)

### 3. Settings (Full)
- **1 file rewritten**: `lib/features/settings/presentation/settings_screen.dart`
- 9 sections: Security, Appearance, Notifications, Privacy, Data, Account, Subscription, Support, Danger Zone
- Wired to AppLockCubit for security toggle
- GlassCard-based design with AppBottomNav

### 4. Monetization
- **5 files** in `lib/monetization/`
- Free/Premium plan comparison screen
- MonetizationPlan, EntitlementSnapshot, MonetizationPolicy models
- AiQuotaPolicy for free vs premium AI limits
- AdFrequencyState for interstitial ads
- RewardedAdCredit for watch-to-earn AI credits

### 5. AI Services
- **3 files** in `lib/features/ai/services/`
- Voice input service (speech-to-text via `speech_to_text` package)
- Spending prediction service (monthly forecast based on history)
- MockAiService for offline AI parsing

### 6. Backup/Restore
- **1 file** in `lib/services/backup/`
- Full backup serialization (JSON with manifest)
- Ownership validation
- Schema version tracking

### 7. Wallet & Subscriptions (Mock → Real)
- WalletBloc created (3 files)
- wallets_accounts_screen rewired to WalletBloc (Firebase Firestore)
- subscriptions_center_screen rewired to RecurringExpenseBloc (Firebase Firestore)
- Wallet form dialog for create/edit

## Routes Added
- `/categories` → CategoriesScreen
- `/security/unlock` → UnlockScreen
- `/security/create-pin` → CreatePinScreen
- `/account/profile` → AccountProfileScreen
- `/subscription` → FreePremiumScreen

## Blocs Added to App Tree
- `AppLockCubit` (both authenticated + unauthenticated branches)
- `WalletBloc` (authenticated branch)
- `RecurringExpenseBloc` (authenticated branch)

## Success Criteria
- [x] All ported screens use new design system (AppColors, AppTextStyles, AppSpacing, GlassCard)
- [x] No MockData in wallets or subscriptions screens
- [x] AppLockCubit available in entire widget tree
- [x] All routes registered in GoRouter
- [x] Original UI design preserved (not old app design)
