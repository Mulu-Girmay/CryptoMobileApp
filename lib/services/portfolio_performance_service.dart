import '../model/transaction.dart';
import '../model/coin.dart';
import 'transaction_service.dart';

class PerformanceDataPoint {
  final DateTime date;
  final double totalValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPercentage;

  PerformanceDataPoint({
    required this.date,
    required this.totalValue,
    required this.totalInvested,
    required this.profitLoss,
    required this.profitLossPercentage,
  });
}

class PortfolioPerformanceService {
  final TransactionService _transactionService = TransactionService();
  List<Coin> _coins = [];

  Future<List<PerformanceDataPoint>> calculatePerformance({
    required List<Transaction> transactions,
    required List<Coin> coins,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _coins = coins;
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 30));
    final end = endDate ?? now;

    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get all unique dates from transactions
    final dates = <DateTime>[];
    for (var t in sortedTransactions) {
      if (!dates.any(
        (d) =>
            d.year == t.date.year &&
            d.month == t.date.month &&
            d.day == t.date.day,
      )) {
        dates.add(DateTime(t.date.year, t.date.month, t.date.day));
      }
    }

    // Ensure we have at least some dates
    if (dates.isEmpty) {
      dates.add(start);
    }
    dates.add(end);

    // Calculate performance for each date
    final performanceData = <PerformanceDataPoint>[];
    double totalInvested = 0.0;
    double totalCoinsValue = 0.0;

    var currentIndex = 0;
    for (var date in dates) {
      // Process all transactions up to this date
      while (currentIndex < sortedTransactions.length &&
          sortedTransactions[currentIndex].date.isBefore(
            date.add(const Duration(days: 1)),
          )) {
        final tx = sortedTransactions[currentIndex];
        final coin = _coins.firstWhere(
          (c) => c.id == tx.coinId,
          orElse: () => Coin(
            id: tx.coinId,
            name: tx.coinName,
            symbol: tx.coinSymbol,
            image: tx.coinImage,
            price: 0,
            change: 0,
            marketCap: 0,
            totalVolume: 0,
            high24h: 0,
            low24h: 0,
          ),
        );

        switch (tx.type) {
          case TransactionType.buy:
            totalInvested += tx.fiatValue;
            totalCoinsValue +=
                tx.amount * (coin.price > 0 ? coin.price : tx.price);
            break;
          case TransactionType.sell:
            totalInvested -= tx.fiatValue;
            totalCoinsValue -=
                tx.amount * (coin.price > 0 ? coin.price : tx.price);
            break;
          case TransactionType.deposit:
            totalCoinsValue +=
                tx.amount * (coin.price > 0 ? coin.price : tx.price);
            break;
          case TransactionType.withdrawal:
            totalCoinsValue -=
                tx.amount * (coin.price > 0 ? coin.price : tx.price);
            break;
          case TransactionType.swap:
            // For simplicity, treat swap as sell + buy
            break;
        }
        currentIndex++;
      }

      // Get current prices for all coins in portfolio on this date
      final currentValue = _calculatePortfolioValue(
        transactions: sortedTransactions.take(currentIndex).toList(),
        currentDate: date,
      );

      final profitLoss = currentValue - totalInvested;
      final profitLossPercentage = totalInvested > 0
          ? (profitLoss / totalInvested) * 100
          : 0.0; // Ensure double

      performanceData.add(
        PerformanceDataPoint(
          date: date,
          totalValue: currentValue,
          totalInvested: totalInvested,
          profitLoss: profitLoss,
          profitLossPercentage: profitLossPercentage
              .toDouble(), // Convert to double
        ),
      );
    }

    return performanceData;
  }

  double _calculatePortfolioValue({
    required List<Transaction> transactions,
    required DateTime currentDate,
  }) {
    double value = 0.0;

    for (var tx in transactions) {
      if (tx.date.isAfter(currentDate)) continue;

      final coin = _coins.firstWhere(
        (c) => c.id == tx.coinId,
        orElse: () => Coin(
          id: tx.coinId,
          name: tx.coinName,
          symbol: tx.coinSymbol,
          image: tx.coinImage,
          price: 0,
          change: 0,
          marketCap: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
        ),
      );

      switch (tx.type) {
        case TransactionType.buy:
        case TransactionType.deposit:
          value += tx.amount * (coin.price > 0 ? coin.price : tx.price);
          break;
        case TransactionType.sell:
        case TransactionType.withdrawal:
          value -= tx.amount * (coin.price > 0 ? coin.price : tx.price);
          break;
        case TransactionType.swap:
          // Simplified - treat as neutral
          break;
      }
    }

    return value;
  }

  // Calculate portfolio allocation
  Map<String, double> getPortfolioAllocation(List<Transaction> transactions) {
    final allocation = <String, double>{};

    for (var tx in transactions) {
      if (tx.type == TransactionType.buy ||
          tx.type == TransactionType.deposit) {
        allocation[tx.coinId] = (allocation[tx.coinId] ?? 0) + tx.amount;
      } else if (tx.type == TransactionType.sell ||
          tx.type == TransactionType.withdrawal) {
        allocation[tx.coinId] = (allocation[tx.coinId] ?? 0) - tx.amount;
      }
    }

    return allocation;
  }

  // Calculate total return
  double getTotalReturn(List<PerformanceDataPoint> performance) {
    if (performance.isEmpty) return 0.0;
    final first = performance.first;
    final last = performance.last;
    return last.totalValue - first.totalInvested;
  }

  // Calculate return percentage
  double getReturnPercentage(List<PerformanceDataPoint> performance) {
    if (performance.isEmpty) return 0.0;
    final first = performance.first;
    final last = performance.last;
    if (first.totalInvested == 0) return 0.0;
    return ((last.totalValue - first.totalInvested) / first.totalInvested) *
        100;
  }

  // Get best performing day
  PerformanceDataPoint? getBestDay(List<PerformanceDataPoint> performance) {
    if (performance.length < 2) return null;
    double maxGain = 0.0;
    PerformanceDataPoint? bestDay;

    for (int i = 1; i < performance.length; i++) {
      final gain = performance[i].profitLoss - performance[i - 1].profitLoss;
      if (gain > maxGain) {
        maxGain = gain;
        bestDay = performance[i];
      }
    }

    return bestDay;
  }

  // Get worst performing day
  PerformanceDataPoint? getWorstDay(List<PerformanceDataPoint> performance) {
    if (performance.length < 2) return null;
    double maxLoss = 0.0;
    PerformanceDataPoint? worstDay;

    for (int i = 1; i < performance.length; i++) {
      final loss = performance[i].profitLoss - performance[i - 1].profitLoss;
      if (loss < maxLoss) {
        maxLoss = loss;
        worstDay = performance[i];
      }
    }

    return worstDay;
  }
}
