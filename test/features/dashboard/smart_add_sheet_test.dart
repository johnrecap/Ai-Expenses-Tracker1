import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/dashboard/presentation/widgets/smart_add_sheet.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartAddSheet', () {
    testWidgets('renders English choices and returns AI text route', (tester) async {
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapSheet(
          locale: const Locale('en'),
          onRouteSelected: (route) => selectedRoute = route,
        ),
      );

      expect(find.byKey(SmartAddSheet.sheetKey), findsOneWidget);
      expect(find.text('AI text'), findsOneWidget);
      expect(find.text('Quick add'), findsOneWidget);
      expect(find.text('Receipt'), findsOneWidget);

      await tester.tap(find.byKey(SmartAddSheet.aiTextChoiceKey));
      await tester.pump();

      expect(selectedRoute, AppRoutes.expensesNewText);
      expect(tester.takeException(), isNull);
    });

    testWidgets('returns quick add route', (tester) async {
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapSheet(
          locale: const Locale('en'),
          onRouteSelected: (route) => selectedRoute = route,
        ),
      );

      await tester.tap(find.byKey(SmartAddSheet.quickAddChoiceKey));
      await tester.pump();

      expect(selectedRoute, AppRoutes.expensesNewQuick);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps receipt disabled and honest', (tester) async {
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapSheet(
          locale: const Locale('en'),
          onRouteSelected: (route) => selectedRoute = route,
        ),
      );

      expect(find.text('Unavailable for now'), findsOneWidget);

      await tester.tap(find.byKey(SmartAddSheet.receiptChoiceKey));
      await tester.pump();

      expect(selectedRoute, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dismisses from close button', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        _wrapSheet(
          locale: const Locale('en'),
          onRouteSelected: (_) {},
          onDismiss: () => dismissed = true,
        ),
      );

      await tester.tap(find.byKey(SmartAddSheet.closeKey));
      await tester.pump();

      expect(dismissed, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Arabic RTL without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapSheet(
          locale: const Locale('ar'),
          onRouteSelected: (_) {},
        ),
      );

      expect(find.text('إضافة مصروف'), findsOneWidget);
      expect(find.text('نص ذكي'), findsOneWidget);
      expect(find.text('إضافة سريعة'), findsOneWidget);
      expect(find.text('غير متاح حاليا'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byKey(SmartAddSheet.sheetKey))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _wrapSheet({
  required Locale locale,
  required ValueChanged<String> onRouteSelected,
  VoidCallback? onDismiss,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SmartAddSheet(
          onRouteSelected: onRouteSelected,
          onDismiss: onDismiss,
        ),
      ),
    ),
  );
}
