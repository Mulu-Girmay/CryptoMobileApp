import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final String name;
  final String image;
  final double currentPrice;

  final VoidCallback? onTap;

  const ReusableCard({
    super.key,
    required this.name,
    required this.image,
    required this.currentPrice,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 190;

            if (compact) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: Image.network(
                        image,
                        width: 50,
                        height: 50,

                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.image, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    width: 36,
                    height: 36,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, size: 44),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$${currentPrice.toStringAsFixed(2)}',
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
  final String name;
  final String image;
  final double currentPrice;
  final String symbol;
  final double change;
  final VoidCallback? onTap;

  const OnClickReusableCard({
    super.key,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.symbol,
    required this.change,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
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
            // 🔥 Coin Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                width: 90,
                height: 90,
                errorBuilder: (c, e, s) => const Icon(Icons.image, size: 90),
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 Name
            Text(
              name,
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

            // 🔥 Symbol
            Text(
              symbol.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Price
            Text(
              '\$${currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 Change badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Action Button (optional but PRO)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
