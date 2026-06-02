import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_repository/expense_repository.dart';

enum ExchangeRateLookupStatus { fresh, stale, failed }

class ExchangeRateException implements Exception {
  final String fromCurrency;
  final String toCurrency;
  final String message;
  final Object? cause;

  const ExchangeRateException({
    required this.fromCurrency,
    required this.toCurrency,
    required this.message,
    this.cause,
  });

  @override
  String toString() => 'ExchangeRateException($fromCurrency->$toCurrency: $message)';
}

class ExchangeRateStaleException extends ExchangeRateException {
  final double staleRate;
  final DateTime fetchedAt;

  const ExchangeRateStaleException({
    required super.fromCurrency,
    required super.toCurrency,
    required this.staleRate,
    required this.fetchedAt,
  }) : super(message: 'Exchange rate is stale');
}

class ExchangeRateLookupResult {
  final String fromCurrency;
  final String toCurrency;
  final ExchangeRateLookupStatus status;
  final double? rate;
  final DateTime? fetchedAt;
  final ExchangeRateException? failure;

  const ExchangeRateLookupResult._({
    required this.fromCurrency,
    required this.toCurrency,
    required this.status,
    this.rate,
    this.fetchedAt,
    this.failure,
  });

  factory ExchangeRateLookupResult.fresh({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    required DateTime fetchedAt,
  }) {
    return ExchangeRateLookupResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.fresh,
      rate: rate,
      fetchedAt: fetchedAt,
    );
  }

  factory ExchangeRateLookupResult.stale({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    required DateTime fetchedAt,
  }) {
    return ExchangeRateLookupResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.stale,
      rate: rate,
      fetchedAt: fetchedAt,
      failure: ExchangeRateStaleException(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        staleRate: rate,
        fetchedAt: fetchedAt,
      ),
    );
  }

  factory ExchangeRateLookupResult.failed({
    required String fromCurrency,
    required String toCurrency,
    required ExchangeRateException failure,
  }) {
    return ExchangeRateLookupResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.failed,
      failure: failure,
    );
  }

  bool get isUsable => status != ExchangeRateLookupStatus.failed && rate != null;

  double requireFreshRate() {
    if (status == ExchangeRateLookupStatus.fresh && rate != null) {
      return rate!;
    }

    throw failure ??
        ExchangeRateException(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          message: 'Exchange rate is unavailable',
        );
  }
}

class CurrencyConversionResult {
  final String fromCurrency;
  final String toCurrency;
  final ExchangeRateLookupStatus status;
  final double? amount;
  final DateTime? fetchedAt;
  final ExchangeRateException? failure;

  const CurrencyConversionResult._({
    required this.fromCurrency,
    required this.toCurrency,
    required this.status,
    this.amount,
    this.fetchedAt,
    this.failure,
  });

  factory CurrencyConversionResult.fresh({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required DateTime fetchedAt,
  }) {
    return CurrencyConversionResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.fresh,
      amount: amount,
      fetchedAt: fetchedAt,
    );
  }

  factory CurrencyConversionResult.stale({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required double staleRate,
    required DateTime fetchedAt,
  }) {
    return CurrencyConversionResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.stale,
      amount: amount,
      fetchedAt: fetchedAt,
      failure: ExchangeRateStaleException(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        staleRate: staleRate,
        fetchedAt: fetchedAt,
      ),
    );
  }

  factory CurrencyConversionResult.failed({
    required String fromCurrency,
    required String toCurrency,
    required ExchangeRateException failure,
  }) {
    return CurrencyConversionResult._(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      status: ExchangeRateLookupStatus.failed,
      failure: failure,
    );
  }
}

class ExchangeRateService {
  static const Duration _cacheTtl = Duration(hours: 24);

  final String? _apiKey;
  final http.Client _client;
  final DateTime Function() _now;
  final Map<String, double> _cache = {};
  final Map<String, DateTime> _fetchedAt = {};

  ExchangeRateService({
    this._apiKey,
    http.Client? client,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  Future<double> getRate(String fromCurrency, String toCurrency) async {
    return (await getRateResult(fromCurrency, toCurrency)).requireFreshRate();
  }

  Future<ExchangeRateLookupResult> getRateResult(String fromCurrency, String toCurrency) async {
    final from = _normalizeCurrency(fromCurrency);
    final to = _normalizeCurrency(toCurrency);
    if (from == to) {
      return ExchangeRateLookupResult.fresh(
        fromCurrency: from,
        toCurrency: to,
        rate: 1.0,
        fetchedAt: _now(),
      );
    }

    final key = _cacheKey(from, to);
    final cachedRate = _cache[key];
    final cachedAt = _fetchedAt[key];
    if (cachedRate != null && cachedAt != null && !_isExpired(cachedAt)) {
      return ExchangeRateLookupResult.fresh(
        fromCurrency: from,
        toCurrency: to,
        rate: cachedRate,
        fetchedAt: cachedAt,
      );
    }

    try {
      final rate = await _fetchRate(from, to);
      final fetchedAt = _now();
      _cache[key] = rate;
      _fetchedAt[key] = fetchedAt;
      return ExchangeRateLookupResult.fresh(
        fromCurrency: from,
        toCurrency: to,
        rate: rate,
        fetchedAt: fetchedAt,
      );
    } catch (error) {
      if (cachedRate != null && cachedAt != null) {
        return ExchangeRateLookupResult.stale(
          fromCurrency: from,
          toCurrency: to,
          rate: cachedRate,
          fetchedAt: cachedAt,
        );
      }

      return ExchangeRateLookupResult.failed(
        fromCurrency: from,
        toCurrency: to,
        failure: ExchangeRateException(
          fromCurrency: from,
          toCurrency: to,
          message: 'Exchange rate lookup failed',
          cause: error,
        ),
      );
    }
  }

  Future<double> _fetchRate(String from, String to) async {
    final uri = _apiKey != null
        ? Uri.parse('https://api.exchangerate-api.com/v4/latest/$from')
        : Uri.parse('https://open.er-api.com/v6/latest/$from');
    final response = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = body['rates'] as Map<String, dynamic>?;
      if (rates != null && rates.containsKey(to)) {
        return (rates[to] as num).toDouble();
      }
    }
    throw ExchangeRateException(
      fromCurrency: from,
      toCurrency: to,
      message: 'Exchange rate response did not include a usable rate',
    );
  }

  Future<void> refreshAll(List<String> currencies) async {
    for (final from in currencies) {
      for (final to in currencies) {
        if (from != to) {
          await getRateResult(from, to);
        }
      }
    }
  }

  double convert(double amount, String fromCurrency, String toCurrency) {
    final from = _normalizeCurrency(fromCurrency);
    final to = _normalizeCurrency(toCurrency);
    if (from == to) return amount;

    final key = _cacheKey(from, to);
    final rate = _cache[key];
    final fetchedAt = _fetchedAt[key];
    if (rate == null || fetchedAt == null) {
      throw ExchangeRateException(
        fromCurrency: from,
        toCurrency: to,
        message: 'Exchange rate is unavailable',
      );
    }
    if (_isExpired(fetchedAt)) {
      throw ExchangeRateStaleException(
        fromCurrency: from,
        toCurrency: to,
        staleRate: rate,
        fetchedAt: fetchedAt,
      );
    }

    return amount * rate;
  }

  CurrencyConversionResult convertResult(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    final from = _normalizeCurrency(fromCurrency);
    final to = _normalizeCurrency(toCurrency);
    if (from == to) {
      return CurrencyConversionResult.fresh(
        fromCurrency: from,
        toCurrency: to,
        amount: amount,
        fetchedAt: _now(),
      );
    }

    final key = _cacheKey(from, to);
    final rate = _cache[key];
    final fetchedAt = _fetchedAt[key];
    if (rate == null || fetchedAt == null) {
      return CurrencyConversionResult.failed(
        fromCurrency: from,
        toCurrency: to,
        failure: ExchangeRateException(
          fromCurrency: from,
          toCurrency: to,
          message: 'Exchange rate is unavailable',
        ),
      );
    }

    final convertedAmount = amount * rate;
    if (_isExpired(fetchedAt)) {
      return CurrencyConversionResult.stale(
        fromCurrency: from,
        toCurrency: to,
        amount: convertedAmount,
        staleRate: rate,
        fetchedAt: fetchedAt,
      );
    }

    return CurrencyConversionResult.fresh(
      fromCurrency: from,
      toCurrency: to,
      amount: convertedAmount,
      fetchedAt: fetchedAt,
    );
  }

  bool get isStale => lastFetched == null || _isExpired(lastFetched!);
  DateTime? get lastFetched {
    if (_fetchedAt.isEmpty) return null;
    return _fetchedAt.values.reduce((current, next) => current.isAfter(next) ? current : next);
  }

  bool _isExpired(DateTime fetchedAt) => _now().difference(fetchedAt) >= _cacheTtl;

  String _cacheKey(String fromCurrency, String toCurrency) => '$fromCurrency-$toCurrency';

  String _normalizeCurrency(String currency) => currency.trim().toUpperCase();
}

class ExchangeRateRefreshService {
  final ExchangeRateService _rateService;
  final SettingsRepository _settingsRepo;
  Timer? _timer;

  ExchangeRateRefreshService(this._rateService, this._settingsRepo);

  void start() {
    _timer = Timer.periodic(const Duration(hours: 12), (_) => _refresh());
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final settings = await _settingsRepo.getSettings();
      await _rateService.refreshAll(settings.supportedCurrencies);
    } catch (_) {}
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
