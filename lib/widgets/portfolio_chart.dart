import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/portfolio.dart';
import '../model/coin.dart';
import '../utils/formatter.dart';

class PortfolioChart extends StatelessWidget {
  final List<PortfolioItem> portfolioItems;
  final List<Coin> coins;

  const PortfolioChart({
    super.key,
    required this.portfolioItems,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = portfolioItems.fold<double>(0, (sum, item) {
      final coin = coins.firstWhere(
        (c) => c.id == item.coinId,
        orElse: () => Coin(
          id: '',
          name: '',
          symbol: '',
          image: '',
          price: 0,
          change: 0,
          marketCap: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
        ),
      );
      return sum + (coin.price * item.amount);
    });

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Distribution',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                Formatter.formatPrice(totalValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildPieChart()),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Prepare data for pie chart with proper null safety
    final List<_ChartData> chartData = [];

    for (final item in portfolioItems) {
      final coin = coins.firstWhere(
        (c) => c.id == item.coinId,
        orElse: () => Coin(
          id: '',
          name: '',
          symbol: '',
          image: '',
          price: 0,
          change: 0,
          marketCap: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
        ),
      );

      final value = coin.price * item.amount;
      if (value > 0) {
        chartData.add(
          _ChartData(
            label: item.coinSymbol.toUpperCase(),
            value: value,
            color: _getColor(item.coinId),
          ),
        );
      }
    }

    if (chartData.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.white38)),
      );
    }

    final total = chartData.fold<double>(0, (sum, data) => sum + data.value);

    return PieChart(
      PieChartData(
        sections: chartData.map((data) {
          final percentage = data.value / total;
          return PieChartSectionData(
            color: data.color,
            value: percentage,
            title: '${(percentage * 100).toStringAsFixed(1)}%',
            radius: 40,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 20,
        startDegreeOffset: -90,
      ),
    );
  }

  Color _getColor(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
    ];
    final hash = id.hashCode.abs();
    return colors[hash % colors.length];
  }
}

// Helper class for chart data
class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData({required this.label, required this.value, required this.color});
}
