import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/reusable_card.dart';

class CryptoList extends StatelessWidget {
  final int columns;

  const CryptoList({super.key, this.columns = 2});

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

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemCount: coins.length,
          itemBuilder: (context, index) {
            final coin = coins[index];

            return ReusableCard(
              name: coin.name,
              image: coin.image,
              currentPrice: coin.price,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(coin.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OnClickReusableCard(
                          name: coin.name,
                          image: coin.image,
                          currentPrice: coin.price,
                          symbol: coin.symbol,
                          change: coin.change,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
