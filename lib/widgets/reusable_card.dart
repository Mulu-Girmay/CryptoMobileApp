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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.black.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // coin image
              Center(
                child: Image.network(
                  image,
                  width: 64,
                  height: 64,
                  errorBuilder: (c, e, s) => const Icon(Icons.image, size: 64),
                ),
              ),

              const SizedBox(height: 10),

              // name
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              // price
              Text(
                '\$${currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
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
  final double change; // add change %
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

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.black.withValues(alpha: 0.78),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                  image,
                  width: 84,
                  height: 84,
                  errorBuilder: (c, e, s) => const Icon(Icons.image, size: 84),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                symbol.toUpperCase(),
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
