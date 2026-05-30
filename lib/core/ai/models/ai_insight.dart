/// {@template ai_insight}
/// Represents an AI-generated insight about the user's spending patterns.
///
/// Insights are produced by the AI advisor to highlight trends, anomalies,
/// or actionable observations derived from expense data.
/// {@endtemplate}
class AiInsight {
  /// Creates an [AiInsight] instance.
  ///
  /// All fields are required except [relatedRoute], which may be `null`.
  const AiInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    this.relatedRoute,
    required this.generatedAt,
  });

  /// Unique identifier for this insight.
  final String id;

  /// Short, human-readable title of the insight.
  final String title;

  /// Detailed summary explaining the insight.
  final String summary;

  /// Severity level of the insight: "low", "medium", or "high".
  final String severity;

  /// Optional route name related to this insight (e.g., a screen to navigate to).
  final String? relatedRoute;

  /// Timestamp when this insight was generated.
  final DateTime generatedAt;

  /// Creates a copy of this instance with the given fields replaced.
  AiInsight copyWith({
    String? id,
    String? title,
    String? summary,
    String? severity,
    String? relatedRoute,
    DateTime? generatedAt,
  }) {
    return AiInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      severity: severity ?? this.severity,
      relatedRoute: relatedRoute ?? this.relatedRoute,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Creates an [AiInsight] from a JSON map.
  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      severity: json['severity'] as String,
      relatedRoute: json['relatedRoute'] as String?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  /// Converts this [AiInsight] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'summary': summary,
      'severity': severity,
      'relatedRoute': relatedRoute,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AiInsight('
        'id: $id, '
        'title: "$title", '
        'summary: "$summary", '
        'severity: $severity, '
        'relatedRoute: $relatedRoute, '
        'generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiInsight &&
        other.id == id &&
        other.title == title &&
        other.summary == summary &&
        other.severity == severity &&
        other.relatedRoute == relatedRoute &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      summary,
      severity,
      relatedRoute,
      generatedAt,
    );
  }
}
