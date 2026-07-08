import 'package:flutter/material.dart';
import '../model/currency.dart';
import '../services/currency_service.dart';
import '../utils/formatter.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyService _currencyService = CurrencyService();
  late String _selectedCode;
  bool _isLoading = false;
  Map<String, double> _exchangeRates = {};

  @override
  void initState() {
    super.initState();
    _selectedCode = _currencyService.currentCode;
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      final rates = await CurrencyService.getExchangeRates(_selectedCode);
      setState(() {
        _exchangeRates = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectCurrency(Currency currency) async {
    setState(() => _isLoading = true);

    try {
      await _currencyService.setCurrency(currency);
      setState(() {
        _selectedCode = currency.code;
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Currency changed to ${currency.flag} ${currency.name}',
          ),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh exchange rates
      await _loadExchangeRates();

      // Refresh the app (navigate back)
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change currency'),
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
        title: const Text('Select Currency'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF22C55E),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading && _exchangeRates.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            )
          : Column(
              children: [
                // Current selection indicator
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.currency_exchange,
                          color: Color(0xFF22C55E),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Currency',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currencyService.selectedCurrency.flag} ${_currencyService.selectedCurrency.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currencyService.currentSymbol,
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select your preferred currency for all prices',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Currency list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: Currency.supportedCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = Currency.supportedCurrencies[index];
                      final isSelected = _selectedCode == currency.code;
                      final rate = _exchangeRates[currency.code];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF22C55E).withOpacity(0.1)
                              : const Color(0xFF0B1220),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : Colors.white.withOpacity(0.05),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Text(
                            currency.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            currency.name,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF22C55E)
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${currency.code.toUpperCase()} ${rate != null ? '• ${rate.toStringAsFixed(2)} USD' : ''}',
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF22C55E).withOpacity(0.7)
                                  : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                )
                              : Text(
                                  currency.symbol,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          onTap: () => _selectCurrency(currency),
                        ),
                      );
                    },
                  ),
                ),

                // Info footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exchange rates provided by CoinGecko',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
