import 'package:intl/intl.dart';

class Formatter {
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: price < 1 ? 4 : 2,
    );
    return formatter.format(price);
  }

  static String formatLargeNumber(double number) {
    if (number >= 1e9) {
      return '\$${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '\$${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '\$${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return formatPrice(number);
    }
  }

  static String formatChange(double change) {
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }
}
