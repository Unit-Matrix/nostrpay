import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/models/fiat_currency.dart';

final Logger _logger = Logger('CurrencyService');

class CurrencyService {
  static const String _endpoint =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/btc.json';
  final Dio _dio;

  CurrencyService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<FiatCurrency, double>> fetchBtcRates({
    List<FiatCurrency>? currencies,
  }) async {
    final List<FiatCurrency> fiatList = currencies ?? supportedCurrencies;
    try {
      final response = await _dio.get(_endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final btc = response.data['btc'] as Map<String, dynamic>?;
        if (btc == null) throw Exception('Malformed response: missing btc key');

        final Map<FiatCurrency, double> rates = {};
        _logger.info(
            'Available API currencies: ${btc.keys.take(10).toList()}...'); // Show first 10 for debugging

        for (final fiat in fiatList) {
          final value = btc[fiat.code];
          if (value != null) {
            rates[fiat] = (value as num).toDouble();
            _logger.info('Rate found for ${fiat.code}: $value');
          } else {
            _logger.warning('Rate not available for ${fiat.code}');
          }
          // If a currency is not available, we skip it instead of throwing an error
          // This allows the app to work with available currencies
        }

        // If no rates were found, throw an error
        if (rates.isEmpty) {
          throw Exception('No currency rates available from API');
        }

        return rates;
      } else {
        throw Exception('Failed to fetch rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('CurrencyService error: $e');
    }
  }

  /// Get list of currencies that have rates available
  List<FiatCurrency> getAvailableCurrencies(Map<FiatCurrency, double> rates) {
    return rates.keys.toList();
  }
}
