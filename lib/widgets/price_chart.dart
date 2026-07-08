import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/historical_data.dart';
import '../services/historical_service.dart';
import '../utils/formatter.dart';

class PriceChart extends StatefulWidget {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final double currentPrice;

  const PriceChart({
    super.key,
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.currentPrice,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  Timeframe _selectedTimeframe = Timeframe.day7;
  HistoricalData? _historicalData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showMockData = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await HistoricalService.fetchHistoricalData(
        coinId: widget.coinId,
        timeframe: _selectedTimeframe,
      );

      setState(() {
        _historicalData = data;
        _isLoading = false;
        _showMockData = false;
      });
    } catch (e) {
      // If API fails, use mock data
      print('API Error: $e, using mock data');

      final mockData = HistoricalService.generateMockData(
        coinId: widget.coinId,
        coinName: widget.coinName,
        coinSymbol: widget.coinSymbol,
        timeframe: _selectedTimeframe,
        basePrice: widget.currentPrice,
      );

      setState(() {
        _historicalData = mockData;
        _isLoading = false;
        _showMockData = true;
        _errorMessage = 'Using simulated data (API limit reached)';
      });
    }
  }

  void _changeTimeframe(Timeframe timeframe) {
    if (_selectedTimeframe == timeframe) return;
    setState(() {
      _selectedTimeframe = timeframe;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeframeSelector(),

        const SizedBox(height: 16),

        // Chart
        if (_isLoading)
          const Center(
            child: SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              ),
            ),
          )
        else if (_historicalData != null)
          _buildChart(context)
        else
          Center(
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _errorMessage.isEmpty ? 'No data available' : _errorMessage,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Stats
        if (_historicalData != null && !_isLoading) _buildStats(context),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = [
      Timeframe.hour24,
      Timeframe.day7,
      Timeframe.day30,
      Timeframe.day90,
      Timeframe.year1,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: timeframes.map((timeframe) {
          final isSelected = _selectedTimeframe == timeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeTimeframe(timeframe),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF22C55E).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF22C55E))
                      : null,
                ),
                child: Center(
                  child: Text(
                    timeframe.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF22C55E)
                          : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final data = _historicalData!;
    final isPositive = data.priceChange >= 0;

    // Prepare chart data
    final spots = data.data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      return FlSpot(index.toDouble(), point.price);
    }).toList();

    // Calculate min and max for Y axis with some padding
    final minPrice = data.lowestPrice * 0.99;
    final maxPrice = data.highestPrice * 1.01;
    final priceRange = maxPrice - minPrice;

    // Determine interval for Y axis labels
    double interval;
    if (priceRange > 1000) {
      interval = 500;
    } else if (priceRange > 100) {
      interval = 50;
    } else if (priceRange > 10) {
      interval = 5;
    } else if (priceRange > 1) {
      interval = 0.5;
    } else {
      interval = 0.1;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.coinSymbol.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${data.priceChangePercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (_showMockData)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SIM',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  Formatter.formatPrice(data.lastPrice),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
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
                        if (index >= 0 && index < data.data.length) {
                          final point = data.data[index];
                          // Show every nth label based on data length
                          final step = (data.data.length / 6).ceil();
                          if (index % step == 0 ||
                              index == data.data.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${point.timestamp.day}/${point.timestamp.month}',
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final price = value;
                        return Text(
                          '\$${price.toStringAsFixed(price > 100 ? 0 : 2)}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.right,
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
                maxX: data.data.length.toDouble() - 1,
                minY: minPrice,
                maxY: maxPrice,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: isPositive ? Colors.green : Colors.red,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isPositive ? Colors.green : Colors.red)
                          .withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final price = spot.y;
                        final index = spot.x.toInt();
                        final point = data.data[index];
                        return LineTooltipItem(
                          '\$${price.toStringAsFixed(2)}\n${_formatTimestamp(point.timestamp)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                    tooltipBgColor: const Color(0xFF0B1220),
                    tooltipBorder: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final data = _historicalData!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Highest', Formatter.formatPrice(data.highestPrice)),
          _buildStatItem('Lowest', Formatter.formatPrice(data.lowestPrice)),
          _buildStatItem('Average', Formatter.formatPrice(data.averagePrice)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Extension for HistoricalData
extension HistoricalDataExtension on HistoricalData {
  double get lastPrice {
    if (data.isEmpty) return 0;
    return data.last.price;
  }
}
