import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/reusable_card.dart';

class CryptoList extends StatelessWidget {
  const CryptoList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Coin>>(
      future: fetchCoins("usd"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        }

        final coins = snapshot.data!;

        return ListView.builder(
          itemCount: coins.length,
          itemBuilder: (context, index) {
            final coin = coins[index];

            return ReusableCard(
              name: coin.name,
              image: coin.image,
              currentPrice: coin.price,
              symbol: coin.symbol,
              change: coin.change,
            );
          },
        );
      },
    );
  }
}
