import "package:flutter/material.dart";

class PortfolioItem {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String coinImage;
  final double amount;
  final double purchasePrice;
  final DateTime purchaseDate;

  PortfolioItem({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.amount,
    required this.purchasePrice,
    required this.purchaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'coinImage': coinImage,
      'amount': amount,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'] ?? '',
      coinName: json['coinName'] ?? '',
      coinSymbol: json['coinSymbol'] ?? '',
      coinImage: json['coinImage'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(
        json['purchaseDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  double calculateCurrentValue(double currentPrice) {
    return currentPrice * amount;
  }

  double calculateProfit(double currentPrice) {
    final currentValue = calculateCurrentValue(currentPrice);
    final purchaseValue = purchasePrice * amount;
    return currentValue - purchaseValue;
  }

  double calculateProfitPercentage(double currentPrice) {
    final purchaseValue = purchasePrice * amount;
    if (purchaseValue == 0) return 0.0;
    final profit = calculateProfit(currentPrice);
    return (profit / purchaseValue) * 100;
  }

  double get purchaseValue {
    return purchasePrice * amount;
  }

  bool isProfitable(double currentPrice) {
    return calculateProfit(currentPrice) > 0;
  }

  Color getProfitLossColor(double currentPrice) {
    return isProfitable(currentPrice) ? Colors.green : Colors.red;
  }

  String formatProfit(double currentPrice) {
    final profit = calculateProfit(currentPrice);
    return '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)}';
  }

  String formatProfitPercentage(double currentPrice) {
    final percentage = calculateProfitPercentage(currentPrice);
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
  }
}

// New: Portfolio Summary with Cash Balance
class PortfolioSummary {
  final double totalValue; // Total value of all holdings + cash
  final double totalInvested; // Total amount invested (purchase value)
  final double totalProfit; // Total profit/loss
  final double cashBalance; // Available cash/fiat balance
  final double holdingsValue; // Value of crypto holdings
  final double profitPercentage; // Profit percentage

  PortfolioSummary({
    required this.totalValue,
    required this.totalInvested,
    required this.totalProfit,
    required this.cashBalance,
    required this.holdingsValue,
    required this.profitPercentage,
  });

  bool get isProfitable => totalProfit >= 0;
}
