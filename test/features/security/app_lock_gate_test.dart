import 'dart:math';

import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/features/security/presentation/app_lock_gate.dart';
import 'package:expenses_tracker/features/security/presentation/unlock_screen.dart';
import 'package:expenses_tracker/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppLockGate covers the app when lock is required', (tester) async {
    final service = await _buildLockedService();
    final cubit = AppLockCubit(appLockService: service);
    await cubit.initialize();

    await tester.pumpWidget(_wrap(cubit, const Text('Private area')));

    expect(cubit.state.status, AppLockStatus.locked);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.text('Private area'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('AppLockGate removes the cover after a valid PIN unlock', (tester) async {
    final service = await _buildLockedService();
    final cubit = AppLockCubit(appLockService: service);
    await cubit.initialize();

    await tester.pumpWidget(_wrap(cubit, const Text('Private area')));
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(cubit.state.status, AppLockStatus.unlocked);
    expect(find.byType(UnlockScreen), findsNothing);
    expect(find.text('Private area'), findsOneWidget);

    await cubit.close();
  });

  test('checkOnResume locks again when app lock timeout has passed', () async {
    final service = await _buildLockedService();
    final cubit = AppLockCubit(appLockService: service);

    await cubit.initialize();
    expect(cubit.state.status, AppLockStatus.locked);

    final unlocked = await cubit.unlockWithPin('1234');
    expect(unlocked, true);
    expect(cubit.state.status, AppLockStatus.unlocked);

    await cubit.checkOnResume();
    expect(cubit.state.status, AppLockStatus.locked);

    await cubit.close();
  });

  test('changePin requires the current PIN before saving a new PIN', () async {
    final service = await _buildLockedService();
    final cubit = AppLockCubit(appLockService: service);

    final rejected = await cubit.changePin(newPin: '5678', currentPin: '0000');
    expect(rejected, false);
    expect(await service.pinService.verifyPin('1234'), true);
    expect(await service.pinService.verifyPin('5678'), false);

    final accepted = await cubit.changePin(newPin: '5678', currentPin: '1234');
    expect(accepted, true);
    expect(await service.pinService.verifyPin('1234'), false);
    expect(await service.pinService.verifyPin('5678'), true);

    await cubit.close();
  });

  test('enabling biometrics requires successful biometric verification', () async {
    final rejectedBiometrics = _FakeBiometricAuthenticator(
      supported: true,
      authenticateResult: false,
    );
    final rejectedService = await _buildLockedService(biometric: rejectedBiometrics);
    final rejectedCubit = AppLockCubit(appLockService: rejectedService);

    await rejectedCubit.initialize();
    await rejectedCubit.setBiometricEnabled(true);
    expect(rejectedBiometrics.authenticateCalls, 1);
    expect(rejectedCubit.state.biometricEnabled, false);

    final acceptedBiometrics = _FakeBiometricAuthenticator(
      supported: true,
      authenticateResult: true,
    );
    final acceptedService = await _buildLockedService(biometric: acceptedBiometrics);
    final acceptedCubit = AppLockCubit(appLockService: acceptedService);

    await acceptedCubit.initialize();
    await acceptedCubit.setBiometricEnabled(true);
    expect(acceptedBiometrics.authenticateCalls, 1);
    expect(acceptedCubit.state.biometricEnabled, true);

    await rejectedCubit.close();
    await acceptedCubit.close();
  });
}

Widget _wrap(AppLockCubit cubit, Widget child) {
  return MaterialApp(
    home: BlocProvider.value(
      value: cubit,
      child: AppLockGate(child: child),
    ),
  );
}

Future<AppLockService> _buildLockedService({
  BiometricAuthenticator? biometric,
}) async {
  final storage = _MemoryAppLockStorage();
  final pinService = PinService(storage: storage, random: Random(1));
  final service = AppLockService(
    storage: storage,
    pinService: pinService,
    biometricService: biometric ?? _FakeBiometricAuthenticator(),
  );
  await service.setupPin('1234');
  return service;
}

class _MemoryAppLockStorage implements AppLockStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator({
    this.supported = false,
    this.authenticateResult = false,
  });

  final bool supported;
  final bool authenticateResult;
  int authenticateCalls = 0;

  @override
  Future<bool> authenticate() async {
    authenticateCalls += 1;
    return authenticateResult;
  }

  @override
  Future<bool> isSupported() async => supported;
}
