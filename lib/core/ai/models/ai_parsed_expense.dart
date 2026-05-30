/// {@template ai_parsed_expense}
/// Represents an expense parsed from natural language input by the AI parser.
///
/// This model holds all fields that could be extracted from user input,
/// along with metadata about parsing confidence and missing fields.
/// {@endtemplate}
class AiParsedExpense {
  /// Creates an [AiParsedExpense] instance.
  ///
  /// [confidence] must be between 0.0 and 1.0 (inclusive).
  /// [originalInput] must not be empty.
  const AiParsedExpense({
    this.amount,
    this.currency,
    this.category,
    this.date,
    this.note,
    required this.confidence,
    required this.missingFields,
    required this.originalInput,
  })  : assert(confidence >= 0.0 && confidence <= 1.0);

  /// The parsed monetary amount, or `null` if not detected.
  final double? amount;

  /// The parsed currency code (e.g., "EGP", "USD"), or `null` if not detected.
  final String? currency;

  /// The parsed expense category (e.g., "food", "transport"), or `null` if not detected.
  final String? category;

  /// The parsed transaction date, or `null` if not detected.
  final DateTime? date;

  /// Any additional note or description extracted from the input, or `null`.
  final String? note;

  /// Confidence score of the AI parsing, from 0.0 (uncertain) to 1.0 (certain).
  final double confidence;

  /// List of field names that could not be parsed from the input.
  final List<String> missingFields;

  /// The original natural language input provided by the user.
  final String originalInput;

  /// Creates a copy of this instance with the given fields replaced.
  AiParsedExpense copyWith({
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? note,
    double? confidence,
    List<String>? missingFields,
    String? originalInput,
  }) {
    return AiParsedExpense(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      confidence: confidence ?? this.confidence,
      missingFields: missingFields ?? this.missingFields,
      originalInput: originalInput ?? this.originalInput,
    );
  }

  /// Creates an [AiParsedExpense] from a JSON map.
  ///
  /// The [json] map must contain a "confidence" key (double) and
  /// an "originalInput" key (String).
  factory AiParsedExpense.fromJson(Map<String, dynamic> json) {
    return AiParsedExpense(
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      category: json['category'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      note: json['note'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      missingFields: (json['missingFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      originalInput: json['originalInput'] as String,
    );
  }

  /// Converts this [AiParsedExpense] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date?.toIso8601String(),
      'note': note,
      'confidence': confidence,
      'missingFields': missingFields,
      'originalInput': originalInput,
    };
  }

  @override
  String toString() {
    return 'AiParsedExpense('
        'amount: $amount, '
        'currency: $currency, '
        'category: $category, '
        'date: $date, '
        'note: $note, '
        'confidence: $confidence, '
        'missingFields: $missingFields, '
        'originalInput: "$originalInput")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiParsedExpense &&
        other.amount == amount &&
        other.currency == currency &&
        other.category == category &&
        other.date == date &&
        other.note == note &&
        other.confidence == confidence &&
        _listEquals(other.missingFields, missingFields) &&
        other.originalInput == originalInput;
  }

  @override
  int get hashCode {
    return Object.hash(
      amount,
      currency,
      category,
      date,
      note,
      confidence,
      Object.hashAll(missingFields),
      originalInput,
    );
  }
}

/// Internal helper for list equality.
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
