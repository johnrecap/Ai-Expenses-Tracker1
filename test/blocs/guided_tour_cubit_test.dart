import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/guided_tour/cubit/guided_tour_cubit.dart';
import 'package:expense_repository/expense_repository.dart';
import 'dart:async';

void main() {
  late _MockSettingsRepo repo;

  setUp(() => repo = _MockSettingsRepo());

  group('GuidedTourCubit', () {
    test('initial state is inactive', () {
      final cubit = GuidedTourCubit(repo);
      expect(cubit.state.active, false);
    });

    test('maybeStart activates tour for new user', () async {
      final cubit = GuidedTourCubit(repo);
      await cubit.maybeStart();
      expect(cubit.state.active, true);
      expect(cubit.state.steps.length, 4);
    });

    test('next advances step', () async {
      final cubit = GuidedTourCubit(repo);
      await cubit.maybeStart();
      cubit.nextStep();
      expect(cubit.state.currentStep, 1);
    });

    test('previous goes back', () async {
      final cubit = GuidedTourCubit(repo);
      await cubit.maybeStart();
      cubit.nextStep();
      cubit.nextStep();
      cubit.previousStep();
      expect(cubit.state.currentStep, 1);
    });

    test('complete deactivates tour', () async {
      final cubit = GuidedTourCubit(repo);
      await cubit.maybeStart();
      await cubit.complete();
      expect(cubit.state.active, false);
    });

    test('skip deactivates tour', () async {
      final cubit = GuidedTourCubit(repo);
      await cubit.maybeStart();
      await cubit.skip();
      expect(cubit.state.active, false);
    });
  });
}

class _MockSettingsRepo implements SettingsRepository {
  @override
  Future<UserSettings> getSettings() async => UserSettings(
    userId: 'u1', baseCurrency: 'USD', supportedCurrencies: ['USD'],
    defaultPaymentMethod: PaymentMethod.cash,
    onboardingCompleted: true,
    updatedAt: DateTime.now(),
  );

  @override Stream<UserSettings> watchSettings() => Stream.empty();
  @override Future<void> saveSettings(UserSettings s) async {}
  @override Future<void> updateBaseCurrency(String c) async {}
  @override Future<void> updateLanguagePreference(LanguagePreference p) async {}
  @override Future<void> updateDefaultPaymentMethod(PaymentMethod m) async {}
  @override Future<UserSettings> ensureDefaultSettings() async => UserSettings(
    userId: 'u1', baseCurrency: 'USD', supportedCurrencies: ['USD'],
    defaultPaymentMethod: PaymentMethod.cash,
    updatedAt: DateTime.now(),
  );
}
