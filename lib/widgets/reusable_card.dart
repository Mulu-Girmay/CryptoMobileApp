import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final String name;
  final String image;
  final double currentPrice;
  final String symbol;
  final double change; // add change %

  const ReusableCard({
    super.key,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.symbol,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return GestureDetector(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.black.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // coin image
              Image.network(image, width: 40, height: 40),

              const SizedBox(width: 12),

              // name + symbol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      symbol.toUpperCase(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              // price + change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
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
