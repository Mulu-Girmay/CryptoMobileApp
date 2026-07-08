import 'package:flutter/material.dart';

enum TransactionType { buy, sell, swap, deposit, withdrawal }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.swap:
        return 'Swap';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.buy:
        return Icons.trending_up;
      case TransactionType.sell:
        return Icons.trending_down;
      case TransactionType.swap:
        return Icons.swap_horiz;
      case TransactionType.deposit:
        return Icons.call_received;
      case TransactionType.withdrawal:
        return Icons.call_made;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.buy:
        return Colors.green;
      case TransactionType.sell:
        return Colors.red;
      case TransactionType.swap:
        return Colors.blue;
      case TransactionType.deposit:
        return Colors.purple;
      case TransactionType.withdrawal:
        return Colors.orange;
    }
  }
}

class Transaction {
  final String id;
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String coinImage;
  final TransactionType type;
  final double amount;
  final double price;
  final DateTime date;
  final String? note;
  final String? fromCoin; // For swaps
  final String? toCoin; // For swaps
  final double? fee;

  Transaction({
    required this.id,
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.type,
    required this.amount,
    required this.price,
    required this.date,
    this.note,
    this.fromCoin,
    this.toCoin,
    this.fee,
  });

  // Calculate total value in fiat
  double get fiatValue => amount * price;

  // Calculate value after fee
  double get fiatValueWithFee => fiatValue - (fee ?? 0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'coinImage': coinImage,
      'type': type.index,
      'amount': amount,
      'price': price,
      'date': date.toIso8601String(),
      'note': note,
      'fromCoin': fromCoin,
      'toCoin': toCoin,
      'fee': fee,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      coinId: json['coinId'],
      coinName: json['coinName'],
      coinSymbol: json['coinSymbol'],
      coinImage: json['coinImage'],
      type: TransactionType.values[json['type']],
      amount: (json['amount'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
      fromCoin: json['fromCoin'],
      toCoin: json['toCoin'],
      fee: (json['fee'] as num?)?.toDouble(),
    );
  }
}
