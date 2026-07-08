import 'dart:convert';
import 'package:crypto/utils/formatter.dart';
import 'package:http/http.dart' as http;
import '../services/favorites_storage.dart';

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
  bool isFavorite; // Made mutable

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
  String getFormattedPrice() {
    return Formatter.formatPrice(price);
  }

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

  // Create a copy with updated favorite status
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

Future<List<Coin>> fetchCoins(String currency) async {
  try {
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

      // Mark favorites
      for (var coin in coins) {
        if (favorites.contains(coin.id)) {
          coin.isFavorite = true;
        }
      }

      return coins;
    } else {
      throw Exception('Failed to load coins: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: ${e.toString()}');
  }
}
