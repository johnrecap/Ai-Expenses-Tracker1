import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/core/widgets/secondary_pill_button.dart';
import 'package:expenses_tracker/core/widgets/icon_circle_button.dart';
import 'package:expenses_tracker/core/widgets/search_field.dart';
import 'package:expenses_tracker/core/widgets/filter_chip_row.dart';
import 'package:expenses_tracker/core/widgets/section_header.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/metric_card.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';
import 'package:expenses_tracker/core/widgets/progress_ring.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(body: child),
    ),
  );
}

Widget wrapRTL(Widget child) {
  return MaterialApp(
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: SizedBox()),
    ),
  );
}

void main() {
  group('AppBackground', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppBackground(child: Text('Content')),
        ),
      );
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('GlassCard', () {
    testWidgets('renders content', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const GlassCard(child: Text('Card Content')),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('supports onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          GlassCard(
            child: const Text('Tap'),
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Tap'));
      expect(tapped, true);
    });
  });

  group('GlassBottomSheet', () {
    testWidgets('renders child with handle', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const GlassBottomSheet(child: Text('Sheet')),
        ),
      );
      expect(find.text('Sheet'), findsOneWidget);
    });
  });

  group('AppTopBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppTopBar(title: 'Dashboard')),
        ),
      );
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  group('AppBottomNav', () {
    testWidgets('renders all destinations', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          AppBottomNav(selectedIndex: 0, onDestinationSelected: (_) {}),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Wallets'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('GradientButton', () {
    testWidgets('renders label and responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          GradientButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(tapped, true);
    });
  });

  group('SecondaryPillButton', () {
    testWidgets('renders active and inactive states', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          Row(
            children: const [
              SecondaryPillButton(label: 'Active', isActive: true, onPressed: null),
              SecondaryPillButton(label: 'Inactive', onPressed: null),
            ],
          ),
        ),
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
    });
  });

  group('IconCircleButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const IconCircleButton(icon: Icons.search),
        ),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('SearchField', () {
    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const SearchField(hintText: 'Search expenses'),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('FilterChipRow', () {
    testWidgets('renders all labels', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          FilterChipRow(
            labels: const ['All', 'Food', 'Transport'],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders title and action', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const SectionHeader(
            title: 'RECENT',
            actionLabel: 'See All',
          ),
        ),
      );
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No data',
            subtitle: 'Add your first expense',
          ),
        ),
      );
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Add your first expense'), findsOneWidget);
    });
  });

  group('MetricCard', () {
    testWidgets('renders label, value, and trend', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          MetricCard(
            label: 'Total Spent',
            value: '845.500 KWD',
            trendLabel: '-12% vs last month',
            trendUp: false,
          ),
        ),
      );
      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.text('845.500 KWD'), findsOneWidget);
      expect(find.text('-12% vs last month'), findsOneWidget);
    });
  });

  group('ProgressBar', () {
    testWidgets('renders without overflow', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const SizedBox(
            width: 300,
            child: ProgressBar(progress: 0.7),
          ),
        ),
      );
      expect(find.byType(ProgressBar), findsOneWidget);
    });
  });

  group('ProgressRing', () {
    testWidgets('renders percentage', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const ProgressRing(progress: 0.65),
        ),
      );
      expect(find.text('65%'), findsOneWidget);
    });
  });

  group('AiInsightCard', () {
    testWidgets('renders title and summary', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AiInsightCard(
            title: 'Spending Alert',
            summary: 'Your food expenses increased 22%',
            severity: 'warning',
          ),
        ),
      );
      expect(find.text('Spending Alert'), findsOneWidget);
      expect(find.text('Your food expenses increased 22%'), findsOneWidget);
    });
  });
}
