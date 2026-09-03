import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../Logic/calc.dart';
import '../utils/formatter.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late Future<List<Coin>> _coinsFuture;
  List<Coin> _coins = [];
  String? fromCoin;
  String? toCoin;
  final TextEditingController _amountController = TextEditingController();
  String _convertedAmount = '0';
  bool _isConverting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _coinsFuture = fetchCoins('usd');
    _coinsFuture
        .then((coins) {
          if (!mounted) return;
          setState(() {
            _coins = coins;
          });
          _performConversion();
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            _errorMessage =
                'Failed to load coins. Please check your connection.';
          });
        });
    _amountController.addListener(_performConversion);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _performConversion() async {
    if (fromCoin == null || toCoin == null || _amountController.text.isEmpty) {
      setState(() {
        _convertedAmount = '0';
        _isConverting = false;
      });
      return;
    }

    setState(() => _isConverting = true);

    try {
      final amount = double.parse(_amountController.text);
      final fromPrice = _coins
          .firstWhere((coin) => coin.name == fromCoin)
          .price;
      final toPrice = _coins.firstWhere((coin) => coin.name == toCoin).price;

      await Future.delayed(const Duration(milliseconds: 300));

      final converted = Convert(amount, fromPrice, toPrice);
      setState(() {
        _convertedAmount = Formatter.formatPrice(converted);
        _isConverting = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _convertedAmount = 'Error';
        _isConverting = false;
        _errorMessage = 'Invalid input or coin data';
      });
    }
  }

  void _swapCoins() {
    setState(() {
      final temp = fromCoin;
      fromCoin = toCoin;
      toCoin = temp;
      _performConversion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Converter'),
      ),
      body: FutureBuilder<List<Coin>>(
        future: _coinsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Unable to load coins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check your internet connection\nand try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _coinsFuture = fetchCoins('usd');
                        _errorMessage = '';
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final coins = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  _buildInputCard(coins),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: _swapCoins,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                        ),
                      ),
                      child: Icon(Icons.swap_vert, color: Theme.of(context).iconTheme.color),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildOutputCard(coins),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Converted Amount',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isConverting)
                          const SizedBox(
                            height: 26,
                            width: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF22C55E),
                            ),
                          )
                        else
                          Text(
                            _convertedAmount,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _convertedAmount == 'Error'
                                  ? Colors.red
                                  : const Color(0xFF22C55E),
                            ),
                          ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(List<Coin> coins) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardStyle(context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                border: InputBorder.none,
              ),
            ),
          ),
          _buildDropdown(coins, fromCoin, (v) {
            setState(() {
              fromCoin = v;
              _performConversion();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildOutputCard(List<Coin> coins) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardStyle(context),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _convertedAmount,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 18,
              ),
            ),
          ),
          _buildDropdown(coins, toCoin, (v) {
            setState(() {
              toCoin = v;
              _performConversion();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    List<Coin> coins,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    return DropdownButton<String>(
      value: value,
      dropdownColor: theme.cardTheme.color,
      hint: Text('Select', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      underline: const SizedBox(),
      items: coins
          .map(
            (coin) =>
                DropdownMenuItem(value: coin.name, child: Text(coin.name)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  BoxDecoration _cardStyle(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.dividerTheme.color ?? Colors.transparent,
      ),
    );
  }
}
