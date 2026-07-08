import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/transaction.dart';

class TransactionStorage {
  static const String _key = 'transactions';

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = transactions.map((t) => t.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving transactions: $e');
      rethrow;
    }
  }

  static Future<List<Transaction>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  static Future<void> clearTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing transactions: $e');
      rethrow;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final transactions = await loadTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }
}
