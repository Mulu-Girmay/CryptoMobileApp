import 'dart:convert';
import 'package:http/http.dart' as http;

class Coin {
  final String name;
  final String symbol;
  final String image;
  final double price;
  final double change;

  Coin({
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.change,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      name: json['name'],
      symbol: json['symbol'],
      image: json['image'],
      price: (json['current_price'] as num).toDouble(),
      change: (json['price_change_percentage_24h'] as num).toDouble(),
    );
  }
}

Future<List<Coin>> fetchCoins(String currency) async {
  final response = await http.get(
    Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=20&page=1&sparkline=false',
    ),
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((e) => Coin.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load coins');
  }
}
