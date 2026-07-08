import 'package:flutter/material.dart';

enum AlertCondition { above, below }

class PriceAlert {
  final String id;
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String coinImage;
  final double targetPrice;
  final AlertCondition condition;
  final bool isActive;
  final DateTime createdAt;
  DateTime? lastTriggeredAt;

  PriceAlert({
    required this.id,
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.targetPrice,
    required this.condition,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'coinImage': coinImage,
      'targetPrice': targetPrice,
      'condition': condition.index,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
    };
  }

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'],
      coinId: json['coinId'],
      coinName: json['coinName'],
      coinSymbol: json['coinSymbol'],
      coinImage: json['coinImage'],
      targetPrice: (json['targetPrice'] as num).toDouble(),
      condition: AlertCondition.values[json['condition']],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggeredAt: json['lastTriggeredAt'] != null
          ? DateTime.parse(json['lastTriggeredAt'])
          : null,
    );
  }

  bool shouldTrigger(double currentPrice) {
    if (!isActive) return false;

    switch (condition) {
      case AlertCondition.above:
        return currentPrice >= targetPrice;
      case AlertCondition.below:
        return currentPrice <= targetPrice;
    }
  }

  // Getter for condition text
  String get conditionText {
    switch (condition) {
      case AlertCondition.above:
        return 'above';
      case AlertCondition.below:
        return 'below';
    }
  }

  // Getter for condition display text (with capitalization)
  String get conditionDisplayText {
    switch (condition) {
      case AlertCondition.above:
        return 'Above';
      case AlertCondition.below:
        return 'Below';
    }
  }

  // Getter for condition icon
  IconData get conditionIcon {
    switch (condition) {
      case AlertCondition.above:
        return Icons.arrow_upward;
      case AlertCondition.below:
        return Icons.arrow_downward;
    }
  }

  // Getter for condition color
  Color get conditionColor {
    switch (condition) {
      case AlertCondition.above:
        return Colors.green;
      case AlertCondition.below:
        return Colors.red;
    }
  }
}
