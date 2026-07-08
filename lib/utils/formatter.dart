import 'package:intl/intl.dart';
import '../services/currency_service.dart';

class Formatter {
  static final CurrencyService _currencyService = CurrencyService();

  // Format price with current currency symbol
  static String formatPrice(double price) {
    final symbol = _currencyService.currentSymbol;
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: price < 1 ? 4 : 2,
    );
    return formatter.format(price);
  }

  // Format large number with current currency symbol
  static String formatLargeNumber(double number) {
    final symbol = _currencyService.currentSymbol;
    if (number >= 1e9) {
      return '$symbol${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '$symbol${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '$symbol${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return formatPrice(number);
    }
  }

  // Format price change percentage
  static String formatChange(double change) {
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  // Format price with specific currency symbol (for converter or specific use cases)
  static String formatPriceWithSymbol(double price, String symbol) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: price < 1 ? 4 : 2,
    );
    return formatter.format(price);
  }

  // Format price without currency symbol (for charts, etc.)
  static String formatPriceWithoutSymbol(double price) {
    return price.toStringAsFixed(price < 1 ? 4 : 2);
  }

  // Format large number without currency symbol
  static String formatLargeNumberWithoutSymbol(double number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(number < 1 ? 4 : 2);
    }
  }
}
