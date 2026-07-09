import 'package:crypto/model/coin.dart';
import 'package:crypto/model/portfolio.dart';
import 'package:crypto/model/transaction.dart';
import 'package:crypto/services/transaction_service.dart';

class PortfolioCalculatorService {
  final TransactionService _transactionService = TransactionService();

  // Calculate portfolio summary with cash balance
  Future<PortfolioSummary> calculatePortfolioSummary({
    required List<PortfolioItem> holdings,
    required List<Coin> coins,
    double initialCash = 0.0,
  }) async {
    await _transactionService.loadTransactions();
    final transactions = _transactionService.getTransactions();

    // Calculate holdings value
    double holdingsValue = 0.0;
    double totalInvested = 0.0;
    double totalProfit = 0.0;

    for (final holding in holdings) {
      final coin = coins.firstWhere(
        (c) => c.id == holding.coinId,
        orElse: () => Coin(
          id: holding.coinId,
          name: holding.coinName,
          symbol: holding.coinSymbol,
          image: holding.coinImage,
          price: 0,
          change: 0,
          marketCap: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
        ),
      );

      final currentValue = holding.calculateCurrentValue(coin.price);
      final purchaseValue = holding.purchaseValue;

      holdingsValue += currentValue;
      totalInvested += purchaseValue;
      totalProfit += (currentValue - purchaseValue);
    }

    // Calculate cash balance from transactions
    double cashBalance = initialCash;

    for (final tx in transactions) {
      switch (tx.type) {
        case TransactionType.buy:
          cashBalance -= tx.fiatValue;
          break;
        case TransactionType.sell:
          cashBalance += tx.fiatValue;
          break;
        case TransactionType.deposit:
        case TransactionType.withdrawal:
        case TransactionType.swap:
          break;
      }
    }

    final totalValue = holdingsValue + cashBalance;
    final totalProfitOverall = holdingsValue + cashBalance - totalInvested;
    final profitPercentage = totalInvested > 0
        ? (totalProfitOverall / totalInvested) * 100
        : 0.0;

    return PortfolioSummary(
      totalValue: totalValue,
      totalInvested: totalInvested,
      totalProfit: totalProfitOverall,
      cashBalance: cashBalance,
      holdingsValue: holdingsValue,
      profitPercentage: profitPercentage,
    );
  }

  // Calculate the effect of a new transaction on the portfolio
  Map<String, dynamic> calculateTransactionEffect({
    required Transaction transaction,
    required List<PortfolioItem> currentHoldings,
    required List<Coin> coins,
    double initialCash = 0.0,
  }) {
    // Create a copy of holdings and apply the transaction
    final newHoldings = List<PortfolioItem>.from(currentHoldings);
    double cashChange = 0.0;

    switch (transaction.type) {
      case TransactionType.buy:
        // Add to holdings, reduce cash
        final existingIndex = newHoldings.indexWhere(
          (h) => h.coinId == transaction.coinId,
        );

        if (existingIndex != -1) {
          // Update existing holding
          final existing = newHoldings[existingIndex];
          final totalAmount = existing.amount + transaction.amount;
          final totalCost = existing.purchaseValue + transaction.fiatValue;
          final avgPrice = totalAmount > 0 ? totalCost / totalAmount : 0.0;

          newHoldings[existingIndex] = PortfolioItem(
            coinId: existing.coinId,
            coinName: existing.coinName,
            coinSymbol: existing.coinSymbol,
            coinImage: existing.coinImage,
            amount: totalAmount,
            purchasePrice: avgPrice.toDouble(), 
            purchaseDate: transaction.date,
          );
        } else {
          // Add new holding
          newHoldings.add(
            PortfolioItem(
              coinId: transaction.coinId,
              coinName: transaction.coinName,
              coinSymbol: transaction.coinSymbol,
              coinImage: transaction.coinImage,
              amount: transaction.amount,
              purchasePrice: transaction.price,
              purchaseDate: transaction.date,
            ),
          );
        }
        cashChange = -transaction.fiatValue;
        break;

      case TransactionType.sell:
        // Remove from holdings, increase cash
        final existingIndex = newHoldings.indexWhere(
          (h) => h.coinId == transaction.coinId,
        );

        if (existingIndex != -1) {
          final existing = newHoldings[existingIndex];
          final newAmount = existing.amount - transaction.amount;

          if (newAmount <= 0) {
            newHoldings.removeAt(existingIndex);
          } else {
            // Keep the same average price
            newHoldings[existingIndex] = PortfolioItem(
              coinId: existing.coinId,
              coinName: existing.coinName,
              coinSymbol: existing.coinSymbol,
              coinImage: existing.coinImage,
              amount: newAmount,
              purchasePrice: existing.purchasePrice,
              purchaseDate: existing.purchaseDate,
            );
          }
        }
        cashChange = transaction.fiatValue;
        break;

      case TransactionType.deposit:
        // Add to holdings, no cash change
        final existingIndex = newHoldings.indexWhere(
          (h) => h.coinId == transaction.coinId,
        );

        if (existingIndex != -1) {
          final existing = newHoldings[existingIndex];
          final totalAmount = existing.amount + transaction.amount;
          final totalCost = existing.purchaseValue + transaction.fiatValue;
          final avgPrice = totalAmount > 0 ? totalCost / totalAmount : 0.0;

          newHoldings[existingIndex] = PortfolioItem(
            coinId: existing.coinId,
            coinName: existing.coinName,
            coinSymbol: existing.coinSymbol,
            coinImage: existing.coinImage,
            amount: totalAmount,
            purchasePrice: avgPrice.toDouble(),
            purchaseDate: transaction.date,
          );
        } else {
          newHoldings.add(
            PortfolioItem(
              coinId: transaction.coinId,
              coinName: transaction.coinName,
              coinSymbol: transaction.coinSymbol,
              coinImage: transaction.coinImage,
              amount: transaction.amount,
              purchasePrice: transaction.price,
              purchaseDate: transaction.date,
            ),
          );
        }
        break;

      case TransactionType.withdrawal:
        // Remove from holdings, no cash change
        final existingIndex = newHoldings.indexWhere(
          (h) => h.coinId == transaction.coinId,
        );

        if (existingIndex != -1) {
          final existing = newHoldings[existingIndex];
          final newAmount = existing.amount - transaction.amount;

          if (newAmount <= 0) {
            newHoldings.removeAt(existingIndex);
          } else {
            newHoldings[existingIndex] = PortfolioItem(
              coinId: existing.coinId,
              coinName: existing.coinName,
              coinSymbol: existing.coinSymbol,
              coinImage: existing.coinImage,
              amount: newAmount,
              purchasePrice: existing.purchasePrice,
              purchaseDate: existing.purchaseDate,
            );
          }
        }
        break;

      case TransactionType.swap:
        // For swap, remove from one coin and add to another
        final fromCoinIndex = newHoldings.indexWhere(
          (h) => h.coinId == transaction.coinId,
        );

        // Remove from source coin
        if (fromCoinIndex != -1) {
          final existing = newHoldings[fromCoinIndex];
          final newAmount = existing.amount - transaction.amount;

          if (newAmount <= 0) {
            newHoldings.removeAt(fromCoinIndex);
          } else {
            newHoldings[fromCoinIndex] = PortfolioItem(
              coinId: existing.coinId,
              coinName: existing.coinName,
              coinSymbol: existing.coinSymbol,
              coinImage: existing.coinImage,
              amount: newAmount,
              purchasePrice: existing.purchasePrice,
              purchaseDate: existing.purchaseDate,
            );
          }
        }

        // Add to destination coin (if specified)
        if (transaction.toCoin != null) {
          final destCoin = coins.firstWhere(
            (c) => c.symbol.toLowerCase() == transaction.toCoin?.toLowerCase(),
            orElse: () => Coin(
              id: '',
              name: transaction.toCoin ?? '',
              symbol: transaction.toCoin ?? '',
              image: '',
              price: 0,
              change: 0,
              marketCap: 0,
              totalVolume: 0,
              high24h: 0,
              low24h: 0,
            ),
          );

          newHoldings.add(
            PortfolioItem(
              coinId: destCoin.id.isNotEmpty ? destCoin.id : 'unknown',
              coinName: destCoin.name.isNotEmpty
                  ? destCoin.name
                  : (transaction.toCoin ?? 'Unknown'),
              coinSymbol: destCoin.symbol.isNotEmpty
                  ? destCoin.symbol
                  : (transaction.toCoin ?? 'UNKNOWN'),
              coinImage: destCoin.image,
              amount: transaction.amount, 
              purchasePrice: transaction.price,
              purchaseDate: transaction.date,
            ),
          );
        }
        break;
    }

    return {'holdings': newHoldings, 'cashChange': cashChange};
  }

  // Get total cash balance
  Future<double> getCashBalance({
    required List<Transaction> transactions,
    double initialCash = 0.0,
  }) async {
    double cashBalance = initialCash;

    for (final tx in transactions) {
      switch (tx.type) {
        case TransactionType.buy:
          cashBalance -= tx.fiatValue;
          break;
        case TransactionType.sell:
          cashBalance += tx.fiatValue;
          break;
        case TransactionType.deposit:
        case TransactionType.withdrawal:
        case TransactionType.swap:
          break;
      }
    }

    return cashBalance;
  }
}
