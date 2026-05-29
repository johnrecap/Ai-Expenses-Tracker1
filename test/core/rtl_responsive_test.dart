import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/core/widgets/metric_card.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';

Widget rtlWrap(Widget child) {
  return MaterialApp(
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: SizedBox()),
    ),
  );
}

void main() {
  group('GlassCard RTL', () {
    testWidgets('renders in RTL without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 360,
                child: GlassCard(
                  child: Column(children: [
                    Text('بطاقة زجاجية', style: TextStyle(fontSize: 16)),
                    Text('محتوى عربي طويل للتجربة', style: TextStyle(fontSize: 14)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('بطاقة زجاجية'), findsOneWidget);
      expect(find.text('محتوى عربي طويل للتجربة'), findsOneWidget);
    });
  });

  group('MetricCard RTL', () {
    testWidgets('renders with Arabic text at 360 width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 360,
                child: MetricCard(
                  label: 'إجمالي المصروفات',
                  value: '٨٤٥ د.ك',
                  trendLabel: 'انخفاض ١٢٪',
                  trendUp: false,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('إجمالي المصروفات'), findsOneWidget);
      expect(find.text('٨٤٥ د.ك'), findsOneWidget);
    });
  });

  group('Responsive viewports', () {
    for (final width in [360.0, 375.0, 390.0]) {
      testWidgets('GlassCard renders at width $width', (tester) async {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: const GlassCard(
                  child: Text('Responsive content that is somewhat long to test overflow'),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(GlassCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('ProgressBar at key widths', () {
    for (final width in [360.0, 375.0, 390.0]) {
      testWidgets('ProgressBar at width $width', (tester) async {
        tester.view.physicalSize = Size(width * 3, 100 * 3);
        tester.view.devicePixelRatio = 3.0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                child: const ProgressBar(progress: 0.7),
              ),
            ),
          ),
        );
        expect(find.byType(ProgressBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
