class AppConfig {
  AppConfig._();

  static const aiGatewayUrl = String.fromEnvironment(
    'AI_GATEWAY_URL',
    defaultValue: 'https://ai-expenses-gateway.mohamedsaied-m20.workers.dev',
  );
}
