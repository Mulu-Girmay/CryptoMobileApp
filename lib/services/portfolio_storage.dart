import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/portfolio.dart';

class PortfolioStorage {
  static const String _key = 'portfolio_items';

  static Future<void> savePortfolio(List<PortfolioItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<PortfolioItem>> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => PortfolioItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
