import 'package:expenses_tracker/app/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

@Deprecated('Use AddExpenseAiTextScreen through AppRoutes.expensesNewText.')
class AiExpenseScreen extends StatelessWidget {
  const AiExpenseScreen({super.key});

  static const routeName = AppRoutes.expensesNewAi;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(AppRoutes.expensesNewText);
      }
    });
    return const SizedBox.shrink();
  }
}
