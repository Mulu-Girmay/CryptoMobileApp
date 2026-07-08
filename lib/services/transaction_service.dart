import '../model/transaction.dart';
import 'transaction_storage.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  List<Transaction> _transactions = [];

  Future<void> loadTransactions() async {
    _transactions = await TransactionStorage.loadTransactions();
  }

  Future<void> saveTransactions() async {
    await TransactionStorage.saveTransactions(_transactions);
  }

  List<Transaction> getTransactions() {
    return _transactions;
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await saveTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await saveTransactions();
  }

  Future<void> clearAll() async {
    _transactions.clear();
    await saveTransactions();
  }

  // Get transactions by type
  List<Transaction> getByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get transactions by coin
  List<Transaction> getByCoin(String coinId) {
    return _transactions.where((t) => t.coinId == coinId).toList();
  }

  // Get total spent on a specific coin
  double getTotalSpent(String coinId) {
    return _transactions
        .where((t) => t.coinId == coinId && t.type == TransactionType.buy)
        .fold(0.0, (sum, t) => sum + t.fiatValue);
  }

  // Get total received from selling a specific coin
  double getTotalReceived(String coinId) {
    return _transactions
        .where((t) => t.coinId == coinId && t.type == TransactionType.sell)
        .fold(0.0, (sum, t) => sum + t.fiatValue);
  }

  // Get total coins bought (amount) for a specific coin
  double getTotalCoinsBought(String coinId) {
    return _transactions
        .where((t) => t.coinId == coinId && t.type == TransactionType.buy)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total coins sold (amount) for a specific coin
  double getTotalCoinsSold(String coinId) {
    return _transactions
        .where((t) => t.coinId == coinId && t.type == TransactionType.sell)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total value of all transactions
  double getTotalValue() {
    return _transactions.fold(0.0, (sum, t) => sum + t.fiatValue);
  }

  // Get average buy price for a coin
  double getAverageBuyPrice(String coinId) {
    final buys = _transactions
        .where((t) => t.coinId == coinId && t.type == TransactionType.buy)
        .toList();

    if (buys.isEmpty) return 0.0;

    final totalCoins = buys.fold(0.0, (sum, t) => sum + t.amount);
    final totalCost = buys.fold(0.0, (sum, t) => sum + t.fiatValue);

    return totalCoins > 0 ? totalCost / totalCoins : 0.0;
  }
}
