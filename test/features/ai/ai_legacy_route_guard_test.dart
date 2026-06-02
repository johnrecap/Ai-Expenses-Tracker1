import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy prompt advice is not wired to production AI services', () {
    final aiApiService = File('lib/features/ai/services/ai_api_service.dart').readAsStringSync();
    final advisorService = File('lib/features/ai/services/advisor_service.dart').readAsStringSync();

    expect(aiApiService, isNot(contains("summary: {'prompt'")));
    expect(aiApiService, isNot(contains('AiGatewayAdviceRequest(')));
    expect(advisorService, isNot(contains('_fetchInsightsFromAi')));
    expect(advisorService, isNot(contains('_fetchRecommendationsFromAi')));
    expect(advisorService, isNot(contains('getAdvice(prompt)')));
  });
}
