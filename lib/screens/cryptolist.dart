import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/reusable_card.dart';
import '../utils/formatter.dart';

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
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF22C55E)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 12),
                Text(
                  'Error: ${snapshot.error.toString()}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Refresh
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final coins = snapshot.data!;
        final query = searchQuery.trim().toLowerCase();
        final filteredCoins = query.isEmpty
            ? coins
            : coins
                  .where(
                    (coin) =>
                        coin.name.toLowerCase().contains(query) ||
                        coin.symbol.toLowerCase().contains(query),
                  )
                  .toList();

        if (filteredCoins.isEmpty) {
          return const Center(
            child: Text(
              'No coins found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // You can implement refresh logic here
          },
          color: const Color(0xFF22C55E),
          child: GridView.builder(
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
                coin: coin,
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
                        backgroundColor: const Color(0xFF0B1220),
                        title: Text(
                          coin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        content: SizedBox(
                          width: maxDialogWidth,
                          child: SingleChildScrollView(
                            child: OnClickReusableCard(coin: coin),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Color(0xFF22C55E)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
