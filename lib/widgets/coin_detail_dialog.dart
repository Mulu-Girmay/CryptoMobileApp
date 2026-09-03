import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../screens/chart_screen.dart';
import '../utils/formatter.dart';
import 'price_chart.dart';

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
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          child: PriceChart(
            coinId: coin.id,
            coinName: coin.name,
            coinSymbol: coin.symbol,
            currentPrice: coin.price,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildInfoRow(context, 'Market Cap', Formatter.formatLargeNumber(coin.marketCap)),
              const SizedBox(height: 2),
              _buildInfoRow(context, '24h Volume', Formatter.formatLargeNumber(coin.totalVolume)),
              const SizedBox(height: 2),
              _buildInfoRow(context, '24h High', Formatter.formatPrice(coin.high24h)),
              const SizedBox(height: 2),
              _buildInfoRow(context, '24h Low', Formatter.formatPrice(coin.low24h)),
            ],
          ),
        ),
        const SizedBox(height: 6),
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
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 28),
                ),
                icon: const Icon(Icons.show_chart, size: 14),
                label: const Text('Full Chart', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
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
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 28),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        if (onFavoriteToggle != null)
          Center(
            child: TextButton.icon(
              onPressed: onFavoriteToggle,
              icon: Icon(
                coin.isFavorite ? Icons.star : Icons.star_border,
                color: coin.isFavorite ? Colors.amber : theme.textTheme.bodySmall?.color,
                size: 12,
              ),
              label: Text(
                coin.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: TextStyle(
                  color: coin.isFavorite ? Colors.amber : theme.textTheme.bodySmall?.color,
                  fontSize: 10,
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 9)),
        Text(
          value,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
