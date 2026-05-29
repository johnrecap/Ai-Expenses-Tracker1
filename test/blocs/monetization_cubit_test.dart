import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';

void main() {
  group('MonetizationCubit', () {
    test('initial state is free user', () {
      final cubit = MonetizationCubit();
      expect(cubit.state.isPremium, false);
      expect(cubit.state.showAds, false);
    });

    test('setPremium toggles premium state', () {
      final cubit = MonetizationCubit();
      cubit.setPremium(true);
      expect(cubit.state.isPremium, true);
    });

    test('load sets initialized', () async {
      final cubit = MonetizationCubit(adService: NoOpAdService());
      await cubit.load();
      expect(cubit.state.initialized, true);
    });
  });
}
