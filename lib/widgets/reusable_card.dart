import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../utils/formatter.dart';

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
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(10),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          coin.image,
                          width: 50,
                          height: 50,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (coin.isFavorite)
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coin.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatter.formatChange(coin.change),
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      coin.isFavorite ? Icons.star : Icons.star_border,
                      color: coin.isFavorite ? Colors.amber : Colors.white54,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        coin.image,
                        width: 36,
                        height: 36,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image,
                          size: 44,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (coin.isFavorite)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coin.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onFavoriteToggle,
                            icon: Icon(
                              coin.isFavorite ? Icons.star : Icons.star_border,
                              color: coin.isFavorite
                                  ? Colors.amber
                                  : Colors.white54,
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isPositive ? Colors.green : Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              Formatter.formatChange(coin.change),
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedPrice,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  coin.image,
                  width: 80,
                  height: 80,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              if (onFavoriteToggle != null)
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    coin.isFavorite ? Icons.star : Icons.star_border,
                    color: coin.isFavorite ? Colors.amber : Colors.white54,
                    size: 30,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            coin.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            coin.symbol.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            Formatter.formatPrice(coin.price),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              Formatter.formatChange(coin.change),
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Market Cap',
            Formatter.formatLargeNumber(coin.marketCap),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            '24h Volume',
            Formatter.formatLargeNumber(coin.totalVolume),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('24h High', Formatter.formatPrice(coin.high24h)),
          const SizedBox(height: 8),
          _buildInfoRow('24h Low', Formatter.formatPrice(coin.low24h)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
