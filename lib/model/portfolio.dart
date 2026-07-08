import 'package:flutter/material.dart';

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

  // Calculate current value based on current price
  double calculateCurrentValue(double currentPrice) {
    return currentPrice * amount;
  }

  // Calculate profit/loss
  double calculateProfit(double currentPrice) {
    final currentValue = calculateCurrentValue(currentPrice);
    final purchaseValue = purchasePrice * amount;
    return currentValue - purchaseValue;
  }

  // Calculate profit/loss percentage
  double calculateProfitPercentage(double currentPrice) {
    final purchaseValue = purchasePrice * amount;
    if (purchaseValue == 0) return 0.0;
    final profit = calculateProfit(currentPrice);
    return (profit / purchaseValue) * 100;
  }

  // Calculate total purchase value
  double get purchaseValue {
    return purchasePrice * amount;
  }

  // Calculate return on investment (ROI)
  double calculateROI(double currentPrice) {
    final purchaseValue = purchasePrice * amount;
    if (purchaseValue == 0) return 0.0;
    final currentValue = calculateCurrentValue(currentPrice);
    return ((currentValue - purchaseValue) / purchaseValue) * 100;
  }

  // Check if position is profitable
  bool isProfitable(double currentPrice) {
    return calculateProfit(currentPrice) > 0;
  }

  // Get profit/loss color
  Color getProfitLossColor(double currentPrice) {
    return isProfitable(currentPrice) ? Colors.green : Colors.red;
  }

  // Format profit/loss as string with sign
  String formatProfit(double currentPrice) {
    final profit = calculateProfit(currentPrice);
    return '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)}';
  }

  // Format profit/loss percentage as string with sign
  String formatProfitPercentage(double currentPrice) {
    final percentage = calculateProfitPercentage(currentPrice);
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
  }
}
