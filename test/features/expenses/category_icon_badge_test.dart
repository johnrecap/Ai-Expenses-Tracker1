import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/expenses/presentation/widgets/category_icon_badge.dart';

void main() {
  group('CategoryIconBadge', () {
    testWidgets('renders with valid category icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CategoryIconBadge(iconName: 'restaurant', colorValue: 0xFFFF7043))),
      );
      expect(find.byType(CategoryIconBadge), findsOneWidget);
    });

    testWidgets('renders with unknown icon name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CategoryIconBadge(iconName: 'unknown_icon'))),
      );
      expect(find.byType(CategoryIconBadge), findsOneWidget);
    });

    testWidgets('supports custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CategoryIconBadge(iconName: 'restaurant', colorValue: 0xFFFF7043, size: 24))),
      );
      expect(find.byType(CategoryIconBadge), findsOneWidget);
    });
  });
}
