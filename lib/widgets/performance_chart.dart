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
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;
    final subtleText = theme.textTheme.bodySmall?.color;

    if (widget.performanceData.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 50, color: subtleText?.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('No performance data yet', style: TextStyle(color: subtleText)),
              const SizedBox(height: 4),
              Text(
                'Add transactions to see your performance',
                style: TextStyle(color: subtleText?.withOpacity(0.6), fontSize: 12),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _buildStatItem(
                context,
                'Total Value',
                Formatter.formatPrice(widget.currentValue),
                theme.textTheme.bodyLarge?.color ?? Colors.white,
              ),
              _buildStatItem(
                context,
                'Invested',
                Formatter.formatPrice(widget.totalInvested),
                subtleText ?? Colors.grey,
              ),
              _buildStatItem(
                context,
                'Return',
                Formatter.formatPrice(totalReturn),
                isPositive ? Colors.green : Colors.red,
                subtitle: '${isPositive ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio Performance',
                    style: TextStyle(color: subtleText, fontSize: 12),
                  ),
                  Row(
                    children: [
                      _buildToggleButton(context, 'Value', !_showValue),
                      const SizedBox(width: 4),
                      _buildToggleButton(context, 'P&L', _showValue),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildLineChart(cardColor, borderColor)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _buildSummaryItem(context, 'Best Day', _getBestDay(), Colors.green),
              _buildSummaryItem(context, 'Worst Day', _getWorstDay(), Colors.red),
              _buildSummaryItem(
                context,
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

  Widget _buildStatItem(BuildContext context, String label, String value, Color color, {String? subtitle}) {
    final subtleText = Theme.of(context).textTheme.bodySmall?.color;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: subtleText, fontSize: 10)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (subtitle != null)
            Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String label, bool isSelected) {
    final subtleText = Theme.of(context).textTheme.bodySmall?.color;
    return GestureDetector(
      onTap: () => setState(() => _showValue = !isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF22C55E).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : (subtleText?.withOpacity(0.3) ?? Colors.grey),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF22C55E) : subtleText,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(Color? cardColor, Color borderColor) {
    final data = widget.performanceData;
    final minValue = _showValue
        ? data.map((d) => d.totalValue).reduce((a, b) => a < b ? a : b) * 0.95
        : data.map((d) => d.profitLoss).reduce((a, b) => a < b ? a : b) * 1.1;
    final maxValue = _showValue
        ? data.map((d) => d.totalValue).reduce((a, b) => a > b ? a : b) * 1.05
        : data.map((d) => d.profitLoss).reduce((a, b) => a > b ? a : b) * 1.1;

    final spots = data.asMap().entries.map((entry) {
      final value = _showValue ? entry.value.totalValue : entry.value.profitLoss;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    final lineColor = widget.currentValue >= widget.totalInvested ? Colors.green : Colors.red;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white12, strokeWidth: 1),
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
                  final step = (data.length / 6).ceil();
                  if (index % step == 0 || index == data.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${data[index].date.day}/${data[index].date.month}',
                        style: const TextStyle(color: Colors.white38, fontSize: 9),
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
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.1)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final point = data[index];
                final value = _showValue ? point.totalValue : point.profitLoss;
                return LineTooltipItem(
                  '${_showValue ? 'Value' : 'P&L'}: \$${value.toStringAsFixed(0)}\n${_formatDate(point.date)}',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
            tooltipBgColor: cardColor ?? Colors.black,
            tooltipBorder: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String? value, Color color) {
    final subtleText = Theme.of(context).textTheme.bodySmall?.color;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: subtleText, fontSize: 10)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: value != null ? color : subtleText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBestDay() {
    if (widget.performanceData.length < 2) return 'N/A';
    double maxGain = 0.0;
    String bestDay = 'N/A';
    for (int i = 1; i < widget.performanceData.length; i++) {
      final gain = widget.performanceData[i].profitLoss - widget.performanceData[i - 1].profitLoss;
      if (gain > maxGain) {
        maxGain = gain;
        bestDay = '${_formatDate(widget.performanceData[i].date)}\n+\$${gain.toStringAsFixed(2)}';
      }
    }
    return bestDay;
  }

  String _getWorstDay() {
    if (widget.performanceData.length < 2) return 'N/A';
    double maxLoss = 0.0;
    String worstDay = 'N/A';
    for (int i = 1; i < widget.performanceData.length; i++) {
      final loss = widget.performanceData[i].profitLoss - widget.performanceData[i - 1].profitLoss;
      if (loss < maxLoss) {
        maxLoss = loss;
        worstDay = '${_formatDate(widget.performanceData[i].date)}\n${loss.toStringAsFixed(2)}';
      }
    }
    return worstDay;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
