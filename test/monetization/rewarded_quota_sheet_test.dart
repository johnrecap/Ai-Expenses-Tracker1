import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/widgets/rewarded_quota_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RewardedQuotaSheet', () {
    testWidgets('shows manual reward amount before the ad starts', (tester) async {
      var tapped = false;

      await _pumpSheet(
        tester,
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
        onWatchAd: () => tapped = true,
      );

      expect(find.text('Watch one ad to get 5 extra entries today.'), findsOneWidget);
      await tester.tap(find.byKey(RewardedQuotaSheet.watchAdButtonKey));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows AI reward amount before the ad starts', (tester) async {
      await _pumpSheet(
        tester,
        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
      );

      expect(find.text('Watch one ad to get 2 extra AI entries today.'), findsOneWidget);
    });

    testWidgets('shows Arabic RTL copy without overflowing at 360px', (tester) async {
      await _setPhoneSize(tester);
      await _pumpSheet(
        tester,
        textDirection: TextDirection.rtl,
        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
      );

      expect(find.text('وصلت إلى الحد اليومي'), findsOneWidget);
      expect(
        find.text('شاهد إعلانا واحدا لتحصل على 5 إدخالات يدوية إضافية اليوم.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders unavailable and loading states', (tester) async {
      await _pumpSheet(
        tester,
        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
        adsAvailable: false,
      );

      expect(find.byKey(RewardedQuotaSheet.unavailableKey), findsOneWidget);
      expect(find.byKey(RewardedQuotaSheet.watchAdButtonKey), findsNothing);

      await _pumpSheet(
        tester,
        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
        loading: true,
      );

      expect(find.byKey(RewardedQuotaSheet.loadingKey), findsOneWidget);
      expect(find.byKey(RewardedQuotaSheet.watchAdButtonKey), findsNothing);
    });
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required EntryQuotaRewardPlacement placement,
  TextDirection textDirection = TextDirection.ltr,
  bool adsAvailable = true,
  bool loading = false,
  VoidCallback? onWatchAd,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: RewardedQuotaSheet(
            placement: placement,
            adsAvailable: adsAvailable,
            loading: loading,
            onWatchAd: onWatchAd,
          ),
        ),
      ),
    ),
  );
}
