import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../Logic/calc.dart';

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

  @override
  void initState() {
    super.initState();
    _coinsFuture = fetchCoins('usd');
    _coinsFuture.then((coins) {
      if (!mounted) return;
      setState(() {
        _coins = coins;
      });
      _performConversion();
    });
    _amountController.addListener(_performConversion);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _performConversion() {
    if (fromCoin == null || toCoin == null || _amountController.text.isEmpty) {
      setState(() => _convertedAmount = '0');
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      final fromPrice = _coins
          .firstWhere((coin) => coin.name == fromCoin)
          .price;
      final toPrice = _coins.firstWhere((coin) => coin.name == toCoin).price;
      final converted = Convert(amount, fromPrice, toPrice);
      setState(() {
        _convertedAmount = converted.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() => _convertedAmount = '0');
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
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Converter'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Coin>>(
        future: _coinsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No coins available',
                style: TextStyle(color: Colors.white),
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
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: const Icon(Icons.swap_vert, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildOutputCard(coins),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Converted Amount",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _convertedAmount,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22C55E),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardStyle(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Amount",
                hintStyle: TextStyle(color: Colors.white38),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardStyle(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _convertedAmount,
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
    return DropdownButton<String>(
      value: value,
      dropdownColor: const Color(0xFF0B1220),
      hint: const Text("Select", style: TextStyle(color: Colors.white54)),
      style: const TextStyle(color: Colors.white),
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

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: const Color(0xFF0B1220),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    );
  }
}
