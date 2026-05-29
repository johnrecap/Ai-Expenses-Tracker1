class MoneySnapshot {
  final double originalAmount;
  final String originalCurrency;
  final double convertedAmount;
  final String targetCurrency;
  final double exchangeRate;
  final DateTime capturedAt;
  final String? rateSource;

  const MoneySnapshot({
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.targetCurrency,
    required this.exchangeRate,
    required this.capturedAt,
    this.rateSource,
  });

  Map<String, dynamic> toJson() => {
    'originalAmount': originalAmount,
    'originalCurrency': originalCurrency,
    'convertedAmount': convertedAmount,
    'targetCurrency': targetCurrency,
    'exchangeRate': exchangeRate,
    'capturedAt': capturedAt.toIso8601String(),
    if (rateSource != null) 'rateSource': rateSource,
  };

  static MoneySnapshot fromJson(Map<String, dynamic> json) => MoneySnapshot(
    originalAmount: (json['originalAmount'] as num).toDouble(),
    originalCurrency: json['originalCurrency'] as String,
    convertedAmount: (json['convertedAmount'] as num).toDouble(),
    targetCurrency: json['targetCurrency'] as String,
    exchangeRate: (json['exchangeRate'] as num).toDouble(),
    capturedAt: DateTime.parse(json['capturedAt'] as String),
    rateSource: json['rateSource'] as String?,
  );
}
