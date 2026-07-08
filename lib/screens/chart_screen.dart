import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../widgets/price_chart.dart';
import '../utils/formatter.dart';
import "../screens/Converter.dart";

class ChartScreen extends StatefulWidget {
  final Coin coin;

  const ChartScreen({super.key, required this.coin});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    final isPositive = widget.coin.change >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.coin.image,
                width: 30,
                height: 30,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image, size: 30, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.coin.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.coin.symbol.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Current price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatter.formatPrice(widget.coin.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
                  child: Text(
                    Formatter.formatChange(widget.coin.change),
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Price Chart - Takes most of the space
              Expanded(
                child: PriceChart(
                  coinId: widget.coin.id,
                  coinName: widget.coin.name,
                  coinSymbol: widget.coin.symbol,
                  currentPrice: widget.coin.price,
                ),
              ),

              const SizedBox(height: 16),

              // Quick stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1220),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(
                      'Market Cap',
                      Formatter.formatLargeNumber(widget.coin.marketCap),
                    ),
                    _buildQuickStat(
                      '24h Volume',
                      Formatter.formatLargeNumber(widget.coin.totalVolume),
                    ),
                    _buildQuickStat(
                      '24h High',
                      Formatter.formatPrice(widget.coin.high24h),
                    ),
                    _buildQuickStat(
                      '24h Low',
                      Formatter.formatPrice(widget.coin.low24h),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConverterScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1220),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.currency_exchange, size: 18),
                      label: const Text('Convert'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add to portfolio
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Go to Portfolio to add this coin'),
                            backgroundColor: Color(0xFF22C55E),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add to Portfolio'),
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

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
