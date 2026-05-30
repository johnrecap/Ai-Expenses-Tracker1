/// {@template ai_recommendation}
/// Represents an AI-generated recommendation for the user.
///
/// Recommendations suggest concrete actions the user can take to improve
/// their financial situation, along with the estimated potential savings.
/// {@endtemplate}
class AiRecommendation {
  /// Creates an [AiRecommendation] instance.
  const AiRecommendation({
    required this.id,
    required this.title,
    required this.body,
    required this.potentialSavings,
    required this.generatedAt,
  });

  /// Unique identifier for this recommendation.
  final String id;

  /// Short, human-readable title of the recommendation.
  final String title;

  /// Detailed body text explaining the recommendation and how to apply it.
  final String body;

  /// Estimated potential savings in the user's primary currency (e.g., EGP).
  final double potentialSavings;

  /// Timestamp when this recommendation was generated.
  final DateTime generatedAt;

  /// Creates a copy of this instance with the given fields replaced.
  AiRecommendation copyWith({
    String? id,
    String? title,
    String? body,
    double? potentialSavings,
    DateTime? generatedAt,
  }) {
    return AiRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      potentialSavings: potentialSavings ?? this.potentialSavings,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Creates an [AiRecommendation] from a JSON map.
  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      potentialSavings: (json['potentialSavings'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  /// Converts this [AiRecommendation] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'potentialSavings': potentialSavings,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AiRecommendation('
        'id: $id, '
        'title: "$title", '
        'body: "$body", '
        'potentialSavings: $potentialSavings, '
        'generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiRecommendation &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.potentialSavings == potentialSavings &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      body,
      potentialSavings,
      generatedAt,
    );
  }
}
