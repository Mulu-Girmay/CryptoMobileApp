import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../model/portfolio.dart';
import '../services/portfolio_storage.dart';
import '../services/transaction_storage.dart';
import '../services/portfolio_performance_service.dart';
import '../utils/formatter.dart';
import '../widgets/performance_chart.dart';
import '../services/portofolio_calculator_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<PortfolioItem> _portfolioItems = [];
  List<Coin> _coins = [];
  bool _isLoading = true;
  double _totalValue = 0.0;
  double _totalProfit = 0.0;
  double _cashBalance = 0.0;
  double _holdingsValue = 0.0;
  double _totalInvested = 0.0;
  List<PerformanceDataPoint> _performanceData = [];
  bool _isLoadingPerformance = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);

    try {
      final items = await PortfolioStorage.loadPortfolio();
      final coins = await fetchCoins('usd');

      setState(() {
        _portfolioItems = items;
        _coins = coins;
        _isLoading = false;
      });

      await _calculatePortfolioSummary();

      if (_portfolioItems.isNotEmpty && _coins.isNotEmpty) {
        await _loadPerformanceData();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load portfolio: $e');
    }
  }

  Future<void> _calculatePortfolioSummary() async {
    try {
      final transactions = await TransactionStorage.loadTransactions();
      final calculator = PortfolioCalculatorService();

      // Calculate cash balance
      _cashBalance = await calculator.getCashBalance(
        transactions: transactions,
        initialCash: 0.0,
      );

      // Calculate holdings value and profit
      double holdingsValue = 0.0;
      double totalProfit = 0.0;
      double totalInvested = 0.0;

      for (final item in _portfolioItems) {
        final coin = _coins.firstWhere(
          (c) => c.id == item.coinId,
          orElse: () => Coin(
            id: item.coinId,
            name: item.coinName,
            symbol: item.coinSymbol,
            image: item.coinImage,
            price: 0,
            change: 0,
            marketCap: 0,
            totalVolume: 0,
            high24h: 0,
            low24h: 0,
          ),
        );

        final currentValue = item.calculateCurrentValue(coin.price);
        holdingsValue += currentValue;
        totalProfit += item.calculateProfit(coin.price);
        totalInvested += item.purchaseValue;
      }

      setState(() {
        _holdingsValue = holdingsValue;
        _totalProfit = totalProfit;
        _totalInvested = totalInvested;
        _totalValue = holdingsValue + _cashBalance;
      });
    } catch (e) {
      print('Error calculating portfolio summary: $e');
    }
  }

  Future<void> _loadPerformanceData() async {
    if (_portfolioItems.isEmpty || _coins.isEmpty) return;

    setState(() => _isLoadingPerformance = true);

    try {
      final service = PortfolioPerformanceService();
      final transactions = await TransactionStorage.loadTransactions();
      final performance = await service.calculatePerformance(
        transactions: transactions,
        coins: _coins,
      );

      setState(() {
        _performanceData = performance;
        _isLoadingPerformance = false;
      });
    } catch (e) {
      print('Error loading performance: $e');
      setState(() => _isLoadingPerformance = false);
    }
  }

  Future<void> _addToPortfolio(Coin coin) async {
    final amountController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                coin.image,
                width: 30,
                height: 30,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image, size: 30, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Text(coin.name, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount of coins',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF22C55E)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Purchase price per coin',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF22C55E)),
                ),
                hintText: '\$${coin.price.toStringAsFixed(2)}',
                hintStyle: const TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final price = double.tryParse(priceController.text) ?? coin.price;

              if (amount == null || amount <= 0) {
                _showError('Please enter a valid amount');
                return;
              }

              Navigator.pop(context, true);

              final newItem = PortfolioItem(
                coinId: coin.id,
                coinName: coin.name,
                coinSymbol: coin.symbol,
                coinImage: coin.image,
                amount: amount,
                purchasePrice: price,
                purchaseDate: DateTime.now(),
              );

              setState(() {
                _portfolioItems.add(newItem);
              });
              _savePortfolio();
              _calculatePortfolioSummary();
              _loadPerformanceData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromPortfolio(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text(
          'Remove from Portfolio',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove ${_portfolioItems[index].coinName} from your portfolio?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _portfolioItems.removeAt(index);
      });
      _savePortfolio();
      _calculatePortfolioSummary();
      _loadPerformanceData();
    }
  }

  Future<void> _savePortfolio() async {
    await PortfolioStorage.savePortfolio(_portfolioItems);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showAddCoinDialog() async {
    if (_coins.isEmpty) {
      await _loadPortfolio();
      if (_coins.isEmpty) {
        _showError('Failed to load coins. Please try again.');
        return;
      }
    }

    final selectedCoin = await showDialog<Coin>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text('Select Coin', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _coins.length,
            itemBuilder: (context, index) {
              final coin = _coins[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coin.image,
                    width: 30,
                    height: 30,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                ),
                title: Text(
                  coin.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  Formatter.formatPrice(coin.price),
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => Navigator.pop(context, coin),
                tileColor: Colors.transparent,
                hoverColor: Colors.white.withOpacity(0.05),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );

    if (selectedCoin != null) {
      final existing = _portfolioItems.firstWhere(
        (item) => item.coinId == selectedCoin.id,
        orElse: () => PortfolioItem(
          coinId: '',
          coinName: '',
          coinSymbol: '',
          coinImage: '',
          amount: 0,
          purchasePrice: 0,
          purchaseDate: DateTime.now(),
        ),
      );

      if (existing.coinId.isNotEmpty) {
        _showError('${selectedCoin.name} is already in your portfolio');
        return;
      }

      await _addToPortfolio(selectedCoin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadPortfolio,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Portfolio Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        // Total Value
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Value',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              Formatter.formatPrice(_totalValue),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Holdings and Cash breakdown
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Holdings',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatter.formatPrice(_holdingsValue),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Cash Balance',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatter.formatPrice(_cashBalance),
                                    style: TextStyle(
                                      color: _cashBalance >= 0
                                          ? Colors.white
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Total P&L
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total P&L',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              Formatter.formatPrice(_totalProfit),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _totalProfit >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Assets count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Assets',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_portfolioItems.length} coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Performance Chart
                  if (_isLoadingPerformance)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    )
                  else
                    PerformanceChart(
                      performanceData: _performanceData,
                      totalInvested: _totalInvested,
                      currentValue: _totalValue,
                    ),

                  const SizedBox(height: 16),

                  // Add Coin Button
                  ElevatedButton.icon(
                    onPressed: _showAddCoinDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Coin to Portfolio',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Portfolio List
                  _portfolioItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 80,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No coins in portfolio',
                                style: TextStyle(color: Colors.white54),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first coin!',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _portfolioItems.length,
                          itemBuilder: (context, index) {
                            final item = _portfolioItems[index];
                            final coin = _coins.firstWhere(
                              (c) => c.id == item.coinId,
                              orElse: () => Coin(
                                id: item.coinId,
                                name: item.coinName,
                                symbol: item.coinSymbol,
                                image: item.coinImage,
                                price: 0,
                                change: 0,
                                marketCap: 0,
                                totalVolume: 0,
                                high24h: 0,
                                low24h: 0,
                              ),
                            );

                            final currentValue = item.calculateCurrentValue(
                              coin.price,
                            );
                            final profit = item.calculateProfit(coin.price);
                            final profitPercentage = item
                                .calculateProfitPercentage(coin.price);

                            return _buildPortfolioCard(
                              item: item,
                              coin: coin,
                              currentValue: currentValue,
                              profit: profit,
                              profitPercentage: profitPercentage,
                              index: index,
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildPortfolioCard({
    required PortfolioItem item,
    required Coin coin,
    required double currentValue,
    required double profit,
    required double profitPercentage,
    required int index,
  }) {
    final isPositive = profit >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.coinImage,
              width: 40,
              height: 40,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.coinName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.amount.toStringAsFixed(4),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatter.formatPrice(coin.price),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatter.formatPrice(currentValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${profitPercentage >= 0 ? '+' : ''}${profitPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeFromPortfolio(index),
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
