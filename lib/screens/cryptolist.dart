import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/reusable_card.dart';

class CryptoList extends StatelessWidget {
  final int columns;
  final String searchQuery;

  const CryptoList({super.key, this.columns = 2, this.searchQuery = ''});

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
        final query = searchQuery.trim().toLowerCase();
        final filteredCoins = query.isEmpty
            ? coins
            : coins
                  .where((coin) => coin.name.toLowerCase().contains(query))
                  .toList();

        if (filteredCoins.isEmpty) {
          return const Center(
            child: Text(
              'No coins found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: filteredCoins.length,
          itemBuilder: (context, index) {
            final coin = filteredCoins[index];

            return ReusableCard(
              name: coin.name,
              image: coin.image,
              currentPrice: coin.price,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final media = MediaQuery.sizeOf(context);
                    final maxDialogWidth = media.width - 48;

                    return AlertDialog(
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      title: Text(
                        coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      content: SizedBox(
                        width: maxDialogWidth,
                        child: SingleChildScrollView(
                          child: OnClickReusableCard(
                            name: coin.name,
                            image: coin.image,
                            currentPrice: coin.price,
                            symbol: coin.symbol,
                            change: coin.change,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
