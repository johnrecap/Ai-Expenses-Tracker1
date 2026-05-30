import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

/// {@template location_service}
/// Provides location-aware expense suggestions.
///
/// When the user is at a known location (e.g. a frequently visited
/// restaurant or supermarket), the service suggests the most likely
/// category and merchant based on historical expenses recorded near
/// that place.
///
/// This implementation is a lightweight heuristic-based version that
/// works without requiring a native geolocation plugin. If a real
/// GPS fix is needed in the future, `geolocator` can be plugged in
/// behind the same interface.
/// {@endtemplate}
class LocationService {
  /// Creates a [LocationService].
  ///
  /// [expenseRepository] provides historical expenses used to infer
  /// location-based patterns.
  LocationService({required this.expenseRepository});

  final ExpenseRepository expenseRepository;

  /// In-memory cache of location-to-category mappings built from history.
  Map<String, LocationPattern>? _cache;

  /// Refreshes the internal location pattern cache from the database.
  Future<void> refreshCache() async {
    try {
      final expenses = await expenseRepository.getExpenses();
      _cache = _buildCache(expenses);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to refresh location cache',
        name: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      _cache = {};
    }
  }

  /// Returns a [LocationSuggestion] for the given [locationName].
  ///
  /// [locationName] should be a human-readable place name such as
  /// "Starbucks", "Carrefour", or "Shell Gas Station". The service
  /// matches it against the description / merchant fields of past
  /// expenses.
  ///
  /// Returns `null` if no historical data is available.
  Future<LocationSuggestion?> suggestFor(String locationName) async {
    if (_cache == null || _cache!.isEmpty) {
      await refreshCache();
    }

    final normalized = _normalize(locationName);
    final pattern = _cache![normalized];

    if (pattern == null) {
      // Try fuzzy matching: find the key with the highest similarity.
      final fuzzy = _fuzzyMatch(normalized, _cache!.keys);
      if (fuzzy != null) {
        return _toSuggestion(fuzzy, _cache![fuzzy]!);
      }
      return null;
    }

    return _toSuggestion(normalized, pattern);
  }

  /// Returns the most likely category for a given location.
  Future<Category?> suggestCategory(String locationName) async {
    final suggestion = await suggestFor(locationName);
    return suggestion?.category;
  }

  /// Returns the most likely merchant name for a given location.
  Future<String?> suggestMerchant(String locationName) async {
    final suggestion = await suggestFor(locationName);
    return suggestion?.merchant;
  }

  /// Returns a list of known location names from the cache.
  Future<List<String>> getKnownLocations() async {
    if (_cache == null) await refreshCache();
    return _cache?.keys.toList() ?? const [];
  }

  // ---------------------------------------------------------------------------
  // Cache building
  // ---------------------------------------------------------------------------

  Map<String, LocationPattern> _buildCache(List<Expense> expenses) {
    final map = <String, List<Expense>>{};

    for (final e in expenses) {
      final key = _extractLocationKey(e);
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => []).add(e);
    }

    final cache = <String, LocationPattern>{};
    for (final entry in map.entries) {
      if (entry.value.length < 2) continue; // Need at least 2 visits.
      cache[entry.key] = _computePattern(entry.value);
    }

    return cache;
  }

  String _extractLocationKey(Expense expense) {
    // Prefer merchant, fallback to description.
    final raw = expense.merchant?.trim() ?? expense.description.trim();
    return _normalize(raw);
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  LocationPattern _computePattern(List<Expense> group) {
    // Count category frequencies.
    final categoryCounts = <Category, int>{};
    for (final e in group) {
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
    }

    // Most common category.
    final topCategoryEntry = categoryCounts.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    });

    // Average amount.
    final avgAmount =
        group.map((e) => e.amount).reduce((a, b) => a + b) / group.length;

    // Most common currency.
    final currencyCounts = <String, int>{};
    for (final e in group) {
      currencyCounts[e.currency] = (currencyCounts[e.currency] ?? 0) + 1;
    }
    final topCurrency = currencyCounts.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    }).key;

    return LocationPattern(
      category: topCategoryEntry.key,
      merchant: group.first.merchant ?? group.first.description,
      averageAmount: avgAmount,
      currency: topCurrency,
      visitCount: group.length,
      confidence: (topCategoryEntry.value / group.length).clamp(0.0, 1.0),
    );
  }

  // ---------------------------------------------------------------------------
  // Fuzzy matching
  // ---------------------------------------------------------------------------

  String? _fuzzyMatch(String query, Iterable<String> candidates) {
    String? best;
    var bestScore = 0.0;

    for (final candidate in candidates) {
      final score = _similarity(query, candidate);
      if (score > bestScore && score >= 0.6) {
        bestScore = score;
        best = candidate;
      }
    }

    return best;
  }

  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    // Simple substring bonus.
    if (longer.contains(shorter)) return shorter.length / longer.length;

    // Jaccard similarity on word sets.
    final setA = a.split(RegExp(r'\s+')).toSet();
    final setB = b.split(RegExp(r'\s+')).toSet();
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union > 0 ? intersection / union : 0.0;
  }

  LocationSuggestion _toSuggestion(String locationName, LocationPattern pattern) {
    return LocationSuggestion(
      locationName: locationName,
      category: pattern.category,
      merchant: pattern.merchant,
      suggestedAmount: pattern.averageAmount,
      currency: pattern.currency,
      confidence: pattern.confidence,
    );
  }
}

/// {@template location_pattern}
/// Aggregated data about expenses tied to a specific location.
/// {@endtemplate}
class LocationPattern {
  /// Creates a [LocationPattern].
  const LocationPattern({
    required this.category,
    required this.merchant,
    required this.averageAmount,
    required this.currency,
    required this.visitCount,
    required this.confidence,
  });

  final Category category;
  final String merchant;
  final double averageAmount;
  final String currency;
  final int visitCount;
  final double confidence;
}

/// {@template location_suggestion}
/// A suggestion produced by [LocationService] for a given place.
/// {@endtemplate}
class LocationSuggestion {
  /// Creates a [LocationSuggestion].
  const LocationSuggestion({
    required this.locationName,
    required this.category,
    required this.merchant,
    required this.suggestedAmount,
    required this.currency,
    required this.confidence,
  });

  /// The matched location name.
  final String locationName;

  /// Suggested category based on historical expenses.
  final Category category;

  /// Suggested merchant name.
  final String merchant;

  /// Average amount spent at this location.
  final double suggestedAmount;

  /// Currency code.
  final String currency;

  /// Confidence that the suggestion is correct (0.0 to 1.0).
  final double confidence;

  /// Whether the suggestion is strong enough to auto-fill.
  bool get isStrong => confidence >= 0.7;
}
