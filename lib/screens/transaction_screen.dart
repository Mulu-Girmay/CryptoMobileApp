import 'package:flutter/material.dart';
import '../model/transaction.dart';
import '../model/coin.dart';
import '../services/transaction_service.dart';
import '../utils/formatter.dart';
import '../services//portofolio_calculator_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TransactionService _transactionService = TransactionService();
  final PortfolioCalculatorService _calculator = PortfolioCalculatorService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  TransactionType? _selectedType;
  String _searchQuery = '';
  double _totalValue = 0.0;
  double _totalSpent = 0.0;
  double _totalReceived = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _transactionService.loadTransactions();
    setState(() {
      _transactions = _transactionService.getTransactions();
      _isLoading = false;
      _calculateStats();
    });
  }

  void _calculateStats() {
    _totalValue = _transactionService.getTotalValue();
    _totalSpent = _transactions
        .where((t) => t.type == TransactionType.buy)
        .fold(0.0, (sum, t) => sum + t.fiatValue);
    _totalReceived = _transactions
        .where((t) => t.type == TransactionType.sell)
        .fold(0.0, (sum, t) => sum + t.fiatValue);
  }

  List<Transaction> get _filteredTransactions {
    var filtered = _transactions;

    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.coinName.toLowerCase().contains(query) ||
                t.coinSymbol.toLowerCase().contains(query),
          )
          .toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Map<DateTime, List<Transaction>> get _groupedTransactions {
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in _filteredTransactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    return grouped;
  }

  Future<void> _addTransaction() async {
    final result = await showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        onTransactionCreated: (transaction) {
          _addTransactionToPortfolio(transaction);
        },
      ),
    );

    if (result != null) {
      await _transactionService.addTransaction(result);
      setState(() {
        _transactions = _transactionService.getTransactions();
        _calculateStats();
      });

      // Show success message with transaction effect
      _showTransactionSuccess(result);
    }
  }

  Future<void> _addTransactionToPortfolio(Transaction transaction) async {
    // This will be handled by the portfolio screen's refresh
    // The portfolio screen will recalculate everything
  }

  void _showTransactionSuccess(Transaction transaction) {
    final isPositive =
        transaction.type == TransactionType.buy ||
        transaction.type == TransactionType.deposit;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isPositive ? '✅' : '📤'} ${transaction.type.displayName} Successful',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${transaction.amount.toStringAsFixed(4)} ${transaction.coinSymbol.toUpperCase()} @ ${Formatter.formatPrice(transaction.price)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: isPositive ? const Color(0xFF22C55E) : Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _deleteTransaction(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text(
          'Delete Transaction',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this transaction? This will also update your portfolio balance.',
          style: TextStyle(color: Colors.white70),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _transactionService.deleteTransaction(id);
      setState(() {
        _transactions = _transactionService.getTransactions();
        _calculateStats();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // Summary Stats
          _buildSummaryStats(),

          // Search and Filters
          _buildSearchAndFilters(),

          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF22C55E)),
                  )
                : _transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _groupedTransactions.keys.length,
                    itemBuilder: (context, index) {
                      final date = _groupedTransactions.keys.toList()[index];
                      final transactions = _groupedTransactions[date]!;
                      return _buildDateGroup(date, transactions);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final profitLoss = _totalReceived - _totalSpent;

    return Container(
      margin: const EdgeInsets.all(16),
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
            'Transactions',
            _transactions.length.toString(),
            Icons.receipt,
          ),
          _buildStatItem(
            'Total Spent',
            Formatter.formatPrice(_totalSpent),
            Icons.trending_down,
            color: Colors.red,
          ),
          _buildStatItem(
            'Total Received',
            Formatter.formatPrice(_totalReceived),
            Icons.trending_up,
            color: Colors.green,
          ),
          _buildStatItem(
            'Net P&L',
            Formatter.formatPrice(profitLoss),
            Icons.attach_money,
            color: profitLoss >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: Colors.white38),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Type Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                ...TransactionType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(type, type.displayName),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TransactionType? type, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: const Color(0xFF0B1220),
      selectedColor: const Color(0xFF22C55E).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF22C55E) : Colors.white54,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF22C55E)
            : Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first transaction to track your crypto journey',
            style: TextStyle(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<Transaction> transactions) {
    final isToday =
        DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;

    final isYesterday =
        DateTime.now().subtract(const Duration(days: 1)).day == date.day &&
        DateTime.now().subtract(const Duration(days: 1)).month == date.month &&
        DateTime.now().subtract(const Duration(days: 1)).year == date.year;

    String label;
    if (isToday) {
      label = 'Today';
    } else if (isYesterday) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ...transactions.map(
          (transaction) => _buildTransactionCard(transaction),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isPositive =
        transaction.type == TransactionType.buy ||
        transaction.type == TransactionType.deposit;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteTransaction(transaction.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction.type.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.type.icon,
                color: transaction.type.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.coinName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: transaction.type.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.type.displayName,
                          style: TextStyle(
                            color: transaction.type.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (transaction.type == TransactionType.swap)
                    Text(
                      '${transaction.amount.toStringAsFixed(4)} ${transaction.coinSymbol.toUpperCase()} → ${transaction.toCoin ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      '${transaction.amount.toStringAsFixed(4)} ${transaction.coinSymbol.toUpperCase()} @ ${Formatter.formatPrice(transaction.price)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  if (transaction.note != null)
                    Text(
                      transaction.note!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatter.formatPrice(transaction.fiatValue),
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTime(transaction.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Add Transaction Sheet
class AddTransactionSheet extends StatefulWidget {
  final Function(Transaction) onTransactionCreated;

  const AddTransactionSheet({super.key, required this.onTransactionCreated});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _selectedType = TransactionType.buy;
  Coin? _selectedCoin;
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Coin> _coins = [];
  bool _isLoadingCoins = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    try {
      final coins = await fetchCoins('usd');
      setState(() {
        _coins = coins;
        _isLoadingCoins = false;
      });
    } catch (e) {
      setState(() => _isLoadingCoins = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() => _isSubmitting = true);

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        coinId: _selectedCoin!.id,
        coinName: _selectedCoin!.name,
        coinSymbol: _selectedCoin!.symbol,
        coinImage: _selectedCoin!.image,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        price: double.parse(_priceController.text),
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        fee: null,
      );

      widget.onTransactionCreated(transaction);
      Navigator.pop(context, transaction);

      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF020617),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type
                    const Text(
                      'Transaction Type',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TransactionType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return FilterChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedType = type);
                          },
                          backgroundColor: const Color(0xFF0B1220),
                          selectedColor: const Color(
                            0xFF22C55E,
                          ).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : Colors.white54,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : Colors.white.withOpacity(0.1),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Coin Selection
                    const Text(
                      'Select Coin',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingCoins
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF22C55E),
                            ),
                          )
                        : DropdownButtonFormField<Coin>(
                            value: _selectedCoin,
                            dropdownColor: const Color(0xFF0B1220),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0B1220),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                            hint: const Text(
                              'Select a coin',
                              style: TextStyle(color: Colors.white38),
                            ),
                            items: _coins.map((coin) {
                              return DropdownMenuItem(
                                value: coin,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        coin.image,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (c, e, s) =>
                                            const Icon(Icons.image, size: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(coin.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCoin = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a coin';
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 16),
                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF0B1220),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF22C55E)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Price per coin',
                        labelStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF0B1220),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF22C55E)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Date & Time',
                        style: TextStyle(color: Colors.white54),
                      ),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF22C55E),
                                    surface: Color(0xFF0B1220),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _selectedDate,
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF22C55E),
                                      surface: Color(0xFF0B1220),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                _selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Note
                    TextFormField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        labelStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF0B1220),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF22C55E)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white54,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Add Transaction',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
