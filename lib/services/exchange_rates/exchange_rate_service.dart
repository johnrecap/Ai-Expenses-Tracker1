import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_repository/expense_repository.dart';

class ExchangeRateService {
  final String? _apiKey;
  final http.Client _client;
  final Map<String, double> _cache = {};
  DateTime? _lastFetched;

  ExchangeRateService({this._apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<double> getRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;
    final key = '$fromCurrency-$toCurrency';
    if (_cache.containsKey(key) && _lastFetched != null && DateTime.now().difference(_lastFetched!).inHours < 24) {
      return _cache[key]!;
    }
    try {
      final rate = await _fetchRate(fromCurrency, toCurrency);
      _cache[key] = rate;
      _lastFetched = DateTime.now();
      return rate;
    } catch (_) {
      return _cache[key] ?? 1.0;
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
    throw Exception('Failed to fetch rate');
  }

  Future<void> refreshAll(List<String> currencies) async {
    for (final from in currencies) {
      for (final to in currencies) {
        if (from != to) {
          try { await getRate(from, to); } catch (_) {}
        }
      }
    }
  }

  double convert(double amount, String fromCurrency, String toCurrency) {
    return amount * (_cache['$fromCurrency-$toCurrency'] ?? 1.0);
  }

  bool get isStale => _lastFetched == null || DateTime.now().difference(_lastFetched!).inHours > 24;
  DateTime? get lastFetched => _lastFetched;
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
