import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../utils/formatter.dart';
import 'price_chart.dart';
import '../screens/chart_screen.dart';

class ReusableCard extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ReusableCard({
    super.key,
    required this.coin,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.change >= 0;
    final formattedPrice = Formatter.formatPrice(coin.price);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: coin.isFavorite
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 190;

            if (compact) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          coin.image,
                          width: 40,
                          height: 40,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (coin.isFavorite)
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                    ],
                  ),
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      Formatter.formatChange(coin.change),
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formattedPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(coin.image, width: 32, height: 32),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (coin.isFavorite)
                  const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnClickReusableCard extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onFavoriteToggle;

  const OnClickReusableCard({
    super.key,
    required this.coin,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.change >= 0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Image.network(coin.image, width: 50, height: 50),
                const SizedBox(height: 12),
                Text(
                  coin.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  Formatter.formatPrice(coin.price),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Small Chart
          SizedBox(
            height: 180,
            child: PriceChart(
              coinId: coin.id,
              coinName: coin.name,
              coinSymbol: coin.symbol,
              currentPrice: coin.price,
            ),
          ),
          const SizedBox(height: 12),
          // Info Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildRow(
                  'Market Cap',
                  Formatter.formatLargeNumber(coin.marketCap),
                ),
                _buildRow('24h High', Formatter.formatPrice(coin.high24h)),
                _buildRow('24h Low', Formatter.formatPrice(coin.low24h)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChartScreen(coin: coin)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
