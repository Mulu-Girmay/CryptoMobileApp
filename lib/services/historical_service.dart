import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/historical_data.dart';
import 'dart:math';

enum Timeframe { hour1, hour24, day7, day30, day90, year1 }

extension TimeframeExtension on Timeframe {
  String get apiValue {
    switch (this) {
      case Timeframe.hour1:
        return '1h';
      case Timeframe.hour24:
        return '24h';
      case Timeframe.day7:
        return '7d';
      case Timeframe.day30:
        return '30d';
      case Timeframe.day90:
        return '90d';
      case Timeframe.year1:
        return '1y';
    }
  }

  String get displayName {
    switch (this) {
      case Timeframe.hour1:
        return '1H';
      case Timeframe.hour24:
        return '24H';
      case Timeframe.day7:
        return '7D';
      case Timeframe.day30:
        return '30D';
      case Timeframe.day90:
        return '90D';
      case Timeframe.year1:
        return '1Y';
    }
  }

  int get days {
    switch (this) {
      case Timeframe.hour1:
        return 1;
      case Timeframe.hour24:
        return 1;
      case Timeframe.day7:
        return 7;
      case Timeframe.day30:
        return 30;
      case Timeframe.day90:
        return 90;
      case Timeframe.year1:
        return 365;
    }
  }

  int get dataPoints {
    switch (this) {
      case Timeframe.hour1:
        return 60; // 60 minutes
      case Timeframe.hour24:
        return 24; // 24 hours
      case Timeframe.day7:
        return 7; // 7 days
      case Timeframe.day30:
        return 30; // 30 days
      case Timeframe.day90:
        return 90; // 90 days
      case Timeframe.year1:
        return 365; // 365 days
    }
  }
}

class HistoricalService {
  static Future<HistoricalData> fetchHistoricalData({
    required String coinId,
    required Timeframe timeframe,
    String currency = 'usd',
  }) async {
    try {
      final days = timeframe.days;
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=$currency&days=$days',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] as List;

        // Get coin info for name and symbol
        final coinInfo = await _fetchCoinInfo(coinId);

        final historicalDataPoints = prices.map((point) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(
            point[0].toInt(),
          );
          final price = (point[1] as num).toDouble();
          return HistoricalDataPoint(timestamp: timestamp, price: price);
        }).toList();

        return HistoricalData(
          coinId: coinId,
          coinName: coinInfo['name'] ?? coinId,
          coinSymbol: coinInfo['symbol']?.toUpperCase() ?? coinId.toUpperCase(),
          data: historicalDataPoints,
          timeframe: timeframe.displayName,
        );
      } else {
        throw Exception(
          'Failed to load historical data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching historical data: $e');
    }
  }

  static Future<Map<String, dynamic>> _fetchCoinInfo(String coinId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/$coinId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'name': data['name'] ?? coinId,
          'symbol': data['symbol'] ?? coinId,
        };
      }
    } catch (e) {
      print('Error fetching coin info: $e');
    }
    return {'name': coinId, 'symbol': coinId};
  }

  static HistoricalData generateMockData({
    required String coinId,
    required String coinName,
    required String coinSymbol,
    required Timeframe timeframe,
    double basePrice = 50000,
    double volatility = 0.02,
  }) {
    final dataPoints = timeframe.dataPoints;
    final now = DateTime.now();
    final points = <HistoricalDataPoint>[];
    final random = Random();
    double price = basePrice;
    for (int i = dataPoints - 1; i >= 0; i--) {
      final timestamp = now.subtract(
        Duration(hours: timeframe == Timeframe.hour1 ? i : i * 24),
      );
      final change = (1 + (volatility * (0.5 - random.nextDouble())));
      price *= change;

      points.add(HistoricalDataPoint(timestamp: timestamp, price: price));
    }

    return HistoricalData(
      coinId: coinId,
      coinName: coinName,
      coinSymbol: coinSymbol,
      data: points,
      timeframe: timeframe.displayName,
    );
  }

  static double random() {
    return DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
  }
}
