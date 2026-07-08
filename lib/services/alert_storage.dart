import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/alert.dart';

class AlertStorage {
  static const String _key = 'price_alerts';

  static Future<void> saveAlerts(List<PriceAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = alerts.map((alert) => alert.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving alerts: $e');
      rethrow;
    }
  }

  static Future<List<PriceAlert>> loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => PriceAlert.fromJson(json)).toList();
    } catch (e) {
      print('Error loading alerts: $e');
      return [];
    }
  }

  static Future<void> clearAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing alerts: $e');
      rethrow;
    }
  }
}
