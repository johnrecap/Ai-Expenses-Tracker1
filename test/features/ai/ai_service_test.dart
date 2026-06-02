import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiService payment method detection', () {
    test('detects common English and Arabic payment wording', () async {
      const service = AiService();
      final context = AiContext(
        now: DateTime.utc(2026, 5, 31),
        defaultCurrency: 'EGP',
      );

      final cases = <String, PaymentMethod>{
        'spent 50 cash on lunch': PaymentMethod.cash,
        'دفعت 50 كاش على الغدا': PaymentMethod.cash,
        'paid 120 by visa card': PaymentMethod.visa,
        'دفعت 120 فيزا': PaymentMethod.visa,
        'paid 80 with vodafone cash wallet': PaymentMethod.wallet,
        'دفعت 80 من المحفظة': PaymentMethod.wallet,
        'sent 200 by bank transfer': PaymentMethod.bankTransfer,
        'دفعت 200 تحويل بنكي': PaymentMethod.bankTransfer,
      };

      for (final entry in cases.entries) {
        final response = await service.parseExpenseText(entry.key, context);

        expect(
          PaymentMethod.fromStorageValue(response.paymentMethod),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('keeps detected payment method in draft conversion', () async {
      const service = AiService();
      final response = await service.parseExpenseText(
        'paid 120 by card',
        AiContext(now: DateTime.utc(2026, 5, 31), defaultCurrency: 'EGP'),
      );

      final draft = service.parseExpenseToDraft(response);

      expect(draft, isNotNull);
      expect(draft!.paymentMethod, PaymentMethod.visa);
    });
  });
}
