import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalBudgetRepository', () {
    test('returns the requested month and year only', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalBudgetRepository(store: store);

      await repository.saveBudget(_budget(month: 6, year: 2026, amount: 6000));
      await repository.saveBudget(_budget(month: 5, year: 2026, amount: 5000));

      final may = await repository.getCurrentMonthBudget(month: 5, year: 2026);
      final june = await repository.getCurrentMonthBudget(month: 6, year: 2026);
      final missing = await repository.getCurrentMonthBudget(month: 7, year: 2026);

      expect(may?.amount, 5000);
      expect(june?.amount, 6000);
      expect(missing, isNull);
    });

    test('watchCurrentMonthBudget ignores other months', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalBudgetRepository(store: store);
      final emissions = <Budget?>[];
      final subscription = repository
          .watchCurrentMonthBudget(month: 5, year: 2026)
          .listen(emissions.add);

      try {
        await Future<void>.delayed(Duration.zero);
        await repository.saveBudget(_budget(month: 6, year: 2026, amount: 6000));
        await Future<void>.delayed(Duration.zero);

        expect(emissions.whereType<Budget>(), isEmpty);

        await repository.saveBudget(_budget(month: 5, year: 2026, amount: 5000));
        await Future<void>.delayed(Duration.zero);

        expect(emissions.whereType<Budget>().single.amount, 5000);
      } finally {
        await subscription.cancel();
      }
    });
  });
}

Budget _budget({
  required int month,
  required int year,
  required double amount,
}) {
  final now = DateTime.utc(2026, month, 1);
  return Budget(
    budgetId: Budget.budgetIdFor(month: month, year: year),
    userId: 'user-1',
    month: month,
    year: year,
    amount: amount,
    currency: 'EGP',
    warningThresholdPercent: 80,
    createdAt: now,
    updatedAt: now,
  );
}
