class AppConfig {
  AppConfig._();

  static const aiGatewayUrl = String.fromEnvironment(
    'AI_GATEWAY_URL',
    defaultValue: 'https://ai-expenses-gateway.mohamedsaied-m20.workers.dev',
  );

  static Uri get aiGatewayUri {
    final parsed = Uri.parse(aiGatewayUrl);
    if (!parsed.hasScheme || parsed.host.isEmpty) {
      throw const FormatException('AI_GATEWAY_URL must be an absolute URL.');
    }
    return parsed;
  }
}
