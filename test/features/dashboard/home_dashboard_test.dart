import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/dashboard/presentation/home_dashboard_screen.dart';

void main() {
  group('HomeDashboardScreen', () {
    testWidgets('renders greeting and sections', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeDashboardScreen()));

      expect(find.text('Good morning, Muhammad'), findsOneWidget);
      expect(find.text('THIS MONTH SPENDING'), findsOneWidget);
      expect(find.textContaining('12,450.00'), findsOneWidget);
      expect(find.text('Budget Left'), findsOneWidget);
      expect(find.text('Top Category'), findsOneWidget);
      expect(find.text('Weekly Review'), findsOneWidget);
      expect(find.text('Upcoming Bills'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('renders bottom navigation', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeDashboardScreen()));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Wallets'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
