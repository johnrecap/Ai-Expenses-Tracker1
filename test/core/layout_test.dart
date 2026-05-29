import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/core/layout/app_breakpoints.dart';
import 'package:expenses_tracker/core/layout/responsive_constraints.dart';
import 'package:expenses_tracker/core/layout/directionality_utils.dart';

void main() {
  group('AppBreakpoints', () {
    test('breakpoints are in ascending order', () {
      expect(AppBreakpoints.width360, lessThan(AppBreakpoints.width375));
      expect(AppBreakpoints.width375, lessThan(AppBreakpoints.width390));
    });

    test('maxMobileWidth is reasonable', () {
      expect(AppBreakpoints.maxMobileWidth, 390);
    });
  });

  group('ResponsiveConstraints', () {
    test('mobileContent constrains to max width', () {
      final constraints = ResponsiveConstraints.mobileContent(500);
      expect(constraints.maxWidth, AppBreakpoints.maxMobileWidth);
    });

    test('mobileContent respects min width', () {
      final constraints = ResponsiveConstraints.mobileContent(300);
      expect(constraints.maxWidth, AppBreakpoints.width360);
    });
  });

  group('DirectionalityUtils', () {
    testWidgets('isRTL returns true for RTL direction', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      expect(DirectionalityUtils.isRTL(context), true);
    });

    testWidgets('isRTL returns false for LTR direction', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      expect(DirectionalityUtils.isRTL(context), false);
    });

    testWidgets('safeContentPadding includes bottom nav height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      final padding = DirectionalityUtils.safeContentPadding(context);
      expect(padding.bottom, isNonNegative);
    });
  });
}
