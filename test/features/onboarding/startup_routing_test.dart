import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/onboarding/presentation/splash_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startup decision', () {
    const user = AppUser(userId: 'user-1', email: 'user@example.com');

    test('local-only waits until auth state is known', () {
      expect(
        decideStartupDestination(AuthInitial(), null),
        StartupDestination.waiting,
      );
    });

    test('local-only unauthenticated users go to login', () {
      expect(
        decideStartupDestination(AuthUnauthenticated(), null),
        StartupDestination.login,
      );
    });

    test('legacy unauthenticated users go to login', () {
      expect(
        decideStartupDestination(
          AuthUnauthenticated(),
          null,
          runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        ),
        StartupDestination.login,
      );
    });

    test('authenticated users wait while settings are loading', () {
      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          SettingsLoading(),
          runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        ),
        StartupDestination.waiting,
      );
    });

    test('authenticated incomplete users go to onboarding', () {
      final settings = UserSettings.defaults(userId: user.userId);

      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          SettingsSuccess(settings),
          runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        ),
        StartupDestination.onboarding,
      );
    });

    test('local-only authenticated incomplete users go to onboarding', () {
      final settings = UserSettings.defaults(userId: 'local-only-device');

      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          SettingsSuccess(settings),
        ),
        StartupDestination.onboarding,
      );
    });

    test('authenticated completed users go home', () {
      final settings = UserSettings.defaults(
        userId: user.userId,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
      );

      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          SettingsSuccess(settings),
          runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        ),
        StartupDestination.home,
      );
    });

    test('local-only authenticated completed users go home', () {
      final settings = UserSettings.defaults(
        userId: 'local-only-device',
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
      );

      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          SettingsSuccess(settings),
        ),
        StartupDestination.home,
      );
    });

    test('settings failures expose retry state', () {
      expect(
        decideStartupDestination(
          const AuthAuthenticated(user),
          const SettingsFailure('failed'),
          runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        ),
        StartupDestination.retry,
      );
    });
  });
}
