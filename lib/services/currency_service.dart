import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/currency.dart';
import 'currency_storage.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  Currency _selectedCurrency = Currency.getDefault();
  bool _isInitialized = false;

  Currency get selectedCurrency => _selectedCurrency;
  String get currentCode => _selectedCurrency.code;
  String get currentSymbol => _selectedCurrency.symbol;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final code = await CurrencyStorage.loadCurrency();
    final currency = Currency.fromCode(code);
    if (currency != null) {
      _selectedCurrency = currency;
    }
    _isInitialized = true;
  }

  Future<void> setCurrency(Currency currency) async {
    _selectedCurrency = currency;
    await CurrencyStorage.saveCurrency(currency.code);
  }

  // Format price with current currency symbol
  String formatPrice(double price) {
    return '$currentSymbol${price.toStringAsFixed(price < 1 ? 4 : 2)}';
  }

  // Format large number with current currency symbol
  String formatLargeNumber(double number) {
    if (number >= 1e9) {
      return '$currentSymbol${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '$currentSymbol${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '$currentSymbol${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return formatPrice(number);
    }
  }

  // Get exchange rates for all currencies
  static Future<Map<String, double>> getExchangeRates(
    String baseCurrency,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/exchange_rates'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        final result = <String, double>{};
        for (var entry in rates.entries) {
          result[entry.key.toLowerCase()] = (entry.value['value'] as num)
              .toDouble();
        }
        return result;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return {};
    }
  }
}
