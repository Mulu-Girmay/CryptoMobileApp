import 'package:shared_preferences/shared_preferences.dart';

class CurrencyStorage {
  static const String _key = 'selected_currency';

  static Future<void> saveCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, currencyCode);
    } catch (e) {
      print('Error saving currency: $e');
      rethrow;
    }
  }

  static Future<String> loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key) ?? 'usd';
    } catch (e) {
      print('Error loading currency: $e');
      return 'usd';
    }
  }
}
