class HistoricalDataPoint {
  final DateTime timestamp;
  final double price;

  HistoricalDataPoint({required this.timestamp, required this.price});

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp.toIso8601String(), 'price': price};
  }

  factory HistoricalDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalDataPoint(
      timestamp: DateTime.parse(json['timestamp']),
      price: (json['price'] as num).toDouble(),
    );
  }
}

class HistoricalData {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final List<HistoricalDataPoint> data;
  final String timeframe;

  HistoricalData({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.data,
    required this.timeframe,
  });

  // Calculate price change between first and last data point
  double get priceChange {
    if (data.length < 2) return 0;
    final firstPrice = data.first.price;
    final lastPrice = data.last.price;
    return lastPrice - firstPrice;
  }

  double get priceChangePercentage {
    if (data.length < 2) return 0;
    final firstPrice = data.first.price;
    final lastPrice = data.last.price;
    if (firstPrice == 0) return 0;
    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }

  double get highestPrice {
    if (data.isEmpty) return 0;
    return data.map((d) => d.price).reduce((a, b) => a > b ? a : b);
  }

  double get lowestPrice {
    if (data.isEmpty) return 0;
    return data.map((d) => d.price).reduce((a, b) => a < b ? a : b);
  }

  double get averagePrice {
    if (data.isEmpty) return 0;
    final sum = data.map((d) => d.price).reduce((a, b) => a + b);
    return sum / data.length;
  }
}
