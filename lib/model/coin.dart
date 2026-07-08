import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../services/connection_service.dart';
import '../services/favorites_storage.dart';
import '../utils/error_handler.dart';
import '../utils/retry_helper.dart';

class Coin {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double price;
  final double change;
  final double marketCap;
  final double totalVolume;
  final double high24h;
  final double low24h;
  bool isFavorite;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.change,
    required this.marketCap,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    this.isFavorite = false,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? '???',
      image: json['image'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Coin copyWithFavorite(bool favorite) {
    return Coin(
      id: id,
      name: name,
      symbol: symbol,
      image: image,
      price: price,
      change: change,
      marketCap: marketCap,
      totalVolume: totalVolume,
      high24h: high24h,
      low24h: low24h,
      isFavorite: favorite,
    );
  }
}

class CoinFetchResult {
  final List<Coin> coins;
  final AppError? error;
  final bool isFromCache;

  CoinFetchResult({required this.coins, this.error, this.isFromCache = false});
}

Future<CoinFetchResult> fetchCoinsWithErrorHandling(String currency) async {
  try {
    // Check connection first
    final connectionService = ConnectionService();
    final isConnected = await connectionService.checkConnection();

    if (!isConnected) {
      return CoinFetchResult(
        coins: [],
        error: AppError(
          message: 'No internet connection',
          details: 'Please connect to the internet and try again',
          type: ErrorType.network,
          isRetryable: true,
        ),
      );
    }

    // Use retry helper
    final data = await RetryHelper.retry(
      () => _fetchCoins(currency),
      maxRetries: 3,
      delay: const Duration(seconds: 2),
      timeout: const Duration(seconds: 30),
      shouldRetry: (e) {
        // Don't retry on certain errors
        if (e is http.ClientException) return true;
        if (e.toString().contains('429')) return true;
        if (e.toString().contains('500')) return true;
        return false;
      },
    );

    return CoinFetchResult(coins: data);
  } on SocketException catch (e) {
    return CoinFetchResult(coins: [], error: AppError.fromException(e));
  } on TimeoutException catch (e) {
    return CoinFetchResult(coins: [], error: AppError.fromException(e));
  } catch (e) {
    return CoinFetchResult(coins: [], error: AppError.fromException(e));
  }
}

Future<List<Coin>> _fetchCoins(String currency) async {
  final response = await http.get(
    Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=20&page=1&sparkline=false',
    ),
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    final coins = data.map((e) => Coin.fromJson(e)).toList();

    // Load favorites from storage
    final favorites = await FavoritesStorage.loadFavorites();
    for (var coin in coins) {
      if (favorites.contains(coin.id)) {
        coin.isFavorite = true;
      }
    }

    return coins;
  } else if (response.statusCode == 429) {
    throw Exception('429: Rate limit exceeded');
  } else if (response.statusCode >= 500) {
    throw Exception('${response.statusCode}: Server error');
  } else {
    throw Exception('Failed to load coins: ${response.statusCode}');
  }
}

// Keep existing fetchCoins for backward compatibility
Future<List<Coin>> fetchCoins(String currency) async {
  final result = await fetchCoinsWithErrorHandling(currency);
  if (result.error != null) {
    throw result.error!;
  }
  return result.coins;
}
