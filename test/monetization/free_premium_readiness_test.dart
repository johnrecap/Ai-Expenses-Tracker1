import 'package:expenses_tracker/monetization/models/monetization_plan.dart';
import 'package:expenses_tracker/monetization/presentation/free_premium_screen.dart';
import 'package:expenses_tracker/monetization/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Free/Premium release readiness', () {
    testWidgets('screen keeps upgrade and restore visibly unavailable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FreePremiumScreen(),
        ),
      );

      expect(find.text('Premium is not available yet'), findsOneWidget);
      expect(find.text('Upgrade unavailable'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.textContaining('purchase successful'), findsNothing);
      expect(find.textContaining('premium active'), findsNothing);
      expect(find.text('4.99 USD/mo'), findsNothing);

      final upgradeButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Upgrade unavailable'),
      );
      final restoreButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Restore Purchases'),
      );
      expect(upgradeButton.onPressed, isNull);
      expect(restoreButton.onPressed, isNull);
    });

    test('purchase and restore cannot report verified premium yet', () async {
      final purchase = await const PurchaseService().purchasePremium();
      final restore = await const PurchaseService().restorePurchases();

      expect(purchase.status, PurchaseFlowStatus.unavailable);
      expect(restore.status, PurchaseFlowStatus.unavailable);
      expect(purchase.isVerifiedPremium, isFalse);
      expect(restore.isVerifiedPremium, isFalse);
      expect(restore.message, contains('Restore is unavailable'));
    });

    test('plan metadata does not enable premium CTA or ads in production placeholder state', () {
      expect(MonetizationPlan.free.adsEnabled, isFalse);
      expect(MonetizationPlan.free.premiumCtaEnabled, isFalse);
      expect(MonetizationPlan.premium.adsEnabled, isFalse);
      expect(MonetizationPlan.premium.premiumCtaEnabled, isFalse);
    });
  });
}
