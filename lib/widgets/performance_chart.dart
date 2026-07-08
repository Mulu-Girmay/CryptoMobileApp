import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/portfolio_performance_service.dart';
import '../utils/formatter.dart';

class PerformanceChart extends StatefulWidget {
  final List<PerformanceDataPoint> performanceData;
  final double totalInvested;
  final double currentValue;

  const PerformanceChart({
    super.key,
    required this.performanceData,
    required this.totalInvested,
    required this.currentValue,
  });

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  bool _showValue = true;

  @override
  Widget build(BuildContext context) {
    if (widget.performanceData.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 50, color: Colors.white24),
              SizedBox(height: 12),
              Text(
                'No performance data yet',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 4),
              Text(
                'Add transactions to see your performance',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final isPositive = widget.currentValue >= widget.totalInvested;
    final totalReturn = widget.currentValue - widget.totalInvested;
    final returnPercentage = widget.totalInvested > 0
        ? (totalReturn / widget.totalInvested) * 100
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
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
              _buildStatItem(
                'Total Value',
                Formatter.formatPrice(widget.currentValue),
                Colors.white,
              ),
              _buildStatItem(
                'Total Invested',
                Formatter.formatPrice(widget.totalInvested),
                Colors.white70,
              ),
              _buildStatItem(
                'Total Return',
                Formatter.formatPrice(totalReturn),
                isPositive ? Colors.green : Colors.red,
                subtitle:
                    '${isPositive ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Chart
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              // Chart toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Portfolio Performance',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Row(
                    children: [
                      _buildToggleButton('Value', !_showValue),
                      const SizedBox(width: 4),
                      _buildToggleButton('P&L', _showValue),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildLineChart()),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Performance summary
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
              _buildSummaryItem('Best Day', _getBestDay(), Colors.green),
              _buildSummaryItem('Worst Day', _getWorstDay(), Colors.red),
              _buildSummaryItem(
                'Total Days',
                '${widget.performanceData.length}',
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
          ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showValue = !isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF22C55E).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF22C55E) : Colors.white54,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final data = widget.performanceData;
    final minValue = _showValue
        ? data.map((d) => d.totalValue).reduce((a, b) => a < b ? a : b) * 0.95
        : data.map((d) => d.profitLoss).reduce((a, b) => a < b ? a : b) * 1.1;

    final maxValue = _showValue
        ? data.map((d) => d.totalValue).reduce((a, b) => a > b ? a : b) * 1.05
        : data.map((d) => d.profitLoss).reduce((a, b) => a > b ? a : b) * 1.1;

    final spots = data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final value = _showValue ? point.totalValue : point.profitLoss;
      return FlSpot(index.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white12, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final point = data[index];
                  final step = (data.length / 6).ceil();
                  if (index % step == 0 || index == data.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${point.date.day}/${point.date.month}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final price = value;
                return Text(
                  _showValue
                      ? '\$${price.toStringAsFixed(0)}'
                      : '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: minValue,
        maxY: maxValue,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _showValue
                ? (widget.currentValue >= widget.totalInvested
                      ? Colors.green
                      : Colors.red)
                : (widget.currentValue >= widget.totalInvested
                      ? Colors.green
                      : Colors.red),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color:
                  (_showValue
                          ? (widget.currentValue >= widget.totalInvested
                                ? Colors.green
                                : Colors.red)
                          : (widget.currentValue >= widget.totalInvested
                                ? Colors.green
                                : Colors.red))
                      .withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final point = data[index];
                final value = _showValue ? point.totalValue : point.profitLoss;
                return LineTooltipItem(
                  _showValue
                      ? 'Value: \$${value.toStringAsFixed(0)}\n${_formatDate(point.date)}'
                      : 'P&L: \$${value.toStringAsFixed(0)}\n${_formatDate(point.date)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
            tooltipBgColor: const Color(0xFF0B1220),
            tooltipBorder: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: TextStyle(
            color: value != null ? color : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getBestDay() {
    if (widget.performanceData.length < 2) return 'N/A';
    double maxGain = 0.0;
    String bestDay = 'N/A';

    for (int i = 1; i < widget.performanceData.length; i++) {
      final gain =
          widget.performanceData[i].profitLoss -
          widget.performanceData[i - 1].profitLoss;
      if (gain > maxGain) {
        maxGain = gain;
        bestDay =
            '${_formatDate(widget.performanceData[i].date)}\n+\$${gain.toStringAsFixed(2)}';
      }
    }

    return bestDay;
  }

  String _getWorstDay() {
    if (widget.performanceData.length < 2) return 'N/A';
    double maxLoss = 0.0;
    String worstDay = 'N/A';

    for (int i = 1; i < widget.performanceData.length; i++) {
      final loss =
          widget.performanceData[i].profitLoss -
          widget.performanceData[i - 1].profitLoss;
      if (loss < maxLoss) {
        maxLoss = loss;
        worstDay =
            '${_formatDate(widget.performanceData[i].date)}\n${loss.toStringAsFixed(2)}';
      }
    }

    return worstDay;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
