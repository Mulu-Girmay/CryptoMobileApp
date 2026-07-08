class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  static const List<Currency> supportedCurrencies = [
    Currency(code: 'usd', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    Currency(code: 'eur', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'gbp', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    Currency(code: 'jpy', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    Currency(
      code: 'aud',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
    ),
    Currency(
      code: 'cad',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
    ),
    Currency(code: 'chf', symbol: 'Fr', name: 'Swiss Franc', flag: '🇨🇭'),
    Currency(code: 'cny', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    Currency(code: 'inr', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    Currency(code: 'brl', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
    Currency(code: 'krw', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    Currency(code: 'rub', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
    Currency(
      code: 'zar',
      symbol: 'R',
      name: 'South African Rand',
      flag: '🇿🇦',
    ),
    Currency(
      code: 'sgd',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
    ),
  ];

  static Currency getDefault() {
    return supportedCurrencies.firstWhere((c) => c.code == 'usd');
  }

  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}
