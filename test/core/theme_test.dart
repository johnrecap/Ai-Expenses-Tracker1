import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_shadows.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('all color tokens are defined', () {
      expect(AppColors.surface, isNotNull);
      expect(AppColors.primary, isNotNull);
      expect(AppColors.secondary, isNotNull);
      expect(AppColors.tertiary, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.onSurface, isNotNull);
    });

    test('lightColorScheme has correct brightness', () {
      expect(AppColors.lightColorScheme.brightness, Brightness.light);
    });
  });

  group('AppGradients', () {
    test('gradients have correct number of colors', () {
      expect(AppGradients.primaryAction.colors.length, 2);
      expect(AppGradients.secondaryAi.colors.length, 2);
    });
  });

  group('AppRadii', () {
    test('pill radius is very large', () {
      expect(AppRadii.pill.topLeft.x, greaterThan(100));
    });
  });

  group('AppSpacing', () {
    test('spacing tokens are positive', () {
      expect(AppSpacing.xs, greaterThan(0));
      expect(AppSpacing.xl, greaterThan(AppSpacing.md));
    });
  });

  group('AppShadows', () {
    test('glass card shadow is defined', () {
      expect(AppShadows.glassCard, isNotNull);
    });
  });

  group('AppTextStyles', () {
    test('text styles have defined size and weight', () {
      expect(AppTextStyles.displayLarge.fontSize, 40);
      expect(AppTextStyles.displayLarge.fontWeight, FontWeight.w700);
      expect(AppTextStyles.bodyLarge.fontSize, 16);
      expect(AppTextStyles.arabicBody.height, isNotNull);
      expect(AppTextStyles.arabicBody.height!, greaterThan(AppTextStyles.bodyLarge.height!));
    });
  });

  group('AppTheme', () {
    testWidgets('light theme renders text in LTR', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: Center(child: Text('Hello'))),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('light theme renders text in RTL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: Center(child: Text('مرحباً'))),
          ),
        ),
      );
      expect(find.text('مرحباً'), findsOneWidget);
    });

    testWidgets('theme uses correct color scheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      final context = tester.element(find.byType(SizedBox));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
    });
  });
}
