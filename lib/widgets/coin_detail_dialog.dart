import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../screens/chart_screen.dart';
import '../utils/formatter.dart';
import 'price_chart.dart';

// NEW: Simplified version for dialog (without duplicate price header)
class DialogCoinDetail extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onFavoriteToggle;

  const DialogCoinDetail({
    super.key,
    required this.coin,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ⭐ PRICE CHART - Very compact version
        SizedBox(
          height: 140, // Reduced from 180 to 140
          child: PriceChart(
            coinId: coin.id,
            coinName: coin.name,
            coinSymbol: coin.symbol,
            currentPrice: coin.price,
          ),
        ),

        const SizedBox(height: 6), // Reduced from 10
        // Additional Info - More compact
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ), // Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Market Cap',
                Formatter.formatLargeNumber(coin.marketCap),
              ),
              const SizedBox(height: 2), // Reduced from 3
              _buildInfoRow(
                '24h Volume',
                Formatter.formatLargeNumber(coin.totalVolume),
              ),
              const SizedBox(height: 2),
              _buildInfoRow('24h High', Formatter.formatPrice(coin.high24h)),
              const SizedBox(height: 2),
              _buildInfoRow('24h Low', Formatter.formatPrice(coin.low24h)),
            ],
          ),
        ),

        const SizedBox(height: 6), // Reduced from 10
        // Action Buttons - More compact
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChartScreen(coin: coin)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ), // Reduced from 8
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(0, 28), // Reduced from 34
                  textStyle: const TextStyle(
                    fontSize: 11,
                  ), // Added smaller font
                ),
                icon: const Icon(Icons.show_chart, size: 14), // Reduced from 16
                label: const Text('Full Chart', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(width: 6), // Reduced from 8
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to portfolio or show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add to Portfolio feature coming soon!'),
                      backgroundColor: Color(0xFF22C55E),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ), // Reduced from 8
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(0, 28), // Reduced from 34
                  textStyle: const TextStyle(fontSize: 11),
                ),
                icon: const Icon(Icons.add, size: 14), // Reduced from 16
                label: const Text('Add', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2), // Reduced from 4
        // Favorite toggle button
        if (onFavoriteToggle != null)
          Center(
            child: TextButton.icon(
              onPressed: onFavoriteToggle,
              icon: Icon(
                coin.isFavorite ? Icons.star : Icons.star_border,
                color: coin.isFavorite ? Colors.amber : Colors.white54,
                size: 12, // Reduced from 14
              ),
              label: Text(
                coin.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: TextStyle(
                  color: coin.isFavorite ? Colors.amber : Colors.white54,
                  fontSize: 10, // Reduced from 11
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                minimumSize: const Size(0, 22),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9, // Reduced from 10
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9, // Reduced from 10
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
